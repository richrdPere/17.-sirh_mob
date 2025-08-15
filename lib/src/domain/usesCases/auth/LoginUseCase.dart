import 'package:injectable/injectable.dart';

// data

// domain
import 'package:sirh_mob/src/domain/repositories/AuthRepository.dart';

// @Injectable()
class LoginUseCase {

  // AuthRepository authRepository = AuthRepositoryImpl();

  AuthRepository reporitory;

  LoginUseCase(this.reporitory);

  run(String username, String password) => reporitory.login(username, password);
}