import 'dart:typed_data';

import 'package:dio/dio.dart';

class KitchenProvider {
  final dio = Dio();

  static const baseUrl = 'https://holyhack.breitburg.com';

  Future<String> ideate(String value) async {
    print('ideating');
    final response = await dio.get(
      '$baseUrl/description',
      queryParameters: {'idea': value},
    );

    return response.data['description'];
  }

  Future<Uint8List> fetchImage(String description) async {
    print('fetching image');
    final response = await dio.get(
      '$baseUrl/image',
      queryParameters: {'dish_description': description},
      options: Options(responseType: ResponseType.bytes),
    );

    return Uint8List.fromList(response.data);
  }

  Future<List<String>> fetchSuggestions(String query) async {
    print('fetching suggestions');
    final response = await dio.get(
      '$baseUrl/suggestions',
      queryParameters: {'idea': query},
    );

    return List<String>.from(response.data['suggestions']);
  }

  Future<String> modifyIdeation(String description, String modifications) async {
    print('modifying ideation');
    final response = await dio.get(
      '$baseUrl/make-modifications',
      queryParameters: {'description': description, 'modifications': modifications},
    );

    return response.data['description'];
  }
}
