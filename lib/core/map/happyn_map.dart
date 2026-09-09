import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:happyn_mobile/core/providers.dart';
import 'package:happyn_mobile/core/theme/app_theme.dart';

/// OpenFreeMap serves vector tiles with no account, no API key and no card on
/// file, which is why the basemap is MapLibre rather than Mapbox. The two
/// styles are the same city at different hours.
const _dayStyle = 'https://tiles.openfreemap.org/styles/liberty';
const _nightStyle = 'https://tiles.openfreemap.org/styles/dark';

/// Required by OpenFreeMap's terms; it is not decoration. The style JSON
/// carries no attribution of its own, so the SDK's attribution button would
/// show nothing — this text is the only thing satisfying the licence.
const mapAttribution = 'OpenFreeMap © OpenMapTiles Data from OpenStreetMap';

/// The licence line for [HappynMap]. Every screen embedding a map MUST stack
/// this **last**, so its own header and controls cannot bury it: the map fills
/// the frame, and anything the map itself drew would sit under that chrome.
class MapAttribution extends StatelessWidget {
  const MapAttribution({super.key, this.bottomInset = 0});

  /// How far the screen's own bottom chrome reaches, so the line clears it.
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.viewPaddingOf(context).bottom + bottomInset + 2,
      right: 8,
      child: Text(
        mapAttribution,
        style: TextStyle(
          color: AppColors.onSurface.withValues(alpha: 0.55),
          fontSize: 9,
          shadows: const [Shadow(blurRadius: 4, color: AppColors.background)],
        ),
      ),
    );
  }
}

/// Widget tests have no platform views, and MapLibre's method channel throws a
/// LateInitializationError on dispose when one was never created. The screens
/// already supply a designed stand-in, so render that instead of a live map.
// ponytail: env sniffing, swap for an injected map factory if the map itself
// ever needs test coverage.
final bool inWidgetTest =
    !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

/// How the city is lit. A style swap rather than a second map.
enum MapLight { day, night }

/// A point the map should mark. Deliberately plain: the screens above decide
/// what a pin means, and never see a MapLibre annotation.
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
/// ADR 002 keeps the map SDK behind an adapter: its types stay inside this
/// file, and the screens above pass plain coordinates and stack their own
/// widgets on top. That is what made the Mapbox-to-MapLibre swap a one-file
/// change. The camera carries the design's own angles — the Stitch diorama is
/// `rotateX(60deg) rotateZ(-30deg)`, which is tilt 60 and bearing -30 here.
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

  /// Shown until the first style finishes loading, so the designed diorama
  /// covers the blank frame instead of a grey rectangle.
  final Widget fallback;
  final MapLight light;
  final ValueChanged<String>? onPinTapped;
  final List<MapPin> pins;

  @override
  State<HappynMap> createState() => _HappynMapState();
}

class _HappynMapState extends State<HappynMap> {
  static const _tilt = 60.0;
  static const _bearing = -30.0;
  static const _zoom = 15.5;
  static const _eventSourceId = 'happyn-event-worlds';
  static const _eventExtrusionLayerId = 'happyn-event-world-extrusions';
  static const _eventGlowLayerId = 'happyn-event-world-glow';

  MapLibreMapController? _map;
  bool _styleLoaded = false;

  String get _styleUri =>
      widget.light == MapLight.day ? _dayStyle : _nightStyle;

