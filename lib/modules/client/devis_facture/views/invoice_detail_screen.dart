import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tiko_tiko/shared/models/invoice_model.dart';
import 'package:tiko_tiko/shared/services/file_service.dart';
import 'package:tiko_tiko/shared/widgets/custom_snackbar.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final InvoiceModel invoice;

  const InvoiceDetailScreen({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final isQuote = invoice.type == 'quote';
    final typeLabel = isQuote ? "Devis" : "Facture";
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "$typeLabel #${invoice.reference}",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        actions: [_buildStatusChip(invoice.status), const SizedBox(width: 16)],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoColumn(
                        "Date d'émission",
                        DateFormat('dd/MM/yyyy').format(invoice.createdAt),
                      ),
                      if (invoice.dueDate != null)
                        _buildInfoColumn(
                          "Date d'échéance",
                          DateFormat('dd/MM/yyyy').format(invoice.dueDate!),
                        ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Items Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Description",
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Qté",
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Total",
                            textAlign: TextAlign.right,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Items List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: invoice.items.length,
                    separatorBuilder: (_, __) =>
                        Divider(color: Colors.grey.shade100, height: 1),
                    itemBuilder: (context, index) {
                      final item = invoice.items[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.description,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (item.unit != null)
                                    Text(
                                      "${item.unitPrice.toStringAsFixed(2)} € / ${item.unit}",
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Text(
                                item.quantity.toStringAsFixed(0),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "${item.total.toStringAsFixed(2)} €",
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(thickness: 1, height: 40),

                  // Totals
                  _buildTotalRow(
                    "Sous-total (HT)",
                    "${invoice.subTotal.toStringAsFixed(2)} €",
                  ),
                  const SizedBox(height: 8),
                  _buildTotalRow(
                    "TVA (${invoice.taxRate.toStringAsFixed(0)}%)",
                    "${invoice.taxAmount.toStringAsFixed(2)} €",
                  ),
                  const SizedBox(height: 16),
                  _buildTotalRow(
                    "TOTAL (TTC)",
                    "${invoice.amount.toStringAsFixed(2)} €",
                    isMain: true,
                  ),
                ],
              ),
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (invoice.status == 'pending' && !isQuote) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () => _payInvoice(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Payer maintenant",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: () => _downloadPdf(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.picture_as_pdf_rounded),
                      label: const Text(
                        "Visualiser le PDF",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _payInvoice(BuildContext context) {
    // TODO: Stripe integration
    AppSnackBar.show(
      context,
      "Redirection vers Stripe...",
      type: SnackType.info,
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isMain = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMain ? 18 : 14,
            fontWeight: isMain ? FontWeight.w900 : FontWeight.w600,
            color: isMain ? Colors.black : Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isMain ? 20 : 15,
            fontWeight: isMain ? FontWeight.w900 : FontWeight.bold,
            color: isMain ? Colors.black : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'paid':
      case 'accepted':
        color = Colors.green;
        label = status.toLowerCase() == 'paid' ? "Payée" : "Accepté";
        break;
      case 'pending':
        color = Colors.orange;
        label = "En attente";
        break;
      case 'canceled':
        color = Colors.red;
        label = "Annulé";
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _downloadPdf(BuildContext context) async {
    try {
      AppSnackBar.show(
        context,
        "Génération du PDF en cours...",
        position: SnackPosition.bottom,
      );
      final pdfUrl = '/invoices/${invoice.id}/pdf';
      await FileService().downloadAndOpenFile(
        pdfUrl,
        'Hipster_${invoice.type}_${invoice.reference}.pdf',
      );
    } catch (e) {
      AppSnackBar.show(
        context,
        "Erreur lors du téléchargement",
        type: SnackType.error,
      );
    }
  }
}
