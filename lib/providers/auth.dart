import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/http_exception.dart';

class Auth with ChangeNotifier {
  String _token = '';
  DateTime _expiryDate = DateTime.now();
  String _userId = '';

  Future _authenticate(String email, String password, String urlSegment) async {
    final url = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyAoD5HL-opp17whYX9gsspN4VD9Hig0ooE');
    try {
      final res = await http.post(url, body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true
      }));
      final resData = json.decode(res.body);
      if (resData['error'] != null) {
        throw HttpException(resData['error']['message']);
      }
    } catch (error) {
      throw error;
    }
  }

  Future signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }
}