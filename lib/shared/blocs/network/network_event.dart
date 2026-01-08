import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkEvent {}

class NetworkStatusChanged extends NetworkEvent {
  final List<ConnectivityResult> connectionStatus;

  NetworkStatusChanged(this.connectionStatus);
}
