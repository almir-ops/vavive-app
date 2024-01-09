import 'package:abg_utils/abg_utils.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/ui/theme.dart';
import 'package:ondemandservice/widgets/edit/edit42.dart';
import '../strings.dart';

int _type = 1;

getBodyAddressDialog(MainModel _mainModel, Function() _redraw, Function() _close, TextEditingController _editControllerAddress,
    TextEditingController _editControllerName, TextEditingController _editControllerPhone, BuildContext context){

    _mainModel.account.initAddressEdit(_editControllerAddress, _editControllerName, _editControllerPhone);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10,),
        Center(child: Text(strings.get(66), /// "Add the location",
            textAlign: TextAlign.center, style: theme.style14W800)),
        SizedBox(height: 10,),
        Text(strings.get(67), /// "Label as",
            textAlign: TextAlign.start, style: theme.style12W400),
        SizedBox(height: 10,),
        Row(
          children: [
            Expanded(child: button2(strings.get(68), /// "Home",
              _type == 1 ? theme.mainColor : Colors.grey.withAlpha(80), (){
                  _type = 1;
                  _redraw();
                },
              style: _type == 1 ? theme.style12W800W : theme.style12W800,
            )),
            SizedBox(width: 10,),
            Expanded(child: button2(strings.get(69), /// "Office",
              _type == 2 ? theme.mainColor : Colors.grey.withAlpha(80), (){
                  _type = 2;
                  _redraw();
                },
                style: _type == 2 ? theme.style12W800W : theme.style12W800,
            )),
            SizedBox(width: 10,),
            Expanded(child: button2(strings.get(70), /// "Other",
              _type == 3 ? theme.mainColor : Colors.grey.withAlpha(80), (){
                  _type = 3;
                  _redraw();
                },
              style: _type == 3 ? theme.style12W800W : theme.style12W800,
            )),
          ],
        ),
        SizedBox(height: 10,),
        // Text(strings.get(71), /// "Delivery Address",
        //     textAlign: TextAlign.start, style: theme.style12W400),
        SizedBox(height: 5,),
        edit42V2(strings.get(71), /// "Delivery Address",
            _editControllerAddress,
            strings.get(75), /// "Enter Delivery Address",
            ),
        SizedBox(height: 5,),
        Text("${strings.get(203)} ${_mainModel.account.latitude} - " /// "Latitude",
            "${strings.get(204)} ${_mainModel.account.longitude}", style: theme.style10W400,), /// "Longitude",
        SizedBox(height: 15,),
        edit42V2(strings.get(72), /// "Contact name",
            _editControllerName,
            strings.get(77), /// "Enter Contact name",
            ),
        SizedBox(height: 15,),
        edit42V2(strings.get(73), /// "Contact phone number",
            _editControllerPhone,
            strings.get(76), /// "Enter Contact phone number",
            type: TextInputType.phone),
        SizedBox(height: 25,),
        Row(
          children: [
            Expanded(child: button2(strings.get(74), /// "Save location",
                theme.mainColor, () async {
                  var ret = await _mainModel.account.saveLocation(_type, _editControllerAddress.text, _editControllerName.text,
                      _editControllerPhone.text);
                  if (ret != null)
                    return messageError(context, ret);
                  _close();
                  goBack();
                  if (currentScreen() == "address")
                    goBack();
            }))
          ],
        ),
      ],
    );

}