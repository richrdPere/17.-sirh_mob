import 'package:sirh_mob/src/domain/models/AuthResponse.dart';
import 'package:sirh_mob/src/domain/repositories/AuthRepository.dart';

class SaveUserSessionUseCase {
  AuthRepository authRepository;
  SaveUserSessionUseCase(this.authRepository);

  run(AuthResponse authResponse) =>
      authRepository.saveUserSession(authResponse);
}
