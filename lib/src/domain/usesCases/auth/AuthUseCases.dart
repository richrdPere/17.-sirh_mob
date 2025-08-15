import 'package:sirh_mob/src/domain/usesCases/auth/GetUserSessionUseCase.dart';
import 'package:sirh_mob/src/domain/usesCases/auth/LoginUseCase.dart';
import 'package:sirh_mob/src/domain/usesCases/auth/RegisterUseCase.dart';
import 'package:sirh_mob/src/domain/usesCases/auth/SaveUserSessionUseCase.dart';
// import 'package:injectable/injectable.dart';

// @Injectable()
class AuthUsesCases {
  LoginUseCase login;
  RegisterUseCase register;
  SaveUserSessionUseCase saveUserSession;
  GetUserSessionUseCase getUserSession;

  AuthUsesCases({
    required this.login,
    required this.register,
    required this.saveUserSession,
    required this.getUserSession,
  });
}
