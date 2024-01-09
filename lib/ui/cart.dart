import 'package:abg_utils/abg_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/widgets/need_login.dart';
import 'strings.dart';
import 'theme.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin{

  double windowWidth = 0;
  double windowHeight = 0;

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: theme.darkMode ? Colors.black : mainColorGray,
      body: Directionality(
      textDirection: strings.direction,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top+10),
              child: ListView(
                padding: EdgeInsets.only(top: 0),
                children: _body(),
              )
          ),

          // if (_count != 0 && numberOfProvidersInCart < 2)
          // Container(
          //   alignment: Alignment.bottomCenter,
          //     margin: EdgeInsets.only(left: 10, right: 10, bottom: 70),
          //     child: button2s(numberOfProvidersInCart > 1 ? strings.get(211)
          //         : strings.get(161), /// "Proceed all checkout", "Proceed to checkout",
          //     (){
          //       _mainModel.cart.allCheckout();
          //       route("checkout");
          //     })
          // ),

        ]),
      ));
  }

  var _count = 0;
  int numberOfProvidersInCart = 0;

  _body(){
    List<Widget> list = [];

    _count = 0;
    list.add(Text(strings.get(158), /// "My Cart",
        textAlign: TextAlign.center, style: theme.style14W400),);

    list.add(SizedBox(height: 20,));

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null)
      return needLogin(windowWidth, (){route("login");});

    List<ProviderData> providers = cartGetProvidersData();
    numberOfProvidersInCart = providers.length;

    for (var provider in providers){
      if (provider.id == "root")
        list.add(Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
            child: Text(strings.get(265), /// Other products
              style: theme.style14W800,)),
        );
      else
        list.add(Container(
          color: (theme.darkMode) ? theme.blackColorTitleBkg : mainColorGray,
          padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
          child:Text(getTextByLocale(provider.name, strings.locale),
              style: theme.style14W800,)),
        );
      // list.add(SizedBox(height: 10,));
      for (var item in cart) {
        if (item.providers.contains(provider.id)) {
          list.add(_oneItem(item));
          _count++;
        }else{
          if (item.providers.isEmpty && provider.id == "root"){
            list.add(item.thisIsArticle ? _oneItemArticle(item) : _oneItem(item));
            _count++;
          }
        }
        list.add(SizedBox(height: 10,));
      }
      cartCurrentProvider = provider;
      var t = cartGetTotalForAllServices();
      bool _notShow = false;

      if (provider.useMinPurchaseAmount && t.subtotal < provider.minPurchaseAmount){
        list.add(Container(
            margin: EdgeInsets.only(top: 20),
            padding: EdgeInsets.only(top: 10, bottom: 10),
            color: (theme.darkMode) ? Colors.black : Colors.white,
            alignment: Alignment.center,
            child: Text(strings.get(270) + getPriceString(provider.minPurchaseAmount),
                style: theme.style12W600Red)), /// Minimum purchase amount for this provider:
        );
        _notShow = true;
      }
      if (provider.useMaxPurchaseAmount && t.subtotal > provider.maxPurchaseAmount){
        list.add(Container(
            margin: EdgeInsets.only(top: 20),
            padding: EdgeInsets.only(top: 10, bottom: 10),
            color: (theme.darkMode) ? Colors.black : Colors.white,
            alignment: Alignment.center,
            child: Text(strings.get(271) + getPriceString(provider.maxPurchaseAmount),
                style: theme.style12W600Red)), /// Maximum purchase amount for this provider:
        );
        _notShow = true;
      }

      list.add(SizedBox(height: 50,));
      if (!_notShow)
        list.add(Container(
          margin: EdgeInsets.only(left: 20, right: 20),
            child: button2(strings.get(161), /// "Proceed to checkout",
                theme.mainColor, (){
              checkoutProvider(provider);
              route("checkout");
            })));

      list.add(SizedBox(height: 10,));
    }

    if (_count == 0){
      list.add(SizedBox(height: 100,));
      list.add(Container(
          width: windowWidth*0.5,
          height: windowWidth*0.5,
          child: Image.asset("assets/notfound.png", fit: BoxFit.contain)
      ));
      list.add(SizedBox(height: 50,));
      list.add(Center(child: Text(strings.get(160), /// "Your cart in empty",
          style: theme.style14W800)));
    }

    list.add(SizedBox(height: 150,));

    return list;
  }

  _oneItem(ProductData item){
    countProduct = item.countProduct;
    setDataToCalculate(null, item);

    int countAddons = getSelectedAddonsCount();
    return Container(
        color: theme.darkMode ? theme.blackColorTitleBkg : Colors.white,
        child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10,),
                  //
                  // Items
                  //
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(theme.radius),
                                bottomLeft: Radius.circular(theme.radius)),
                            child: Container(
                                width: 60,
                                height: 60,
                                child: Stack(
                                  children: [
                                    item.gallery.isNotEmpty ? showImage(item.gallery[0].serverPath, fit: BoxFit.cover) : Container(),
                                    // item.gallery.isNotEmpty && item.gallery[0].serverPath.isNotEmpty ? CachedNetworkImage(
                                    //     imageUrl: item.gallery[0].serverPath,
                                    //     imageBuilder: (context, imageProvider) => Container(
                                    //       decoration: BoxDecoration(
                                    //           image: DecorationImage(
                                    //             image: imageProvider,
                                    //             fit: BoxFit.cover,
                                    //           )),
                                    //     )
                                    // ) : Container(),
                                  ],
                                )
                            ),
                          )
                      ),
                      SizedBox(width: 10,),
                      Expanded(child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(getTextByLocale(item.name, strings.locale), style: theme.style12W400,),
                          SizedBox(height: 8,),
                          Text(getPriceString(price.getPrice()),
                            style: theme.style12W800,),
                          SizedBox(height: 8,),

                          if (countAddons != 0)
                            Text(strings.get(150), style: theme.style12W400,), /// "Addons:"
                          if (countAddons != 0)
                            SizedBox(height: 8,),
                          if (countAddons != 0)
                            addonsList(item)
                        ],
                      ),),
                      Column(
                        children: [
                          Text(strings.get(92), /// "Quantity",
                              style: theme.style12W800),
                          SizedBox(height: 8),
                          plusMinus(item.id, item.countProduct, (String id, int count) {
                            item.countProduct = count;
                            if (item.countProduct == 0)
                              removeFromCart(item);
                            _redraw();
                          }, countMayBeNull: true, padding: 10)
                        ],
                      )
                    ],),
                  SizedBox(height: 10,),
                  Divider(height: 0.5, color: Colors.grey,),
                  SizedBox(height: 20,),

                  //
                  // price
                  //
                  Row(
                    children: [
                      Expanded(child: Text(strings.get(152), style: theme.style13W400,)), /// "Item price"
                      Text(getPriceString(getCostWidthCount()),
                        style: theme.style13W400,)
                    ],
                  ),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Expanded(child: Text(strings.get(93), style: theme.style13W400,)), /// "Addons"
                      Text("(+) ${getPriceString(getAddonsTotal())}",
                        style: theme.style13W400,)
                    ],
                  ),
                  SizedBox(height: 10,),
                  Divider(height: 0.5, color: Colors.grey,),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Expanded(child: Text(strings.get(153), style: theme.style13W400,)), /// "Subtotal"
                      Text(getPriceString(getSubTotalWithoutCoupon()),
                        style: theme.style13W400,)
                    ],
                  ),
                ]
            )
        )
    );
  }

  _oneItemArticle(ProductData item){

    currentArticle = item;
    double? _price = articleGetTotalPrice();

    return Container(
        color: theme.darkMode ? theme.blackColorTitleBkg : Colors.white,
        child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10,),
                  //
                  // Items
                  //
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(theme.radius),
                                bottomLeft: Radius.circular(theme.radius)),
                            child: Container(
                                width: 60,
                                height: 60,
                                child: Stack(
                                  children: [
                                    item.gallery.isNotEmpty ? showImage(item.gallery[0].serverPath, fit: BoxFit.cover) : Container(),
                                  ],
                                )
                            ),
                          )
                      ),
                      SizedBox(width: 10,),
                      Expanded(child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(articleGetFullName(), style: theme.style12W400,),
                          SizedBox(height: 8,),
                          Text(_price != null ? getPriceString(_price) : "",
                            style: theme.style12W800,),
                          SizedBox(height: 8,),
                        ],
                      ),),
                      Column(
                        children: [
                          Text(strings.get(92), /// "Quantity",
                              style: theme.style12W800),
                          SizedBox(height: 8),
                          plusMinus(item.id, item.countProduct, (String id, int count) {
                            item.countProduct = count;
                            if (item.countProduct == 0)
                              removeFromCart(item);
                            else
                              cartSave();
                            _redraw();
                          }, countMayBeNull: true, padding: 10)
                        ],
                      )
                    ],),
                  SizedBox(height: 10,),
                  Divider(height: 0.5, color: Colors.grey,),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Expanded(child: Text(strings.get(153), style: theme.style13W400,)), /// "Subtotal"
                      Text(_price != null ? getPriceString(_price*item.countProduct) : "",
                        style: theme.style13W400,)
                    ],
                  ),
                ]
            )
        )
    );
  }


  _redraw(){
    if (mounted)
      setState(() {
      });
  }

  Widget addonsList(ProductData service){
    List<Widget> list = [];

    for (var item in service.addon)
      if (item.selected){

        String name = getTextByLocale(item.name, strings.locale);
        String price = getPriceString(item.price);
        _callback(){
          item.selected = !item.selected;
          redrawMainWindow();
        }

        list.add(
          Container(
              width: windowWidth*0.25,
              child: Column(
                children: [
                  button2twoLine(name, price, item.selected, _callback),
                  SizedBox(height: 5,),
                  // plusMinus2(_redraw, item, countMayBeNull: true),
                  plusMinus(item.id, item.needCount, (String id, int count) {
                    item.needCount = count;
                    item.selected = item.needCount <= 0 ? false : true;
                    _redraw();
                  }, countMayBeNull : true, padding: 10)
                ],
              )),
        );
      }
    return Wrap(
      runSpacing: 10,
      spacing: 10,
      children: list
    );
  }
}
