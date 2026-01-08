import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tiko_tiko/shared/widgets/project_card.dart';
import 'package:tiko_tiko/modules/client/project/bloc/project_bloc.dart';
import 'package:tiko_tiko/modules/client/project/bloc/project_event.dart';
import 'package:tiko_tiko/modules/client/project/bloc/project_state.dart';
import 'package:tiko_tiko/shared/utils/ui_helpers.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  String searchQuery = "";
  String? filterStatus;
  String sortBy = "date_desc";

  @override
  void initState() {
    super.initState();
    context.read<ProjectBloc>().add(ProjectLoadRequested());
  }

  void _onStatusSelected(String? value) {
    setState(() {
      filterStatus = (value == "Tous") ? null : value;
    });
    context.read<ProjectBloc>().add(
      ProjectLoadRequested(status: filterStatus, search: searchQuery),
    );
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
    });
    context.read<ProjectBloc>().add(
      ProjectLoadRequested(status: filterStatus, search: searchQuery),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectSubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Projet soumis avec succès !"),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ProjectSubmitFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Échec: ${state.error}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<ProjectBloc>().add(
              ProjectLoadRequested(
                refresh: true,
                status: filterStatus,
                search: searchQuery,
              ),
            );
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                scrolledUnderElevation: 0,
                backgroundColor: Colors.white,
                title: Text(
                  "Projets",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                centerTitle: false,
                actions: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.filter_list_rounded),
                    onSelected: _onStatusSelected,
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: "Tous", child: Text("Tous")),
                      PopupMenuItem(
                        value: "in_progress",
                        child: Text("En cours"),
                      ),
                      PopupMenuItem(value: "completed", child: Text("Livré")),
                      PopupMenuItem(
                        value: "on_hold",
                        child: Text("En attente"),
                      ),
                    ],
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(85),
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: "Rechercher un projet...",
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Colors.black54,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              BlocBuilder<ProjectBloc, ProjectState>(
                builder: (context, state) {
                  if (state is ProjectLoading) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.black),
                      ),
                    );
                  }
                  if (state is ProjectLoaded) {
                    final projects = state.projects;
                    if (projects.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_open_rounded,
                                size: 80,
                                color: Colors.grey.shade300,
                              ),
                              const Text(
                                "Aucun projet trouvé",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return ProjectCard(
                            project: projects[index],
                            index: index,
                          );
                        }, childCount: projects.length),
                      ),
                    );
                  }
                  if (state is ProjectFailure) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text(state.error)),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSubmitProjectDialog(context),
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          "NOUVEAU PROJET",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showSubmitProjectDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 30));

    showAppModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "SOUMETTRE UN PROJET",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Nom du projet",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Date de début :",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: startDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) startDate = picked;
                },
                child: Text(DateFormat('dd/MM/yyyy').format(startDate)),
              ),
              const Text(
                "Date de fin prévue :",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: endDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) endDate = picked;
                },
                child: Text(DateFormat('dd/MM/yyyy').format(endDate)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      descController.text.isNotEmpty) {
                    context.read<ProjectBloc>().add(
                      ProjectSubmitRequested(
                        name: nameController.text,
                        description: descController.text,
                        startDate: startDate,
                        endDate: endDate,
                      ),
                    );
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "SOUMETTRE",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
