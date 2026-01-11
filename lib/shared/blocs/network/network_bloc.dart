import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:tiko_tiko/shared/blocs/network/network_service.dart';
import 'network_event.dart';
import 'network_state.dart';

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  final NetworkService _networkService;
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  NetworkBloc(this._networkService) : super(const NetworkInitial()) {
    on<NetworkStatusChanged>(_onStatusChanged);

    // Écoute les changements réseau
    _subscription = _networkService.onConnectivityChanged.listen((status) {
      add(NetworkStatusChanged(status));
    });

    // Vérifie l'état initial
    _networkService.checkConnectivity().then((status) {
      add(NetworkStatusChanged(status));
    });
  }

  // Helper method to check if device is online
  static bool isOnline(NetworkState state) {
    return !state.connectionStatus.contains(ConnectivityResult.none);
  }

  void _onStatusChanged(
    NetworkStatusChanged event,
    Emitter<NetworkState> emit,
  ) {
    emit(NetworkUpdated(event.connectionStatus));
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
