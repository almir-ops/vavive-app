import 'package:abg_utils/abg_utils.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/ui/theme.dart';
import 'package:ondemandservice/widgets/buttons/button202n2d.dart';
import 'package:provider/provider.dart';
import 'horizontal_articles.dart';
import 'strings.dart';

double _lastOffset = 0;

class ProvidersScreen extends StatefulWidget {
  final GlobalKey keyDestProvider;
  const ProvidersScreen({Key? key, required this.keyDestProvider}) : super(key: key);

  @override
  _ProvidersScreenState createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  final _controllerSearch = TextEditingController();
  bool _opeAllWorkTime = false;
  late MainModel _mainModel;
  final _controllerScroll = ScrollController(initialScrollOffset: _lastOffset);

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _init();
    });
    _controllerScroll.addListener((){
      _lastOffset = _controllerScroll.position.pixels;
    });
    super.initState();
  }

  _init() async {
    var ret = await loadReviewsForProviderScreen(_mainModel.currentProvider.id);
    if (ret != null)
      messageError(context, ret);
    addStat("reviews", reviews.length);
    _redraw();
  }

  @override
  void dispose() {
    _controllerSearch.dispose();
    super.dispose();
  }

  _redraw(){
    if (mounted)
      setState(() {
      });
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);
    return Scaffold(
        backgroundColor: (theme.darkMode) ? Colors.black : Colors.white,
        body: Directionality(
          textDirection: strings.direction,
          child: Stack(
              children: [
                Container(
                    child: ListView(
                      controller: _controllerScroll,
                      padding: EdgeInsets.only(top: 0),
                      children: _body(),
                    )
                ),

                appbar1(Colors.transparent, theme.mainColor, "", context, () {goBack();})

              ]),
        ));
  }

  _body(){
    List<Widget> list = [];

    list.add(Container(
      width: windowWidth,
      height: windowWidth/2,
      child:showImage(_mainModel.currentProvider.imageUpperServerPath, fit: BoxFit.cover),
      // _mainModel.currentProvider.imageUpperServerPath.isNotEmpty ? CachedNetworkImage(
      //     imageUrl: _mainModel.currentProvider.imageUpperServerPath,
      //     imageBuilder: (context, imageProvider) => Container(
      //       child: Container(
      //         decoration: BoxDecoration(
      //             image: DecorationImage(
      //               image: imageProvider,
      //               fit: BoxFit.cover,
      //             )),
      //       ),
      //     )
      // ) : Container(),
    ));

    list.add(Container(
        width: windowWidth,
        margin: EdgeInsets.only(left: 10, right: 10),
        child: RepaintBoundary(
            key: widget.keyDestProvider,
            child: Card50forProvider(
              direction: strings.direction,
              locale: strings.locale,
              category: categories,
              provider: _mainModel.currentProvider,
        ))));

    list.add(SizedBox(height: 10,));

    DateTime _now = DateTime.now();
    var index = 0;
    var _view = false;
    for (var item in _mainModel.currentProvider.workTime){
      if ((item.id+1 == _now.weekday && !_opeAllWorkTime) || _opeAllWorkTime) {
        DateTime _timeOpen = DateFormat('HH:mm').parse(item.openTime);
        DateTime _timeClose = DateFormat('HH:mm').parse(item.closeTime);
        var _open = DateFormat("hh:mm a").format(_timeOpen);
        var _close = DateFormat("hh:mm a").format(_timeClose);
        if (item.weekend){
          list.add(Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              child: Row(
                children: [
                  Text(strings.get(96+index) + ":", style: theme.style12W800,),
                  SizedBox(width: 8,),
                  Expanded(child: Text(strings.get(103), style: theme.style12W400)), /// "Weekend",
                  if ((item.id+1 == _now.weekday && !_opeAllWorkTime) || (_opeAllWorkTime && !_view))
                    button134(strings.get(26), (){_opeAllWorkTime = !_opeAllWorkTime; _redraw();},
                        style: theme.style11W800MainColor) /// "View all",
                ],
              )));
        }else
          list.add(Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              child: Row(
                children: [
                  Text(strings.get(96+index) + ":", style: theme.style12W800,),
                  SizedBox(width: 8,),
                  Text(_open, style: theme.style12W400),
                  Text("-"),
                  Expanded(child: Text(_close, style: theme.style12W400)),
                  if ((item.id+1 == _now.weekday && !_opeAllWorkTime) || (_opeAllWorkTime && !_view))
                    button134(strings.get(26), (){_opeAllWorkTime = !_opeAllWorkTime; _redraw();},
                        style: theme.style11W800MainColor) /// "View all",
                ],
              )));
        list.add(SizedBox(height: 5,));
        _view = true;
      }
      index++;
    }

    list.add(SizedBox(height: 20,));

    List<Widget> list2 = [];
    if (_mainModel.currentProvider.phone.isNotEmpty)
      list2.add(InkWell(
          onTap: () {
            callMobile(_mainModel.currentProvider.phone);
          }, // needed
          child: UnconstrainedBox(
            child: Container(
                width: 40,
                height: 40,
                child: Image.asset("assets/phone.png",
                    fit: BoxFit.contain
                )
            ),
          )),);

    if (_mainModel.currentProvider.www.isNotEmpty)
      list2.add(InkWell(
          onTap: () {
            openUrl(_mainModel.currentProvider.www);
          }, // needed
          child: UnconstrainedBox(
            child: Container(
                width: 40,
                height: 40,
                child: Image.asset("assets/www.png",
                    fit: BoxFit.contain
                )
            ),
          )),);

    if (_mainModel.currentProvider.instagram.isNotEmpty)
      list2.add(InkWell(
          onTap: () {
            openUrl(_mainModel.currentProvider.instagram);
          }, // needed
          child: UnconstrainedBox(
            child: Container(
                width: 40,
                height: 40,
                child: Image.asset("assets/insta.png",
                    fit: BoxFit.contain
                )
            ),
          )),);

    if (_mainModel.currentProvider.telegram.isNotEmpty)
      list2.add(InkWell(
          onTap: () {
            openUrl(_mainModel.currentProvider.telegram);
          }, // needed
          child: UnconstrainedBox(
            child: Container(
                width: 40,
                height: 40,
                child: Image.asset("assets/tg.png",
                    fit: BoxFit.contain
                )
            ),
          )),);

    if (list2.isNotEmpty)
      list.add(Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        height: 40,
        width: windowWidth - 20,
        child: Wrap(
          alignment: WrapAlignment.center,
          runSpacing: 20,
          spacing: 20,
          children: list2,
        ),
      ));

    list.add(SizedBox(height: 20,),);

    list.add(InkWell(
        onTap: () async {
          var _user = await getProviderUserByEmail(_mainModel.currentProvider.login);
          if (_user == null)
            return;
          setChat2Data(
              UserData(
              id: _user.id,
              name: getTextByLocale(_mainModel.currentProvider.name, strings.locale),
              logoServerPath: _mainModel.currentProvider.logoServerPath, address: [],
            ),
          );
          route("chat2");
        },
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.chat_bubble_outline, color: theme.mainColor,),
        SizedBox(width: 8,),
        FittedBox(fit: BoxFit.scaleDown, child: Text(strings.get(269), /// Chat with provider
          style: theme.style13W400,)),
      ],
    )));
    list.add(SizedBox(height: 20,),);

    if (_mainModel.currentProvider.descTitle.isNotEmpty)
      list.add(Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          color: (theme.darkMode) ? Colors.black : Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(getTextByLocale(_mainModel.currentProvider.descTitle, strings.locale),
                style: theme.style14W800, textAlign: TextAlign.start,),   /// "Description",
              Divider(color: (theme.darkMode) ? Colors.white : Colors.black),
              SizedBox(height: 5,),
              Text(getTextByLocale(_mainModel.currentProvider.desc, strings.locale), style: theme.style12W400),
              SizedBox(height: 5,),
              // Divider(color: (darkMode) ? Colors.white : Colors.black),
            ],
          )
      ));

    list.add(SizedBox(height: 10,),);

    list.add(Container(
        color: (theme.darkMode) ? theme.blackColorTitleBkg : mainColorGray,
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(child: Text(strings.get(104), /// "Galleries",
              style: theme.style14W800,)),
          ],
        )));

    list.add(SizedBox(height: 10,));

    if (_mainModel.currentProvider.gallery.isNotEmpty)
      list.add(Container(
        margin: EdgeInsets.only(left: 20, right: 20),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _mainModel.currentProvider.gallery.map((e){
            var _tag = UniqueKey().toString();
            return InkWell(
                onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GalleryScreen(item: e, gallery: _mainModel.currentProvider.gallery,
                          tag: _tag, textDirection: strings.direction,),
                      )
                  );
                },
                child: Hero(
                    tag: _tag,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(theme.radius),
                        child: Container(
                        width: windowSize/3-20,
                        height: windowSize/3-20,
                        child: Image.network(e.serverPath, fit: BoxFit.cover)
                    ))));
          }).toList(),
        ),
      ));

    if (ifProviderHaveArticles(_mainModel.currentProvider.id)){
      list.add(SizedBox(height: 20,));
      list.add(Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 8),
          child: Row(
            children: [
              Expanded(child: Text(strings.get(264), /// "Provider products",
                style: theme.style13W800,)),
            ],
          )));
      list.add(SizedBox(height: 20,));
      list.add(articleHorizontalBar(_mainModel.currentProvider.id,
          windowWidth, context, _mainModel));
    }

    list.add(SizedBox(height: 20,));

    // services
    for (var item in product){
      if (!item.providers.contains(_mainModel.currentProvider.id))
        continue;
      list.add(Container(
        width: windowWidth,
        // height: windowWidth*0.25,
        margin: EdgeInsets.only(left: 10, right: 10),
          child: button202n2d(item, _mainModel, windowWidth, false)
      ));

      list.add(Divider(color: Colors.grey,));
    }
    list.add(SizedBox(height: 10,));

    if (reviews.isNotEmpty)
      list.add(Container(
          color: (theme.darkMode) ? theme.blackColorTitleBkg : mainColorGray,
          padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
          child: Row(children: [
              Expanded(child: Text(strings.get(105), /// "Reviews & Ratings"
                style: theme.style14W800,)),
              card51(reviewsRate, Colors.orange, 20),
              Text(reviewsRateString, style: theme.style12W400, textAlign: TextAlign.center,),
              SizedBox(width: 5,),
              Text("${reviews.length} ${strings.get(209)}",
                style: theme.style10W600Grey, textAlign: TextAlign.center,), /// ratings
            ],),
      ));

    list.add(SizedBox(height: 10,));

    for (var item in reviews){
      list.add(card47(item.userAvatar,
          item.userName,
          appSettings.getDateTimeString(item.time),
          item.text,
          item.images,
          item.rating,
          context,
          strings.direction
      ),);
      list.add(SizedBox(height: 2,));
    }

    list.add(SizedBox(height: 150,));
    return list;
  }
}

