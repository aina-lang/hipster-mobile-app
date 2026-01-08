import 'package:dio/dio.dart';
import 'package:tiko_tiko/shared/models/project_model.dart';
import 'package:tiko_tiko/shared/utils/constants.dart';

class ProjectRepository {
  final Dio _dio = AppConstants.dio;

  Future<List<ProjectModel>> getProjects({
    String? status,
    String? search,
  }) async {
    try {
      final response = await _dio.get(
        '/projects',
        queryParameters: {
          if (status != null) 'status': status,
          if (search != null) 'search': search,
        },
      );

      if (response.statusCode == 200) {
        final rawData = response.data['data'];
        final List listData = (rawData is Map)
            ? (rawData['data'] ?? [])
            : (rawData ?? []);
        return listData.map((json) => ProjectModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching projects: $e');
      return [];
    }
  }

  Future<bool> createProject({
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _dio.post(
        '/projects',
        data: {
          'name': name,
          'description': description,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error creating project: $e');
      return false;
    }
  }

  Future<ProjectModel?> getProject(int id) async {
    try {
      final response = await _dio.get('/projects/$id');
      if (response.statusCode == 200) {
        // Handle wrapped response { data: ... } or direct object
        final dynamic data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return ProjectModel.fromJson(data['data']);
        }
        return ProjectModel.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching project $id: $e');
      return null;
    }
  }
}
