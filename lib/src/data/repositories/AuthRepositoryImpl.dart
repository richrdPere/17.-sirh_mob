 // Inject from App Module
import 'dart:convert';

import 'package:sirh_mob/src/data/datasource/local/SharedPref.dart';
import 'package:sirh_mob/src/data/datasource/remote/services/AuthService.dart';

// Dominio
import 'package:sirh_mob/src/domain/models/AuthResponse.dart';
import 'package:sirh_mob/src/domain/models/UserModel.dart';
import 'package:sirh_mob/src/domain/repositories/AuthRepository.dart';
import 'package:sirh_mob/src/domain/utils/Resource.dart';

// import 'package:injectable/injectable.dart';

// @Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthService _authService;
  SharedPref sharedPref;

  AuthRepositoryImpl(this._authService, this.sharedPref);

  @override
  Future<Resource<AuthResponse>> login(String username, String password) {
    return _authService.login(username, password);
  }

  @override
  Future<Resource<AuthResponse>> register(UserModel sereno) {
    return _authService.register(sereno);
  }

  @override
  Future<AuthResponse?> getUserSession() async {
    final data = await sharedPref.read('user');
    // print("=======================");
    // print("DATA: ${data.runtimeType}");
    // print("=======================");
    if (data != null){
      // final decoded = jsonDecode(data); // Convierte String JSON → Map
      AuthResponse authResponse = AuthResponse.fromJson(data);
      return authResponse;
    }
    return null;
  }

  @override
  Future<void> saveUserSession(AuthResponse authResponse) async {
    sharedPref.save('username', authResponse.username);
  }
}
