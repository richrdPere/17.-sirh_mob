import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sirh_mob/src/presentation/roles/RolesItem.dart';
import 'package:sirh_mob/src/presentation/roles/bloc/RolesBloc.dart';
import 'package:sirh_mob/src/presentation/roles/bloc/RolesState.dart';

class RolesPage extends StatefulWidget {
  const RolesPage({super.key});

  @override
  State<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends State<RolesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<RolesBloc, RolesState>(
        builder: (context, state) {
          // return ListView(children: state.roles.map((Role role) => null),
          return ListView(
            children:
                (state.roles?.map((String? role) {
                      return role != null ? RolesItem(role): Container();
                    }).toList())
                    as List<Widget>,
          );
        },
      ),
    );
  }
}
