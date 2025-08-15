import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sirh_mob/src/domain/models/AuthResponse.dart';
import 'package:sirh_mob/src/domain/usesCases/auth/AuthUseCases.dart';
import 'package:sirh_mob/src/presentation/roles/bloc/RolesEvent.dart';
import 'package:sirh_mob/src/presentation/roles/bloc/RolesState.dart';

class RolesBloc extends Bloc<RolesEvent, RolesState> {
  AuthUsesCases authUsesCases;

  RolesBloc(this.authUsesCases) : super(RolesState()) {
    on<GetRolesList>(_onGetRolesList);
  }

  Future<void> _onGetRolesList(
    GetRolesList event,
    Emitter<RolesState> emit,
  ) async {
    AuthResponse? authResponse = await authUsesCases.getUserSession.run();

    emit(
      state.copyWith(
        // roles: authResponse?.user.roles
        roles: authResponse?.roles
      )
    );
  }
}
