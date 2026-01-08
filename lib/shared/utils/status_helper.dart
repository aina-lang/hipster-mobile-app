import 'package:flutter/material.dart';

class StatusHelper {
  static String translateStatus(String status) {
    switch (status.toLowerCase()) {
      case 'planned':
      case 'open':
      case 'nouveau':
        return 'PLANIFIÉ';
      case 'in_progress':
      case 'en cours':
        return 'EN COURS';
      case 'on_hold':
      case 'en attente':
        return 'EN ATTENTE';
      case 'completed':
      case 'paid':
      case 'payé':
      case 'livré':
      case 'terminé':
        return 'TERMINÉ';
      case 'canceled':
      case 'fermé':
      case 'annulé':
        return 'ANNULÉ';
      case 'todo':
        return 'À FAIRE';
      case 'review':
        return 'RÉVISION';
      case 'done':
        return 'TERMINÉ';
      case 'blocked':
        return 'BLOQUÉ';
      default:
        return status.toUpperCase();
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'planned':
      case 'open':
      case 'nouveau':
      case 'todo':
        return Colors.blue;
      case 'in_progress':
      case 'en cours':
        return Colors.orange;
      case 'completed':
      case 'paid':
      case 'payé':
      case 'livré':
      case 'terminé':
      case 'done':
        return Colors.green;
      case 'on_hold':
      case 'en attente':
      case 'blocked':
        return Colors.red;
      case 'canceled':
      case 'fermé':
      case 'annulé':
        return Colors.grey;
      case 'review':
        return Colors.purple;
      default:
        return Colors.black;
    }
  }
}
