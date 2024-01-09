import 'package:abg_utils/abg_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/ui/checkout/checkout2.dart';
import 'package:ondemandservice/ui/checkout/map_details.dart';
import 'package:ondemandservice/ui/pending.dart';
import 'package:ondemandservice/ui/documents.dart';
import 'package:ondemandservice/ui/products.dart';
import 'package:ondemandservice/ui/profile/change_password.dart';
import 'package:ondemandservice/ui/providers_all.dart';
import 'package:ondemandservice/ui/rating.dart';
import 'package:ondemandservice/ui/services.dart';
import 'package:ondemandservice/ui/start/otp.dart';
import 'package:ondemandservice/ui/start/phone.dart';
import 'package:ondemandservice/widgets/local_hero.dart';
import 'package:provider/provider.dart';
import 'article.dart';
import 'blog/blog_all.dart';
import 'blog/blogdetails.dart';
import 'cart.dart';
import 'checkout/addpromo.dart';
import 'checkout/checkout.dart';
import 'checkout/confirm.dart';
import 'checkout/enter_code.dart';
import 'dialogs/avatar.dart';
import 'map_near_by.dart';
import 'profile/profile.dart';
import 'package:ondemandservice/ui/provider.dart';
import 'start/register.dart';
import 'address/add_address.dart';
import 'address/address_list.dart';
import 'address/add_address_map.dart';
import 'address/map_details.dart';
import 'category.dart';
import 'profile/change_profile.dart';
import 'chat.dart';
import 'strings.dart';
import 'chat2.dart';
import 'dialogs/add_address.dart';
import 'dialogs/menu.dart';
import 'dialogs/service.dart';
import 'favorite.dart';
import 'dialogs/filter.dart';
import 'start/forgot.dart';
import 'lang.dart';
import 'booking.dart';
import 'theme.dart';

import 'home.dart';
import 'start/login.dart';
import 'notify.dart';

