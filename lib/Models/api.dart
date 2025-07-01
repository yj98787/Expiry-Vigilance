import 'dart:convert';
import 'package:http/http.dart' as http;

/*
Future<Map<String, String?>> fetchProductInfo(String barcode) async {
  final apiKey = 'amtnkvt1b0g14fbez80rhaj8mtiw85';
  final url = Uri.parse('https://api.barcodelookup.com/v3/products?barcode=$barcode&formatted=y&key=$apiKey');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final product = data['products'][0];

    return {
      "name": product['product_name'],
      "image": product['images'].isNotEmpty ? product['images'][0] : null,
    };
  } else {
    throw Exception('Failed to load product data');
  }
}
 */

class API{

  static Future<Map<String, String?>> fetchProductInfo(String barcode) async {
    final apiKey = 'amtnkvt1b0g14fbez80rhaj8mtiw85';
    final url = Uri.parse('https://api.barcodelookup.com/v3/products?barcode=$barcode&formatted=y&key=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final product = data['products'][0];

      return {
        "name": product['title'],
        "image": product['images'].isNotEmpty ? product['images'][0] : null,
        "description": product['description'],
      };
    } else {
      throw Exception('Failed to load product data');
    }
  }
}
