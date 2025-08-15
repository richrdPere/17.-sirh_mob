import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Bloc cubit
import 'package:sirh_mob/src/presentation/auth/login/bloc/LoginBloc.dart';
import 'package:sirh_mob/src/presentation/auth/login/bloc/LoginEvent.dart';
import 'package:sirh_mob/src/presentation/auth/login/bloc/LoginState.dart';

// Model's
// import 'package:app_sistema_de_patrullaje/src/domain/utils/Resource.dart';

// Router
import 'package:go_router/go_router.dart';

// Widgets
import 'package:sirh_mob/src/presentation/utils/BlocFormItem.dart';
import 'package:sirh_mob/src/presentation/widgets/default_textfield.dart';

// ignore: must_be_immutable
class LoginContent extends StatelessWidget {
  // Instancias
  LoginBloc? bloc;

  LoginState state;

  LoginContent(this.bloc, this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: state.formKey,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background
          _imageBackground(context),

          // Title
          Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 0.3),
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon Person
                _iconPerson(),

                // Text Login
                _textLogin(),

                // Username
                _textFieldUsername(),

                // Password
                _textFieldPassword(),

                // Login
                _buttonLogin(context),

                // Don't have account
                _textDontHaveAccount(),

                // to Register
                _buttonGoToRegister(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widgets
  Widget _iconPerson() {
    // return Icon(Icons.person, color: Colors.white, size: 125);
    return Container(
      margin: const EdgeInsets.only(bottom: 60),
      child: Image.asset(
        'assets/img/logo.png',
        width: 260, // tamaño fijo, ajusta según lo necesites
        height: 120,
        fit: BoxFit.contain, // mantiene proporciones
        //color: Colors.white, // color blanco
        colorBlendMode: BlendMode.srcIn, // aplica el blanco sobre la imagen
      ),
    );
  }

  Widget _imageBackground(BuildContext context) {
    return Image.asset(
      'assets/img/background7.jpg',
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      fit: BoxFit.cover,
      color: Colors.black54,
      colorBlendMode: BlendMode.darken,
    );
  }

  Widget _textLogin() {
    return Text(
      'LOGIN',
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _textFieldUsername() {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 25),
      child: DefaultTextField(
        label: 'Username',
        icon: Icons.person,
        // errorText: snapshot.error?.toString(),
        onChanged: (text) {
          bloc?.add(UsernameChanged(username: BlocFormItem(value: text)));
        },
        validator: (value) {
          return state.username.error;
        },
      ),
    );
  }

  Widget _textFieldPassword() {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 25),
      child: DefaultTextField(
        label: 'Contraseña',
        icon: Icons.lock,
        // errorText: snapshot.error?.toString(),
        onChanged: (text) {
          bloc?.add(PasswordChanged(password: BlocFormItem(value: text)));
        },
        obscureText: true,
        validator: (value) {
          return state.password.error;
        },
      ),
    );
  }

  Widget _buttonLogin(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 55,
      margin: EdgeInsets.only(left: 25, right: 25, top: 55, bottom: 15),
      child: ElevatedButton(
        onPressed: () {
          if (state.formKey!.currentState!.validate()) {
            bloc?.add(LoginSubmit());
            // context.go('/dashboard/home');
          } else {
            Fluttertoast.showToast(
              msg: 'El formulario no es valido',
              toastLength: Toast.LENGTH_SHORT,
            );
          }
        },

        style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(73, 157, 255, 1)),
        child: Text('INICIAR SESIÓN', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _textDontHaveAccount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 65,
          height: 1,
          color: Colors.white,
          margin: EdgeInsets.only(right: 5),
        ),
        Text(
          '¿No tienes cuenta?',
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
        Container(
          width: 65,
          height: 1,
          color: Colors.white,
          margin: EdgeInsets.only(left: 5),
        ),
      ],
    );
  }

  Widget _buttonGoToRegister(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 55,
      margin: EdgeInsets.only(left: 25, right: 25, top: 15),
      child: ElevatedButton(
        onPressed: () {
          // Navigator.pushNamed(context, 'register');
          context.go('/register');
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
        child: Text('REGISTRATE', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
