import 'package:equatable/equatable.dart';

class UiState extends Equatable {
  final bool isBottomNavBarVisible;

  const UiState({this.isBottomNavBarVisible = true});

  UiState copyWith({bool? isBottomNavBarVisible}) {
    return UiState(
      isBottomNavBarVisible:
          isBottomNavBarVisible ?? this.isBottomNavBarVisible,
    );
  }

  @override
  List<Object?> get props => [isBottomNavBarVisible];
}
