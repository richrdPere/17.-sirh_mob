import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sirh_mob/src/presentation/dashboard/bloc/MCuscoEvent.dart';
import 'package:sirh_mob/src/presentation/dashboard/bloc/MCuscoState.dart';

class MCuscoBloc extends Bloc<MCuscoEvent, MCuscoState> {
  MCuscoBloc() : super(MCuscoState()) {
    on<ChangeDrawerPage>((event, emit) {
      emit(state.copyWith(pageIndex: event.pageIndex));
    });
  }
}
