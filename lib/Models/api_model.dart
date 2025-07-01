class BarcodeModel{
  String? images;
  String? description;
  String? productName;

  BarcodeModel({
    required this.description,
    required this.productName,
    required this.images,
});

  factory BarcodeModel.fromJSON(final Map<String,dynamic>map){
    return BarcodeModel(
    description: map["description"],
        productName: map["title"],
        images: map["images"],
    );
  }
}