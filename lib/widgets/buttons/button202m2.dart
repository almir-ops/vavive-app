//import 'package:cached_network_image/cached_network_image.dart';
import 'package:abg_utils/abg_utils.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/ui/theme.dart';

button202m2(String text,
    String text2,
    String image,
    double height,
    Function() _callbackPending,
    // Function() _callbackTrack,
    String stringPending, // "Pending"
    ) {
  return Stack(
    children: <Widget>[

      Container(
    color: theme.darkMode ? theme.blackColorTitleBkg : Colors.white,
      child: Container(
          margin: EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(theme.radius),
          ),
          child: Row(
            children: [

              Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(height)),
                  child:
                    showImage(image, fit: BoxFit.cover, height: height-20, width: height-20,),
                  // image.isNotEmpty ? CachedNetworkImage(
                  //     imageUrl: image,
                  //     imageBuilder: (context, imageProvider) =>
                  //       Container(
                  //         height: height-20,
                  //         width: height-20,
                  //         decoration: BoxDecoration(
                  //             image: DecorationImage(
                  //               image: imageProvider,
                  //               fit: BoxFit.cover,
                  //             )),
                  //       ),
                  //     ) : Container(),
                ),
              ),

              SizedBox(width: 10,),

              Expanded(
                  flex: 3,
                  child: Container(
                        margin: EdgeInsets.only(left: 5, right: 5, top: 3, bottom: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(text, style: theme.style11W600, textAlign: TextAlign.start, maxLines: 2, overflow: TextOverflow.ellipsis,),
                            SizedBox(height: 15,),
                            Text(text2, style: theme.style11W600Grey, textAlign: TextAlign.start, maxLines: 1, overflow: TextOverflow.ellipsis,),
                          ],
                        ),
                      ),
                  ),

              Expanded(
                flex: 2,
                  child: Container(
                  margin: EdgeInsets.only(left: 5, right: 5, top: 3, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  button2(stringPending,  /// "Pending"
                      theme.mainColor, (){
                        _callbackPending();
                      }, style: theme.style12W600White,
                      padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10), width: null),
                  // SizedBox(height: 8,),
                  // button2(strings.get(141), /// "Track booking"
                  //     theme.mainColor, (){
                  //       _callbackTrack();
                  //     }, style: theme.style11W800W,
                  //     padding: EdgeInsets.only(top: 5, bottom: 5, left: 3, right: 3), width: null),
                ],
              )))



            ],
          )
      )),


    ],
  );
}
