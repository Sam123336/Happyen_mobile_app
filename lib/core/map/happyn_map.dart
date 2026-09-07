import 'dart:async';

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
    this.selected = false,
  });

  final String id;
  final double latitude;
  final double longitude;
  final bool selected;

  @override
  bool operator ==(Object other) =>
      other is MapPin &&
      other.id == id &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.selected == selected;

  @override
  int get hashCode => Object.hash(id, latitude, longitude, selected);
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

  MapboxMap? _map;
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
    if (!listEquals(oldWidget.pins, widget.pins)) unawaited(_syncPins());
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
  /// closer to the living-map design than a dropped marker would be.
  Future<void> _syncPins() async {
    final layer = _pinLayer;
    if (layer == null) return;

    await layer.deleteAll();
    if (widget.pins.isEmpty) return;

    await layer.createMulti([
      for (final pin in widget.pins)
        CircleAnnotationOptions(
          circleBlur: 0.4,
          circleColor: AppColors.secondary.toARGB32(),
          circleOpacity: 0.9,
          circleRadius: pin.selected ? 14 : 9,
          circleStrokeColor: AppColors.onSurface.toARGB32(),
          circleStrokeWidth: pin.selected ? 2 : 0,
          customData: {'pinId': pin.id},
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
      onStyleLoadedListener: (_) => _applyLight(),
      styleUri: MapboxStyles.STANDARD,
    );
  }
}
