
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Resources
import 'package:sirh_mob/src/domain/utils/Resource.dart';
import 'package:sirh_mob/src/presentation/auth/register/RegisterContent.dart';

// Bloc's
import 'package:sirh_mob/src/presentation/auth/register/bloc/RegisterBloc.dart';
import 'package:sirh_mob/src/presentation/auth/register/bloc/RegisterEvent.dart';
import 'package:sirh_mob/src/presentation/auth/register/bloc/RegisterState.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  RegisterBloc? _bloc;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   _registerBlocCubit?.dispose();
    // });
  }

  @override
  Widget build(BuildContext context) {
    _bloc = BlocProvider.of<RegisterBloc>(context);

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        //color: Colors.black,
        child: BlocListener<RegisterBloc, RegisterState>(
          listener: (context, state) {
            final responseState = state.response;
            if (responseState is Error) {
              Fluttertoast.showToast(
                msg: responseState.error,
                toastLength: Toast.LENGTH_LONG,
              );
            } else if (responseState is Success) {
              _bloc?.add(RegisterFormReset());
              Fluttertoast.showToast(
                msg: "Registro Exitoso",
                toastLength: Toast.LENGTH_LONG,
              );
            }
          },
          child: BlocBuilder<RegisterBloc, RegisterState>(
            builder: (context, state) {
              return RegisterContent(_bloc, state);
            },
          ),
        ),
      ),
    );
  }
}
