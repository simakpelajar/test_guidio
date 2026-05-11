import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'name_feature_event.dart';
part 'name_feature_state.dart';

class NameFeatureBloc extends Bloc<NameFeatureEvent, NameFeatureState> {
  NameFeatureBloc() : super(NameFeatureInitial()) {
    on<NameFeatureEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
