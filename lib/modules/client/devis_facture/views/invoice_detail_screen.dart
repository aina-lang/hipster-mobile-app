import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tiko_tiko/modules/client/devis_facture/bloc/invoice_bloc.dart';
import 'package:tiko_tiko/modules/client/devis_facture/services/invoice_repository.dart';
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

    return BlocListener<InvoiceBloc, InvoiceState>(
      listener: (context, state) {
        if (state is InvoiceStatusUpdateSuccess) {
          AppSnackBar.show(
            context,
            "Document mis à jour avec succès",
            type: SnackType.success,
          );
        } else if (state is InvoiceFailure) {
          AppSnackBar.show(
            context,
            "Erreur: ${state.error}",
            type: SnackType.error,
          );
        }
      },
      child: Scaffold(
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
          actions: [
            BlocBuilder<InvoiceBloc, InvoiceState>(
              builder: (context, state) {
                final currentInvoice = state is InvoiceStatusUpdateSuccess
                    ? state.updatedInvoice
                    : invoice;
                return _buildStatusChip(currentInvoice.status);
              },
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: BlocBuilder<InvoiceBloc, InvoiceState>(
          builder: (context, state) {
            final currentInvoice = state is InvoiceStatusUpdateSuccess
                ? state.updatedInvoice
                : invoice;
            final isLoading = state is InvoiceLoading;

            return Stack(
              children: [
                Column(
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
                                  DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(currentInvoice.createdAt),
                                ),
                                if (currentInvoice.dueDate != null)
                                  _buildInfoColumn(
                                    "Date d'échéance",
                                    DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(currentInvoice.dueDate!),
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
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade600,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Qté",
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
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
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
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
                              itemCount: currentInvoice.items.length,
                              separatorBuilder: (_, __) => Divider(
                                color: Colors.grey.shade100,
                                height: 1,
                              ),
                              itemBuilder: (context, index) {
                                final item = currentInvoice.items[index];
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                              "${currentInvoice.subTotal.toStringAsFixed(2)} €",
                            ),
                            const SizedBox(height: 8),
                            _buildTotalRow(
                              "TVA (${currentInvoice.taxRate.toStringAsFixed(0)}%)",
                              "${currentInvoice.taxAmount.toStringAsFixed(2)} €",
                            ),
                            const SizedBox(height: 16),
                            _buildTotalRow(
                              "TOTAL (TTC)",
                              "${currentInvoice.amount.toStringAsFixed(2)} €",
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
                            if (isQuote &&
                                currentInvoice.status == 'pending') ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 55,
                                      child: ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : () => _handleQuoteAction(
                                                context,
                                                currentInvoice.id,
                                                'accepted',
                                              ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: const Text(
                                          "Accepter",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: SizedBox(
                                      height: 55,
                                      child: ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : () => _handleQuoteAction(
                                                context,
                                                currentInvoice.id,
                                                'canceled',
                                              ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red.shade50,
                                          foregroundColor: Colors.red,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: const Text(
                                          "Refuser",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (!isQuote &&
                                currentInvoice.status == 'pending') ...[
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () => _payInvoice(
                                          context,
                                          currentInvoice.id,
                                        ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
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
                            if (!isQuote &&
                                currentInvoice.status == 'paid') ...[
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton.icon(
                                  onPressed: () => _viewReceipt(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade50,
                                    foregroundColor: Colors.blue.shade700,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.receipt_outlined),
                                  label: const Text(
                                    "Voir le reçu",
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
                                onPressed: () =>
                                    _downloadPdf(context, currentInvoice),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.black87,
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.picture_as_pdf_rounded),
                                label: const Text(
                                  "Télécharger le PDF",
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
                if (isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _payInvoice(BuildContext context, int id) async {
    try {
      final repository = InvoiceRepository();
      final url = await repository.getPaymentLink(id);
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      AppSnackBar.show(
        context,
        "Erreur lors du paiement: $e",
        type: SnackType.error,
      );
    }
  }

  void _handleQuoteAction(BuildContext context, int id, String status) {
    context.read<InvoiceBloc>().add(
      InvoiceStatusUpdateRequested(id: id, status: status),
    );
  }

  void _viewReceipt(BuildContext context) {
    AppSnackBar.show(
      context,
      "Ouverture du reçu de paiement...",
      type: SnackType.info,
    );
    // TODO: Ouvrir le lien du reçu (Stripe receipt_url)
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

  void _downloadPdf(BuildContext context, InvoiceModel currentInvoice) async {
    try {
      AppSnackBar.show(
        context,
        "Génération du PDF en cours...",
        position: SnackPosition.bottom,
      );
      final pdfUrl = '/invoices/${currentInvoice.id}/pdf';
      await FileService().downloadAndOpenFile(
        pdfUrl,
        'Hipster_${currentInvoice.type}_${currentInvoice.reference}.pdf',
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
