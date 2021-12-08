class Config {
  String onboardingImage1 = 'assets/banners/shop_at_ease.svg';
  String onboardingImage2 = 'assets/banners/wide_categories.svg';
  String onboardingImage3 = 'assets/banners/easy_returns.svg';

//TODO: change below given title and subtitle as per your requirement
  String onboardingPage1Title = 'Shop at ease';
  String onboardingPage1Subtitle =
      'Just add the products to cart and have them delivered to you in 60 minutes';

  String onboardingPage2Title = 'Wide categories';
  String onboardingPage2Subtitle =
      'Select the products as per your need from our wide range of categories';

  String onboardingPage3Title = 'Easy returns';
  String onboardingPage3Subtitle =
      'Hand over the product to our delivery agent with no questions asked';

//TODO: change the currency and country prefix as per your need
  String currency = '\$';
  String countryMobileNoPrefix = "+1";

  //stripe api keys
  String apiBase = 'https://api.stripe.com';
  String currencyCode = 'inr';

  String appName = 'My Wash App';

  //dynamic link url
  String urlPrefix = 'https://mywashapp.page.link';

  String packageName = 'com.eleven11.laundry';

  List<String> reportList = [
    'Inappropriate product description',
    'Fake product',
    'Product title is misleading',
    'Product price is too high',
    'Other',
  ];

  List<String> cancelOrderReasons = [
    'Order no longer needed',
    'Order placed by mistake',
    'Wrong products ordered',
    'Product prices changed after ordering',
    'Other',
  ];

  //razorpay
  String companyName = 'b2x_codes';
  String razorpayCreateOrderIdUrl = 'RAZORPAY_FIREBASE_FUNCTION_URL';
  String razorpayKey = 'RAZORPAY_KEY';
}
