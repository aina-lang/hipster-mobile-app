import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tiko_tiko/shared/widgets/project_card.dart';
import 'package:tiko_tiko/modules/client/project/bloc/project_bloc.dart';
import 'package:tiko_tiko/modules/client/project/bloc/project_event.dart';
import 'package:tiko_tiko/modules/client/project/bloc/project_state.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<ProjectBloc>().add(ProjectLoadRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
    });
    // We filter client-side for now to support tabs
    context.read<ProjectBloc>().add(ProjectLoadRequested(search: searchQuery));
  }

  List<dynamic> _filterProjects(List<dynamic> projects, bool isPendingTab) {
    if (isPendingTab) {
      return projects
          .where(
            (p) =>
                (p.status == 'pending' || p.status == 'refused') &&
                p.status != 'canceled',
          )
          .toList();
    } else {
      return projects
          .where(
            (p) =>
                p.status != 'pending' &&
                p.status != 'refused' &&
                p.status != 'canceled',
          )
          .toList();
    }
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
            // Switch to Pending tab
            _tabController.animateTo(1);
          } else if (state is ProjectSubmitFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Échec: ${state.error}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              floating: true,
              pinned: true,
              backgroundColor: Colors.white,
              title: Text(
                "Projets",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(110),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: "Rechercher...",
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 16,
                          ),
                        ),
                      ),
                    ),
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.black,
                      tabs: const [
                        Tab(text: "Mes Projets"),
                        Tab(text: "Demandes"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Active Projects
              _buildProjectList(context, false),
              // Tab 2: Pending/Refused Projects
              _buildProjectList(context, true),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/client/projects/new'),
          backgroundColor: Colors.black,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            "SOUMETTRE UN PROJET",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectList(BuildContext context, bool isPendingTab) {
    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, state) {
        if (state is ProjectLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.black),
          );
        }
        if (state is ProjectLoaded) {
          final projects = _filterProjects(state.projects, isPendingTab);

          if (projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isPendingTab
                        ? Icons.hourglass_empty_rounded
                        : Icons.folder_open_rounded,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPendingTab
                        ? "Aucune demande en cours"
                        : "Aucun projet actif",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              return ProjectCard(project: projects[index], index: index);
            },
          );
        }
        if (state is ProjectFailure) {
          return Center(child: Text(state.error));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
