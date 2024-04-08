import 'package:dio/dio.dart';
import 'package:shapmanpaypoint/utils/Getters/base_url.dart';
import 'package:shapmanpaypoint/utils/flutter_storage/flutter_storage.dart';

class CsrfService {
  static BaseOptions options = BaseOptions(
    baseUrl: Constants.base_url,
    connectTimeout: const Duration(minutes: 3),
    receiveTimeout: const Duration(minutes: 3),
  );
  final Dio dio = Dio(options);
  final SecureStorage stora = SecureStorage();
  Future<Response<dynamic>> get() async {
// Obtain shared preferences.
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final response = await dio.get('/ctoken', options: Options());
      // print(options);
      // print("HELLO ${response.data['success']}");
      // final List<dynamic> resData = [];
      if (response.data.containsKey('success')) {
        // print("HI");
        await stora.writeSecureData("X-csrf", response.data['message']);
      } else {
        print('NAN');
      }
      return response;
    } catch (error) {
      rethrow;
    }
  }
}
