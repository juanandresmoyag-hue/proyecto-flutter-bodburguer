import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'profile_validators.dart';
import 'profile_widgets.dart';

class NewsletterScreen extends StatefulWidget {
  const NewsletterScreen({super.key});

  @override
  State<NewsletterScreen> createState() => _NewsletterScreenState();
}

class _NewsletterScreenState extends State<NewsletterScreen> {
  final _formKey = GlobalKey<FormState>();

  void _subscribe() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    _formKey.currentState!.reset();
    showDemoConfirmation(
      context,
      title: '¡Suscripción simulada completada!',
      message:
          'Probaste la suscripción voluntaria. No se guardó tu correo '
          'ni recibirás mensajes reales.',
    );
  }

  @override
  Widget build(BuildContext context) => ProfileScaffold(
    title: 'Newsletter',
    children: [
      const ProfileIntro(
        icon: Icons.mark_email_unread_outlined,
        title: '¡Novedades recién salidas de la parrilla!',
        description:
            'Descubre promociones, lanzamientos y beneficios. '
            'Prueba esta suscripción con un correo ficticio; es voluntaria y simulada.',
      ),
      Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              decoration: ProfileStyles.input('Correo electrónico'),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autocorrect: false,
              validator: ProfileValidators.email,
            ),
            const SizedBox(height: 16),
            const ConsentField(
              label: 'Quiero recibir novedades y promociones en esta demostración.',
              errorMessage:
                  'Necesitamos tu consentimiento para simular la suscripción.',
            ),
            ProfileSubmitButton(label: 'Suscribirme', onPressed: _subscribe),
          ],
        ),
      ),
    ],
  );
}
