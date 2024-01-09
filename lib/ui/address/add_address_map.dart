import 'package:abg_utils/abg_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:provider/provider.dart';
import '../strings.dart';
import '../theme.dart';

class AddAddressScreen2 extends StatefulWidget {
  @override
  _AddAddressScreen2State createState() => _AddAddressScreen2State();
}

class _AddAddressScreen2State extends State<AddAddressScreen2> {

  double windowWidth = 0;
  double windowHeight = 0;
  GoogleMapController? _controller;
  double _currentZoom = 12;
  CameraPosition _kGooglePlex = CameraPosition(target: LatLng(0, 0), zoom: 12,);
  final _controllerSearch = TextEditingController();
  final _controllerScroll = ScrollController();
  String? _mapStyle;
  late MainModel _mainModel;
  Set<Marker> markers = {};
  String _textAddress = "";

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    places =  GoogleMapsPlaces(apiKey: appSettings.googleMapApiKey);
    _kGooglePlex = CameraPosition(target: LatLng(
        localSettings.mapLat != 0 ? localSettings.mapLat: 48.846575206328446,
        localSettings.mapLng != 0 ? localSettings.mapLng: 2.302420789679285),
        zoom: localSettings.mapZoom,); // paris coordinates by default
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
    super.initState();
  }

  @override
  void dispose() {
    _controllerScroll.dispose();
    _controllerSearch.dispose();
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
                      buttonMyLocation(_getCurrentLocation),
                      buttonPlus(_onMapPlus),
                      buttonMinus(_onMapMinus),
                    ],
                  )
              ),
            ),

            Container(
              margin: EdgeInsets.only(left: 10, right: 10, top: 10+MediaQuery.of(context).padding.top+40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                Edit26(
                  hint: strings.get(24), /// "Search",
                  color: (theme.darkMode) ? Colors.black : Colors.white,
                  style: theme.style14W400,
                  suffixIcon: Icons.cancel,
                  useAlpha: false,
                  icon: Icons.search,
                  decor: decor,
                  onChangeText: _onPressSearch,
                  controller: _controllerSearch,
                  onSuffixIconPress: (){
                    _controllerSearch.text = "";
                    _searchResult = [];
                    _redraw();
                  }
                ),
                if (_searchResult.isNotEmpty && _isShow)
                  Container(
                    margin: EdgeInsets.only(top: 1),
                    height: 200,
                    width: windowWidth,
                    //color: mainColorGrayDialog,
                    child: Scrollbar(
                      isAlwaysShown: true,
                      controller: _controllerScroll,
                      child: ListView(
                        controller: _controllerScroll,
                        addAutomaticKeepAlives: false,
                        padding: EdgeInsets.only(top: 0),
                        children: _searchResult,
                    )),
                  )
              ],),
            ),

            Container(
              alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.all(10),
                    color: (theme.darkMode) ? Colors.black : Colors.white,
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 10),
                      Text(_textAddress, style: theme.style14W600Grey,),
                      SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                        Text("${strings.get(203)} ${_mainModel.account.latitude} - " /// "Latitude",
                            "${strings.get(204)} ${_mainModel.account.longitude}", style: theme.style10W400,) /// "Longitude",
                      ],),
                      SizedBox(height: 20),
                      Container(
                        width: windowWidth,
                        child: button2(strings.get(64), /// "This address",
                            theme.mainColor, (){
                              if (_mainModel.account.latitude == 0)
                                return messageError(context, strings.get(205)); /// Please select address
                              _mainModel.account.address = _textAddress;
                              _mainModel.account.openAddAddressDialog();
                        }),
                      ),
                    ]))),

            appbar1(Colors.transparent,
                (theme.darkMode) ? Colors.white : Colors.black, strings.get(63), /// "Pick the Address"
                context, () {
                  goBack();
            }, style: theme.style14W800)
          ],
        )
    ));
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
        onCameraMove:(CameraPosition cameraPosition){
          localSettings.setMap(cameraPosition.target.latitude, cameraPosition.target.longitude, cameraPosition.zoom);
          _currentZoom = cameraPosition.zoom;
        },
        onLongPress: (LatLng pos) {

        },
        onTap: (LatLng pos) {
          _mainModel.account.latitude = pos.latitude;
          _mainModel.account.longitude = pos.longitude;
          _isShow = false;
          _selectPos(pos);
          _onMapTap(pos);
        },
        onMapCreated: (GoogleMapController controller) {
           _controller = controller;
           if (theme.darkMode)
             controller.setMapStyle(_mapStyle);
        });
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

  _onMapTap(LatLng pos) async {
    _textAddress = await getAddressFromLatLng(pos);
    _redraw();
  }

  _redraw(){
    if (mounted)
      setState(() {
      });
  }

  _selectPos(LatLng pos){
    markers.clear();
    var _lastMarkerId = MarkerId("addr${pos.latitude}");
    final marker = Marker(
        markerId: _lastMarkerId,
        position: LatLng(pos.latitude, pos.longitude),
        onTap: () {

        }
    );
    markers.add(marker);
    _redraw();
  }

  Future<Position> getCurrent() async {
    var _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation)
        .timeout(Duration(seconds: 10));
    dprint("MyLocation::_currentPosition $_currentPosition");
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

  bool _isShow = true;
  late GoogleMapsPlaces places;
  List<Widget> _searchResult = [];

  _onPressSearch(String val) async {
    _isShow = true;
    PlacesSearchResponse response = await places.searchByText(val);
    if (!response.isOkay && response.errorMessage != null)
      messageError(context, response.errorMessage!);
    dprint(response.toString());
    _searchResult = [];
    for (var ret in response.results) {
      if (ret.formattedAddress != null)
        _searchResult.add(
            Stack(
            children: [
              Container(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                  width: windowWidth,
                  color: (theme.darkMode) ? Colors.black : Colors.white,
                  child: Text(ret.formattedAddress!, style: theme.style14W400,)
              ),
              Positioned.fill(
                child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: Colors.grey[400],
                      onTap: (){
                        _textAddress = ret.formattedAddress!;
                        _onAddressClick(ret);
                      }, // needed
                    )),
              )

            ],
          )
      );
      _searchResult.add(
          Container(height: 1,
            width: windowWidth,
            color: Colors.grey,
          )
      );
    }
    _redraw();
  }

  _onAddressClick(PlacesSearchResult ret){
    _searchResult = [];
    // if (ret.formattedAddress != null)
    //   _editControllerAddress.text = ret.formattedAddress!;
    _mainModel.account.latitude = ret.geometry!.location.lat;
    _mainModel.account.longitude = ret.geometry!.location.lng;
    var pos = LatLng(ret.geometry!.location.lat, ret.geometry!.location.lng);
    _controller!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: pos,
          zoom: _currentZoom,
        ),
      ),
    );
    _isShow = false;
    _redraw();
  }
}
