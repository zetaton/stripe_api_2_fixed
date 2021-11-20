import '../model/stripe_json_model.dart';

class Address extends StripeJsonModel {
  static const String fieldCity = "city";

  /* 2 Character Country Code */
  static const String fieldCountry = "country";
  static const String fieldLine1 = "line1";
  static const String fieldLine2 = "line2";
  static const String fieldPostalCode = "postal_code";
  static const String fieldState = "state";

  String? city;
  String? country;
  String? line1;
  String? line2;
  String? postalCode;
  String? state;

  Address({
    this.city,
    this.country,
    this.line1,
    this.line2,
    this.postalCode,
    this.state,
  });

  Address.fromJson(Map<String, dynamic> json) {
    city = json[fieldCity];
    country = json[fieldCountry];
    line1 = json[fieldLine1];
    line2 = json[fieldLine2];
    postalCode = json[fieldPostalCode];
    state = json[fieldState];
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, Object> hashMap = {};
    hashMap[fieldCity] = city ?? "";
    hashMap[fieldCountry] = country ?? "";
    hashMap[fieldLine1] = line1 ?? "";
    hashMap[fieldLine2] = line2 ?? "";
    hashMap[fieldPostalCode] = postalCode ?? "";
    hashMap[fieldState] = state ?? "";
    return hashMap;
  }
}
