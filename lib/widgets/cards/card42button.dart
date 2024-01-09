import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/ui/theme.dart';
import 'package:abg_utils/abg_utils.dart';
// 01.11.2021

card42button(
    String text1,
    String text2,
    MainModel _mainModel,
    double windowWidth,
    Function() onClickText2,
    String _avatar,
    {double height = 200}
    ){
  return InkWell(
      onTap: onClickText2,
      child: Container(
          width: windowWidth,
          // color: bkgColor,
          //
          child: Stack(
            children: [
              Container(
                //alignment: Alignment.bottomRight,
                  height: height,
                  child: Container(
                    width: windowWidth,
                    child: Image.asset("assets/bkg.jpg", fit: BoxFit.cover)
                    ,)
              ),
              Container(
                padding: EdgeInsets.only(left: 20, top: 40, bottom: 20, right: 20),
                child: Row(
                  children: [
                    Expanded(child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(text1, style: theme.style14W800W),
                        SizedBox(height: 6,),
                        Text(text2, style: theme.style12W400),
                      ],
                    )),
                    Container(
                        width: windowWidth*0.4,
                        padding: EdgeInsets.only(bottom: 10),
                        height: 100,
                        alignment: Alignment.bottomRight,
                        child: image16(_avatar.isNotEmpty ?
                            showImage(_avatar, fit: BoxFit.cover)
                          //   _avatar.isNotEmpty ?
                          // CachedNetworkImage(
                          //   imageUrl: _avatar,
                          //   imageBuilder: (context, imageProvider) => Container(
                          //     child: Container(
                          //       decoration: BoxDecoration(
                          //           image: DecorationImage(
                          //             image: imageProvider,
                          //             fit: BoxFit.cover,
                          //           )),
                          //     ),
                          //   )
                        // )
                            : Image.asset("assets/user5.png", fit: BoxFit.cover), 80, Colors.white)
                    )
                  ],
                ),
              )
            ],
          )
      ));
}

