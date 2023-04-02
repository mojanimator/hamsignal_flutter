class ProductItem {
  String id;

  String value;
  String name;
  bool consumable;
  String price;

  // final String icon;
  // final bool consumable;
  // SkuDetails? skuDetails;
  // PurchaseInfo? purchaseInfo;

  ProductItem(
      {required this.id,
      required this.name,
      required this.value,
      required this.consumable,
      required this.price});
}
