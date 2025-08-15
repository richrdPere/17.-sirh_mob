import 'package:sirh_mob/src/domain/models/UserModel.dart';
import 'package:sirh_mob/src/domain/repositories/AuthRepository.dart';

class RegisterUseCase {
  AuthRepository authRepository;

  RegisterUseCase(this.authRepository);

  run(UserModel sereno) => authRepository.register(sereno);
}
