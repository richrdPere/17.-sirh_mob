import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

// Models
import 'package:sirh_mob/src/domain/utils/Resource.dart';

// Utils
import 'package:sirh_mob/src/presentation/utils/BlocFormItem.dart';

// abstract class LoginState extends Equatable {}

class LoginState extends Equatable {
  final BlocFormItem username;
  final BlocFormItem password;
  final Resource? response;
  final GlobalKey<FormState>? formKey;

  const LoginState({
    this.username = const BlocFormItem(error: 'Ingresa su Username'),
    this.password = const BlocFormItem(error: 'Ingrese su Contraseña'),
    this.formKey,
    this.response
  });

  LoginState copyWith({
    BlocFormItem? username,
    BlocFormItem? password,
    Resource? response,
    GlobalKey<FormState>? formKey,
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      formKey: formKey,
      response: response
    );
  }

  @override
  List<Object?> get props => [username, password, response];
}
