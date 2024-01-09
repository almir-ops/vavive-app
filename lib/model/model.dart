import 'dart:async';
import 'package:abg_utils/abg_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/ui/theme.dart';
import '../ui/strings.dart';
import 'account.dart';
import 'lang.dart';

class MainModel with ChangeNotifier, DiagnosticableTreeMixin {

  List<LangData> appLangs = [];
  String directoryPath = "";
  CategoryData currentCategory = CategoryData.createEmpty();
  List<ProductData> topRating = [];
  List<ProductData> serviceSearch = [];
  ProductData currentService = ProductData.createEmpty();
  ProviderData currentProvider = ProviderData.createEmpty();
  List<UserData> users = [];
  bool searchActivate = false;

  //
  // Navigation
  //
  BlogData? openBlog;
  AddressData? addressData;
  PriceData currentPrice = PriceData.createEmpty();
  bool showTopRating = false;
  bool showTopTrends = false;
  late Function(String) openDialog;

  setMainWindow(Function(String) _openDialog,){
    openDialog = _openDialog;
  }

  late MainModelUserAccount account;
  late MainDataLang lang;

  Future<String?> init(BuildContext context) async {
    account = MainModelUserAccount(parent: this);
    lang = MainDataLang(parent: this);

    //
    // Settings
    //
    String? _return = await getSettingsFromFile((AppSettings _appSettings){
      appSettings = _appSettings;
    });

    loadSettings(() async {
      localSettings.setLogo(appSettings.customerLogoServer);
      localSettings.setMainColor(appSettings.customerMainColor);
      localSettings.saveFontSizePlus(appSettings.customerFontSize);
      localSettings.saveCustomerCategoryImageSize(appSettings.customerCategoryImageSize);
      theme = AppTheme(localSettings.darkMode);

      await saveSettingsToLocalFile(appSettings);
      for (var item in appSettings.customerAppElementsDisabled)
        appSettings.customerAppElements.remove(item);

      if (redrawMainWindowInitialized)
        redrawMainWindow();
    });

    var ret = await ifNeedLoadNewLanguages(appLangs, "service", (LangData _){});
    if (ret != null)
      messageError(context, ret);

    await loadLangsFromLocal(localSettings.locale, appSettings.currentServiceAppLanguage,
            (LangData item){
              strings.setLang(item.data, item.locale, context, item.direction);
          }, (List<LangData> langs){
            appLangs = langs;
        });

    notifyListeners();
    return _return;
  }

  Future<String?> init2() async {
    var ret = await loadCategory(true);
    if (ret != null)
      return ret;
    ret = await initService("all", "", (){});
    if (ret != null)
      return ret;
    product.sort((a, b) => b.rating.compareTo(a.rating));
    var index = 0;
    for (var item in product) {
      topRating.add(item);
      index++;
      if (index == 6)
        break;
    }
    loadProvider((){
      redrawMainWindow();
    });
    initProviderDistances();
    redrawMainWindow();
    ret = await loadBanners();
    if (ret != null)
      return ret;
    redrawMainWindow();
    ret = await loadArticleCache(true);
    if (ret != null)
      return ret;
    ret = await loadOffers();
    if (ret != null)
      return ret;

    notifyListeners();
    return null;
  }

  Future<String?> finish(String paymentMethod) async{
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null)
      return "user == null";
    if (appSettings.statuses.isEmpty)
      return "statuses.isEmpty";
    bool cachePayment = false;
    if (paymentMethod == strings.get(81)) /// "Cash payment",
      cachePayment = true;

    String? ret = await finishCartV4(false, paymentMethod, cachePayment,
        strings.get(184), /// "From user:",
        strings.get(185) /// "New Booking was arrived",
    );

    if (ret != null)
      return ret;

    return null;
  }

  String getServiceCategoriesString(List<String> val){
    String ret = "";
    for (var item in val) {
      for (var item2 in categories)
        if (item == item2.id) {
          if (ret.isNotEmpty)
            ret = "$ret, ";
          ret = "$ret ${getTextByLocale(item2.name, strings.locale)}";
          break;
        }
    }
    return ret;
  }
}

