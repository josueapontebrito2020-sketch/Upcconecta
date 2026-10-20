import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/report_reason.dart';
import '../repositories/feed_repository.dart';

/// Envía un reporte (denuncia) de una publicación para que se revise.
class ReportPost {
  const ReportPost(this._repository);

  final FeedRepository _repository;

  Future<Result<void, DataFailure>> call(String postId, ReportReason reason) {
    return _repository.reportPost(postId, reason);
  }
}
