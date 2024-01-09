import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/ui/search.dart';
import 'package:ondemandservice/widgets/address.dart';
import 'package:ondemandservice/widgets/buttons/button202m.dart';
import 'package:ondemandservice/widgets/buttons/button202n.dart';
import 'package:abg_utils/abg_utils.dart';
import 'package:ondemandservice/widgets/buttons/button202n2d.dart';
import 'package:provider/provider.dart';
import 'horizontal_articles.dart';
import 'strings.dart';
import 'theme.dart';

double _scrollPosition = 0;

class HomeScreen extends StatefulWidget {
  final Function(String) callback;
  final Function(ProductData item) openDialogService;
  const HomeScreen({Key? key, required this.callback,
    required this.openDialogService}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin{

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  final _controllerSearch = TextEditingController();
  String _searchText = "";
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey _keySearch = GlobalKey();
  final _controllerScroll = ScrollController(initialScrollOffset: _scrollPosition);
  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    _controllerScroll.addListener((){
      _scrollPosition = _controllerScroll.position.pixels;
    });
    super.initState();
  }

  _init() async {
    _waits(true);
    var ret = await _mainModel.init2();
    _redraw();
    if (ret != null)
      messageError(context, ret);
    _waits(false);
    ret = await loadBlog(true);
    if (ret != null)
      messageError(context, ret);
    _redraw();
  }

  @override
  void dispose() {
    _controllerSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);
    return Scaffold(
      backgroundColor: theme.darkMode ? Colors.black : mainColorGray,
      body: Directionality(
      textDirection: strings.direction,
    child: Stack(
          children: [

            if (_mainModel.searchActivate)
              SearchScreen(
                close: () {
                _mainModel.searchActivate = false;
                _redraw();
              },
              ),
            if (!_mainModel.searchActivate)
              Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: RefreshIndicator(
                      key: _refreshIndicatorKey,
                      onRefresh: () async{
                        _init();
                      },
                      child: ListView(
                        controller: _controllerScroll,
                        padding: EdgeInsets.only(top: 0),
                        children: _body(),
                      )
                  )),
                if (_wait)
                  Center(child: Container(child: Loader7(color: theme.mainColor,))),
          ]),
    ));
  }

  _body(){
    List<Widget> list = [];

    list.add(SizedBox(height: 10,));

    if (_searchText.isEmpty)
      list.add(Row(
        children: [
          Expanded(
          flex: 2,
          child: comboBoxAddress(_mainModel)),
          Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      alignment: Alignment.topRight,
                      child: IconButton(onPressed: (){
                        widget.callback("chat");
                      },
                          icon: Container(
                              child: Stack(
                                children: [
                                  Icon(Icons.chat, color: Colors.grey, size: 30,),
                                  if (unreadMessagesInChat != 0)
                                  Container(
                                    margin: EdgeInsets.only(left: 3, right: 3),
                                    alignment: Alignment.topRight,
                                    child: Container(
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(unreadMessagesInChat.toString(), style: theme.style10W400White,),
                                    ),
                                  )
                                ],
                              )))
                  ),
                  Container(
                      alignment: Alignment.topRight,
                      child: IconButton(onPressed: (){
                        widget.callback("notify");
                      },
                          icon: Container(
                              child: Stack(
                                children: [
                                  Icon(Icons.notifications, color: Colors.grey, size: 30,),
                                  if (getNumberOfUnreadMessages() != 0)
                                  Container(
                                    margin: EdgeInsets.only(left: 3, right: 3),
                                    alignment: Alignment.topRight,
                                    child: Container(
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(getNumberOfUnreadMessages().toString(),
                                        style: theme.style10W400White,),
                                    ),
                                  )
                                ],
                              )))
                  )

                ],
              )
          ),

        ],
      ));

    //
    // search
    //
    list.add(Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Row(
        children: [
          Expanded(child: Edit26(
              keyForEdit: _keySearch,
              // focusNode : _myFocusNode,
              hint: strings.get(24), /// "Search",
              color: (theme.darkMode) ? Colors.black : Colors.white,
              style: theme.style14W400,
              decor: decor,
              useAlpha: false,
              icon: Icons.search,
              suffixIcon: Icons.cancel,
              controller: _controllerSearch,
              onTap: (){
                _mainModel.searchActivate = true;
              },
              onChangeText: (String val){
                _searchText = val;
                _redraw();

              },
              onSuffixIconPress: (){
                _searchText = "";
                _controllerSearch.text = "";
                _redraw();
              }
          )),
          // IconButton(onPressed: (){
          //   filterType = _tabController.index+1;
          //   initialFilter(_mainModel);
          //   _mainModel.openDialog("filter");
          // }, icon: Icon(Icons.filter_alt, color: theme.mainColor,))
        ],
      )),
    );
    list.add(SizedBox(height: 10,));

    // if (_searchText.isNotEmpty){
      // WidgetsBinding.instance!.addPostFrameCallback((_) {
      //   _myFocusNode.requestFocus();
      // });
    //   _searchWindow(list);
    //   return list;
    // }

    //
    // banner
    //
    if (banners.isNotEmpty)
      list.add(Center(child: IBanner(
        banners,
        width: windowWidth,
        height: windowWidth*0.3,
        colorActive: theme.mainColor,
        colorProgressBar: theme.mainColor,
        radius: theme.radius,
        shadow: 0,
        callback: _openBanner,
        seconds: 4,
      )));
    list.add(SizedBox(height: 10,));

    // categories
    list.add(Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Row(
      children: [
        Expanded(child: Text(strings.get(25), style: theme.style14W800,)), /// "Categories",
        button134(strings.get(26), (){
          route("category_all");
        }, style: theme.style14W800MainColor) /// "View all",
      ],
    )));
    list.add(SizedBox(height: 10,));
    list.add(Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        child: _horizontalCategories()));

    // categories details
    for (var item in categories) {
      var t = _horizontalCategoryDetails(item);
      if (t != null){
        list.add(Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: [
                Expanded(child: Text(getTextByLocale(item.name, strings.locale), style: theme.style14W800,)),
                button134(strings.get(26), (){
                  _mainModel.currentCategory = item;
                  widget.callback("services");
                }, style: theme.style14W800MainColor) /// "View all",
              ],
            ))
        );
        list.add(SizedBox(height: 10,));
        list.add(t);
        list.add(SizedBox(height: 10,));
      }
    }

    //
    // related products
    //
    // if (item == "related_products"){
      list.add(Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 0),
          child: Row(
            children: [
              Expanded(child: Text(strings.get(257), /// "Related products",
                style: theme.style13W800,)),
            ],
          )));
      list.add(SizedBox(height: 20,));
      list.add(articleHorizontalBar("root", windowWidth, context, _mainModel));
    // }

    // blog
    if (blog.isNotEmpty) {
      list.add(Container(
          margin: EdgeInsets.only(left: 20, right: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(strings.get(252), style: theme.style14W800,)), /// "Blog",
                  button134(strings.get(26), (){
                  route("blog_all");
              }, style: theme.style14W800MainColor) /// "View all",
            ],
          )));
      _addBlog(list);
      list.add(SizedBox(height: 10,));
    }

    // Top Rating
    Widget? _topRating = _horizontalTopFavoritesDetails(_mainModel.topRating, false);
    if (_topRating != null){
      list.add(Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          child: Row(
            children: [
              Expanded(child: Text(strings.get(27), style: theme.style14W800,)), /// Top Rating
              button134(strings.get(26), (){
                _mainModel.showTopRating = true;
                _mainModel.currentCategory = CategoryData.createEmpty();
                _mainModel.currentCategory.name = [StringData(code: strings.locale, text: strings.get(27))]; /// Top Rating
                widget.callback("services");
              }, style: theme.style14W800MainColor) /// "View all",
            ],
          ))
      );
      list.add(SizedBox(height: 10,));
      list.add(_topRating);
      list.add(SizedBox(height: 10,));
    }

    // trends
    Widget? _topTrends = _horizontalTopFavoritesDetails(product, true);
    if (_topTrends != null){
      list.add(Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          child: Row(
            children: [
              Expanded(child: Text(strings.get(28), style: theme.style14W800,)), /// Top Trends
              button134(strings.get(26), (){
                _mainModel.showTopTrends = true;
                _mainModel.currentCategory = CategoryData.createEmpty();
                _mainModel.currentCategory.name = [StringData(code: strings.locale, text: strings.get(28))]; /// Top Trends
                widget.callback("services");
              }, style: theme.style14W800MainColor) /// "View all",
            ],
          ))
      );
      list.add(SizedBox(height: 10,));
      list.add(_topTrends);
      list.add(SizedBox(height: 10,));
    }

    // providers
    list.add(Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        child: Row(
          children: [
            Expanded(child: Text(strings.get(29), style: theme.style14W800,)), /// Providers
            button134(strings.get(26), (){
              widget.callback("providers_all");
            }, style: theme.style14W800MainColor) /// "View all",
          ],
        ))
    );
    list.add(SizedBox(height: 10,));
    for (var item in providers){
      list.add(Container(
        color: (theme.darkMode) ? Colors.black : Colors.white,
        padding: EdgeInsets.only(bottom: 5, top: 5),
          child: RepaintBoundary(
              key: item.dataKey,
              child: button202m(item, _mainModel, windowSize*0.26)
      )));
      list.add(SizedBox(height: 1,));
    }
    list.add(SizedBox(height: 150,));
    return list;
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

  _horizontalCategories(){
    List<Widget> list = [];
    for (var item in categories){
      if (item.parent.isNotEmpty)
        continue;
      list.add(InkWell(
        onTap: (){
          _mainModel.currentCategory = item;
          widget.callback("services");
        },
          child: Stack(
        children: [
          Column(
            children: [
              ClipRRect(
              borderRadius: BorderRadius.circular(5),
                child: Container(
                  color: theme.darkMode ? Colors.black : Colors.white,
                width: appSettings.customerCategoryImageSize,
                height: appSettings.customerCategoryImageSize,
                child: showImage(item.serverPath, fit: BoxFit.cover))),
              SizedBox(height: 8),
              Container(
                width: 65,
                  child: Text(getTextByLocale(item.name, strings.locale), style: theme.style11W600,
                    textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,))
            ],
          )
        ],
      )));
      list.add(SizedBox(width: 10,));
    }
    return Container(
      height: appSettings.customerCategoryImageSize+50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: list,
      ),
    );
  }

  Widget? _horizontalCategoryDetails(CategoryData category){
    List<Widget> list = [];
    list.add(SizedBox(width: 10,));
    int _count = 0;
    for (var item in product){
      if (!item.category.contains(category.id))
        continue;
      list.add(button202n(item, _mainModel, windowSize*0.33));
      list.add(SizedBox(width: 10,));
      _count++;
      if (_count == 10)
        break;
    }
    if (_count == 0)
      return null;
    return Container(
      height: windowSize*0.4,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: list,
      ),
    );
  }

  Widget? _horizontalTopFavoritesDetails(List<ProductData> service, bool topTrends){
    List<Widget> list = [];
    list.add(SizedBox(width: 10,));
    bool _found = false;
    for (var item in service){
      if (topTrends)
        if (!appSettings.inMainScreenServices.contains(item.id))
          continue;
      list.add(Stack(
        children: [
          button202n2d(item, _mainModel, windowWidth*0.9, true)
        ]
      ));
      list.add(SizedBox(width: 10,));
      _found = true;
    }
    if (!_found)
      return null;
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: list,
        )
    );

    //   Container(
    //   // height: windowSize*0.23,
    //   child: Column(
    //     mainAxisSize: MainAxisSize.min,
    //     // scrollDirection: Axis.horizontal,
    //     children: list,
    //   ),
    // );
  }

  // _searchWindow(List<Widget> list){
  //   list.add(Container(
  //     color: (theme.darkMode) ? Colors.black : Colors.white,
  //       child: TabBar(
  //     labelColor: Colors.black,
  //     tabs: [
  //       Text(strings.get(31), textAlign: TextAlign.center, style: theme.style12W800), /// "Service",
  //       Text(strings.get(32), textAlign: TextAlign.center, style: theme.style12W800), /// "Provider",
  //     ],
  //     controller: _tabController,
  //   )));
  //   list.add(Container(
  //     height: windowHeight,
  //     width: windowWidth,
  //     color: (theme.darkMode) ? Colors.black : Colors.white,
  //     child: TabBarView(
  //       controller: _tabController,
  //       children: <Widget>[
  //         _tabService(),
  //         _tabProvider(),
  //       ],
  //     ),
  //   ));
  //   list.add(SizedBox(height: 30,));
  // }

  // _tabService(){
  //   List<Widget> list = [];
  //   list.add(SizedBox(height: 10,));
  //
  //   int _count = 0;
  //   for (var item in _mainModel.serviceSearch){
  //     if (!getTextByLocale(item.name, strings.locale).toUpperCase().contains(_searchText.toUpperCase()))
  //       continue;
  //     list.add(
  //       Container(
  //         margin: EdgeInsets.only(left: 10, right: 10),
  //           child: Stack(
  //         children: [
  //           button202n2d(item, _mainModel, windowWidth, true)
  //         ]
  //     )));
  //     list.add(SizedBox(height: 10,));
  //     _count++;
  //   }
  //
  //   if (_count == 0){
  //     list.add(SizedBox(height: 100,));
  //     list.add(Container(
  //         width: windowWidth*0.5,
  //         height: windowWidth*0.5,
  //         child: Image.asset("assets/notfound.png", fit: BoxFit.contain)
  //     ));
  //     list.add(SizedBox(height: 50,));
  //     list.add(Center(child: Text(strings.get(86), /// "Not found ...",
  //         style: theme.style14W800)));
  //   }
  //
  //   list.add(SizedBox(height: 150,));
  //   return ListView(
  //     children: list,
  //   );
  // }

  // _tabProvider(){
  //   List<Widget> list = [];
  //
  //   list.add(SizedBox(height: 10,));
  //   int _count = 0;
  //   for (var item in providers){
  //     if (!getTextByLocale(item.name, strings.locale).toUpperCase().contains(_searchText.toUpperCase()))
  //       continue;
  //     list.add(Container(
  //         color: (theme.darkMode) ? Colors.black : Colors.white,
  //         padding: EdgeInsets.only(bottom: 5, top: 5),
  //         child: button202m(item, _mainModel, windowWidth*0.26)
  //     ));
  //     list.add(SizedBox(height: 1,));
  //     _count++;
  //   }
  //
  //   if (_count == 0){
  //     list.add(SizedBox(height: 100,));
  //     list.add(Container(
  //         width: windowWidth*0.5,
  //         height: windowWidth*0.5,
  //         child: Image.asset("assets/notfound.png", fit: BoxFit.contain)
  //     ));
  //     list.add(SizedBox(height: 50,));
  //     list.add(Center(child: Text(strings.get(86), /// "Not found ...",
  //         style: theme.style14W800)));
  //   }
  //
  //   list.add(SizedBox(height: 150,));
  //   return ListView(
  //     children: list,
  //   );
  // }

  _openBanner(String id, String heroId, String image) {
    for (var item in banners)
      if (item.id == id) {
        if (item.type == "provider") {
          for (var pr in providers)
            if (pr.id == item.open) {
              _mainModel.currentProvider = pr;
              route("provider");
              break;
            }
        }
        if (item.type == "category") {
          for (var cat in categories)
            if (cat.id == item.open) {
              //categoryScreenTag = UniqueKey().toString();
              _mainModel.currentCategory = cat;
              route("services");
              break;
            }
        }
        if (item.type == "service") {
          for (var ser in product)
            if (ser.id == item.open) {
              for (var item2 in ser.addon) {
                item2.selected = false;
                item2.needCount = 0;
              }
              _mainModel.currentService = ser;
              _mainModel.openDialog("service");
              break;
            }
        }
      }
  }

  _addBlog(List<Widget> list) {
    list.add(SizedBox(height: 10,));
    var _count = 0;
    for (var item in blog) {
      list.add(Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        child: button202Blog(item,
            (theme.darkMode) ? Colors.black : Colors.white,
            windowWidth, windowWidth * 0.35, () {
              _mainModel.openBlog = item;
              route("blog_details");
            }),
      )
      );
      list.add(SizedBox(height: 10,));
      _count++;
      if (_count == 3)
        break;
    }
  }
}
