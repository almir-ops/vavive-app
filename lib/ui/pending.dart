import 'dart:math';
import 'package:abg_utils/abg_utils.dart';
import 'package:flutter/material.dart';
import 'strings.dart';
import 'theme.dart';

class PendingScreen extends StatefulWidget {
  @override
  _PendingScreenState createState() => _PendingScreenState();
}

class _PendingScreenState extends State<PendingScreen> with TickerProviderStateMixin{

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;

  @override
  void initState() {
    setJobInfoListen((){
      for (var item in bookings)
        if (item.id == currentOrder.id)
          currentOrder = item;
      _redraw();
    });
    super.initState();
  }

  @override
  void dispose() {
    setJobInfoListen(null);
    super.dispose();
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
    windowSize = min(windowWidth, windowHeight);

    StatusData _currentStatus = StatusData.createEmpty();
    StatusData _last = StatusData.createEmpty();
    var _found = false;
    for (var item in appSettings.statuses) {
      if (_found) {
        _currentStatus = item;
        _found = false;
      }
      if (item.id == currentOrder.status) {
        _found = true;
      }
      if (!item.cancel)
        _last = item;
    }

    var _needReview = false;
    if (currentOrder.status == _last.id)
      _needReview = true;

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
              (theme.darkMode) ? Colors.white : Colors.black, strings.get(144), /// "Booking details",
              context, () {goBack();}, style: theme.style14W400),

          Container(
            alignment: Alignment.bottomCenter,
            margin: EdgeInsets.all(10),
            child: Row(
              children: [
                if (_needReview && !currentOrder.rated)
                  Expanded(
                    child: button2(strings.get(242), /// "Rate this provider",
                        theme.mainColor, (){
                        route("rating");
                        }),
                  ),
                if (_currentStatus.byProviderApp && !_currentStatus.cancel)
                  Expanded(child: Text(strings.get(243), style: theme.style13W800Red, textAlign: TextAlign.center,)), /// Wait for a response from the provider

                if (_currentStatus.byCustomerApp && !_currentStatus.cancel)
                  Expanded(
                    child: button2(getTextByLocale(_currentStatus.name, strings.locale),
                      theme.mainColor, () async {
                          _waits(true);
                          var ret = await setNextStep(_currentStatus, true, false, false,
                              strings.get(186), /// "Now status:",
                              strings.get(187) /// "Booking status was changed",
                          );
                          _waits(false);
                          if (ret != null)
                            return messageError(context, ret);
                        // route("trackMap");
                      }, enable: _currentStatus.byCustomerApp && !_currentStatus.cancel),
                ),
                SizedBox(width: 10,),

                  Expanded(
                    child: button2(strings.get(157), /// "Cancel booking",
                      Colors.red, (){

                      }, enable: !_currentStatus.cancel && !currentOrder.finished),
                ),
              ],
            )
          ),

