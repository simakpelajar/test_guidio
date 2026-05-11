import 'package:bloc/bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeState.initial()) {
    on<ToggleStreaming>(_onToggle);
  }

  void _onToggle(ToggleStreaming event, Emitter<HomeState> emit) {
    emit(state.copyWith(streaming: !state.streaming));
  }
}
