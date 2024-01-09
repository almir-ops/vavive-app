import 'package:abg_utils/abg_utils.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/ui/main.dart';
import 'package:ondemandservice/ui/theme.dart';
import 'package:ondemandservice/widgets/buttons/button202n2d.dart';
import '../strings.dart';

getBodyServiceDialog(Function() _redraw, Function() _close, double windowWidth,
    MainModel _mainModel, BuildContext context){

  ProductData item = _mainModel.currentService;
  if (item.countProduct == 0)
    item.countProduct = 1;
  countProduct = item.countProduct;
  setDataToCalculate(null, item);

  // print ("countProduct = item.count=${item.count}");

  _openProvider(){
    var _provider = getProviderById(item.providers[0]);
    if (_provider == null)
      return;
    _mainModel.currentProvider = _provider;
    currentSourceKeyProvider = _provider.dataKey;
    route("provider");
    _close();
  }

  //
  bool available = true;
  var t = item.providers.isNotEmpty ? getProviderById(item.providers[0]) : null;
  if (t != null)
    available = t.available;
  //

  return Column(
      children: [
        Container(
          height: windowWidth*0.3,
          child: Stack(
            children: [
              button202n2d(item, _mainModel, windowWidth, false, openService: false)
            ]
        )),

        SizedBox(height: 10,),

        ..._priceList(_mainModel, _redraw),

        SizedBox(height: 10,),
        Text(getTextByLocale(item.descTitle, strings.locale), style: theme.style12W800),
        SizedBox(height: 5,),
        Text(getTextByLocale(item.desc, strings.locale),
            style: theme.style12W400),
        SizedBox(height: 20,),
        Row(
          children: [
            Expanded(child: Text(strings.get(92), /// "Quantity",
                style: theme.style12W800)),
              plusMinus(item.id, item.countProduct, (String id, int count) {
                item.countProduct = count;
                dprint("service dialog item.count=${item.countProduct} ${item.id}");
                dprint("${_mainModel.currentService.countProduct}");
                _redraw();
              }, padding: 10 )
          ],
        ),
        SizedBox(height: 10,),
        if (item.addon.isNotEmpty)
          Text(strings.get(93), /// "Addons",
              style: theme.style12W800),
        SizedBox(height: 10,),
        _listAddons(windowWidth, _redraw, item, _mainModel),
        SizedBox(height: 20,),

        Row(
          children: [
            Text(strings.get(95), /// "Total amount",
                style: theme.style12W800),
            SizedBox(width: 10,),
            Text(getPriceString(getSubTotalWithoutCoupon()),
                style: theme.style13W800Red),
          ],
        ),

        SizedBox(height: 20,),
        Row(
          children: [
            Expanded(child:
            button2(strings.get(32), /// "Provider",
                theme.mainColor, _openProvider)
            //button134(strings.get(32), _openProvider, style: theme.style14W800MainColor)), /// "Provider",
            ),
            SizedBox(width: 10,),
            Expanded(flex: 2, child: button2(strings.get(94), /// "Add to cart",
                    theme.mainColor, (){
                      var ret = addToCart(item,
                          strings.get(210) /// This service already in the cart
                      );
                      if (ret != null)
                        messageError(context, ret);
                      else
                        messageOk(context, strings.get(206)); /// Service added to cart
                      _close();
                }, enable: available))
          ],
        ),
      ],
    );
}

_priceList(MainModel _mainModel, Function() _redraw){
  List<Widget> list = [];
  for (var item in _mainModel.currentService.price){
    List<Widget> list2 = [];
    list2.add((item.image.serverPath.isNotEmpty)
        ? Container(
        width: 30,
        height: 30,
        child: Image.network(item.image.serverPath, fit: BoxFit.contain))
        : Container(width: 30, height: 30));
    list2.add(SizedBox(width: 10,));
    list2.add(Expanded(child: Text(getTextByLocale(item.name, strings.locale), style: theme.style13W400)));
    list2.add(SizedBox(width: 5,));
    _getPriceText(item, list2, _mainModel);
    list.add(InkWell(
        onTap: (){
          for (var item in _mainModel.currentService.price)
            item.selected = false;
          item.selected = true;
          _mainModel.currentPrice = item;
          _redraw();
        },
        child: Container(
            decoration: BoxDecoration(
              color: (item.selected) ? Colors.grey.withAlpha(60) : Colors.transparent,
              border: Border.all(color: Colors.grey.withAlpha(60)),
              borderRadius: BorderRadius.circular(theme.radius),
            ),
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
            child: Row(children: list2))
    ));
  }
  return list;
}

_getPriceText(PriceData item, List<Widget> list2, MainModel _mainModel){
  if (item.discPrice == 0)
    list2.add(Column(
      children: [
        Text(getPriceString(item.price), style: theme.style20W800Green),
        Text((item.priceUnit == "fixed") ? strings.get(207) : strings.get(208), style: theme.style11W800), /// "fixed", - "hourly",
      ],));
  else{
    list2.add(Column(
      children: [
        Text(getPriceString(item.discPrice), style: theme.style20W800Red),
        Text((item.priceUnit == "fixed") ? strings.get(207) : strings.get(208), style: theme.style11W800), /// "fixed", - "hourly",
      ],
    ));
    list2.add(SizedBox(width: 5,));
    list2.add(Text(getPriceString(item.price), style: theme.style16W400U),);
  }
}

_listAddons(double windowWidth, Function() _redraw, ProductData item, MainModel _mainModel){

  List<Widget> list = [];
  for (var item in item.addon){
    String name = getTextByLocale(item.name, strings.locale);
    String price = getPriceString(item.price);

    _callback(){
      item.selected = !item.selected;
      if (item.selected && item.needCount <= 0)
        item.needCount = 1;
      else
        item.needCount = 0;
      redrawMainWindow();
    }

    list.add(Container(
      width: windowWidth*0.25,
      child: Column(
        children: [
          button2twoLine(name, price, item.selected, _callback),
          SizedBox(height: 5,),
          // if (item.selected)
          //   plusMinus2(_redraw, item, countMayBeNull : true),
          plusMinus(item.id, item.needCount, (String id, int count) {
            item.needCount = count;
            item.selected = item.needCount <= 0 ? false : true;
            _redraw();
          }, countMayBeNull : true, padding: 10)
        ],
      )));
  }

  return Wrap(
      runSpacing: 10,
      spacing: 10,
      children: list
  );
}


