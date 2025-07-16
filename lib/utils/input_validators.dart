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

  /// Sanitiza un nombre o apellido para guardar archivos:
  /// - Reemplaza acentos.
  /// - Elimina espacios extremos.
  /// - Reemplaza espacios intermedios por "_".
  /// - Convierte todo a minúsculas.
  static String sanitizeName(String input) {
    String cleaned = input.trim();

    // Reemplazar tildes y diéresis
    _accentMap.forEach((accent, plain) {
      cleaned = cleaned.replaceAll(accent, plain);
    });

    // Eliminar cualquier carácter especial excepto letras y espacios
    cleaned = cleaned.replaceAll(RegExp(r'[^a-zA-Z\s]'), '');

    // Normalizar espacios múltiples
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    // Reemplazar espacios intermedios por "_"
    cleaned = cleaned.replaceAll(' ', '_');

    return cleaned.toLowerCase();
  }

  /// Valida que el nombre o apellido tenga solo letras y espacios.
  static String? validateNameOrSurname(String? value,
      {String fieldName = 'campo'}) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa tu $fieldName';
    }

    final regex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$');
    if (!regex.hasMatch(value.trim())) {
      return 'El $fieldName solo debe contener letras y espacios (sin números ni símbolos)';
    }

    return null;
  }
}
