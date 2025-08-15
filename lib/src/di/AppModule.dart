import 'package:injectable/injectable.dart';
import 'package:sirh_mob/src/data/datasource/local/SharedPref.dart';

// Data y Domain
import 'package:sirh_mob/src/data/repositories/AuthRepositoryImpl.dart';
import 'package:sirh_mob/src/domain/repositories/AuthRepository.dart';
import 'package:sirh_mob/src/domain/usesCases/auth/AuthUseCases.dart';
import 'package:sirh_mob/src/domain/usesCases/auth/GetUserSessionUseCase.dart';
import 'package:sirh_mob/src/domain/usesCases/auth/LoginUseCase.dart';
import 'package:sirh_mob/src/domain/usesCases/auth/RegisterUseCase.dart';

// Services
import 'package:sirh_mob/src/data/datasource/remote/services/AuthService.dart';
import 'package:sirh_mob/src/domain/usesCases/auth/SaveUserSessionUseCase.dart';

@module
abstract class AppModule {
  // @injectable
  // SharedPref get SharedPref => SharedPref();
  @injectable
  AuthService get authService => AuthService();

  @injectable
  SharedPref get sharedPref => SharedPref();

  @injectable
  AuthRepository get authRepository =>
      AuthRepositoryImpl(authService, sharedPref);

  @injectable
  AuthUsesCases get authUseCases => AuthUsesCases(
    login: LoginUseCase(authRepository),
    register: RegisterUseCase(authRepository),
    saveUserSession: SaveUserSessionUseCase(authRepository),
    getUserSession: GetUserSessionUseCase(authRepository),
  );
}
