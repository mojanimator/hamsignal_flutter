import 'IAPPurchase.dart';

class Variables {
  // static String DOMAIN = "http://192.168.44.2:8000";

  static String DOMAIN = "http://172.16.6.2:8000"; //find with fing application;

  // static String DOMAIN = "https://qr-image-creator.com/hamsignal";
  static String APIDOMAIN_V1 = "${DOMAIN}/api";
  static String APIDOMAIN = "${DOMAIN}/api/v2";
  static String LINK_SEND_ERROR =
      "https://qr-image-creator.com/hamsignal/api/senderror";

  static String LINK_GET_USER_INFO = "${APIDOMAIN}/user/info";
  static String LINK_PRE_AUTH = "${APIDOMAIN}/user/preAuth";
  static String LINK_USER_FORGET_PASSWORD = "${APIDOMAIN}/user/forget";
  static String LINK_USER_LOGIN = "${APIDOMAIN}/user/login";
  static String LINK_USER_REGISTER = "${APIDOMAIN}/user/register";
  static String LINK_GET_SETTINGS = "${APIDOMAIN}/settings";

  static String NO_IMAGE_LINK = "${DOMAIN}/img/noimage.png";
  static String LINK_POLICY = "${DOMAIN}/policy";
  static String LINK_STORAGE = "${DOMAIN}/storage";
  static String LINK_NEWS_STORAGE = "${LINK_STORAGE}/news";
  static String LINK_USERS_STORAGE = "${LINK_STORAGE}/users";
  static String LINK_GET_LINKS = "${APIDOMAIN}/link/search";
  static String LINK_GET_NEWS = "${APIDOMAIN}/news/search";
  static String LINK_GET_SIGNALS = "${APIDOMAIN}/signal/search";
  static String LINK_SET_BOOKMARK = "${APIDOMAIN}/user/bookmark";
  static String LINK_TELEGRAM_CONNECT = "${APIDOMAIN}/user/telegram/connect";
  static String LINK_USER_CHANGE_PASSWORD = "${APIDOMAIN}/user/changepassword";
  static String LINK_USER_UPDATE = "${APIDOMAIN}/user/update";
  static String LINK_GET_TICKETS = "${APIDOMAIN}/ticket/search";

  static String LINK_GET_LAWYERS = "${APIDOMAIN}/lawyers";
  static String LINK_GET_LOCATIONS = "${APIDOMAIN}/location";
  static String LINK_GET_LEGALS = "${APIDOMAIN}/legal";
  static String LINK_GET_DOCUMENTS = "${APIDOMAIN}/document";
  static String LINK_GET_BOOKS = "${APIDOMAIN}/book";
  static String LINK_GET_CONTRACTS = "${APIDOMAIN}/contract";
  static String LINK_BUY_CONTRACT = "${APIDOMAIN}/contract/buy";
  static String LINK_BUY_BOOK = "${APIDOMAIN}/book/buy";
  static String LINK_GET_CATEGORIES = "${APIDOMAIN}/document/category";
  static String LINK_FINDER = "${APIDOMAIN}/finder";

  static String LINK_UPDATE_AVATAR = "${APIDOMAIN}/user/updateavatar";
  static String LINK_UPDATE_EMAIL = "${APIDOMAIN}/user/updateemail";
  static String LINK_UPDATE_PROFILE = "${APIDOMAIN}/user/update";
  static String LINK_UPDATE_PASSWORD = "${APIDOMAIN}/user/changepassword";
  static String LINK_BUY = "${APIDOMAIN}/payment/buy";
  static String LINK_GET_TRANSACTIONS =
      "${APIDOMAIN}/payment/transactions/search";
  static String LINK_MAKE_PAYMENT = "${APIDOMAIN}/payment/create";

  static String LINK_UPGRADE_PLAN = "${APIDOMAIN}/upgrade";
  static String LINK_CONFIRM_PAYMENT = "${APIDOMAIN}/payment/done";
  static String LINK_ADV_CLICK = "${APIDOMAIN}/adv/click";
  static String LINK_UPDATE_TICKET = "${APIDOMAIN}/ticket/update";
  static String LINK_CREATE_TICKET_CHAT = "${APIDOMAIN}/ticket/chat/create";

  //
  static String LINK_PLAYER = "${DOMAIN}/player";
  static String LINK_Link = "${DOMAIN}/Link";
  static String LINK_CLUB = "${DOMAIN}/club";
  static String LINK_SHOP = "${DOMAIN}/shop";
  static String LINK_PRODUCT = "${DOMAIN}/product";
  static String LINK_BLOG = "${DOMAIN}/blog";
  static String LINK_GET_LATEST = "${APIDOMAIN}/latest";
  static String LINK_GET_PLAYERS = "${APIDOMAIN}/player/search";
  static String LINK_GET_LinkES = "${APIDOMAIN}/Link/search";
  static String LINK_GET_CLUBS = "${APIDOMAIN}/club/search";
  static String LINK_GET_SHOPS = "${APIDOMAIN}/shop/search";
  static String LINK_GET_PRODUCTS = "${APIDOMAIN}/product/search";
  static String LINK_GET_EVENTS = "${APIDOMAIN}/event/search";
  static String LINK_GET_TABLES = "${APIDOMAIN}/table/search";
  static String LINK_GET_TOURNAMENTS = "${APIDOMAIN}/tournament/search";
  static String LINK_GET_USER = "${APIDOMAIN}/user/get";

  static String LINK_EDIT_LinkES = "${APIDOMAIN}/Link/edit";

  static String LINK_REMOVE_PRODUCT = "${APIDOMAIN}/product/remove";

  static String LINK_GET_ACTIVATION_CODE = "${APIDOMAIN}/getactivationcode";

  static String LINK_LOGIN = "${APIDOMAIN}/login";
  static String LINK_LOGOUT = "${APIDOMAIN}/logout";
  static String LINK_EDIT_USER = "${APIDOMAIN}/user/edit";
  static String LINK_COUPON_CALCULATE = "${APIDOMAIN}/coupon/calculate";
  static String LINK_FIND_BLOG = "${APIDOMAIN}/blog/find";

  static String LINK_CREATE_Link = "${APIDOMAIN}/Link/create";

  static String LANG = 'fa';
  static String LABEL = 'هم سیگنال';
  static String MARKET =
      IAPPurchase.MARKET; // 'playstore'; //bank,myket,bazaar,playstore
//bank,myket,bazar,playstore
}
