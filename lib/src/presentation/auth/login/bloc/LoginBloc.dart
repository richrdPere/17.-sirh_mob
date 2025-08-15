import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

// Services y Caso de uso
// import 'package:app_sistema_de_patrullaje/src/data/dataSource/remote/services/AuthService.dart';
import 'package:sirh_mob/src/domain/models/AuthResponse.dart';
import 'package:sirh_mob/src/domain/usesCases/auth/AuthUseCases.dart';

// Models
import 'package:sirh_mob/src/domain/utils/Resource.dart';

// Bloc
import 'package:sirh_mob/src/presentation/auth/login/bloc/LoginEvent.dart';
import 'package:sirh_mob/src/presentation/auth/login/bloc/LoginState.dart';
import 'package:sirh_mob/src/presentation/utils/BlocFormItem.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  AuthUsesCases authUsesCases;

  LoginBloc(this.authUsesCases) : super(LoginState()) {
    on<InitEvent>(_onInitEvent);
    on<UsernameChanged>(_onUsernameChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<LoginSubmit>(_onLoginSubmit);
    on<LoginFormReset>(_onLoginFormReset);
    on<LoginSaveUserSession>(_onLoginSaveUserSession);
  }

  final formKey = GlobalKey<FormState>();

  // FUNCIONES

  Future<void> _onInitEvent(InitEvent event, Emitter<LoginState> emit) async {
    AuthResponse? authResponse = await authUsesCases.getUserSession.run();
    print('USUARIO DE SESION:  ${authResponse?.toJson()}');
    emit(state.copyWith(formKey: formKey));

    // Usuario Inicio sesion
    if (authResponse != null) {
      emit(
        state.copyWith(
          response: Success(authResponse), // AuthResponse -> user, token
          formKey: formKey,
        ),
      );
    }
    // Usuario no inicio sesion
  }

  Future<void> _onLoginSaveUserSession(
    LoginSaveUserSession event,
    Emitter<LoginState> emit,
  ) async {
    await authUsesCases.saveUserSession.run(event.authResponse);
  }

  Future<void> _onLoginFormReset(
    LoginFormReset event,
    Emitter<LoginState> emit,
  ) async {
    state.formKey?.currentState?.reset();
  }

  Future<void> _onUsernameChanged(
    UsernameChanged event,
    Emitter<LoginState> emit,
  ) async {
    emit(
      state.copyWith(
        username: BlocFormItem(
          value: event.username.value,
          error: event.username.value.isNotEmpty ? null : 'Ingrese su Username',
        ),
        formKey: formKey,
      ),
    );
  }

  Future<void> _onPasswordChanged(
    PasswordChanged event,
    Emitter<LoginState> emit,
  ) async {
    emit(
      state.copyWith(
        password: BlocFormItem(
          value: event.password.value,
          error:
              event.password.value.isNotEmpty &&
                  event.password.value.length >= 5
              ? null
              : 'Ingrese su Contraseña',
        ),
        formKey: formKey,
      ),
    );
  }

  Future<void> _onLoginSubmit(
    LoginSubmit event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(response: Loading(), formKey: formKey));
    Resource<AuthResponse> response = await authUsesCases.login.run(
      state.username.value,
      state.password.value,
    );
    emit(state.copyWith(response: response, formKey: formKey));
  }
}
