import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/academic_program.dart';
import '../../domain/entities/faculty.dart';
import '../../domain/repositories/academic_repository.dart';

/// Lee las facultades y carreras de las tablas `faculties` y `programs`.
class SupabaseAcademicRepository implements AcademicRepository {
  SupabaseAcademicRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<List<Faculty>, DataFailure>> getFaculties() async {
    try {
      final rows = await _client
          .from('faculties')
          .select('id, name')
          .order('sort_order');
      return Ok([
        for (final row in rows)
          Faculty(id: row['id'] as int, name: row['name'] as String),
      ]);
    } catch (error) {
      developer.log('Error al cargar facultades', error: error);
      return const Err(DataFailure.network);
    }
  }

  @override
  Future<Result<List<AcademicProgram>, DataFailure>> getPrograms(
    int facultyId,
  ) async {
    try {
      final rows = await _client
          .from('programs')
          .select('id, faculty_id, name')
          .eq('faculty_id', facultyId)
          .order('sort_order');
      return Ok([
        for (final row in rows)
          AcademicProgram(
            id: row['id'] as int,
            facultyId: row['faculty_id'] as int,
            name: row['name'] as String,
          ),
      ]);
    } catch (error) {
      developer.log('Error al cargar carreras', error: error);
      return const Err(DataFailure.network);
    }
  }
}
