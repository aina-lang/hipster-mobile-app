import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tiko_tiko/shared/models/project_model.dart';
import 'package:tiko_tiko/modules/client/project/bloc/project_bloc.dart';
import 'package:tiko_tiko/modules/client/project/bloc/project_event.dart';
import 'package:tiko_tiko/modules/client/project/bloc/project_state.dart';
import 'package:tiko_tiko/shared/widgets/custom_button.dart';

class ProjectSubmitScreen extends StatefulWidget {
  final ProjectModel? project;
  const ProjectSubmitScreen({super.key, this.project});

  @override
  State<ProjectSubmitScreen> createState() => _ProjectSubmitScreenState();
}

class _ProjectSubmitScreenState extends State<ProjectSubmitScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _budgetController;

  DateTime? _startDate;
  DateTime? _endDate;
  List<PlatformFile> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name);
    _descController = TextEditingController(text: widget.project?.description);
    _budgetController = TextEditingController(
      text: widget.project != null ? widget.project!.budget.toStringAsFixed(0) : '',
    );
    _startDate = widget.project?.startDate;
    _endDate = widget.project?.endDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'jpeg'],
      );

      if (result != null) {
        setState(() {
          _selectedFiles.addAll(result.files);
        });
      }
    } catch (e) {
      print("File picker error: $e");
    }
  }

  void _removeFile(PlatformFile file) {
    setState(() {
      _selectedFiles.remove(file);
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        // Custom theme for date picker to match app style
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.black, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Reset end date if it's before start date
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner les dates de début et de fin'),
          ),
        );
        return;
      }

      final budget = double.tryParse(_budgetController.text);

      if (widget.project != null) {
        context.read<ProjectBloc>().add(
          ProjectUpdateRequested(
            id: widget.project!.id,
            name: _nameController.text,
            description: _descController.text,
            startDate: _startDate,
            endDate: _endDate,
            budget: budget,
          ),
        );
      } else {
        context.read<ProjectBloc>().add(
          ProjectSubmitRequested(
            name: _nameController.text,
            description: _descController.text,
            startDate: _startDate!,
            endDate: _endDate!,
            budget: budget,
            files: _selectedFiles
                .map((f) => f.path)
                .where((path) => path != null)
                .cast<String>()
                .toList(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.project != null ? "Modifier le Projet" : "Nouveau Projet",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocListener<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectSubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.project != null
                      ? 'Projet mis à jour avec succès !'
                      : 'Votre demande de projet a été envoyée !',
                ),
                backgroundColor: Colors.green,
              ),
            );
            context.pop(); // Go back to project list
          } else if (state is ProjectSubmitFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Détails du projet",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Décrivez votre besoin pour que nous puissions établir un devis précis.",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Nom du projet
                _buildLabel("Nom du projet"),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: "Ex: Application Mobile E-commerce",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Le nom est requis" : null,
                ),
                const SizedBox(height: 20),

                // Description
                _buildLabel("Description détaillée"),
                TextFormField(
                  controller: _descController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText:
                        "Décrivez les fonctionnalités principales, le public cible, etc...",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  validator: (v) => v == null || v.isEmpty
                      ? "Une description est requise"
                      : null,
                ),
                const SizedBox(height: 20),

                // Budget (Optionnel)
                _buildLabel("Budget estimé (€) (Optionnel)"),
                TextFormField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Ex: 5000",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 20),

                // Dates
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Date de début souhaitée"),
                          GestureDetector(
                            onTap: () => _selectDate(context, true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.transparent),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _startDate == null
                                        ? "Sélectionner"
                                        : DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(_startDate!),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: _startDate == null
                                          ? Colors.grey[500]
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Date de fin souhaitée"),
                          GestureDetector(
                            onTap: () => _selectDate(context, false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.transparent),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.event_available,
                                    size: 18,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _endDate == null
                                        ? "Sélectionner"
                                        : DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(_endDate!),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: _endDate == null
                                          ? Colors.grey[500]
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Attached Files
                _buildLabel("Fichiers attachés (Optionnel)"),
                GestureDetector(
                  onTap: _pickFiles,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.cloud_upload_outlined,
                          size: 32,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Appuyez pour ajouter des fichiers",
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_selectedFiles.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          ..._selectedFiles
                              .map(
                                (file) => Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.insert_drive_file_outlined,
                                        size: 20,
                                        color: Colors.black54,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          file.name ?? 'Fichier sans nom',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          size: 18,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => _removeFile(file),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Submit Button
                BlocBuilder<ProjectBloc, ProjectState>(
                  builder: (context, state) {
                    return CustomButton(
                      text: widget.project != null
                          ? "Mettre à jour"
                          : "Envoyer la demande",
                      isLoading: state is ProjectSubmitInProgress,
                      onPressed: state is ProjectSubmitInProgress
                          ? null
                          : _submit,
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          fontSize: 14,
        ),
      ),
    );
  }
}