          if (_wait)
            Center(child: Container(child: Loader7(color: theme.mainColor,))),


        ]),
      ));
  }

  _body(){
    List<Widget> list = [];

    List<Widget> list2 = [];
    if (currentOrder.ver4){
      cartCurrentProvider = ProviderData.createEmpty()..id = currentOrder.providerId;
      tablePricesV4(list2, currentOrder.products,
          strings.get(93), /// "Addons"
          strings.get(153), /// "Subtotal"
          strings.get(154), /// "Discount"
          strings.get(155), /// "VAT/TAX"
          strings.get(156)  /// "Total amount"
      );
    }

    var _prov = getProviderById(currentOrder.providerId);
    _prov ??= ProviderData.createEmpty();
    setDataToCalculate(currentOrder, null);
    //
    var _date = strings.get(214); /// "Any Time",
    if (!currentOrder.anyTime)
      _date = appSettings.getDateTimeString(currentOrder.selectTime);

    list.add(Container(
      color: theme.darkMode ? theme.blackColorTitleBkg : Colors.white,
      child: Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10,),
          Row(
            children: [
              Expanded(child: Text("${strings.get(145)} ${currentOrder.id}", style: theme.style12W400,)), /// Order ID:
              Icon(Icons.timer, size: 15, color: theme.darkMode ? Colors.white : Colors.black,),
              SizedBox(width: 5,),
              Text(appSettings.getDateTimeString(currentOrder.time), style: theme.style12W400,)
            ],
          ),
          SizedBox(height: 10,),
          Row(
            children: [
              Expanded(child: Text(strings.get(146), style: theme.style12W400,)), /// "Payment"
              SizedBox(width: 5,),
              Container(
                padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: theme.mainColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(currentOrder.paymentMethod, style: theme.style10W400White,)) /// "cash payment"
            ],
          ),
          SizedBox(height: 10,),
          Divider(height: 0.5, color: Colors.grey,),
          SizedBox(height: 10,),
          Row(
            children: [
              Expanded(child: Text(strings.get(148), style: theme.style12W400,)), /// "Status"
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8,),
              Text(appSettings.getStatusName(currentOrder.status, strings.locale), style: theme.style12W400,) /// "Accept"
            ],
          ),
          if (currentOrder.comment.isNotEmpty)
            SizedBox(height: 8,),
          if (currentOrder.comment.isNotEmpty)
            Row(
              children: [
                Text(strings.get(237), style: theme.style12W400,), /// "Comment",
                SizedBox(width: 8,),
                Expanded(child:Text(currentOrder.comment, style: theme.style12W400, textAlign: TextAlign.end,))
              ],
            ),
          SizedBox(height: 8,),
          Row(
            children: [
              Text(strings.get(238), style: theme.style12W400,), /// "Address",
              SizedBox(width: 8,),
              Expanded(child:Text(currentOrder.address, style: theme.style12W400, textAlign: TextAlign.end,))
            ],
          ),
          SizedBox(height: 8,),
          Row(
            children: [
              Text(strings.get(239), style: theme.style12W400,), /// "Appointed time",
              SizedBox(width: 8,),
              Expanded(child: Text(_date, style: theme.style12W400, textAlign: TextAlign.end,))
            ],
          ),
          SizedBox(height: 10,),
          Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: Container(),),
                  Icon(Icons.phone, color: Colors.blue, size: 20,),
                  SizedBox(width: 10,),
                  InkWell(
                    onTap: (){callMobile(currentOrder.providerPhone);},
                    child: Text(strings.get(240),                  /// "Call now",
                        style: theme.style14W800MainColor),
                  ),
                  SizedBox(width: 30,),
                  Icon(Icons.message, color: Colors.green, size: 20,),
                  SizedBox(width: 10,),
                  InkWell(
                    onTap: (){
                      setChat2Data(UserData(
                        id: currentOrder.providerId,
                        name: getTextByLocale(currentOrder.provider, strings.locale),
                        logoServerPath: currentOrder.providerAvatar, address: [],
                      ),);
                      route("chat2");
                    },
                    child: Text(strings.get(241), /// "Message",
                        style: theme.style14W800MainColor),
                  ),
                  Expanded(child: Container(),),
                ],
              )),
          SizedBox(height: 10,),
          if (!currentOrder.ver4)
          Divider(height: 0.5, color: Colors.grey,),
          if (!currentOrder.ver4)
          SizedBox(height: 10,),
          //
          // Items
          //
          if (!currentOrder.ver4)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
            Container(
                child: ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(theme.radius), bottomLeft: Radius.circular(theme.radius)),
                  child: Container(
                      width: 60,
                      height: 60,
                      child: showImage(currentOrder.serviceImage, fit: BoxFit.cover),
                  ),
                )
            ),
            SizedBox(width: 10,),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(getTextByLocale(currentOrder.service, strings.locale), style: theme.style12W400,),
                SizedBox(height: 8,),
                Text(getPriceString(currentOrder.price), style: theme.style12W800,),
                SizedBox(height: 8,),
                Text(strings.get(150), style: theme.style12W400,), /// "Addons:"
                SizedBox(height: 8,),
                Text(getAddonText(strings.locale), style: theme.style12W400,),
              ],
            ),),
            Text(strings.get(151), style: theme.style10W400,), /// "Quantity:"
            Text("${currentOrder.count} ", style: theme.style11W800MainColor,),
          ],),
          SizedBox(height: 10,),
          Divider(height: 0.5, color: Colors.grey,),
          SizedBox(height: 10,),
          //
          // provider
          //
          if (_prov.id.isNotEmpty)
          Text(strings.get(32), style: theme.style12W400,), /// "Provider"
          if (_prov.id.isNotEmpty)
          Container(
            color: theme.darkMode ? theme.blackColorTitleBkg : Colors.white,
            padding: EdgeInsets.only(bottom: 5, top: 5),
            child: Card50forProvider(
              direction: strings.direction,
              locale: strings.locale,
              category: categories,
              provider: _prov,
            ),
            // child: button202m(providers[0], _mainModel, windowSize*0.26)
          ),
          if (_prov.id.isNotEmpty)
          SizedBox(height: 10,),
          if (_prov.id.isNotEmpty)
          Divider(height: 0.5, color: Colors.grey,),
          SizedBox(height: 10,),
          //
          // price
          //
          if (currentOrder.ver4)
            ...list2,
          if (!currentOrder.ver4)
            pricingTable(
                  (String code){
                if (code == "addons") return strings.get(93);  /// "Addons",
                if (code == "direction") return strings.direction;
                if (code == "locale") return strings.locale;
                if (code == "pricing") return strings.get(152);  /// "Item price",
                if (code == "quantity") return strings.get(92);  /// "Quantity",
                if (code == "taxAmount") return strings.get(155);  /// "VAT/TAX",
                if (code == "total") return strings.get(95);  /// "Total amount",
                if (code == "subtotal") return strings.get(153);  /// "Subtotal",
                if (code == "discount") return strings.get(154);  /// "Discount"
                return "";
              }
          ),
          SizedBox(height: 10,),
        ],
      )
    )));

    list.add(SizedBox(height: 150,));
    return list;
  }


}