GlobalKey currentSourceKeyProvider = GlobalKey();

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin{

  bool _startLocalHero = false;
  bool user = false;
  final GlobalKey _keyDestProvider = GlobalKey();
  late AnimationController _controller2;
  Animation? _animation2;

  final _editControllerAddress = TextEditingController();
  final _editControllerName = TextEditingController();
  final _editControllerPhone = TextEditingController();

  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    state = "home";
    _init();
    super.initState();
    _controller2 = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _editControllerAddress.dispose();
    _editControllerName.dispose();
    _editControllerPhone.dispose();
    _controller2.dispose();
    super.dispose();
  }

  _init() async {
    _waits(true);
    _mainModel.account.userAndNotifyListen(_redraw, context);
    var ret = await _mainModel.init2();
    _redraw();
    if (ret != null)
      messageError(context, ret);
    _waits(false);
    ret = await loadBlog(true);
    if (ret != null)
      messageError(context, ret);
   _redraw();
  }

  bool _wait = false;
  _waits(bool value){
    _wait = value;
    _redraw();
  }
  _redraw(){
    if (mounted)
      setState(() {
      });
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;

    if (localSettings.locale.isEmpty)
      state = "language";

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && needOTPParam && state != "otp"
        && userAccountData.userSocialLogin.isEmpty)
      state = "phone";

    if (state == "chat" && user == null) {
      callbackStackRemoveLast();
      state = "login";
    }
    if (state == "notify"  && user == null) {
      callbackStackRemoveLast();
      state = "login";
    }

    _mainModel.setMainWindow(_openDialog2);
    drawState(_route, context, _redraw, strings.locale, strings.direction);
    return WillPopScope(
        onWillPop: () async {
          if (_show != 0){
            _show = 0;
            _redraw();
            return false;
          }
          if ((state == "home" && !_mainModel.searchActivate)
              || state == "favorite" || state == "cart" || state == "booking"){
            _dialogName = "exit";
            _show = 1;
            _redraw();
            return false;
          }
          if (state == "home" && _mainModel.searchActivate){
            _mainModel.searchActivate = false;
            _redraw();
            return false;
          }
          goBack();
          return false;
    },
    child: Scaffold(
        backgroundColor: (theme.darkMode) ? theme.blackColorTitleBkg : mainColorGray,
        body: ParentScreen(
            waitWidget: Loader7(color: aTheme.mainColor,),
            child: LocalHero(
          getKeySource: (){
            //print("getKeySource currentSourceKeyProvider=$currentSourceKeyProvider");
            return currentSourceKeyProvider;
          },
          getKeyDest: () => _keyDestProvider,
          getStart: () => _startLocalHero,
          setStart: (){
            _startOpacity();
            Future.delayed(const Duration(milliseconds: 100), () {
              state = "provider";
              dprint("_route _redraw _state=$state");
              _redraw();

            });
            // print("setStart");
          },
          setEnd: (){_startLocalHero = false;},
          child: Stack(
          children: <Widget>[

            if (state == "home")
              HomeScreen(callback: _route,
                openDialogService: (ProductData item) {
                                _dialogName = "service";
                                _mainModel.currentService = item;
                                _openDialog(); },
              ),
            if (state == "favorite")
                FavoriteScreen(),
            if (state == "cart")
              CartScreen(),
            if (state == "booking")
              BookingScreen(),

            // bottom bar
            Container(
              alignment: Alignment.bottomCenter,
              child: BottomBar13V2(mainColorGray: (theme.darkMode) ? Colors.black : Colors.white,
                  colorSelect: theme.mainColor,
                  colorUnSelect: Colors.grey,
                  textStyle: theme.style10W600Grey,
                  textStyleSelect: theme.style11W800MainColor,
                  radius: theme.radius,
                  callback: (int y){
                    if (y == 0) state = "home";
                    if (y == 1) state = "favorite";
                    if (y == 2) state = "cart";
                    if (y == 3) state = "booking";
                    if (y == 4) {
                      _dialogName = "menu";
                      return _openDialog();
                    }
                    _redraw();
                  },
                  getItem: (){
                    switch(state){
                      case "home":
                        return 0;
                      case "favorite":
                        return 1;
                      case "cart":
                        return 2;
                      case "booking":
                        return 3;
                    }
                    return 0;
                  },
                  text: [strings.get(19), /// "Home",
                    strings.get(20), /// "Favorites",
                    strings.get(21), /// "Cart",
                    strings.get(82), /// "Booking",
                    strings.get(23), /// "Menu"
                  ],
                  getUnreadMessages: (int index){
                    if (index == 2)
                      return cart.isNotEmpty ? cart.length.toString() : "";
                    return "";
                  },
                  icons: [Icons.home,
                    Icons.favorite,
                    Icons.shopping_cart,
                    Icons.copy,
                    Icons.menu]
              ),
            ),

            if (state == "login")
              LoginScreen(),
            if (state == "register")
              RegisterScreen(),
            if (state == "phone")
              PhoneScreen(),
            if (state == "otp")
              OtpScreen(),
            if (state == "category_all")
              CategoryScreen(),
            if (state == "chat")
              ChatScreen(),
            if (state == "chat2")
              Chat2Screen(),
            if (state == "language")
              LanguageScreen(openLogin: false, callback: _route, redraw: _redraw),
            if (state == "policy" || state == "about" || state == "terms")
              DocumentsScreen(),
            if (state == "provider")
              Opacity(opacity: _animation2 == null ? 1 : _animation2!.value,
                child: ProvidersScreen(keyDestProvider: _keyDestProvider,)),
            if (state == "forgot")
              ForgotScreen(),
            if (state == "address")
              AddAddressScreen(),
            if (state == "map")
              AddAddressScreen2(),
            if (state == "address_list")
              AddressListScreen(),
            if (state == "addressDetails")
              MapDetailsScreen(),
            if (state == "notify")
              NotifyScreen(),
            if (state == "profile")
              ProfileScreen(),
            if (state == "changeProfile")
              ChangeProfileScreen(),
            if (state == "changePassword")
              ChangePassword(),
            // if (_state == "trackMap")
            //   TrackMapScreen(callback: _route),
            if (state == "pending")
              PendingScreen(),
            if (state == "services")
              ServicesScreen(),
            if (state == "checkout")
              CheckoutScreen(),
            if (state == "checkout2")
              Checkout2Screen(),
            if (state == "confirm")
              ConfirmScreen(),
            if (state == "booking_map_details")
              MapDetailsBookingScreen(),
            if (state == "nearby")
              MapNearByScreen(),
            if (state == "rating")
              RatingScreen(),
            if (state == "blog_all")
              BlogAllScreen(),
            if (state == "blog_details")
              BlogDetailsScreen(),
            if (state == "products")
              ProductsScreen(),
            if (state == "article")
              ArticleScreen(),
            if (state == "providers_all")
              ProvidersAllScreen(),
            if (state == "add_promo")
              AddPromoScreen(),
            if (state == "enter_code")
              EnterCodeScreen(),

            IEasyDialog2(setPosition: (double value){_show = value;}, getPosition: () {return _show;}, color: Colors.grey,
              getBody: _getBody, backgroundColor: (theme.darkMode) ? Colors.black : Colors.white,),

            if (_wait)
              Center(child: Container(child: Loader7(color: theme.mainColor,))),
          ],
        ))

    )));
  }


  _route(String state2){
    state = state2;
    if (state.isEmpty)
      state = "home";

    _redraw();
  }


  double _show = 0;
  String _dialogName = "";

  _openDialog(){
    _show = 1;
    _redraw();
  }

  _openDialog2(String val){
    _dialogName = val;
    _openDialog();
  }

  _getBody(){
    if (_dialogName == "service")
      return getBodyServiceDialog(_redraw, (){_show = 0; _redraw(); },
          windowWidth, _mainModel, context);
    if (_dialogName == "filter")
      return getBodyFilterDialog(_redraw, (){_show = 0; _redraw();}, _mainModel);
    if (_dialogName == "menu")
      return getBodyMenuDialog(_mainModel, _redraw, (){_show = 0; _redraw();}, windowWidth,
              (String route){_show = 0; _route(route);}, context);
    if (_dialogName == "addAddress")
      return getBodyAddressDialog(_mainModel, _redraw, (){_show = 0;
        state = "address_list";
        _redraw();}, _editControllerAddress, _editControllerName, _editControllerPhone, context);
    if (_dialogName == "avatar")
      return getBodyAvatarDialog(_redraw, (){_show = 0; _redraw();}, _mainModel);
    if (_dialogName == "exit")
      return getBodyDialogExit(strings.get(227), strings.get(228), strings.get(229),
              (){_show = 0;_redraw();});  /// Are you sure you want to exit? No Exit

    return Container();
  }

  _startOpacity(){
    _animation2 = Tween(begin: 0.0, end: 1).animate(_controller2)
      ..addListener(() {
        setState(() {});
      })..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller2.reset();
          _animation2 = null;
        }
      });
    _controller2.forward();
  }

}
