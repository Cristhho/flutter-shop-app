import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if ((_expiryDate != null && _expiryDate!.isAfter(DateTime.now()))
        && (_token != null && _token!.isNotEmpty)) {
      return _token;
    }

    return null;
  }

  String? get userId {
    return _userId;
  }

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

      _token = resData['idToken'];
      _userId = resData['localId'];
      _expiryDate = DateTime.now().add(Duration(seconds: int.parse(resData['expiresIn'])));
      _autoLogout();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate!.toIso8601String()}
      );
      await prefs.setString('userData', userData);
      notifyListeners();
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

  Future<bool> tryLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }

    final extractedData = json.decode(prefs.getString('userData')!) as Map;
    final expiryDate = DateTime.parse(extractedData['expiryDate'] as String);
    
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = extractedData['token'];
    _userId = extractedData['userId'];
    _expiryDate = expiryDate;
    _autoLogout();
    notifyListeners();
    return true;
  }

  Future logout() async {
    _token = '';
    _userId = '';
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpire = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpire), logout);
  }
}