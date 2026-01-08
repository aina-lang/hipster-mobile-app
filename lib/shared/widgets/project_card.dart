import 'package:flutter/material.dart';
import 'package:tiko_tiko/shared/models/project_model.dart';
import 'package:tiko_tiko/shared/widgets/custom_snackbar.dart';
import '../utils/status_helper.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, required this.index});

  final ProjectModel project;
  final int index;

  @override
  Widget build(BuildContext context) {
    final statusColor = StatusHelper.getStatusColor(project.status);

    return Dismissible(
      key: Key("${project.id}_${project.name}"),
      direction: DismissDirection.endToStart,
      background: _buildRightActions(),
      confirmDismiss: (direction) async {
        _showRightActionDialog(context, project, index);
        return false;
      },
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

  // === 🟪 FOND DROIT — 4 actions marketing client
  Widget _buildRightActions() {
    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade700,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.white),
                    SizedBox(height: 4),
                    Text("PDF", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, color: Colors.white),
                    SizedBox(height: 4),
                    Text("Devis", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.request_quote_outlined, color: Colors.white),
                    SizedBox(height: 4),
                    Text("Facture", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.orangeAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.support_agent, color: Colors.white),
                    SizedBox(height: 4),
                    Text("Ticket", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === 🗂️ Dialogue droite
  void _showRightActionDialog(
    BuildContext context,
    ProjectModel project,
    int index,
  ) {
    showModalBottomSheet(
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
                  AppSnackBar.show(
                    ctx,
                    "Téléchargement du PDF du projet '${project.name}'",
                    position: SnackPosition.top,
                  );
                  // TODO: implémenter le téléchargement PDF ici
                },
              ),

              // 💰 Télécharger le devis
              ListTile(
                leading: const Icon(Icons.receipt_long, color: Colors.teal),
                title: const Text("Télécharger le devis"),
                subtitle: const Text("Récupérer le devis en cours du projet"),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Téléchargement du devis du projet '${project.name}'",
                      ),
                    ),
                  );
                  // TODO: implémenter le téléchargement devis ici
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Téléchargement de la facture du projet '${project.name}'",
                      ),
                    ),
                  );
                  // TODO: implémenter le téléchargement facture ici
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Ouverture du support client..."),
                    ),
                  );
                  // TODO: rediriger vers l’écran de support/ticket
                },
              ),

              // 👁️ Voir le projet
              ListTile(
                leading: const Icon(Icons.visibility, color: Colors.blueAccent),
                title: const Text("Voir le projet"),
                subtitle: const Text("Accéder au détail complet"),
                onTap: () {
                  Navigator.pop(ctx);
                  // context.push('/projects/detail', extra: project);
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
