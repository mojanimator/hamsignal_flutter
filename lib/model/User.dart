class User {
  String id;
  String mobile;
  String fullName;
  String email;
  String tel;
  String categories;
  bool isLawyer;
  String wallet;
  String avatar;
  bool isLogin;
  String expiredAt;
  String dateNow;
  String token;
  String lawyerNumber;
  String lawyerMelicard;
  String lawyerBirthday;
  String lawyerAddress;
  bool lawyerSex;
  String lawyerDocument;
  String cv;
  bool isExpert;
  bool isShowLawyer;
  bool isVerify;
  bool isBlock;
  String lawyerExpiredAt;
  String loginAt;
  String marketerCode;
  String cityId;

  User(
      {required this.id,
      required this.cityId,
      required this.fullName,
      required this.mobile,
      required this.email,
      required this.tel,
      required this.categories,
      required this.isLawyer,
      required this.wallet,
      required this.avatar,
      required this.isLogin,
      required this.expiredAt,
      required this.dateNow,
      required this.lawyerNumber,
      required this.lawyerMelicard,
      required this.lawyerBirthday,
      required this.lawyerAddress,
      required this.lawyerSex,
      required this.lawyerDocument,
      required this.cv,
      required this.isExpert,
      required this.isShowLawyer,
      required this.isVerify,
      required this.isBlock,
      required this.lawyerExpiredAt,
      required this.loginAt,
      required this.marketerCode,
      required this.token});

  User.fromJson(Map<String, dynamic> json)
      : id = "${json["user_id"]}",
        mobile = json["mobile"] ?? '',
        cityId = json["city_id"] != null ? "${json["city_id"]}" : '',
        fullName = json["fullname"] ?? '',
        email = json["email"] ?? '',
        tel = json["tel"] ?? '',
        categories = json["categories"] ?? '',
        isLawyer = json["is_lawyer"] != null ? json["is_lawyer"] == 1 : false,
        wallet = "${json["wallet"]}",
        avatar = json["avatar"] ?? '',
        isLogin = true,
        expiredAt = json["expired_at"] ?? '',
        dateNow = json["date_now"] ?? '',
        token = json["auth_header"] ?? '',
        lawyerNumber = json["lawyer_number"] ?? '',
        lawyerMelicard = json["lawyer_melicard"] ?? '',
        lawyerBirthday = json["lawyer_birthday"] ?? '',
        lawyerAddress = json["lawyer_address"] ?? '',
        lawyerSex =
            json["lawyer_sex"] != null ? json["lawyer_sex"] == 1 : false,
        lawyerDocument = json["lawyer_document"] ?? '',
        cv = json["cv"] ?? '',
        isExpert = json["is_expert"] != null ? json["is_expert"] == 1 : false,
        isShowLawyer = json["is_show_lawyer"] != null
            ? json["is_show_lawyer"] == 1
            : false,
        isVerify = json["is_verify"] != null ? json["is_verify"] == 1 : false,
        isBlock = json["is_block"] != null ? json["is_block"] == 1 : false,
        lawyerExpiredAt = json["lawyer_expired_at"] ?? '',
        loginAt = json["login_at"] ?? '',
        marketerCode = json[" marketer_code"] ?? '';

  User.nullUser()
      : id = '',
        cityId = '',
        fullName = '',
        mobile = '',
        email = '',
        tel = '',
        categories = '',
        isLawyer = false,
        wallet = '0',
        avatar = '',
        isLogin = false,
        expiredAt = '',
        dateNow = '',
        lawyerNumber = '',
        lawyerMelicard = '',
        lawyerBirthday = '',
        lawyerAddress = '',
        lawyerSex = false,
        lawyerDocument = '',
        cv = '',
        isExpert = false,
        isShowLawyer = false,
        isVerify = false,
        isBlock = false,
        lawyerExpiredAt = '',
        loginAt = '',
        marketerCode = '',
        token = '';
}
