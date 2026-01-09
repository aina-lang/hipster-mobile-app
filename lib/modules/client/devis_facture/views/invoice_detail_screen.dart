import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:tiko_tiko/modules/client/devis_facture/bloc/invoice_bloc.dart';
import 'package:tiko_tiko/modules/client/devis_facture/services/invoice_repository.dart';
import 'package:tiko_tiko/shared/models/invoice_model.dart';
import 'package:tiko_tiko/shared/services/file_service.dart';
import 'package:tiko_tiko/shared/widgets/custom_snackbar.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final int? invoiceId;
  final InvoiceModel? initialInvoice;

  const InvoiceDetailScreen({super.key, this.invoiceId, this.initialInvoice})
    : assert(invoiceId != null || initialInvoice != null);

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.invoiceId != null) {
      context.read<InvoiceBloc>().add(
        InvoiceLoadOneRequested(widget.invoiceId!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/client/invoices');
              }
            },
          ),
          title: BlocBuilder<InvoiceBloc, InvoiceState>(
            builder: (context, state) {
              final invoice = _getCurrentInvoice(state);
              if (invoice == null) return const SizedBox.shrink();

              final isQuote = invoice.type == 'quote';
              final typeLabel = isQuote ? "Devis" : "Facture";
              return Text(
                "$typeLabel #${invoice.reference}",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              );
            },
          ),
          actions: [
            BlocBuilder<InvoiceBloc, InvoiceState>(
              builder: (context, state) {
                final invoice = _getCurrentInvoice(state);
                if (invoice == null) return const SizedBox.shrink();
                return _buildStatusChip(invoice.status);
              },
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: BlocBuilder<InvoiceBloc, InvoiceState>(
          builder: (context, state) {
            final invoice = _getCurrentInvoice(state);
            final isLoading = state is InvoiceLoading;

            if (isLoading && invoice == null) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.black),
              );
            }

            if (invoice == null) {
              return const Center(
                child: Text("Impossible de charger le document"),
              );
            }

            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            // Header Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInfoColumn(
                                  "Date d'émission",
                                  DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(invoice.createdAt),
                                ),
                                if (invoice.dueDate != null)
                                  _buildInfoColumn(
                                    "Date d'échéance",
                                    DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(invoice.dueDate!),
                                  ),
                              ],
                            ),
                            const Divider(height: 40),

                            // Parties Info (Sender & Client)
                            _buildPartiesSection(invoice),
                            const Divider(height: 40),

                            // Project Info
                            if (invoice.projectSnapshot != null) ...[
                              _buildProjectSection(invoice.projectSnapshot!),
                              const Divider(height: 40),
                            ],

                            // Items Table Header
                            Text(
                              "DÉTAILS DES PRESTATIONS",
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            _buildItemsTable(invoice),

                            // Totals
                            const SizedBox(height: 24),
                            _buildTotalsSection(invoice),

                            // Notes & Terms
                            if ((invoice.notes?.isNotEmpty ?? false) ||
                                (invoice.terms?.isNotEmpty ?? false)) ...[
                              const Divider(height: 40),
                              _buildNotesTermsSection(invoice),
                            ],

                            // Payment Details
                            if (invoice.senderDetails?.paymentDetails !=
                                null) ...[
                              const Divider(height: 40),
                              _buildPaymentDetailsSection(
                                invoice.senderDetails!.paymentDetails!,
                              ),
                            ],

                            const SizedBox(
                              height: 300,
                            ), // Space for bottom buttons
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Fixed Action Buttons at the bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
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
                      child: _buildActionButtons(invoice, isLoading),
                    ),
                  ),
                ),

                if (isLoading)
                  Container(
                    color: Colors.white.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPartiesSection(InvoiceModel invoice) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sender info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "DE",
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _fallback(
                  invoice.senderDetails?.commercialName ??
                      invoice.senderDetails?.companyName,
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              _buildSmallDetailText(invoice.senderDetails?.address),
              _buildSmallDetailText(invoice.senderDetails?.email),
              _buildSmallDetailText(invoice.senderDetails?.phone),
              if (invoice.senderDetails?.siret != null)
                _buildSmallDetailText("SIRET: ${invoice.senderDetails!.siret}"),
            ],
          ),
        ),
        const SizedBox(width: 20),
        // Client info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "À",
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _fallback(
                  invoice.clientSnapshot?.company ??
                      invoice.clientSnapshot?.name,
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              _buildSmallDetailText(invoice.clientSnapshot?.address),
              _buildSmallDetailText(
                "${invoice.clientSnapshot?.zipCode ?? ''} ${invoice.clientSnapshot?.city ?? ''}",
              ),
              _buildSmallDetailText(invoice.clientSnapshot?.country),
              _buildSmallDetailText(invoice.clientSnapshot?.email),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProjectSection(ProjectSnapshotModel project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "PROJET",
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _fallback(project.name),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        if (project.description != null) ...[
          const SizedBox(height: 4),
          Text(
            project.description!,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ],
    );
  }

  Widget _buildItemsTable(InvoiceModel invoice) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  "Qté",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "Total",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: invoice.items.length,
          separatorBuilder: (_, __) =>
              Divider(color: Colors.grey.shade100, height: 1),
          itemBuilder: (context, index) {
            final item = invoice.items[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "${item.total.toStringAsFixed(2)} €",
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTotalsSection(InvoiceModel invoice) {
    return Column(
      children: [
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
    );
  }

  Widget _buildNotesTermsSection(InvoiceModel invoice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
          Text(
            "NOTES",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            invoice.notes!,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
        ],
        if (invoice.terms != null && invoice.terms!.isNotEmpty) ...[
          Text(
            "CONDITIONS",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            invoice.terms!,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentDetailsSection(PaymentDetailsModel payment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "DÉTAILS DE PAIEMENT",
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        _buildPaymentRow("Banque", _fallback(payment.bank)),
        const SizedBox(height: 8),
        _buildPaymentRow("IBAN", _fallback(payment.iban)),
        const SizedBox(height: 8),
        _buildPaymentRow("BIC", _fallback(payment.bic)),
      ],
    );
  }

  Widget _buildPaymentRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(InvoiceModel invoice, bool isLoading) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (invoice.type == 'quote' && invoice.status == 'pending') ...[
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
                            invoice.id,
                            'accepted',
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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
                            invoice.id,
                            'canceled',
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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
        if (invoice.type != 'quote' && invoice.status == 'pending') ...[
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () => _payInvoice(context, invoice.id),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (invoice.type != 'quote' && invoice.status == 'paid') ...[
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          height: 55,
          child: OutlinedButton.icon(
            onPressed: () => _downloadPdf(context, invoice),
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  String _fallback(String? value) =>
      (value == null || value.isEmpty) ? "N/A" : value;

  Widget _buildSmallDetailText(String? text) {
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        text,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
    );
  }

  InvoiceModel? _lastInvoice;

  InvoiceModel? _getCurrentInvoice(InvoiceState state) {
    if (state is InvoiceStatusUpdateSuccess) {
      _lastInvoice = state.updatedInvoice;
    } else if (state is InvoiceDetailLoaded) {
      _lastInvoice = state.invoice;
    }
    return _lastInvoice ?? widget.initialInvoice;
  }

  void _payInvoice(BuildContext context, int id) async {
    try {
      final repository = InvoiceRepository();
      final data = await repository.createPaymentIntent(id);
      final clientSecret = data['clientSecret'];

      if (clientSecret == null) {
        throw 'Impossible de récupérer le secret de paiement';
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Hipster Marketing',
          style: ThemeMode.light,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(primary: Colors.black),
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      AppSnackBar.show(context, "Paiement réussi !", type: SnackType.success);
      context.read<InvoiceBloc>().add(
        InvoiceStatusUpdateRequested(id: id, status: 'paid'),
      );
    } on StripeException catch (e) {
      if (e.error.code != FailureCode.Canceled) {
        AppSnackBar.show(
          context,
          "Erreur Stripe: ${e.error.localizedMessage}",
          type: SnackType.error,
        );
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
