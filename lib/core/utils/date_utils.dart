// Fechas en formato colombiano: dd/mm/aaaa.

/// Convierte "24/03/2005" en una fecha. Devuelve `null` si el texto está
/// incompleto o la fecha no existe (por ejemplo, 31/02/2005).
DateTime? parseDayMonthYear(String text) {
  final parts = text.split('/');
  if (parts.length != 3 || parts[2].length != 4) return null;

  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;

  final date = DateTime(year, month, day);
  final exists = date.year == year && date.month == month && date.day == day;
  return exists ? date : null;
}

/// Convierte una fecha en "24/03/2005".
String formatDayMonthYear(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

/// Convierte una fecha en "2005-03-24", el formato que guarda la base de datos.
String formatIsoDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

/// Años cumplidos a la fecha [today].
int ageOn(DateTime birthDate, DateTime today) {
  var age = today.year - birthDate.year;
  final hadBirthday =
      today.month > birthDate.month ||
      (today.month == birthDate.month && today.day >= birthDate.day);
  if (!hadBirthday) age--;
  return age;
}
