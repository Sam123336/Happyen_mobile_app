import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:happyn_mobile/core/providers.dart';
import 'package:happyn_mobile/core/theme/app_theme.dart';

/// Mapbox public token, supplied at build time:
/// `--dart-define=MAPBOX_ACCESS_TOKEN=pk...`. Without it there is no map, so
/// the screens fall back to their designed diorama and the app still runs.
const mapboxAccessToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');

bool get hasMapboxToken => mapboxAccessToken.isNotEmpty;

/// How the Standard style is lit. The two city screens are one place at
/// different hours, which is a style config change rather than a second map.
enum MapLight { day, night }

/// A point the map should mark. Deliberately plain: the screens above decide
/// what a pin means, and never see a Mapbox annotation.
@immutable
class MapPin {
  const MapPin({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.isLive = false,
    this.selected = false,
  });

  final String id;
  final bool isLive;
  final double latitude;
  final double longitude;
  final bool selected;

  @override
  bool operator ==(Object other) =>
      other is MapPin &&
      other.id == id &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.isLive == isLive &&
      other.selected == selected;

  @override
  int get hashCode => Object.hash(id, latitude, longitude, isLive, selected);
}

/// The living-city basemap.
///
/// ADR 002 keeps Mapbox types behind an adapter: they stay inside this file,
/// and the screens above pass plain coordinates and stack their own widgets on
/// top. The camera carries the design's own angles — the Stitch diorama is
/// `rotateX(60deg) rotateZ(-30deg)`, which is pitch 60 and bearing -30 here.
class HappynMap extends StatefulWidget {
  const HappynMap({
    required this.centre,
    required this.fallback,
    super.key,
    this.light = MapLight.day,
    this.onPinTapped,
    this.pins = const [],
  });

  final Coordinates centre;

  /// Rendered instead of the map when no access token is configured.
  final Widget fallback;
  final MapLight light;
  final ValueChanged<String>? onPinTapped;
  final List<MapPin> pins;

  @override
  State<HappynMap> createState() => _HappynMapState();
}

class _HappynMapState extends State<HappynMap> {
  static const _pitch = 60.0;
  static const _bearing = -30.0;
  static const _zoom = 15.5;
  static const _eventSourceId = 'happyn-event-worlds';
  static const _eventExtrusionLayerId = 'happyn-event-world-extrusions';
  static const _eventGlowLayerId = 'happyn-event-world-glow';

  MapboxMap? _map;
  GeoJsonSource? _eventWorldSource;
  CircleAnnotationManager? _pinLayer;
  Cancelable? _pinTaps;

  @override
  void initState() {
    super.initState();
    if (hasMapboxToken) MapboxOptions.setAccessToken(mapboxAccessToken);
  }

