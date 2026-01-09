import 'package:flutter/material.dart';

class StatusHelper {
  static String translateStatus(String status) {
    switch (status.toLowerCase()) {
      // --- INVOICES / QUOTES ---
      case 'draft':
      case 'brouillon':
        return 'BROUILLON';
      case 'sent':
      case 'envoyé':
        return 'ENVOYÉ';
      case 'accepted':
      case 'accepté':
        return 'ACCEPTÉ';
      case 'refused':
      case 'refusé':
        return 'REFUSÉ';
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
      case 'open':
      case 'nouveau':
      case 'new':
        return 'PLANIFIÉ';
      case 'in_progress':
      case 'en cours':
        return 'EN COURS';
      case 'on_hold':
      case 'pending': // Shared concept
      case 'en attente':
        return 'EN ATTENTE';
      case 'completed':
      case 'livré':
      case 'terminé':
      case 'done':
        return 'TERMINÉ';
      case 'canceled':
      case 'fermé':
      case 'annulé':
        return 'ANNULÉ';
      case 'todo':
        return 'À FAIRE';
      case 'review':
        return 'RÉVISION';
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
      case 'new':
      case 'draft':
      case 'brouillon':
      case 'todo':
        return Colors.blue; // Or grey for draft? Usually draft is grey.

      case 'in_progress':
      case 'en cours':
      case 'unpaid':
      case 'impayé':
      case 'partially_paid':
      case 'sent': // Sent could be blue or orange waiting
      case 'envoyé':
        return Colors.orange;

      case 'completed':
      case 'paid':
      case 'payé':
      case 'payée':
      case 'livré':
      case 'terminé':
      case 'done':
      case 'accepted':
      case 'accepté':
        return Colors.green;

      case 'on_hold':
      case 'en attente':
      case 'pending':
      case 'blocked':
      case 'refused':
      case 'refusé':
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
