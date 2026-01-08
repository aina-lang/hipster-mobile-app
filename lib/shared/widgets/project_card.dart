import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:tiko_tiko/shared/models/project_model.dart';
import 'package:tiko_tiko/shared/widgets/custom_snackbar.dart';
import '../utils/status_helper.dart';
import '../services/file_service.dart';
import '../../modules/client/dashboard/services/dashboard_repository.dart';
import '../utils/ui_helpers.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, required this.index});

  final ProjectModel project;
  final int index;

  @override
  Widget build(BuildContext context) {
    final statusColor = StatusHelper.getStatusColor(project.status);

    return Slidable(
      key: Key("${project.id}_${project.name}"),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.8,
        children: [
          SlidableAction(
            onPressed: (ctx) => _handlePdfAction(ctx),
            backgroundColor: Colors.blueGrey.shade700,
            foregroundColor: Colors.white,
            icon: Icons.picture_as_pdf,
            label: 'PDF',
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(8),
            ),
          ),
          SlidableAction(
            onPressed: (ctx) => _handleQuoteAction(ctx),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            icon: Icons.receipt_long,
            label: 'Devis',
          ),
          SlidableAction(
            onPressed: (ctx) => _handleInvoiceAction(ctx),
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            icon: Icons.request_quote_outlined,
            label: 'Facture',
          ),
          SlidableAction(
            onPressed: (ctx) => context.push('/client/tickets'),
            backgroundColor: Colors.orangeAccent,
            foregroundColor: Colors.white,
            icon: Icons.support_agent,
            label: 'Ticket',
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(8),
            ),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: InkWell(
          onTap: () => _showRightActionDialog(context, project, index),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        project.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        StatusHelper.translateStatus(project.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  project.description ?? '',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "PROGRESSION",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                "${project.progress.toInt()}%",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: project.progress / 100,
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade100,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Action Handlers ---

  Future<void> _handlePdfAction(BuildContext ctx) async {
    AppSnackBar.show(
      ctx,
      "Génération du rapport PDF...",
      position: SnackPosition.top,
    );
    try {
      await FileService().downloadAndOpenFile(
        '/projects/${project.id}/pdf',
        'rapport_projet_${project.id}.pdf',
      );
    } catch (e) {
      AppSnackBar.show(ctx, "Erreur: $e", type: SnackType.error);
    }
  }

  Future<void> _handleQuoteAction(BuildContext ctx) async {
    AppSnackBar.show(ctx, "Recherche du devis...", position: SnackPosition.top);
    try {
      final response = await DashboardRepository().getInvoices(
        projectId: project.id,
      );
      final quote = response.firstWhere(
        (i) => i.type == 'quote',
        orElse: () =>
            throw Exception("Ce projet n'a pas encore de devis généré."),
      );

      await FileService().downloadAndOpenFile(
        '/invoices/${quote.id}/pdf',
        'devis_${quote.reference}.pdf',
      );
    } catch (e) {
      String message = e.toString().replaceFirst('Exception: ', '');
      AppSnackBar.show(ctx, message, type: SnackType.error);
    }
  }

  Future<void> _handleInvoiceAction(BuildContext ctx) async {
    AppSnackBar.show(
      ctx,
      "Recherche de la facture...",
      position: SnackPosition.top,
    );
    try {
      final response = await DashboardRepository().getInvoices(
        projectId: project.id,
      );
      final invoice = response.firstWhere(
        (i) => i.type == 'invoice',
        orElse: () => throw Exception(
          "Aucune facture n'a encore été générée pour ce projet.",
        ),
      );

      await FileService().downloadAndOpenFile(
        '/invoices/${invoice.id}/pdf',
        'facture_${invoice.reference}.pdf',
      );
    } catch (e) {
      String message = e.toString().replaceFirst('Exception: ', '');
      AppSnackBar.show(ctx, message, type: SnackType.error);
    }
  }

  // === 🗂️ Dialogue droite
  void _showRightActionDialog(
    BuildContext context,
    ProjectModel project,
    int index,
  ) {
    showAppModalBottomSheet(
      scrollControlDisabledMaxHeightRatio: 50,
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Wrap(
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(
                      "Actions du projet",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

              // 📄 Télécharger le PDF
              ListTile(
                leading: const Icon(
                  Icons.picture_as_pdf,
                  color: Colors.blueGrey,
                ),
                title: const Text("Télécharger le rapport PDF"),
                subtitle: const Text("Télécharger la synthèse du projet"),
                onTap: () {
                  Navigator.pop(ctx);
                  _handlePdfAction(ctx);
                },
              ),

              // 💰 Télécharger le devis
              ListTile(
                leading: const Icon(Icons.receipt_long, color: Colors.teal),
                title: const Text("Télécharger le devis"),
                subtitle: const Text("Récupérer le devis en cours du projet"),
                onTap: () {
                  Navigator.pop(ctx);
                  _handleQuoteAction(ctx);
                },
              ),

              // 🧾 Télécharger la facture
              ListTile(
                leading: const Icon(
                  Icons.request_quote_outlined,
                  color: Colors.indigo,
                ),
                title: const Text("Télécharger la facture"),
                subtitle: const Text(
                  "Télécharger la dernière facture du projet",
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _handleInvoiceAction(ctx);
                },
              ),

              // 🎫 Envoyer un ticket
              ListTile(
                leading: const Icon(Icons.support_agent, color: Colors.orange),
                title: const Text("Envoyer un ticket"),
                subtitle: const Text(
                  "Contacter le support ou signaler un souci",
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/client/tickets');
                },
              ),

              // 👁️ Voir le projet
              ListTile(
                leading: const Icon(Icons.visibility, color: Colors.blueAccent),
                title: const Text("Voir le projet"),
                subtitle: const Text("Accéder au détail complet"),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(
                    '/client/projects/${project.id}',
                    extra: project,
                  );
                },
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      // SystemChrome.setEnabledSystemUIMode(
      //   SystemUiMode.manual,
      //   overlays: SystemUiOverlay.values,
      // );
    });
  }
}
