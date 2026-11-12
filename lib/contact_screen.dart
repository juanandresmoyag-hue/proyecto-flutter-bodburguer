import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'profile_validators.dart';
import 'profile_widgets.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();

  void _send() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    _formKey.currentState!.reset();
    showDemoConfirmation(
      context,
      title: '¡Mensaje simulado enviado!',
      message:
          'Gracias por probar Contacto. Esta confirmación es demostrativa; '
          'no se envió ningún correo ni se guardaron tus datos.',
    );
  }

  @override
  Widget build(BuildContext context) => ProfileScaffold(
    title: 'Contacto',
    children: [
      const ProfileIntro(
        icon: Icons.chat_bubble_outline,
        title: 'Queremos escucharte',
        description:
            'Cuéntanos tu consulta usando datos ficticios. '
            'El envío de mensajes es simulado.',
      ),
      Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              decoration: ProfileStyles.input('Nombre'),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: ProfileValidators.requiredText,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: ProfileStyles.input('Correo electrónico'),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              validator: ProfileValidators.email,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: ProfileStyles.input('Motivo de consulta'),
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'pedido', child: Text('Mi pedido')),
                DropdownMenuItem(
                  value: 'beneficios',
                  child: Text('Promociones y coronas'),
                ),
                DropdownMenuItem(
                  value: 'sugerencia',
                  child: Text('Sugerencia'),
                ),
                DropdownMenuItem(value: 'otro', child: Text('Otro motivo')),
              ],
              onChanged: (_) {},
              validator: (value) =>
                  value == null ? 'Selecciona un motivo de consulta.' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: ProfileStyles.input('Descripción del mensaje'),
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              minLines: 4,
              maxLines: 8,
              maxLength: 1000,
              validator: ProfileValidators.requiredText,
            ),
            ProfileSubmitButton(label: 'Enviar mensaje', onPressed: _send),
          ],
        ),
      ),
    ],
  );
}
