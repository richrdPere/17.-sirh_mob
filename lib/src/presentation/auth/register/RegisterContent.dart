import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Router
import 'package:go_router/go_router.dart';

// Register Bloc cubit
import 'package:sirh_mob/src/presentation/auth/register/bloc/RegisterBloc.dart';
import 'package:sirh_mob/src/presentation/auth/register/bloc/RegisterEvent.dart';
import 'package:sirh_mob/src/presentation/auth/register/bloc/RegisterState.dart';

// Widgets
import 'package:sirh_mob/src/presentation/utils/BlocFormItem.dart';
import 'package:sirh_mob/src/presentation/widgets/default_IconBack.dart';
import 'package:sirh_mob/src/presentation/widgets/default_button.dart';
import 'package:sirh_mob/src/presentation/widgets/default_textfield.dart';

// ignore: must_be_immutable
class RegisterContent extends StatelessWidget {
  RegisterBloc? bloc;
  RegisterState state;

  RegisterContent(this.bloc, this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: state.formKey,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Image.asset(
          //   'assets/img/background6.jpg',
          //   width: MediaQuery.of(context).size.width,
          //   height: MediaQuery.of(context).size.height,
          //   fit: BoxFit.cover,
          //   color: Color.fromRGBO(0, 0, 0, 0.7),
          //   colorBlendMode: BlendMode.darken,
          // ),
          // Background
          _imageBackground(context),

          Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 0.3),
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Icon(Icons.person, color: Colors.white, size: 100),
                  // Icon Person
                  _iconPerson(),

                  Text(
                    'REGISTRO',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 25, right: 25),
                    child: DefaultTextField(
                      label: 'Nombres',
                      icon: Icons.person,
                      onChanged: (text) {
                        bloc?.add(
                          RegisterNameChanged(name: BlocFormItem(value: text)),
                        );
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 25, right: 25),
                    child: DefaultTextField(
                      label: 'Apellidos',
                      icon: Icons.person,
                      onChanged: (text) {
                        bloc?.add(
                          RegisterLastnameChanged(
                            lastname: BlocFormItem(value: text),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 25, right: 25),
                    child: DefaultTextField(
                      label: 'Email',
                      icon: Icons.email,
                      onChanged: (text) {
                        bloc?.add(
                          RegisterEmailChanged(
                            email: BlocFormItem(value: text),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 25, right: 25),
                    child: DefaultTextField(
                      label: 'Teléfono',
                      icon: Icons.phone,
                      onChanged: (text) {
                        bloc?.add(
                          RegisterPhoneChanged(
                            phone: BlocFormItem(value: text),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 25, right: 25),
                    child: DefaultTextField(
                      label: 'DNI',
                      icon: Icons.account_balance_sharp,
                      onChanged: (text) {
                        bloc?.add(
                          RegisterDNIChanged(dni: BlocFormItem(value: text)),
                        );
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 25, right: 25),
                    child: DefaultTextField(
                      label: 'Contraseña',
                      icon: Icons.lock,
                      obscureText: true,
                      onChanged: (text) {
                        bloc?.add(
                          RegisterPasswordChanged(
                            password: BlocFormItem(value: text),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 25, right: 25),
                    child: DefaultTextField(
                      label: 'Confirmar Contraseña',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      onChanged: (text) {
                        bloc?.add(
                          RegisterConfirmPasswordChanged(
                            confirmPassword: BlocFormItem(value: text),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 25, right: 25, top: 15),
                    child: DefaultButton(
                      text: 'REGISTRARSE',
                      color: Colors.black,
                      onPressed: () {
                        if (state.formKey!.currentState!.validate()) {
                          bloc?.add(RegisterFormSubmit());
                        } else {
                          Fluttertoast.showToast(
                            msg: 'El formulario no es valido',
                            toastLength: Toast.LENGTH_LONG,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          DefaultIconBack(left: 45, top: 135),
        ],
      ),
    );
  }

  // Widgets
  Widget _iconPerson() {
    // return Icon(Icons.person, color: Colors.white, size: 125);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Image.asset(
        'assets/img/logo.png',
        width: 260, // tamaño fijo, ajusta según lo necesites
        height: 150,
        fit: BoxFit.contain, // mantiene proporciones
        // color: Colors.white, // color blanco
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
}
