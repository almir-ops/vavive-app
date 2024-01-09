import 'dart:typed_data';
import 'package:abg_utils/abg_utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ondemandservice/widgets/buttons/button200.dart';
import 'package:ondemandservice/widgets/buttons/button201.dart';
import 'strings.dart';
import 'theme.dart';
import 'package:ondemandservice/widgets/cards/card49.dart' as a;

class RatingScreen extends StatefulWidget {
  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {

  double windowWidth = 0;
  double windowHeight = 0;
  final ScrollController _scrollController = ScrollController();
  final _editControllerReview = TextEditingController();

  @override
  void initState() {
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  double _scroller = 20;
  _scrollListener() {
    var _scrollPosition = _scrollController.position.pixels;
    _scroller = 20-(_scrollPosition/(windowHeight*0.1/20));
    if (_scroller < 0)
      _scroller = 0;
    setState(() {
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _editControllerReview.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        Container(
          width: windowWidth,
          height: windowHeight,
          child: _body(),
        ),
        appbar1(Colors.transparent, (theme.darkMode) ? Colors.white : Colors.black,
            strings.get(244), context, () {goBack();}), /// "Leave a Review",

        if (_wait)
          Center(child: Container(child: Loader7v1(color: theme.mainColor,))),
      ],
    );
  }

  _body(){

    List<Widget> list = [];

    list.add(SizedBox(height: 50,));

    list.add(Container(
        width: windowWidth,
        margin: EdgeInsets.only(left: 10, right: 10),
        child: a.Card49(
          image: currentOrder.providerAvatar,
          text: getTextByLocale(currentOrder.provider, strings.locale),
          text2: strings.get(245), /// "Click on the stars to rate this service",
          text3: getTextByLocale(currentOrder.service, strings.locale),
          initValue: _stars,
          imageRadius: 50,
          callback: (int stars) { _setStar(stars); },)
    ));

    list.add(SizedBox(height: 20,));

    list.add(Container(
        color: (theme.darkMode) ? Colors.black : Colors.white,
        padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        child: edit42(strings.get(255), /// "Write your review",
        _editControllerReview,
        strings.get(246), /// "Tell us something about this service",
        )));

    list.add(SizedBox(height: 20,));

    list.add(Container(
        color: (theme.darkMode) ? Colors.black : Colors.white,
        padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        child: Text(strings.get(247), /// "Add Images",
          style: theme.style14W800,)),
    );
    list.add(SizedBox(height: 2,));
    list.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Flexible(child: button200(strings.get(248), /// "From Gallery",
            theme.style16W800,
            (theme.darkMode) ? Colors.black : Colors.white, (){_photo(ImageSource.gallery);}, true)),
        SizedBox(width: 2,),
        Flexible(child: button201(strings.get(249), /// "From Camera",
            theme.style16W800,
            (theme.darkMode) ? Colors.black : Colors.white, (){_photo(ImageSource.camera);}, true)),
      ],
    ));

    list.add(SizedBox(height: 20,));

    if (_images.isNotEmpty)
      list.add(Container(
        margin: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _images.map((e){
            return Container(
                width: windowWidth/2-30,
                child: Image.memory(e,
                    fit: BoxFit.contain
                ));
          }).toList(),
        ),
      ));

    list.add(SizedBox(height: 20,));

    list.add(Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
      child: button2(strings.get(250), /// "Submit Review",
          theme.mainColor, (){_confirm();}),
    ));

    list.add(SizedBox(height: 120,));

    return Container(
      child: ListView(
        children: list,
      )
    );
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

  _confirm() async {
    dprint("rating confirm _stars=$_stars; text=${_editControllerReview.text}");

    if (_editControllerReview.text.isEmpty)
      return messageError(context, strings.get(251)); /// "Please enter text",

    _waits(true);
    var ret = await addReview(_stars, _editControllerReview.text, _images, currentOrder);
    _waits(false);
    if (ret != null)
      return messageError(context, ret);

    goBack();
  }

  final List<Uint8List> _images = [];

  _photo(ImageSource source) async {
      final pickedFile = await ImagePicker().pickImage(
          maxWidth: 1000,
          maxHeight: 1000,
          source: source);
      if (pickedFile != null) {
        _images.add(await pickedFile.readAsBytes());
        setState(() {});
      }
  }

  int _stars = 5;
  _setStar(int stars){
    dprint("start $stars");
    _stars = stars;
    _redraw();
  }

}

