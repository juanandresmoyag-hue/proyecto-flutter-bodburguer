# Bod Burguer

Aplicación Flutter con una pantalla de inicio de sesión para Burger King Perú.

## Estructura

- `lib/main.dart`: inicia la aplicación.
- `lib/app_theme.dart`: contiene los colores y estilos compartidos.
- `lib/login_screen.dart`: contiene la pantalla y sus interacciones.

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
flutter run
```

La pantalla permite alternar entre ingreso con celular y correo, mostrar u
ocultar la clave, activar el recordatorio del dispositivo y explorar las
opciones de acceso rápido y como invitado.
