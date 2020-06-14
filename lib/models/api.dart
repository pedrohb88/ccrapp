import 'package:http/http.dart' as http;
import 'dart:convert';

class Api {

  String url = 'https://paradasegura-api.herokuapp.com';

  Future<Map<String, dynamic>> get({route, headers}) async{

    var response = await http.get('$url$route', headers:headers);

    if(response.statusCode != 200) return null;

    return {
      "body": JsonDecoder().convert(response.body),
      "headers": response.headers
    };
  }

  Future<Map<String, dynamic>> post({route, body, headers}) async{
     var response = await http.post('$url$route', body: body, headers: headers);

     if(response.statusCode != 200) return null;

     return {
      "body": response.body.isNotEmpty ? JsonDecoder().convert(response.body):null,
      "headers": response.headers
    };
  }

  Future<Map<String, dynamic>> sendVerificationCode(email) async {

    final result = await Api().get(route: '/user/verification_code/$email');
    print(result);
    return result['body'];
  }
}