  @override
  void didUpdateWidget(HappynMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.light != widget.light) {
      // A style swap discards every app-owned source, layer and annotation;
      // _onStyleLoaded reinstalls them once the new style is in.
      unawaited(_map?.setStyle(_styleUri));
    }
    if (!listEquals(oldWidget.pins, widget.pins)) {
      unawaited(_syncPins());
      unawaited(_syncEventWorlds());
    }
    if (oldWidget.centre != widget.centre) {
      // The first camera is the city centre; the device fix arrives later.
      unawaited(
        _map?.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(widget.centre.latitude, widget.centre.longitude),
          ),
          duration: const Duration(milliseconds: 1200),
        ),
      );
    }
  }

  void _onMapCreated(MapLibreMapController controller) {
    _map = controller;
    controller.onCircleTapped.add(_onCircleTapped);
  }

  void _onCircleTapped(Circle circle) {
    final id = circle.data?['pinId'];
    if (id is String) widget.onPinTapped?.call(id);
  }

  Future<void> _onStyleLoaded() async {
    await _installEventWorldLayers();
    await _syncPins();
    if (mounted && !_styleLoaded) setState(() => _styleLoaded = true);
  }

  /// Circles rather than symbols: a pin needs no image asset, and the glow is
  /// closer to the living-map design than a dropped marker would be. The
  /// native circle remains the touch target; the GeoJSON layers below carry
  /// the 3D event world rendered under it.
  Future<void> _syncPins() async {
    final map = _map;
    if (map == null) return;

    await map.clearCircles();
    if (widget.pins.isEmpty) return;

    await map.addCircles(
      [
        for (final pin in widget.pins)
          CircleOptions(
            circleBlur: 0.4,
            circleColor: _hex(
              pin.isLive ? AppColors.secondary : AppColors.tertiary,
            ),
            circleOpacity: 0.9,
            circleRadius: pin.selected
                ? 16
                : pin.isLive
                ? 12
                : 9,
            circleStrokeColor: _hex(AppColors.onSurface),
            circleStrokeWidth: pin.selected || pin.isLive ? 2 : 0,
            geometry: LatLng(pin.latitude, pin.longitude),
          ),
      ],
      [
        for (final pin in widget.pins)
          <String, dynamic>{'isLive': pin.isLive, 'pinId': pin.id},
      ],
    );
  }

  /// Adds a small, extruded footprint beneath every event. It uses only
  /// GeoJSON and style layers, so the event-world data stays portable across
  /// rendering engines. Active occurrences get a taller coral beacon;
  /// scheduled ones are shorter violet landmarks.
  Future<void> _installEventWorldLayers() async {
    final map = _map;
    if (map == null) return;

    await map.addGeoJsonSource(_eventSourceId, _eventWorldsGeoJson());

    await map.addFillExtrusionLayer(
      _eventSourceId,
      _eventExtrusionLayerId,
      FillExtrusionLayerProperties(
        fillExtrusionColor: <Object>[
          'case',
          <Object>['get', 'isLive'],
          '#FF725C',
          '#9B8AFB',
        ],
        fillExtrusionHeight: <Object>['get', 'height'],
        fillExtrusionOpacity: 0.8,
        fillExtrusionVerticalGradient: true,
      ),
      enableInteraction: false,
    );

    await map.addCircleLayer(
      _eventSourceId,
      _eventGlowLayerId,
      CircleLayerProperties(
        circleBlur: 0.65,
        circleColor: <Object>[
          'case',
          <Object>['get', 'isLive'],
          '#FF725C',
          '#9B8AFB',
        ],
        circleOpacity: 0.6,
        circlePitchAlignment: 'map',
        circlePitchScale: 'map',
        circleRadius: <Object>[
          'case',
          <Object>['get', 'isLive'],
          28,
          18,
        ],
      ),
      enableInteraction: false,
    );
  }

  Future<void> _syncEventWorlds() async {
    await _map?.setGeoJsonSource(_eventSourceId, _eventWorldsGeoJson());
  }

  Map<String, dynamic> _eventWorldsGeoJson() => {
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
  };

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

  /// MapLibre takes paint colours as CSS hex strings, not packed ints.
  String _hex(Color color) =>
      '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';

  @override
  Widget build(BuildContext context) {
    if (inWidgetTest) return widget.fallback;

    return Stack(
      fit: StackFit.expand,
      children: [
        MapLibreMap(
          initialCameraPosition: CameraPosition(
            bearing: _bearing,
            target: LatLng(widget.centre.latitude, widget.centre.longitude),
            tilt: _tilt,
            zoom: _zoom,
          ),
          // The design's "◎ YOU"; the location permission is already declared.
          myLocationEnabled: true,
          onMapCreated: _onMapCreated,
          onStyleLoadedCallback: () => unawaited(_onStyleLoaded()),
          styleString: _styleUri,
        ),
        if (!_styleLoaded) Positioned.fill(child: widget.fallback),
      ],
    );
  }
}
