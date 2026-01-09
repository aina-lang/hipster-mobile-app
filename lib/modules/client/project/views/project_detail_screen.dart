import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tiko_tiko/shared/models/project_model.dart';
import 'package:tiko_tiko/shared/utils/status_helper.dart';
import 'package:intl/intl.dart';
import 'package:tiko_tiko/modules/client/project/services/project_repository.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ProjectDetailScreen extends StatefulWidget {
  final ProjectModel? project;
  final int? projectId;

  const ProjectDetailScreen({super.key, this.project, this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  ProjectModel? _project;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      _project = widget.project;
    } else if (widget.projectId != null) {
      _fetchProject(widget.projectId!);
    } else {
      _error = "Project ID missing";
    }
  }

  Future<void> _fetchProject(int id) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Use repository directly or via provider if available
      final repo = ProjectRepository();
      final project = await repo.getProject(id);
      if (mounted) {
        setState(() {
          _project = project;
          _isLoading = false;
          if (project == null) {
            _error = "Projet introuvable";
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = "Erreur de chargement";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final cs = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white),
        body: const Center(
          child: SpinKitFadingCircle(color: Colors.black, size: 40),
        ),
      );
    }

    if (_error != null || _project == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white),
        body: Center(child: Text(_error ?? "Erreur inconnue")),
      );
    }

    final project = _project!;
    final statusColor = StatusHelper.getStatusColor(project.status);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/client/projects');
            }
          },
        ),
        title: Text(
          project.name.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                StatusHelper.translateStatus(project.status).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "DESCRIPTION",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              project.description ?? "Pas de description fournie.",
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),

            // Progress Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "PROGRESSION",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  "${project.progress.toInt()}%",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: project.progress / 100,
                minHeight: 12,
                backgroundColor: Colors.grey.shade100,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            ),
            const SizedBox(height: 32),

            // Details Grid
            _buildDetailRow(
              context,
              Icons.calendar_today_rounded,
              "Date de début",
              DateFormat('dd MMMM yyyy', 'fr_FR').format(project.startDate),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              context,
              Icons.event_available_rounded,
              "Fin prévue",
              project.endDate != null
                  ? DateFormat('dd MMMM yyyy', 'fr_FR').format(project.endDate!)
                  : "Non définie",
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              context,
              Icons.monetization_on_rounded,
              "Budget total",
              NumberFormat.currency(
                symbol: 'Ar ',
                decimalDigits: 0,
              ).format(project.budget),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
