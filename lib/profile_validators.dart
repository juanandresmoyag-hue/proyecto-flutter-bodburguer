/// Pure validators shared by the demonstration forms. No data is persisted.
class ProfileValidators {
  static String? requiredText(String? value) =>
      value == null || value.trim().isEmpty
      ? 'Este campo es obligatorio.'
      : null;

  static String? email(String? value) {
    if (requiredText(value) != null) return 'Ingresa tu correo electrónico.';
    if (!RegExp(r'^[^\s@]+@[^\s@.]+(?:\.[^\s@.]+)+$').hasMatch(value!.trim())) {
      return 'Ingresa un correo válido, por ejemplo: nombre@correo.com.';
    }
    return null;
  }

  static String? phone(String? value) {
    if (!RegExp(r'^9[0-9]{8}$').hasMatch(value?.trim() ?? '')) {
      return 'Ingresa 9 dígitos de un celular peruano que empiece con 9.';
    }
    return null;
  }

  static String? password(String? value) {
    if (requiredText(value) != null) return 'Ingresa una contraseña.';
    return value!.length < 8 ? 'Usa al menos 8 caracteres.' : null;
  }
}
