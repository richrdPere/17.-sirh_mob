import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sirh_mob/injection.dart';

// Bloc's
import 'package:sirh_mob/src/domain/usesCases/auth/AuthUseCases.dart';
import 'package:sirh_mob/src/presentation/auth/login/bloc/LoginBloc.dart';
import 'package:sirh_mob/src/presentation/auth/login/bloc/LoginEvent.dart';
import 'package:sirh_mob/src/presentation/auth/register/bloc/RegisterBloc.dart';
import 'package:sirh_mob/src/presentation/auth/register/bloc/RegisterEvent.dart';
import 'package:sirh_mob/src/presentation/dashboard/bloc/MCuscoBloc.dart';
import 'package:sirh_mob/src/presentation/roles/bloc/RolesBloc.dart';

List<BlocProvider> blocProviders = [
  BlocProvider<LoginBloc>(
    create: (BuildContext context) =>
        LoginBloc(locator<AuthUsesCases>())..add(InitEvent()),
  ),
  BlocProvider<RegisterBloc>(
    create: (BuildContext context) =>
        RegisterBloc(locator<AuthUsesCases>())..add(RegisterInitEvent()),
  ),
  BlocProvider<RolesBloc>(
    create: (BuildContext context) => RolesBloc(locator<AuthUsesCases>()),
  ),

  BlocProvider<MCuscoBloc>(create: (BuildContext context) => MCuscoBloc()),
];
