import 'package:equatable/equatable.dart';
import 'package:sirh_mob/src/domain/models/AuthResponse.dart';

// Utils
import 'package:sirh_mob/src/presentation/utils/BlocFormItem.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class InitEvent extends LoginEvent {
  const InitEvent();
}

// Reset campos
class LoginFormReset extends LoginEvent {
  const LoginFormReset();
}

// Login Save User Session
class LoginSaveUserSession extends LoginEvent {
  final AuthResponse authResponse;
  const LoginSaveUserSession({required this.authResponse});
  @override
  List<Object?> get props => [authResponse];
}

// Username Changed
class UsernameChanged extends LoginEvent {
  final BlocFormItem username;
  const UsernameChanged({required this.username});
  @override
  List<Object?> get props => [username];
}

// Password Changed
class PasswordChanged extends LoginEvent {
  final BlocFormItem password;
  const PasswordChanged({required this.password});
  @override
  List<Object?> get props => [password];
}

// Login Submit
class LoginSubmit extends LoginEvent {
  const LoginSubmit();
}
