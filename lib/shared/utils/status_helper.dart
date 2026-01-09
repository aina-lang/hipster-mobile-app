import 'package:flutter/material.dart';

class StatusHelper {
  static String translateStatus(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
      case 'brouillon':
        return 'BROUILLON';
      case 'sent':
      case 'envoyé':
        return 'ENVOYÉ';
      case 'accepted':
      case 'accepté':
        return 'ACCEPTÉ';
      case 'paid':
      case 'payé':
      case 'payée':
        return 'PAYÉE';
      case 'unpaid':
      case 'impayé':
        return 'IMPAYÉ';
      case 'partially_paid':
        return 'PARTIELLEMENT PAYÉ';

      // --- PROJECTS / TICKETS ---
      case 'planned':
      case 'in_progress':
      case 'on_hold':
        return 'EN COURS';
      case 'pending':
        return 'EN ATTENTE DE VALIDATION';
      case 'completed':
        return 'TERMINÉ';
      case 'canceled':
      case 'annulé':
        return 'ANNULÉ';
      case 'refused':
      case 'refusé':
        return 'REFUSÉ';
      case 'open':
      case 'new':
      case 'nouveau':
        return 'OUVERT';
      default:
        return status.toUpperCase();
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'planned':
      case 'in_progress':
      case 'on_hold':
        return Colors.blue;

      case 'pending':
        return Colors.orange; // Yellow/Orange for pending validation

      case 'completed':
      case 'paid':
      case 'payée':
        return Colors.green;

      case 'refused':
      case 'canceled':
      case 'annulé':
      case 'refusé':
        return Colors.red;

      case 'draft':
      case 'brouillon':
        return Colors.grey;

      case 'open':
      case 'new':
      case 'nouveau':
        return Colors.teal;

      default:
        return Colors.black;
    }
  }
}
