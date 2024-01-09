import 'dart:math';
import 'package:abg_utils/abg_utils.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:provider/provider.dart';
import '../strings.dart';
import '../theme.dart';

class AddressListScreen extends StatefulWidget {
  @override
  _AddressListScreenState createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(FocusNode());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);
    return Scaffold(
        backgroundColor: theme.darkMode ? Colors.black : mainColorGray,
        body: Directionality(
        textDirection: strings.direction,
        child: Stack(
          children: [

            Container(
              child: ListView(
                padding: EdgeInsets.only(top: 0, left: 10, right: 10),
                children: _children(),
              ),
            ),

            appbar1(Colors.transparent, (theme.darkMode) ? Colors.white : Colors.black,
                strings.get(78), context, () {goBack();}), /// My Address

            Container(
              alignment: Alignment.bottomCenter,
              margin: EdgeInsets.all(10),
              child: button2(strings.get(80), /// "Add address",
                  theme.mainColor, (){
                    route("address");
                  }),
            )

          ]),
        ));
  }

  _children() {
    List<Widget> list = [];

    list.add(SizedBox(height: MediaQuery.of(context).padding.top+40,));

    var _count = 0;
    list.add(SizedBox(height: 10,));
    var _address = getCurrentAddress();
    if (_address.id.isNotEmpty){
      list.add(Text(strings.get(202) + ":", style: theme.style12W600Grey,)); /// "Current address",
      list.add(SizedBox(height: 10,));
      list.add(_item(_address, false));
      list.add(SizedBox(height: 10,));
      _count++;
    }

    bool _first = true;
    for (var item in userAccountData.userAddress) {
      if (item == _address)
        continue;
      if (_first){
        list.add(SizedBox(height: 10,));
        list.add(Text(strings.get(254) + ":", style: theme.style12W600Grey,)); /// "Other addresses",
        list.add(SizedBox(height: 10,));
        _first = false;
      }
      list.add(_item(item, true));
      list.add(SizedBox(height: 10,));
      _count++;
    }

    if (_count == 0){
      list.add(SizedBox(height: 100,));
      list.add(Container(
          width: windowWidth*0.5,
          height: windowWidth*0.5,
          child: Image.asset("assets/notfound.png", fit: BoxFit.contain)
      ));
      list.add(SizedBox(height: 50,));
      list.add(Center(child: Text(strings.get(79), /// "Address not found",
          style: theme.style14W800)));
    }

    list.add(SizedBox(height: 200,));
    return list;
  }

  _item(AddressData item, bool upIcon){
    return Stack(
        children: [
          Positioned.fill(child: Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            alignment: Alignment.centerRight,
            child: Icon(Icons.delete, color: Colors.red, size: 30,),
          )),
          Dismissible(key: Key(item.id.toString()),
              onDismissed: (DismissDirection _direction){
                _delete(item.id);
              },
              confirmDismiss: (DismissDirection _direction) async {
                if (_direction == DismissDirection.startToEnd)
                  return false;
                return true;
              },
              child: Button300(text: item.address,
                  upIcon: upIcon,
                  text2: item.type == 1 ? strings.get(19)
                      : item.type == 2 ? strings.get(69) : strings.get(70), /// "Home", "Office", "Other",
                  icon: Icon(item.type == 1 ? Icons.home
                      : item.type == 2 ? Icons.account_balance : Icons.devices_other, color: theme.mainColor,),
                  pressButtonDelete: (){
                    _delete(item.id);
                  },
                pressButton: (){
                  _mainModel.addressData = item;
                  route("addressDetails");
                },
                pressSetCurrent: (){
                  setCurrentAddress(item.id);
                  _redraw();
                },
              )
          )
        ]);
  }


  _delete(String id){

  }

  _redraw(){
    if (mounted)
      setState(() {
      });
  }

}

