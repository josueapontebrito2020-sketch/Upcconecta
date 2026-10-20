import '../../l10n/app_localizations.dart';
import 'date_utils.dart';

/// Hace cuánto pasó algo (una publicación, una visita), en corto: "Ahora",
/// "25 min", "5 h", "2 d". Después de una semana, la fecha (dd/mm/aaaa).
String timeAgo(DateTime date, AppLocalizations l10n, {DateTime? now}) {
  final elapsed = (now ?? DateTime.now()).difference(date);
  if (elapsed.inMinutes < 1) return l10n.timeNow;
  if (elapsed.inHours < 1) return l10n.timeMinutes(elapsed.inMinutes);
  if (elapsed.inDays < 1) return l10n.timeHours(elapsed.inHours);
  if (elapsed.inDays < 7) return l10n.timeDays(elapsed.inDays);
  return formatDayMonthYear(date);
}
