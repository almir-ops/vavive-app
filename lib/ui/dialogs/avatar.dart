import 'package:abg_utils/abg_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ondemandservice/model/model.dart';
import '../strings.dart';

getBodyAvatarDialog(Function() _redraw, Function() _close, MainModel _mainModel){
  _route(String route) {
    if (route == "camera")
      _photo(ImageSource.camera, _mainModel);
    else
      _photo(ImageSource.gallery, _mainModel);
    _close();
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 5,),
      button1s(strings.get(126), Icons.photo_library_outlined, "library", _route), /// "From Library"
      SizedBox(height: 10,),
      button1s(strings.get(127), Icons.camera_alt, "camera", _route), /// "From Camera"
      SizedBox(height: 10,),
    ],
  );
}

_photo(ImageSource source, MainModel _mainModel) async {
  var user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final pickedFile = await ImagePicker().pickImage(
        maxWidth: 400,
        maxHeight: 400,
        source: source);
    if (pickedFile != null) {
      dprint("Photo file: ${pickedFile.path}");
      waitInMainWindow(true);
      var ret = await uploadAvatar(await pickedFile.readAsBytes());
      waitInMainWindow(false);
      if (ret != null)
        messageError(buildContext, ret);
    }
  }
}