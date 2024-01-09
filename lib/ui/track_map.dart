import 'package:abg_utils/abg_utils.dart';
import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'strings.dart';
import 'theme.dart';

class TrackMapScreen extends StatefulWidget {
  final Function(String) callback;
  const TrackMapScreen({Key? key, required this.callback}) : super(key: key);
  @override
  _TrackMapScreenState createState() => _TrackMapScreenState();
}

class _TrackMapScreenState extends State<TrackMapScreen> {

  double windowWidth = 0;
  double windowHeight = 0;
  GoogleMapController? _controller;
  double _currentZoom = 14;
  CameraPosition _kGooglePlex = CameraPosition(target: LatLng(28.63210763207775, 77.11422465741634), zoom: 14,);
  String? _mapStyle;

  @override
  void initState() {
    _kGooglePlex = CameraPosition(target: LatLng(
        localSettings.mapLat != 0 ? localSettings.mapLat: 48.846575206328446,
        localSettings.mapLng != 0 ? localSettings.mapLng: 2.302420789679285),
      zoom: localSettings.mapZoom,); // paris coordinates by default
    _initIcons();
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
    _add();
    super.initState();
  }

  @override
  void dispose() {
    if (_controller != null)
      _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Directionality(
        textDirection: strings.direction,
        child: Stack(
          children: <Widget>[

            _map(),

            Align(
              alignment: Alignment.centerRight,
              child: Container(
                  margin: EdgeInsets.only(right: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      buttonPlus(_onMapPlus),
                      buttonMinus(_onMapMinus),
                      _buttonMyLocation(_getCurrentLocation),
                    ],
                  )
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top+30),
              alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                    color: (theme.darkMode) ? Colors.black : Colors.white,
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _item("New request", first: true, select: true),
                            _item("Accept", select: true),
                            _item("Ready"),
                            _item("Finish", last: true),
                          ],
                        )
                    ))),

            appbar1(Colors.transparent,
                (theme.darkMode) ? Colors.white : Colors.black, strings.get(142), /// "Booking tracking",
                context, () {widget.callback("orders");}, style: theme.style14W800)
          ],
        )
    ));
  }

  _item(String text, {bool first = false, bool last = false, bool select = false}){
    return Container(
      width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Expanded(child: Container(height: 2, color: !first ? Colors.grey : Colors.transparent,),),
              if (select)
                Icon(Icons.verified, color: theme.mainColor,),
              if (!select)
                Icon(Icons.camera, color: Colors.grey, size: 15,),
              Expanded(child: Container(height: 2, color: !last ? Colors.grey : Colors.transparent,),)
            ],),
            SizedBox(height: 10,),
            if (select)
              FittedBox(child: Text(text, style: theme.style11W400MainColor, maxLines: 1,)),
            if (!select)
              FittedBox(child: Text(text, style: theme.style10W600Grey, maxLines: 1,))
          ],
        )
    );
  }

  _onMapPlus(){
    _controller?.animateCamera(
      CameraUpdate.zoomIn(),
    );
  }

  _onMapMinus(){
    _controller?.animateCamera(
      CameraUpdate.zoomOut(),
    );
  }

  _map(){
    return GoogleMap(
        mapType: MapType.normal,
        zoomGesturesEnabled: true,
        zoomControlsEnabled: false, // Whether to show zoom controls (only applicable for Android).
        myLocationEnabled: true,  // For showing your current location on the map with a blue dot.
        myLocationButtonEnabled: false, // This button is used to bring the user location to the center of the camera view.
        initialCameraPosition: _kGooglePlex,
        markers: Set<Marker>.from(markers),
        polygons: _polygons,
        onCameraMove:(CameraPosition cameraPosition){
          localSettings.setMap(cameraPosition.target.latitude, cameraPosition.target.longitude, cameraPosition.zoom);
          _currentZoom = cameraPosition.zoom;
        },
        onLongPress: (LatLng pos) {

        },
        onTap: (LatLng pos) {
          dprint("latitude=${pos.latitude}, longitude=${pos.longitude}");
          //_selectPos(pos);
        },
        onMapCreated: (GoogleMapController controller) {
           _controller = controller;
           if (theme.darkMode)
             controller.setMapStyle(_mapStyle);
        });
  }

  Set<Marker> markers = {};

  // _selectPos(LatLng pos){
  //   markers.clear();
  //   var _lastMarkerId = MarkerId("addr${pos.latitude}");
  //   final marker = Marker(
  //       markerId: _lastMarkerId,
  //       position: LatLng(pos.latitude, pos.longitude),
  //       onTap: () {
  //
  //       }
  //   );
  //   markers.add(marker);
  //   setState(() {
  //   });
  //
  //   var _ret = mp.PolygonUtil.containsLocation(_toLL(pos), _toLLList(polylineCoordinates), false);
  //   print("mp.PolygonUtil.containsLocation _ret=$_ret");
  // }

  // List<mp.LatLng> _toLLList(List<LatLng> latLng){
  //   List<mp.LatLng> _ret = [];
  //   for (var item in latLng)
  //     _ret.add(mp.LatLng(item.latitude, item.longitude));
  //   return _ret;
  // }
  //
  // mp.LatLng _toLL(LatLng latLng){
  //   return mp.LatLng(latLng.latitude, latLng.longitude);
  // }

  Future<Position> getCurrent() async {
    var _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation)
        .timeout(Duration(seconds: 10));
    print("MyLocation::_currentPosition $_currentPosition");
    return _currentPosition;
  }

  _getCurrentLocation() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied)
        return;
    }
    var position = await getCurrent();
    _controller!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: _currentZoom,
        ),
      ),
    );
  }

  _buttonMyLocation(Function _getCurrentLocation){
    return Stack(
      children: <Widget>[
        Container(
          height: 60,
          width: 60,
          child: IBoxCircle(child: Icon(Icons.my_location, size: 30, color: Colors.black.withOpacity(0.5),)),
        ),
        Container(
          height: 60,
          width: 60,
          child: Material(
              color: Colors.transparent,
              shape: CircleBorder(),
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                splashColor: Colors.grey[400],
                onTap: (){
                  _getCurrentLocation();
                }, // needed
              )),
        )
      ],
    );
  }

  buttonPlus(Function() callback){
    return Stack(
      children: <Widget>[
        Container(
          height: 60,
          width: 60,
          child: IBoxCircle(child: Icon(Icons.add, size: 30, color: Colors.black,)),
        ),
        Container(
          height: 60,
          width: 60,
          child: Material(
              color: Colors.transparent,
              shape: CircleBorder(),
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                splashColor: Colors.grey[400],
                onTap: callback,
              )),
        )
      ],
    );
  }

  buttonMinus(Function() _onMapMinus){
    return Stack(
      children: <Widget>[
        Container(
          height: 60,
          width: 60,
          child: IBoxCircle(child: Icon(Icons.remove, size: 30, color: Colors.black,)),
        ),
        Container(
          height: 60,
          width: 60,
          child: Material(
              color: Colors.transparent,
              shape: CircleBorder(),
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                splashColor: Colors.grey[400],
                onTap: _onMapMinus,
              )),
        )
      ],
    );
  }

  final Set<Polygon> _polygons = HashSet<Polygon>();
  List<LatLng> polylineCoordinates = [];

  _add()  {
    polylineCoordinates.add(LatLng(28.63656671288816, 77.09655862301588));
    polylineCoordinates.add(LatLng(28.641357225395577, 77.10776589810848));
    polylineCoordinates.add(LatLng(28.64436530826774, 77.1136862039566));
    polylineCoordinates.add(LatLng(28.650382, 77.124963));
    polylineCoordinates.add(LatLng(28.637346, 77.129804));
    polylineCoordinates.add(LatLng(28.63694925570639, 77.12867338210344));
    polylineCoordinates.add(LatLng(28.63515923757567, 77.12811883538961));
    polylineCoordinates.add(LatLng(28.62135744629711, 77.11639456450939));
    polylineCoordinates.add(LatLng(28.614826, 77.107558));
    polylineCoordinates.add(LatLng(28.624866, 77.101456));
    polylineCoordinates.add(LatLng(28.63656671288816, 77.09655862301588));

    final String polygonIdVal = 'polygon_id_1';
    _polygons.add(Polygon(
      polygonId: PolygonId(polygonIdVal),
      points: polylineCoordinates,
      strokeWidth: 2,
      strokeColor: Colors.yellow,
      fillColor: Colors.yellow.withOpacity(0.15),
    ));
  }

  late BitmapDescriptor _iconHome;
  late BitmapDescriptor _iconDest;

  _initIcons() async {
    final Uint8List markerIcon = await getBytesFromAsset('assets/marker2.png', 80);
    _iconHome = BitmapDescriptor.fromBytes(markerIcon);
    final Uint8List markerIcon2 = await getBytesFromAsset('assets/marker1.png', 80);
    _iconDest = BitmapDescriptor.fromBytes(markerIcon2);

    _addMarker1();
    _addMarker2();
    setState(() {
    });
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  _addMarker1(){
    var _lastMarkerId2 = MarkerId("1");
    final marker = Marker(
        markerId: _lastMarkerId2,
        position: LatLng(
            28.641093282089596, 77.12215058505535
        ),
        infoWindow: InfoWindow(
          title: "Home",
          snippet: "Destination",
          onTap: () {
            print("tap on marker");
          },
        ),
        onTap: () {

        },
        icon: _iconHome
    );
    markers.add(marker);
  }

  _addMarker2(){
    var _lastMarkerId2 = MarkerId("2");
    final marker = Marker(
        markerId: _lastMarkerId2,
        position: LatLng(
            28.630301345860836, 77.10514102131128
        ),
        infoWindow: InfoWindow(
          title: "Provider",
          snippet: "",
          onTap: () {
            print("tap on marker");
          },
        ),
        onTap: () {

        },
        icon: _iconDest
    );
    markers.add(marker);
  }

}

class IBoxCircle extends StatelessWidget {
  final Widget child;
  final Color color;
  IBoxCircle({this.color = Colors.white, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(5),
        child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(40),
                  spreadRadius: 2,
                  blurRadius: 2,
                  offset: Offset(2, 2), // changes position of shadow
                ),
              ],
            ),
            child: Container(
                child: child)
        ),
      );
  }
}

