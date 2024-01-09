import 'package:abg_utils/abg_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:pay/pay.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../strings.dart';
import '../theme.dart';

class Checkout2Screen extends StatefulWidget {
  @override
  _Checkout2ScreenState createState() => _Checkout2ScreenState();
}

class _Checkout2ScreenState extends State<Checkout2Screen> with TickerProviderStateMixin{

  double windowWidth = 0;
  double windowHeight = 0;
  int paymentMethod = 1;
  // bool cachePayment = true;
  double _show = 0;
  late PriceTotalForCardData _totalPrice;
  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    super.initState();
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
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top+40, bottom: 0),
              child: ListView(
                padding: EdgeInsets.only(top: 0),
                children: _body(),
              )
          ),

          appbar1(Colors.transparent,
              (theme.darkMode) ? Colors.white : Colors.black, strings.get(162), /// "Checkout",
              context, () {goBack();}, style: theme.style14W400),

          // Container(
          //   alignment: Alignment.bottomCenter,
          //   margin: EdgeInsets.all(10),
          //   child: button2(strings.get(163), /// "Confirm order"
          //       theme.mainColor, (){
          //               _confirm();
          //             }),
          //
          //   ),

          IEasyDialog2(setPosition: (double value){_show = value;}, getPosition: () {return _show;}, color: Colors.grey,
            getBody: _getDialogBody, backgroundColor: (theme.darkMode) ? Colors.black : Colors.white,),

          if (_wait)
            Center(child: Container(child: Loader7(color: theme.mainColor,))),

        ]),
      ));
  }

  _body(){
    List<Widget> list = [];
    List<Widget> listPrices = [];

    _totalPrice = cartGetTotalForAllServices();
    tablePricesV4(list, cart,
        strings.get(93), /// "Addons"
        strings.get(153), /// "Subtotal"
        strings.get(154), /// "Discount"
        strings.get(155), /// "VAT/TAX"
        strings.get(156) /// "Total amount"
    );

    // _totalPrice = cartGetTotalForAllServices();
    var _provider = cartCurrentProvider != null ? cartCurrentProvider! : ProviderData.createEmpty();
    // if (!_provider.acceptPaymentInCash)
    //   cachePayment = false;

    list.add(Container(
      color: (theme.darkMode) ? Colors.black : Colors.white,
      child: Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10,),
          Text(strings.get(166), style: theme.style13W800,), /// "Choose payment method"
          SizedBox(height: 10,),

          // if (_provider.acceptPaymentInCash)
          // button1s4(strings.get(147), strings.get(167), /// "Cash payment", "Pay your payment after getting service",
          //     Icons.payments_outlined, cachePayment, (){
          //       cachePayment = true;
          //       _redraw();
          //     }),
          // SizedBox(height: 10,),
          // button1s4(strings.get(168), strings.get(169), /// "Digital payment", "Faster and safer way to send money",
          //     Icons.payment, !cachePayment, (){
          //       cachePayment = false;
          //       _redraw();
          //     }),

          // if (!cachePayment)
          _listPaymentsGateway(_provider),

          //
          // price
          //
          SizedBox(height: 50,),
          ...listPrices,
          SizedBox(height: 10,),

          // Row(
          //   children: [
          //     Expanded(child: Text(strings.get(154), style: theme.style13W400,)), /// "Discount"
          //     Text("(-) ${_totalPrice.discountString}", style: theme.style13W400,)
          //   ],
          // ),
          // SizedBox(height: 10,),
          // Row(
          //   children: [
          //     Expanded(child: Text(strings.get(155), style: theme.style13W400,)), /// "VAT/TAX"
          //     Text("(+) ${_totalPrice.taxString}", style: theme.style13W400,)
          //   ],
          // ),
          // SizedBox(height: 10,),
          // Divider(height: 0.5, color: Colors.grey,),
          // SizedBox(height: 10,),
          // Row(
          //   children: [
          //     Expanded(child: Text(strings.get(156), style: theme.style14W800MainColor,)), /// "Total amount"
          //     Text(_totalPrice.totalString, style: theme.style14W800MainColor,)
          //   ],
          // ),
          SizedBox(height: 10,),
        ],
      )
    )));

    list.add(SizedBox(height: 150,));
    return list;
  }

  Widget _getDialogBody(){
    var widget = CupertinoDatePicker(
        onDateTimeChanged: (DateTime picked) {
          cartSelectTime = picked;
          print(picked.toString());
          _redraw();
        },
        mode: CupertinoDatePickerMode.dateAndTime,
        use24hFormat: appSettings.timeFormat == "24h",
        initialDateTime: DateTime.now().add(Duration(minutes: 1)),
        minimumDate: DateTime.now()
    );

    return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: windowHeight*0.4,
            child: widget,
          ),
          Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              child: button2(strings.get(217), theme.mainColor, (){ /// "CONTINUE",
                _show = 0;
                _redraw();
              })),
        ]);
  }

  dec(String image, int type){
    return InkWell(
        onTap: (){
          paymentMethod = type;
          _confirm();
        },
        child: Container(
            margin: EdgeInsets.only(top: 5, bottom: 5),
            padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(strings.get(272)), /// "Pay with"
                SizedBox(width: 10,),
                Image.asset(image, height: 30,)
              ],
            ),
            decoration: BoxDecoration(
              color: (theme.darkMode) ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.6),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: Offset(1, 1),
                ),
              ],
            )
        ));
  }

  Widget _listPaymentsGateway(ProviderData _provider){
    List<Widget> list = [];

    if (_provider.acceptPaymentInCash)
      list.add(dec("assets/cache.png", 0));

    var _paymentItems = [
      PaymentItem(
        label: 'Total',
        amount: _totalPrice.total.toStringAsFixed(appSettings.digitsAfterComma),
        status: PaymentItemStatus.final_price,
      )
    ];
    if (enableGooglePay)
      list.add(GooglePayButton(
        paymentConfigurationAsset: 'payment_profile_google_pay.json',
        paymentItems: _paymentItems,
        style: theme.darkMode ? GooglePayButtonStyle.black : GooglePayButtonStyle.white,
        type: GooglePayButtonType.pay,
        height: 50,
        width: windowWidth,
        margin: const EdgeInsets.only(top: 5, bottom: 5),
        onPaymentResult: (Map<String, dynamic> result) {
          _appointment("GPay: ${result["paymentMethodData"]["description"]}");
        },
        loadingIndicator: const Center(
          child: CircularProgressIndicator(),
        ),
      ),);

    // if (enableApplePay)
    //   list.add(ApplePayButton(
    //     paymentConfigurationAsset: 'default_payment_profile_apple_pay.json',
    //     paymentItems: _paymentItems,
    //     style: ApplePayButtonStyle.black,
    //     type: ApplePayButtonType.buy,
    //     margin: const EdgeInsets.only(top: 5, bottom: 5),
    //     onPaymentResult: (Map<String, dynamic> result) {
    //       _appointment("ApplePay: ${result["paymentMethodData"]["description"]}");
    //     },
    //     loadingIndicator: const Center(
    //       child: CircularProgressIndicator(),
    //     ),
    //   ),);
    //
    // //
    // Stripe
    //
    if (appSettings.stripeEnable)
      list.add(dec("assets/stripe.png", 1));

    //
    // Razorpay
    //
    if (appSettings.razorpayEnable)
      list.add(dec("assets/razorpay.png", 2));

    //
    // Paypal
    //
    if (appSettings.paypalEnable)
      list.add(dec("assets/paypal.png", 3));

    //
    // Flutterwave
    //
    if (appSettings.flutterWaveEnable)
      list.add(dec("assets/flutterwave.png", 4));

    //
    // Paystack
    //
    if (appSettings.payStackEnable)
      list.add(dec("assets/paystack.png", 5));

    //
    // MercadoPago
    //
    if (appSettings.mercadoPagoEnable)
      list.add(dec("assets/mercadopago.png", 6));

    //
    // Instamojo
    //
    if (appSettings.instamojoEnable)
      list.add(dec("assets/instamojo.png", 7));

    //
    // Payu
    //
    if (appSettings.payUEnable)
      list.add(dec("assets/payu.png", 8));

    //
    // Paymob
    //
    if (appSettings.payMobEnable)
      list.add(dec("assets/paymob.png", 9));

    //
    //
    //
    return Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
        child: Column(
          children: list,
        ));
  }

  _confirm() async {
    String _desc = "";
    List<PriceForCardData> _prices = cartGetPriceForAllServices();
    if (_prices.isNotEmpty)
      _desc = _prices[0].name;
    double _total = _totalPrice.total * 100;
    String _totalString = _totalPrice.totalString;
    int _totalInt = _total.toInt();
    String _currencyCode = appSettings.code;
    String _userName = getCurrentAddress().name;
    // String _userAddress = _mainModel.account.getCurrentAddress().address;
    String _userPhone = getCurrentAddress().phone;
    String _userEmail = userAccountData.userEmail;
    //
    if (paymentMethod == 0)
      return _appointment(strings.get(147)); /// "Cash payment",

    if (paymentMethod == 1){      /// Stripe
      StripeMobile _stripe = StripeMobile();
      _waits(true);
      try {
        _stripe.init(appSettings.stripeKey);
        _stripe.openCheckoutCard(_totalInt, // amount
            _desc,
            _userPhone,
            strings.get(0),
            _currencyCode,
            appSettings.stripeSecretKey,
            _appointment);
      }catch(ex){
        _waits(false);
        print(ex.toString());
        messageError(context, ex.toString());
      }
    }
    if (paymentMethod == 2){      /// Razorpay
      _waits(true);
      RazorpayMobile _razorpayModel = RazorpayMobile();
      _razorpayModel.init();
      _razorpayModel.openCheckout(
          _totalInt.toString(),
          _desc,
          _userPhone,
          appSettings.razorpayName,
          _currencyCode,
          appSettings.razorpayKey,
          _appointment, (String err){messageError(context, err);}
      );
    }
    if (paymentMethod == 3){        /// payPal
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaypalPayment(
              currency: _currencyCode,
              userFirstName: _userName,
              userLastName: "",
              userEmail: _userEmail,
              payAmount: _totalString,
              secret: appSettings.paypalSecretKey,
              clientId: appSettings.paypalClientId,
              sandBoxMode: appSettings.paypalSandBox.toString(),
              onFinish: (w){
                _appointment("PayPal: $w");
              }
          ),
        ),
      );
    }
    if (paymentMethod == 4){          /// Flutterwave
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FlutterwaveMobile(
              onFinish: (String w){
                _appointment("Flutterwave: $w");
                _waits(false);
              },
            desc: _desc,
            amount: _totalPrice.total.toStringAsFixed(appSettings.digitsAfterComma),
            code: _currencyCode, // currency code
            flutterWavePublicKey: appSettings.flutterWavePublicKey,
            userName: _userName,
            userEmail: _userEmail,
            userPhone: _userPhone
          ),
        ),
      );
    }
    //
    // Paystack
    //
    if (paymentMethod == 5){
      double _total = _totalPrice.total;
      var ret = await PayStackMobile().handleCheckout(_total, _userEmail,
          context, appSettings.payStackKey);
      if (ret != null)
        _appointment(ret);
    }
    //
    // Mercadopago
    //
    if (paymentMethod == 6){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MercadoPagoMobile(
            onFinish: (String w){
              _appointment("MercadoPago: $w");
              _waits(false);
            },
            desc: _desc,
            amount: _totalPrice.total,
            accessToken: appSettings.mercadoPagoAccessToken,
            publicKey: appSettings.mercadoPagoPublicKey,
            code: appSettings.demo ? "BRL" : appSettings.code,
          ),
        ),
      );
    }
    //
    // Instamojo
    //
    if (paymentMethod == 7){
      String _total = _totalPrice.total.toStringAsFixed(appSettings.digitsAfterComma);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InstaMojoMobile(
              userName: _userName,
              email: _userEmail,
              phone: _userPhone,
              payAmount: _total,
              token: appSettings.instamojoToken, // PrivateToken
              apiKey: appSettings.instamojoApiKey, // ApiKey
              sandBoxMode: appSettings.instamojoSandBoxMode.toString(), // SandBoxMode
              onFinish: (w){
                _appointment("INSTAMOJO: $w");
              }
          ),
        ),
      );
    }
    //
    // Payu
    //
    if (paymentMethod == 8){
      String _total = _totalPrice.total.toStringAsFixed(appSettings.digitsAfterComma);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PayUMobile(
          userName: _userName,
          email: _userEmail,
          phone: _userPhone,
          payAmount: _total,
          apiKey: appSettings.payUApiKey, // ApiKey
          merchantId: appSettings.payUMerchantId,
              sandBoxMode: appSettings.payUSandBoxMode.toString(),
              onFinish: (w){
                dprint("PayU: $w");
                _appointment("PayU: $w");
              }
          ),
        ),
      );
    }
    //
    // PayMob
    //
    if (paymentMethod == 9){
      String _total = _totalPrice.total.toStringAsFixed(appSettings.digitsAfterComma);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PayMobMobile(
              userFirstName: _userName,
              userEmail: _userEmail,
              userPhone: _userPhone,
              payAmount: _total,
              apiKey: appSettings.payMobApiKey, // ApiKey
              frame: appSettings.payMobFrame, // MobFrame
              integrationId: appSettings.payMobIntegrationId, // IntegrationId
              onFinish: (w){
                dprint("PayMob: $w");
                _appointment("PayMob: $w");
              },
              code: appSettings.code,
              userName: userAccountData.userName,
              mainColor: theme.mainColor,
          ),
        ),
      );
    }
    _waits(false);
  }

  _appointment(String paymentMethod) async {
    dprint("_appointment $paymentMethod");
    waitInMainWindow(true);
    var ret = await _mainModel.finish(paymentMethod);
    waitInMainWindow(false);
    if (ret != null)
      return messageError(context, ret);
    route("confirm");
  }
}
