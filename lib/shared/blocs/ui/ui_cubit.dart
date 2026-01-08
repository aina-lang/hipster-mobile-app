import 'package:flutter_bloc/flutter_bloc.dart';
import 'ui_state.dart';

class UiCubit extends Cubit<UiState> {
  UiCubit() : super(const UiState());

  void setBottomNavBarVisibility(bool visible) {
    emit(state.copyWith(isBottomNavBarVisible: visible));
  }
}
