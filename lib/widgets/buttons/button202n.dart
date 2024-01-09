import 'package:abg_utils/abg_utils.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/ui/theme.dart';

import '../../ui/strings.dart';

button202n(ProductData item, MainModel _mainModel, double width,
    ){

  var iconStarsColor = Colors.orangeAccent;

  String name = getTextByLocale(item.name, strings.locale);
  String providerName = item.providers.isNotEmpty ? getProviderNameById(item.providers[0], strings.locale) : "";// price
  // price
  PriceData _minPrice = getMinPriceInProduct(item.price);
  String textPrice = getPriceString(_minPrice.price);
  String textDiscPrice = _minPrice.discPrice != 0 ? getPriceString(_minPrice.discPrice) : "";
  int stars = item.rating.toInt();
  // image
  String image = item.gallery.isNotEmpty ? item.gallery[0].serverPath : "";

  bool favorite = userAccountData.userFavorites.contains(item.id);
  setFavorite(bool val)
    {changeFavorites(item); redrawMainWindow();}
  //
  bool available = true;
  var t = item.providers.isNotEmpty ? getProviderById(item.providers[0]) : null;
  if (t != null)
    available = t.available;
  //
  _callback(){
    for (var item2 in item.addon) {
      item2.selected = false;
      item2.needCount = 0;
    }
    _mainModel.currentService = item;
    _mainModel.openDialog("service");
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
          margin: EdgeInsets.only(bottom: 5),
          width: width,
          decoration: BoxDecoration(
            color: (theme.darkMode) ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(theme.radius),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(1, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(theme.radius), topRight: Radius.circular(theme.radius)),
                child: Container(
                  width: width,
                    child: Stack(
                    children: [
                      showImage(image, fit: BoxFit.cover),
                      // image.isNotEmpty ? CachedNetworkImage(
                      //   imageUrl: image,
                      //   imageBuilder: (context, imageProvider) => Container(
                      //       decoration: BoxDecoration(
                      //           image: DecorationImage(
                      //             image: imageProvider,
                      //             fit: BoxFit.cover,
                      //           ),
                      //     ),
                      //   )
                    // ) : Container(),
                      if (!available)
                        Container(
                          color: Colors.black.withAlpha(100),
                          child: Center(child: Text(strings.get(30), style: theme.style10W800White, textAlign: TextAlign.center,)), /// Not available Now
                        )
                    ],
                    )
                ),
              )),

              Container(
                margin: EdgeInsets.only(left: 10, right: 10, top: 3, bottom: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(name, style: theme.style11W600, textAlign: TextAlign.start, maxLines: 1, overflow: TextOverflow.ellipsis,),
                    SizedBox(height: 3,),
                    Row(
                      children: [
                        Expanded(child: Text(providerName, style: theme.style11W600Grey, textAlign: TextAlign.start, maxLines: 1, overflow: TextOverflow.ellipsis,)),
                        Icon(Icons.star, color: iconStarsColor, size: 16,),
                        Text(stars.toString(), overflow: TextOverflow.ellipsis,),
                      ],
                    ),
                    SizedBox(height: 3,),
                    Row(children: [
                      Expanded(child: Text(textPrice, style: textDiscPrice.isEmpty ? theme.style13W800 : theme.style12W400D,
                        overflow: TextOverflow.clip, maxLines: 1,)),
                      SizedBox(width: 3,),
                      if (textDiscPrice.isNotEmpty)
                        Expanded(child: Text(textDiscPrice, style: theme.style13W800Red, overflow: TextOverflow.clip, maxLines: 1,)),
                    ]
                    ),
                    SizedBox(height: 3,),
                    Row(
                      children: [
                        Expanded(child: Text(item.providers.isNotEmpty ? getStringDistanceByProviderId(item.providers[0]) : "",
                          style: theme.style10W600Grey, textAlign: TextAlign.end,),)
                      ],
                    )
                  ],
                ),
              ),


            ],
          )
      ),

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

      Positioned.fill(
          child: Container(
            alignment: Alignment.topRight,
            child: Container(
              margin: EdgeInsets.all(8),
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
                child: Text(sale, style: theme.style10W400White)
                ),
              )),


    ],
  );
}
