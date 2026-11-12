# Bod Burguer

Aplicación Flutter con una pantalla de inicio de sesión para Burger King Perú.

## Estructura

- `lib/main.dart`: inicia la aplicación.
- `lib/cart_screen.dart`: administra el carrito y guarda pedidos autenticados.
- `lib/services/`: autenticación, perfiles, eventos de acceso y pedidos.
- `lib/app_theme.dart`: contiene los colores y estilos compartidos.
- `lib/login_screen.dart`: contiene la pantalla y sus interacciones.
- `lib/promotions_screen.dart`: muestra la sección de cupones, recompensas y
  promociones, con filtros, favoritos y canje de demostración.
- `assets/promotions/`: fotografías de muestra de Unsplash para las tarjetas;
  no son imágenes oficiales del restaurante.

## Ejecutar

Instala el [SDK de Flutter para Windows](https://docs.flutter.dev/install) y
agrega la carpeta `flutter\bin` al `PATH` de Windows. Luego cierra y vuelve a
abrir la terminal de VS Code y verifica la instalación:

```shell
flutter --version
flutter doctor
```

Cuando `flutter --version` funcione, ejecuta desde la raíz del proyecto:

```shell
flutter pub get
```

## Configurar Firebase

1. Crea un proyecto en [Firebase Console](https://console.firebase.google.com/).
2. Activa **Authentication > Sign-in method > Email/Password**.
3. Crea una base de datos de **Cloud Firestore**.
4. Agrega una app web (para ejecutar en Chrome) y, si las usaras, apps Android,
   iOS o macOS. Copia sus valores de configuracion del SDK.
5. Crea `firebase_config.json` en la raiz del proyecto. El archivo esta ignorado
   por Git:

```json
{
  "FIREBASE_API_KEY": "api-key-del-proyecto",
  "FIREBASE_PROJECT_ID": "id-del-proyecto",
  "FIREBASE_MESSAGING_SENDER_ID": "sender-id",
  "FIREBASE_AUTH_DOMAIN": "id-del-proyecto.firebaseapp.com",
  "FIREBASE_STORAGE_BUCKET": "id-del-proyecto.firebasestorage.app",
  "FIREBASE_WEB_APP_ID": "id-de-la-app-web",
  "FIREBASE_ANDROID_APP_ID": "",
  "FIREBASE_IOS_APP_ID": "",
  "FIREBASE_MACOS_APP_ID": ""
}
```

Completa los `APP_ID` de cada plataforma que registres en Firebase. La API key
del cliente no es una credencial de administrador; protege los datos con las
reglas de Firestore, nunca con una clave de servicio en la app.

Instala Firebase CLI, inicia sesion y publica las reglas de acceso incluidas:

```shell
npm install -g firebase-tools
firebase login
firebase deploy --only firestore:rules --project id-del-proyecto
```

Luego ejecuta en Chrome:

```shell
flutter run -d chrome --dart-define-from-file=firebase_config.json
```

Firebase Auth guarda las contrasenas y mantiene la sesion. **Recordarme** solo
guarda el correo en el dispositivo; nunca almacena la contrasena. Cada registro
y acceso crea un evento en Firestore. El carrito permite cambiar cantidades y
guardar pedidos bajo la cuenta autenticada.

Los pedidos son demostrativos: no procesan pagos ni envios. Sus precios se
originan en el cliente y no deben usarse como importes comerciales sin una
validacion en un servidor confiable. Los eventos de acceso escritos desde el
cliente sirven para historial de la cuenta, no como auditoria de seguridad
infalsificable. Windows y Linux no tienen soporte para Firebase Auth/Firestore
en esta configuracion; usa Chrome, Android, iOS o macOS.

Sin los valores de un proyecto Firebase, la app abre pero el registro, el
inicio de sesion y el guardado de pedidos muestran que falta configuracion; no
simulan una operacion exitosa. Las promociones, recompensas y canjes siguen
siendo de demostracion y no aplican descuentos reales.
