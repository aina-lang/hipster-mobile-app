import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkState {
  final List<ConnectivityResult> connectionStatus;

  const NetworkState(this.connectionStatus);
}

class NetworkInitial extends NetworkState {
  const NetworkInitial() : super(const [ConnectivityResult.none]);
}

class NetworkUpdated extends NetworkState {
  const NetworkUpdated(super.status);
}