  @override
  void didUpdateWidget(HappynMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.light != widget.light) _applyLight();
    if (!listEquals(oldWidget.pins, widget.pins)) {
      unawaited(_syncPins());
      unawaited(_syncEventWorlds());
    }
    if (oldWidget.centre != widget.centre) {
      // The first camera is the city centre; the device fix arrives later.
      _map?.flyTo(
        CameraOptions(center: _point(widget.centre)),
        MapAnimationOptions(duration: 1200),
      );
    }
  }

  @override
  void dispose() {
    _pinTaps?.cancel();
    super.dispose();
  }

  /// Circles rather than symbols: a pin needs no image asset, and the glow is
  /// closer to the living-map design than a dropped marker would be. The
  /// native circle remains the touch target; the portable GeoJSON layer below
  /// carries the 3D event world rendered under it.
  Future<void> _syncPins() async {
    final layer = _pinLayer;
    if (layer == null) return;

    await layer.deleteAll();
    if (widget.pins.isEmpty) return;

    await layer.createMulti([
      for (final pin in widget.pins)
        CircleAnnotationOptions(
          circleBlur: 0.4,
          circleColor: (pin.isLive ? AppColors.secondary : AppColors.tertiary)
              .toARGB32(),
          circleOpacity: 0.9,
          circleRadius: pin.selected
              ? 16
              : pin.isLive
              ? 12
              : 9,
          circleStrokeColor: AppColors.onSurface.toARGB32(),
          circleStrokeWidth: pin.selected || pin.isLive ? 2 : 0,
          customData: {'isLive': pin.isLive, 'pinId': pin.id},
          geometry: _point((latitude: pin.latitude, longitude: pin.longitude)),
        ),
    ]);
  }

  Future<void> _createPinLayer(MapboxMap map) async {
    final layer = await map.annotations.createCircleAnnotationManager();
    _pinLayer = layer;
    _pinTaps = layer.tapEvents(
      onTap: (annotation) {
        final id = annotation.customData?['pinId'];
        if (id is String) widget.onPinTapped?.call(id);
      },
    );
    await _syncPins();
  }

  /// Adds a small, extruded footprint beneath every event. It uses only
  /// GeoJSON and style layers, so the event-world data remains portable even
  /// though Mapbox is the current rendering engine. Active occurrences get a
  /// taller coral beacon; scheduled ones are shorter violet landmarks.
  Future<void> _installEventWorldLayers() async {
    final map = _map;
    if (map == null) return;

    final style = map.style;
    if (await style.styleSourceExists(_eventSourceId)) {
      final source = await style.getSource(_eventSourceId);
      _eventWorldSource = source is GeoJsonSource ? source : null;
    } else {
      final source = GeoJsonSource(
        id: _eventSourceId,
        data: _eventWorldsGeoJson(),
      );
      await style.addSource(source);
      _eventWorldSource = source;
    }

    if (!await style.styleLayerExists(_eventExtrusionLayerId)) {
      await style.addLayer(
        FillExtrusionLayer(
          id: _eventExtrusionLayerId,
          sourceId: _eventSourceId,
          fillExtrusionColorExpression: const <Object>[
            'case',
            <Object>['get', 'isLive'],
            '#FF725C',
            '#9B8AFB',
          ],
          fillExtrusionEmissiveStrength: 0.7,
          fillExtrusionHeightExpression: const <Object>['get', 'height'],
          fillExtrusionOpacity: 0.8,
          fillExtrusionVerticalGradient: true,
        ),
      );
    }

    if (!await style.styleLayerExists(_eventGlowLayerId)) {
      await style.addLayer(
        CircleLayer(
          id: _eventGlowLayerId,
          sourceId: _eventSourceId,
          circleBlur: 0.65,
          circleColorExpression: const <Object>[
            'case',
            <Object>['get', 'isLive'],
            '#FF725C',
            '#9B8AFB',
          ],
          circleEmissiveStrength: 1,
          circleOpacity: 0.6,
          circlePitchAlignment: CirclePitchAlignment.MAP,
          circlePitchScale: CirclePitchScale.MAP,
          circleRadiusExpression: const <Object>[
            'case',
            <Object>['get', 'isLive'],
            28,
            18,
          ],
        ),
      );
    }

    await _syncEventWorlds();
  }

  Future<void> _syncEventWorlds() async {
    final source = _eventWorldSource;
    if (source == null) return;
    await source.updateGeoJSON(_eventWorldsGeoJson());
  }

  String _eventWorldsGeoJson() => jsonEncode({
    'type': 'FeatureCollection',
    'features': [
      for (final pin in widget.pins)
        {
          'type': 'Feature',
          'id': pin.id,
          'properties': {
            // Heights are visual metres, deliberately bounded so a dense city
            // remains readable rather than becoming a wall of event towers.
            'height': pin.isLive ? 140 : 68,
            'isLive': pin.isLive,
          },
          'geometry': {
            'type': 'Polygon',
            'coordinates': [_eventFootprint(pin)],
          },
        },
    ],
  });

  /// A six-sided footprint roughly 25–36m wide. GeoJSON uses longitude first.
  List<List<double>> _eventFootprint(MapPin pin) {
    const metresPerLatitudeDegree = 111320.0;
    final metresPerLongitudeDegree =
        metresPerLatitudeDegree * math.cos(pin.latitude * math.pi / 180);
    final radiusMetres = pin.isLive ? 36.0 : 25.0;
    final coordinates = <List<double>>[];

    for (var index = 0; index < 6; index++) {
      final angle = math.pi / 3 * index;
      coordinates.add([
        pin.longitude +
            math.cos(angle) * radiusMetres / metresPerLongitudeDegree,
        pin.latitude + math.sin(angle) * radiusMetres / metresPerLatitudeDegree,
      ]);
    }
    coordinates.add(List<double>.from(coordinates.first));
    return coordinates;
  }

  Point _point(Coordinates centre) =>
      Point(coordinates: Position(centre.longitude, centre.latitude));

  void _applyLight() {
    _map?.style.setStyleImportConfigProperty(
      'basemap',
      'lightPreset',
      widget.light.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!hasMapboxToken) return widget.fallback;

    return MapWidget(
      viewport: CameraViewportState(
        bearing: _bearing,
        center: _point(widget.centre),
        pitch: _pitch,
        zoom: _zoom,
      ),
      onMapCreated: (map) {
        _map = map;
        // The design's "◎ YOU"; the location permission is already declared.
        unawaited(
          map.location.updateSettings(LocationComponentSettings(enabled: true)),
        );
        unawaited(_createPinLayer(map));
      },
      onStyleLoadedListener: (_) {
        _applyLight();
        // A style reload discards app-owned sources/layers, so reinstall them
        // after every completed style load rather than only when the widget is
        // created.
        unawaited(_installEventWorldLayers());
      },
      styleUri: MapboxStyles.STANDARD,
    );
  }
}
