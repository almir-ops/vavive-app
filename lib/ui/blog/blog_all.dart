import 'package:abg_utils/abg_utils.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import '../strings.dart';
import '../theme.dart';
import 'package:provider/provider.dart';

class BlogAllScreen extends StatefulWidget {

  @override
  _BlogAllScreenState createState() => _BlogAllScreenState();
}

class _BlogAllScreenState extends State<BlogAllScreen> {

  double windowWidth = 0;
  double windowHeight = 0;
  final _controllerSearch = TextEditingController();
  late MainModel _mainModel;
  bool _loadAdditionData = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _controllerSearch.dispose();
    super.dispose();
  }

  _scrollListener() async {
    var _scrollPosition = _scrollController.position.pixels;
    if (_scrollPosition > _scrollController.position.maxScrollExtent/3){
      _loadAdditionData = true;
      _redraw();
      await loadBlog(false);
      _loadAdditionData = false;
      _redraw();
    }
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
    return Scaffold(
        backgroundColor: theme.darkMode ? Colors.black : mainColorGray,
      body: Directionality(
      textDirection: strings.direction,
    child: Stack(
          children: [
            Container(
                width: windowWidth,
                height: windowHeight,
                child: _body(),
              ),

            appbar1(Colors.transparent, (theme.darkMode) ? Colors.white : Colors.black,
                strings.get(252), context, () {goBack();})  /// "Blog",

          ]),
      ));
  }

  _body(){
    List<Widget> list = [];

    list.add(SizedBox(height: 80,));

    for (var item in blog){
      list.add(Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        child: button202Blog(item,
            (theme.darkMode) ? Colors.black : Colors.white,
            windowWidth, windowWidth*0.35, (){
              _mainModel.openBlog = item;
              route("blog_details");
            }),
      )
      );
      list.add(SizedBox(height: 10,));
    }

    if (_loadAdditionData){
      list.add(SizedBox(height: 10,));
      list.add(Center(child: Loader7v1(color: theme.mainColor)));
      list.add(SizedBox(height: 10,));
      list.add(Center(child: Text(strings.get(253),))); /// Loading ...
    }

    list.add(SizedBox(height: 150,));
    return ListView(
      controller: _scrollController,
      padding: EdgeInsets.only(top: 0),
      children: list,
    );
  }
}
