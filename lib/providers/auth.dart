import 'dart:convert';
import '../models/http_exception.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;


class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

  bool get isAuth{
    return _token != null;
  }
  String get token{
    if(_expiryDate!=null && _expiryDate.isAfter(DateTime.now()) && _token != null){
      return _token;
    }
    return null;
  }
 String get userId{
  return _userId;
 }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
    Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyAzCNhC8Dp3kvCLkcakdPlkdh5phE444x0');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if(responseData['error'] != null){
          throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(Duration(
          seconds: int.parse(
              responseData['expiresIn'])
      ),
      );
      notifyListeners();
    } catch (error) {
      throw error;
    }

    // print(json.decode(response.body));
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }
}

//        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/$urlSegment?key=AIzaSyAzCNhC8Dp3kvCLkcakdPlkdh5phE444x0');