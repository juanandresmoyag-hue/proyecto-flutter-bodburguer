import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Layout shared by the academic profile module, including keyboard-safe scroll.
class ProfileScaffold extends StatelessWidget {
  const ProfileScaffold({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...children,
                const SizedBox(height: 24),
                const DemoNotice(),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class DemoNotice extends StatelessWidget {
  const DemoNotice({super.key});

  @override
  Widget build(BuildContext context) => const Text(
    'Proyecto académico SENATI · No oficial. '
    'Datos, beneficios e interacciones demostrativos.',
    textAlign: TextAlign.center,
    style: TextStyle(color: AppColors.brown, fontSize: 12, height: 1.5),
  );
}

class ProfileIntro extends StatelessWidget {
  const ProfileIntro({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    margin: const EdgeInsets.only(bottom: 24),
    decoration: BoxDecoration(
      color: AppColors.hero,
      borderRadius: BorderRadius.circular(28),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 40, color: AppColors.red),
        const SizedBox(height: 16),
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(description, style: const TextStyle(height: 1.5)),
      ],
    ),
  );
}

class ProfileSubmitButton extends StatelessWidget {
  const ProfileSubmitButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 20),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ProfileStyles.primaryButton,
      child: Text(label, textAlign: TextAlign.center),
    ),
  );
}

/// Consent participates in Form validation and resets with the rest of the form.
class ConsentField extends StatelessWidget {
  const ConsentField({
    super.key,
    required this.label,
    required this.errorMessage,
  });

  final String label;
  final String errorMessage;

  @override
  Widget build(BuildContext context) => FormField<bool>(
    initialValue: false,
    validator: (value) => value == true ? null : errorMessage,
    builder: (field) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(label),
          value: field.value ?? false,
          onChanged: field.didChange,
        ),
        if (field.hasError)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Semantics(
              liveRegion: true,
              child: Text(
                field.errorText!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
      ],
    ),
  );
}

Future<void> showDemoConfirmation(
  BuildContext context, {
  required String title,
  required String message,
}) => showDialog<void>(
  context: context,
  barrierDismissible: false,
  builder: (dialogContext) => AlertDialog(
    scrollable: true,
    icon: const Icon(
      Icons.check_circle_outline,
      color: AppColors.red,
      size: 40,
    ),
    title: Text(title),
    content: Text(message),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(dialogContext).pop(),
        child: const Text('Entendido'),
      ),
    ],
  ),
);
