import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/transformers.dart';
import 'package:sirh_mob/src/domain/models/AuthResponse.dart';

// Bloc cubit
import 'package:sirh_mob/src/presentation/auth/login/bloc/LoginBloc.dart';
import 'package:sirh_mob/src/presentation/auth/login/bloc/LoginEvent.dart';
import 'package:sirh_mob/src/presentation/auth/login/bloc/LoginState.dart';

// Router
import 'package:go_router/go_router.dart';

// Widgets
import 'package:sirh_mob/src/domain/utils/Resource.dart';
import 'package:sirh_mob/src/presentation/auth/login/LoginContent.dart';

class LoginPage extends StatefulWidget {
  static const name = 'login-page';

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Instancias
  LoginBloc? _bloc;

  @override
  void initState() {
    // SE EJECUTA UNA SOLA VEZ CUANDO SE CARGA LA PANTALLA
    super.initState();
    // WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
    //   _loginBloc?.dispose();
    // });
  }

  @override
  Widget build(BuildContext context) {
    _bloc = BlocProvider.of<LoginBloc>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        child: BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {
            final responseState = state.response;
            if (responseState is Error) {
              Fluttertoast.showToast(
                msg: responseState.error,
                toastLength: Toast.LENGTH_LONG,
              );
            } else if (responseState is Success) {
              final authResponse = responseState.data as AuthResponse;

              // _bloc?.add(LoginFormReset());
              _bloc?.add(LoginSaveUserSession(authResponse: authResponse));
              // Fluttertoast.showToast(
              //   msg: "Login Exitoso",
              //   toastLength: Toast.LENGTH_LONG,
              // );
              WidgetsBinding.instance.addPostFrameCallback((timeStamp){
                // context.go('/dashboard/home');
                // context.go('/roles');
                context.go('/muni');
              });
            }
          },
          child: BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) {
              final responseState = state.response;
              if (responseState is Loading) {
                return Stack(
                  children: [
                    LoginContent(_bloc, state),
                    Center(child: CircularProgressIndicator()),
                  ],
                );
              }
              return LoginContent(_bloc, state);
            },
          ),
        ),
      ),
    );
  }
}
