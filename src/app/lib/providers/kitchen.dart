import 'dart:typed_data';

import 'package:dio/dio.dart';

class KitchenProvider {
  final dio = Dio();

  static const baseUrl = 'https://holyhack.breitburg.com/saus';

  Future<String> ideate(String value) async {
    final response = await dio.get(
      '$baseUrl/ideate',
      queryParameters: {'idea': value},
    );

    return response.data['description'];
  }

  Future<Uint8List> fetchImage(String description) async {
    final response = await dio.get(
      '$baseUrl/imagine',
      queryParameters: {'description': description},
      options: Options(responseType: ResponseType.bytes),
    );

    return Uint8List.fromList(response.data);
  }

  Future<List<String>> fetchSuggestions(String description) async {
    final response = await dio.get(
      '$baseUrl/suggest',
      queryParameters: {'description': description},
    );

    return List<String>.from(response.data['suggestions']);
  }

  Future<String> modifyIdeation(String description, String modifications) async {
    print('modifying ideation');
    final response = await dio.get(
      '$baseUrl/modify',
      queryParameters: {'description': description, 'modifications': modifications},
    );

    return response.data['description'];
  }
}
