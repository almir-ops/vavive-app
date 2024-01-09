import 'package:abg_utils/abg_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/widgets/address.dart';
import 'package:ondemandservice/widgets/buttons/button1s.dart';
import 'package:provider/provider.dart';
import '../strings.dart';
import '../theme.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> with TickerProviderStateMixin{

  double windowWidth = 0;
  double windowHeight = 0;
  final _editControllerCoupon = TextEditingController();
  final _editControllerComment = TextEditingController();
  double _show = 0;
  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    super.initState();
  }

  @override
  void dispose() {
    _editControllerCoupon.dispose();
    _editControllerComment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;

    bool _showButtonNext = true;
    if (cartCurrentProvider != null && !ifUserAddressInProviderRoute(cartCurrentProvider!.id))
      if (cartCurrentProvider!.acceptOnlyInWorkArea)
        _showButtonNext = false;

    return Scaffold(
        backgroundColor: theme.darkMode ? Colors.black : mainColorGray,
      body: Directionality(
      textDirection: strings.direction,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top+40, bottom: 60),
              child: ListView(
                padding: EdgeInsets.only(top: 0),
                children: _body(),
              )
          ),

          appbar1(Colors.transparent,
              (theme.darkMode) ? Colors.white : Colors.black, strings.get(162), /// "Checkout",
              context, () {goBack();}, style: theme.style14W400),

          if (_showButtonNext)
            Container(
              alignment: Alignment.bottomCenter,
              margin: EdgeInsets.all(10),
              child: button2(strings.get(217), /// "CONTINUE"
                  theme.mainColor, (){
                    cartHint = _editControllerComment.text;
                    if (getCurrentAddress().id.isEmpty)
                      return messageError(context, strings.get(205)); /// Please select address
                    route("checkout2");
                  }),
              ),

          IEasyDialog2(setPosition: (double value){_show = value;}, getPosition: () {return _show;}, color: Colors.grey,
            getBody: _getDialogBody, backgroundColor: (theme.darkMode) ? Colors.black : Colors.white,),

        ]),
      ));
  }

  _body(){
    List<Widget> list = [];

    // String _couponInfo = couponInfo(_mainModel.currentService.providers, _mainModel.currentService.category,
    //     _mainModel.currentService.id,
    //     strings.get(188), /// "Coupon not found",
    //     strings.get(189), /// "Coupon has expired",
    //     strings.get(190), /// "Coupon not supported by this provider",
    //     strings.get(191), /// "Coupon not support this category",
    //     strings.get(192), /// "Coupon not support this service",
    //     strings.get(193) /// "Coupon activated",
    // );

    Widget _couponWidget = Container();
    if (couponCode.isNotEmpty)
      _couponWidget = Container(
          color: (theme.darkMode) ? Colors.black : Colors.white,
          padding: EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 0),
          child: Row(children: [
            Expanded(child: Text("${strings.get(275)}: $couponCode", style: theme.style14W800,), /// "Promo code",
            ),
            InkWell(
                onTap: (){
                  clearCoupon();
                  _redraw();
                },
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Text(strings.get(274), style: theme.style12W800,), /// "Remove",
                ))
          ],));
    else
    if (isCouponsPresent(true, _mainModel.currentService))
      _couponWidget = InkWell(
          onTap: (){
            route("add_promo");
          },
          child: Container(
            color: (theme.darkMode) ? Colors.black : Colors.white,
            padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
            child: Text(strings.get(276), style: theme.style14W800,), /// "Add promo",
          ));
    else
      _couponWidget = Container(
        color: (theme.darkMode) ? Colors.black : Colors.white,
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
        child: Text("${strings.get(276)} | ${strings.get(277)}", style: theme.style14W400Grey,), /// "Promo not found",
      );

    list.add(Container(
      color: (theme.darkMode) ? Colors.black : Colors.white,
      child: Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10,),
          Text(strings.get(174), style: theme.style13W800,), /// "Select Address"
          SizedBox(height: 10,),
          Row(
            children: [
              Icon(Icons.location_on, color: theme.mainColor,),
              SizedBox(width: 10,),
              Expanded(child: comboBoxAddress(_mainModel))
            ],
          ),
          if (cartCurrentProvider != null && !ifUserAddressInProviderRoute(cartCurrentProvider!.id))
            Column(
              children: [
                SizedBox(height: 10,),
                Divider(thickness: 0.5,),
                SizedBox(height: 10,),
                Row(
                  children: [
                    Expanded(child: Text(strings.get(219), style: theme.style12W600Red,)), /// "Your address is outside provider work area"
                    SizedBox(width: 10,),
                    Expanded(child: button2(strings.get(220), theme.mainColor, (){  /// "See details",
                      route("booking_map_details");
                    }))
                  ],
                ),
                SizedBox(height: 10,),
                Divider(thickness: 0.5,),
                SizedBox(height: 10,),
              ],
            ),
          SizedBox(height: 10,),
          // Row(
          //   children: [
          //     Expanded(
          //         flex: 2,
          //         child: Edit43a(
          //           needDecoration: true,
          //           prefixIcon: Icon(Icons.card_giftcard, color: theme.darkMode ? Colors.white : Colors.black,),
          //           controller: _editControllerCoupon,
          //           hint: strings.get(164), /// "CODE123",
          //           type: TextInputType.text
          //     )),
          //     SizedBox(width: 10,),
          //     Expanded(
          //       child: Container(
          //       child: button2(strings.get(165), /// "Apply"
          //           theme.mainColor, (){
          //             couponCode = _editControllerCoupon.text;
          //             cartCouponCode = _editControllerCoupon.text;
          //             _redraw();
          //           })),
          //     )
          //   ],
          // ),
          // SizedBox(height: 5,),
          // if (cartCouponCode.isNotEmpty)
          //   Center(child: Text(_couponInfo,
          //     style: theme.style12W800, textAlign: TextAlign.center,)),
          _couponWidget,

          SizedBox(height: 10,),
          Divider(height: 0.5, color: Colors.grey,),
          SizedBox(height: 10,),
          Edit43a(
              needDecoration: true,
              prefixIcon: Icon(Icons.info_outline, color: theme.darkMode ? Colors.white : Colors.black,),
              controller: _editControllerComment,
              hint: strings.get(170), /// "Additional note",
          ),
          SizedBox(height: 50,),

          button1s4(strings.get(214), "", /// "Any Time",
              Icons.workspaces_outline, cartAnyTime, (){
                cartAnyTime = true;
                _redraw();
              }),

          SizedBox(height: 10,),

          button1s4(strings.get(215), "", /// "Schedule an Order",
              Icons.timer, !cartAnyTime, (){
                cartAnyTime = false;
                _redraw();
              }),

          SizedBox(height: 20,),

          if (!cartAnyTime)
            Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              child: Row(
                children: [
                  Expanded(child: button2(strings.get(216),  /// "Select a Date & Time",
                          theme.mainColor, (){
                        _show = 1;
                        _redraw();
                      }
                    //    _dateTime
                  )),
                ],
              )),

          SizedBox(height: 10,),

          if (!cartAnyTime)
              Container(
                width: windowWidth,
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(strings.get(213), style: theme.style14W800,), /// "Requested Service on",
                  SizedBox(height: 10,),
                  Text(appSettings.getDateTimeString(cartSelectTime),
                    style: theme.style13W800,),
                ],
            )),
          SizedBox(height: 50,),

        ],
      )
    )));

    list.add(SizedBox(height: 150,));
    return list;
  }

  _redraw(){
    if (mounted)
      setState(() {
      });
  }

  Widget _getDialogBody(){
    var widget = CupertinoDatePicker(
        onDateTimeChanged: (DateTime picked) {
          cartSelectTime = picked;
          print(picked.toString());
          _redraw();
        },
        mode: CupertinoDatePickerMode.dateAndTime,
        use24hFormat: appSettings.timeFormat == "24h",
        initialDateTime: DateTime.now().add(Duration(minutes: 1)),
        minimumDate: DateTime.now()
    );

    return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: windowHeight*0.4,
            child: widget,
          ),
          Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              child: button2(strings.get(217), theme.mainColor, (){ /// "CONTINUE",
                _show = 0;
                _redraw();
              })),
        ]);
  }

}
