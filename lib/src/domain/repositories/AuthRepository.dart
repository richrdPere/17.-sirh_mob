import 'package:sirh_mob/src/domain/utils/Resource.dart';
// Model
import 'package:sirh_mob/src/domain/models/AuthResponse.dart';
import 'package:sirh_mob/src/domain/models/UserModel.dart';

abstract class AuthRepository {
  Future<AuthResponse?> getUserSession();
  Future<void> saveUserSession(AuthResponse authResponse);
  Future<Resource<AuthResponse>> login(String username, String password);
  Future<Resource<AuthResponse>> register(UserModel user);
}
