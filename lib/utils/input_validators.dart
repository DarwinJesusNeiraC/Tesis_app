class InputValidators {
  static final _accentMap = {
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'Á': 'a',
    'É': 'e',
    'Í': 'i',
    'Ó': 'o',
    'Ú': 'u',
    'ñ': 'n',
    'Ñ': 'n',
    'ü': 'u',
    'Ü': 'u',
  };

  /// Sanitiza un nombre/apellido:
  /// - Reemplaza tildes, diéresis.
  /// - Elimina símbolos.
  /// - Reemplaza espacios por guiones bajos.
  /// - Convierte todo a minúsculas.
  static String sanitizeName(String input) {
    String cleaned = input.trim();

    // Reemplazar tildes/dieresis
    _accentMap.forEach((accent, plain) {
      cleaned = cleaned.replaceAll(accent, plain);
    });

    // Eliminar caracteres especiales (solo letras, números, espacios)
    cleaned = cleaned.replaceAll(RegExp(r'[^\w\s]'), '');

    // Normalizar espacios múltiples
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    // Reemplazar espacios intermedios por _
    cleaned = cleaned.replaceAll(' ', '_');

    return cleaned.toLowerCase();
  }

  /// Valida que sea un nombre o apellido válido.
  static String? validateNameOrSurname(String? value,
      {String fieldName = 'campo'}) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa tu $fieldName';
    }

    final sanitized = sanitizeName(value);

    final validPattern = RegExp(r'^[a-z0-9_]+$');
    if (!validPattern.hasMatch(sanitized)) {
      return 'Solo letras sin acentos, números y guiones bajos. Sin símbolos.';
    }

    return null;
  }
}
