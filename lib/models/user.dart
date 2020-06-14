import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:ccrapp/models/api.dart';

class User extends ChangeNotifier {
  String name;
  String phone;
  bool isLogged = false;

  User({
    this.name,
    this.phone,
  });

  verifyCode(phone, verificationCode) async {

    final result = await Api().post(route: '/user/verifyCode', body: {
      'phone': phone,
      'verificationCode': verificationCode
    });

    if(result == null) return false;
    return true;
  }

  update({name, phone, isLogged}) {
    this.name = name;
    this.phone = phone;
    this.isLogged = isLogged;

    notifyListeners();
  }

  register({name, phone, verificationCode}) async {
    var result = await Api().post(route: '/user', body: {
      "name": name,
      "phone": phone,
      "verificationCode": verificationCode,
    });

    if (result == null) {
      return false;
    } else {
      final storage = new FlutterSecureStorage();
      await storage.write(
          key: 'auth-token', value: result['headers']['x-auth']);

      final body = result['body']['data'];
      this.update(
        isLogged: true,
        name: body['name'],
        phone: body['phone'],
      );
      return true;
    }
  }

  login(phone, verificationCode) async {
    final result = await Api().post(
        route: '/user/login',
        body: {"phone": phone, "verificationCode": verificationCode});

    if (result == null) {
      return false;
    } else {
      final storage = new FlutterSecureStorage();

      await storage.write(
          key: 'auth-token', value: result['headers']['x-auth']);

      final body = result['body'];
      this.update(
        isLogged: true,
        name: body['name'],
        phone: body['phone'],
      );
      return true;
    }
  }

  logout() async {
    //TODO: delete token from the database
    /* 
      API.deleteToken(token);
    */

    final storage = FlutterSecureStorage();
    await storage.delete(key: 'auth-token');

    this.update(isLogged: false);
  }
}
