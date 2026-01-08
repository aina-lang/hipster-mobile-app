import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  /// Stream pour écouter les changements de connexion
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  /// Vérifie l'état actuel de la connexion
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return await _connectivity.checkConnectivity();
  }

  /// Lance un écouteur pour réagir aux changements réseau
  void startListening(Function(List<ConnectivityResult>) onChange) {
    _subscription = _connectivity.onConnectivityChanged.listen(onChange);
  }

  /// Arrête l'écoute
  void dispose() {
    _subscription.cancel();
  }
}
