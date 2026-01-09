import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tiko_tiko/modules/client/loyality/models/loyalty_model.dart';
import 'package:tiko_tiko/modules/client/loyality/services/loyalty_repository.dart';

// Events
abstract class LoyaltyEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoyaltyRequested extends LoyaltyEvent {}

class LoyaltyRefreshRequested extends LoyaltyEvent {}

// States
abstract class LoyaltyState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoyaltyInitial extends LoyaltyState {}

class LoyaltyLoading extends LoyaltyState {}

class LoyaltyLoaded extends LoyaltyState {
  final LoyaltyDetailModel loyalty;
  LoyaltyLoaded(this.loyalty);
  @override
  List<Object?> get props => [loyalty];
}

class LoyaltyFailure extends LoyaltyState {
  final String error;
  LoyaltyFailure(this.error);
  @override
  List<Object?> get props => [error];
}

// Bloc
class LoyaltyBloc extends Bloc<LoyaltyEvent, LoyaltyState> {
  final LoyaltyRepository repository;

  LoyaltyBloc(this.repository) : super(LoyaltyInitial()) {
    on<LoyaltyRequested>((event, emit) async {
      emit(LoyaltyLoading());
      try {
        final loyalty = await repository.getLoyaltyMine();
        emit(LoyaltyLoaded(loyalty));
      } catch (e) {
        emit(LoyaltyFailure(e.toString()));
      }
    });

    on<LoyaltyRefreshRequested>((event, emit) async {
      // Don't emit loading for refresh to keep UI stable
      try {
        final loyalty = await repository.getLoyaltyMine();
        emit(LoyaltyLoaded(loyalty));
      } catch (e) {
        // Handle error if needed, but maybe keep last state or show snackbar via listener
      }
    });
  }
}
