import 'package:abg_utils/abg_utils.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/ui/theme.dart';
import '../../ui/strings.dart';
import 'package:firebase_auth/firebase_auth.dart';

button202n2d(ProductData item, MainModel _mainModel,
    double width,
    bool _decoration, {bool openService = true}){

  User? user = FirebaseAuth.instance.currentUser;
  var iconStarsColor = Colors.orangeAccent;

  if (item.providers.isEmpty)
    print(getTextByLocale(item.name, strings.locale));

  String name = getTextByLocale(item.name, strings.locale);
  String providerName = item.providers.isNotEmpty ? getProviderNameById(item.providers[0], strings.locale) : "";
  // price
  PriceData _minPrice = getSelectedPrice(item.price); //item.getMinPriceItem();
  String textPrice = getPriceString(_minPrice.price);
  String textDiscPrice = _minPrice.discPrice != 0 ? getPriceString(_minPrice.discPrice) : "";
  int stars = item.rating.toInt();
  // image
  String image = item.gallery.isNotEmpty ? item.gallery[0].serverPath : "";
  bool favorite = userAccountData.userFavorites.contains(item.id);
  setFavorite(bool val) {
        changeFavorites(item);
        redrawMainWindow();
      }

  //
  bool available = true;
  var t = item.providers.isNotEmpty ? getProviderById(item.providers[0]) : null;
  if (t != null)
    available = t.available;
  //

  _callback(){
    if (openService) {
      for (var item2 in item.addon) {
        item2.selected = false;
        item2.needCount = 0;
      }
      _mainModel.currentService = item;
      _mainModel.openDialog("service");
    }
  }
  var sale = "";
  if (_minPrice.discPrice != 0) {
    var t = _minPrice.price / 100;
    var t1 = (_minPrice.price-_minPrice.discPrice)/t;
    sale = "-${t1.toStringAsFixed(0)}% OFF";
  }

  return Stack(
    children: <Widget>[

      Container(
          width: width,
          decoration: _decoration ? BoxDecoration(
            color: theme.darkMode ? theme.blackColorTitleBkg : Colors.white,
            borderRadius: BorderRadius.circular(theme.radius),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(1, 1),
              ),
            ],
          ) : BoxDecoration(),
          child: IntrinsicHeight(child: Row(
            children: [
              Expanded(
                flex: 2,
                child: ClipRRect(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(theme.radius), bottomLeft: Radius.circular(theme.radius)),
                child: SizedBox.expand(child: Container(
                  width: width,
                  child: Stack(
                    children: [
                      showImage(image, fit: BoxFit.cover),
                      if (!available)
                        Container(
                          color: Colors.black.withAlpha(100),
                          child: Center(child: Text(strings.get(30), style: theme.style10W800White, textAlign: TextAlign.center,)), /// Not available Now
                        )
                    ],
                  ))
                ),
              )),

              Expanded(
                  flex: 3,
                  child:Container(
                    margin: EdgeInsets.only(left: 10, right: 10, top: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(name, style: theme.style11W600, textAlign: TextAlign.start, maxLines: _decoration ? 1 : 2, overflow: TextOverflow.ellipsis,),
                        //SizedBox(height: 5,),
                        Text(providerName, style: theme.style11W600Grey, textAlign: TextAlign.start,),
                        //SizedBox(height: 5,),

                        Row(children: [
                          if (stars >= 1)
                            Icon(Icons.star, color: iconStarsColor, size: 16,),
                          if (stars < 1)
                            Icon(Icons.star_border, color: iconStarsColor, size: 16,),
                          if (stars >= 2)
                            Icon(Icons.star, color: iconStarsColor, size: 16,),
                          if (stars < 2)
                            Icon(Icons.star_border, color: iconStarsColor, size: 16,),
                          if (stars >= 3)
                            Icon(Icons.star, color: iconStarsColor, size: 16,),
                          if (stars < 3)
                            Icon(Icons.star_border, color: iconStarsColor, size: 16,),
                          if (stars >= 4)
                            Icon(Icons.star, color: iconStarsColor, size: 16,),
                          if (stars < 4)
                            Icon(Icons.star_border, color: iconStarsColor, size: 16,),
                          if (stars >= 5)
                            Icon(Icons.star, color: iconStarsColor, size: 16,),
                          if (stars < 5)
                            Icon(Icons.star_border, color: iconStarsColor, size: 16,),
                          Text(stars.toString(), ),
                        ]
                        ),

                        // SizedBox(height: 5,),

                        Row(
                          children: [
                            Text(textPrice, style: textDiscPrice.isEmpty ? theme.style13W800 : theme.style12W400D,),
                            SizedBox(width: 3,),
                            Text(textDiscPrice, style: theme.style13W800Red,),
                            Expanded(child: SizedBox(width: 3,)),
                          ],
                        ),

                        Text(item.providers.isNotEmpty ? getStringDistanceByProviderId(item.providers[0]) : "",
                          style: theme.style10W600Grey, textAlign: TextAlign.end,),

                        SizedBox(height: 5,),

                      ],
                    ),
              )),


            ],
          )
      )),

        Positioned.fill(
          child: Material(
              color: Colors.transparent,
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(theme.radius)),
              child: InkWell(
                splashColor: Colors.black.withOpacity(0.2),
                onTap: (){
                  _callback();
                }, // needed
              )),
        ),

      if (user != null)
      Positioned.fill(
          child: Container(
          alignment: _decoration ? Alignment.bottomRight : Alignment.topRight,
          child: Container(
          margin: _decoration ? EdgeInsets.all(8) : EdgeInsets.only(left: 8, right: 8, top: 38),
          child: InkWell(onTap: (){
            setFavorite(!favorite);
          },
            child: (favorite) ? Icon(Icons.favorite, size: 20, color: Colors.green,)
                : Icon(Icons.favorite_border, size: 18, color: Colors.grey,),
          ),
        ))),

      if (sale.isNotEmpty)
        Positioned.fill(
            child: Container(
              alignment: Alignment.topLeft,
              child: Container(
                  padding: EdgeInsets.all(3),
                  color: Colors.green,
                  margin: EdgeInsets.only(top: 8),
                  child: Text(sale, style: theme.style10W400White,)
              ),
            )),



    ],
  );
}
