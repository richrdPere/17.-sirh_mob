import 'package:sirh_mob/src/domain/repositories/AuthRepository.dart';

class GetUserSessionUseCase {
  AuthRepository authRepository;
  GetUserSessionUseCase(this.authRepository);

  run() => authRepository.getUserSession();
}
