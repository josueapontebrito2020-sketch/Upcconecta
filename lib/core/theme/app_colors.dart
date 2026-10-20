import 'package:flutter/painting.dart';

/// Paleta de UpcConecta, tomada del manual de identidad de la Universidad
/// Popular del Cesar. El manual da los colores en Pantone; estos HEX son
/// equivalentes aproximados. Si la universidad entrega los códigos exactos,
/// se cambian solo aquí.
abstract final class AppColors {
  /// Pantone 356: color principal (botones, banda superior).
  static const Color verdeUpc = Color(0xFF007A33);

  /// Versión más oscura del verde principal, para estados presionados.
  static const Color verdeProfundo = Color(0xFF005C27);

  /// Pantone 362: verde secundario.
  static const Color verdeHoja = Color(0xFF509E2F);

  /// Pantone 7488: verde claro, usado sobre fondos verdes.
  static const Color verdeBrote = Color(0xFF78D64B);

  /// Amarillo institucional (R255 G245). Solo como acento puntual.
  static const Color amarillo = Color(0xFFFFF500);

  /// Negro al 80 % del manual (R83 G80 B79): textos secundarios.
  static const Color tintaSuave = Color(0xFF53504F);

  /// Texto principal.
  static const Color tinta = Color(0xFF262524);

  static const Color superficie = Color(0xFFFFFFFF);

  /// Fondo de las pantallas con tarjetas (inicio, chats, grupos).
  static const Color fondo = Color(0xFFEFF4EE);

  /// "Me gusta" activo.
  static const Color corazon = Color(0xFFE5394B);

  /// Fondo de los campos de texto.
  static const Color campo = Color(0xFFF3F7F2);

  static const Color borde = Color(0xFFD5DFD2);

  static const Color error = Color(0xFFB3261E);
  static const Color errorFondo = Color(0xFFFCEEEE);
}
