# Sincronización Flutter → Google Stitch

**Estado: entrega parcial. Flutter verificado; sincronización remota pendiente de autenticación.**

## Proyecto y fecha

- Proyecto existente: <https://stitch.withgoogle.com/projects/10605328050222563737>
- Project ID: `10605328050222563737`.
- Recurso MCP: `projects/10605328050222563737`.
- Servidor oficial: <https://stitch.googleapis.com/mcp>.
- Fecha de comprobación e intento: **9 de noviembre de 2026, America/Lima**.
- Fecha de sincronización completada: **pendiente; todavía no se realizó**.
- Referencia: código Flutter del workspace, rama `andre`, con cambios sin commit.

No se ha creado otro proyecto ni se ha realizado ninguna escritura remota.
No se han eliminado, reemplazado o actualizado pantallas del equipo.

## Comprobación real del MCP y del acceso

El servidor no estaba registrado como herramienta de Stitch en la sesión. La
búsqueda de plugins por el nombre exacto `Stitch` no devolvió una integración
disponible. Se comprobó directamente el servidor oficial mediante JSON-RPC sobre
HTTP, sin enviar credenciales ni contenido privado.

| Operación realizada | Resultado observado | Alcance de la comprobación |
| --- | --- | --- |
| `initialize`, protocolo `2025-03-26` | HTTP 200; anuncia herramientas y recursos | El servidor está accesible; no acredita acceso al proyecto |
| `tools/list` | HTTP 200 | Expone `get_project`, `list_screens`, `get_screen`, `edit_screens` y `generate_screen_from_text` |
| `tools/call` → `get_project`, `name: projects/10605328050222563737` | **HTTP 401**, `isError: true` | Solicitud sin credencial de autenticación requerida |
| `list_screens` | No ejecutado tras fallar el acceso al proyecto | Inventario remoto desconocido |
| `get_screen` | No ejecutado; no hay IDs remotos obtenidos | Diseños originales sin inspeccionar |
| `edit_screens` / `generate_screen_from_text` | No ejecutados | Ninguna pantalla creada o actualizada |

El mensaje del servidor fue: «Request is missing required authentication credential».
La respuesta solicita autenticación válida. **No demuestra que la cuenta del usuario
carezca de permisos:** todavía no hay una sesión autenticada con la cual comprobarlos.

La disponibilidad de `initialize` y `tools/list` no se interpreta como permiso de
lectura o edición del proyecto. No se intentó generar pantallas sin inspeccionar
primero las existentes. La URL del proyecto tampoco pudo leerse con el lector web;
eso no sustituye la comprobación autorizada mediante MCP.

## Reporte A — Flutter

El módulo ya implementa Perfil, Registro, Guía rápida, Contacto, Newsletter,
Notificaciones y el diálogo de compartir. Los formularios tienen validaciones y
confirmaciones académicas simuladas. No hay almacenamiento de datos personales,
backend, notificaciones reales ni nuevas dependencias.

La navegación utiliza `Navigator` y `MaterialPageRoute`:

- Inicio → avatar con tooltip **Mi perfil** → Perfil.
- Login → **Regístrate aquí** → Registro → regreso a Login.
- Perfil → cada pantalla complementaria → regreso a Perfil.
- Registro válido → **Entendido** → regreso a la pantalla que abrió Registro.
- Guía, cuarto paso → **Finalizar** → Perfil.
- Perfil → **Compartir aplicación** → diálogo → Perfil.

El carrito y las opciones existentes de la barra inferior se conservan al regresar.

**Archivos creados en la implementación Flutter anterior:**

- `lib/profile_screen.dart`
- `lib/register_screen.dart`
- `lib/quick_guide_screen.dart`
- `lib/contact_screen.dart`
- `lib/newsletter_screen.dart`
- `lib/notification_settings_screen.dart`
- `lib/profile_widgets.dart`
- `lib/profile_validators.dart`
- `test/profile_module_test.dart`
- `test/support/network_images.dart`
- `docs/perfil-funciones-complementarias.md`

**Archivos modificados en la implementación Flutter anterior:**

- `lib/app_theme.dart`: estilos del módulo, reutilizando la paleta y el botón rojo.
- `lib/home_screen.dart`: acceso a Perfil desde el avatar existente.
- `lib/login_screen.dart`: acceso funcional a Registro.
- `test/bod_burguer_test.dart`: importación corregida a `flutter_test`.
- `test/widget_test.dart`: eliminación de una importación sin uso.

**Cambio de esta fase:** se añade únicamente este documento; no se modifica el
código Flutter para inventar funcionalidades que no existen en el prototipo.

Verificaciones del código final:

| Comprobación | Resultado |
| --- | --- |
| `flutter pub get` en la fase de implementación | Correcto, sin cambios de dependencias |
| Resolución de dependencias al repetir `flutter test` en esta fase | Correcta |
| `flutter test`, repetido antes de preparar la sincronización | **19 pruebas aprobadas, 0 fallos** |
| `flutter analyze`, repetido en esta fase | **No issues found!** |
| Revisión de los archivos y de las diferencias de integración | Conservan Login, Inicio, tema y barra inferior existentes |

La suite contiene 17 pruebas nuevas y dos anteriores. Incluye navegación,
validaciones, confirmaciones, cuatro pasos de guía, preferencias temporales,
compartir y las seis pantallas nuevas a 320×568, 390×844, 640×360 y 768×1024 con
texto al 150 %. También cubre Registro con teclado simulado y errores visibles.

La rama sigue siendo `andre`: existían cambios locales antes del trabajo, y la
instrucción de crear `feature/perfil-funciones-complementarias` estaba condicionada
a un árbol limpio. No se hicieron commits, push ni merges. La lista de archivos
no incluye los cambios generados preexistentes en `build/` y `windows/flutter/`.

## Reporte B — Stitch: correspondencia pendiente

**Pantallas creadas: ninguna. Pantallas actualizadas: ninguna.**
Los nombres siguientes son objetivos derivados de Flutter, no un inventario del
proyecto remoto. No se conocen todavía sus IDs ni enlaces individuales.

| Pantalla o estado que se debe sincronizar | Fuente Flutter | ID obtenido del MCP | Operación remota | Verificación visual |
| --- | --- | --- | --- | --- |
| Mi perfil | `lib/profile_screen.dart` | No obtenido | Pendiente de inventario y autenticación | Pendiente |
| Crear cuenta / Registro | `lib/register_screen.dart` | No obtenido | Pendiente de inventario y autenticación | Pendiente |
| Guía rápida, cuatro pasos | `lib/quick_guide_screen.dart` | No obtenido | Pendiente de inventario y autenticación | Pendiente |
| Contacto y confirmación | `lib/contact_screen.dart` | No obtenido | Pendiente de inventario y autenticación | Pendiente |
| Newsletter y confirmación | `lib/newsletter_screen.dart` | No obtenido | Pendiente de inventario y autenticación | Pendiente |
| Notificaciones y vista previa | `lib/notification_settings_screen.dart` | No obtenido | Pendiente de inventario y autenticación | Pendiente |
| Compartir aplicación, diálogo sobre Perfil | `lib/profile_screen.dart` | No obtenido | Estado complementario pendiente | Pendiente |

Colores, tipografía, componentes y espaciado de las pantallas originales de
Stitch **aún no se han inspeccionado**. Las especificaciones siguientes proceden
del código final y no afirman que el proyecto remoto ya las utilice.

## Referencia visual exacta del código final

| Propiedad | Valor Flutter |
| --- | --- |
| Sistema de componentes | Material Design 3 |
| Rojo principal | `#D92300` |
| Fondo crema | `#FFF8F1` |
| Beige | `#F2E8D8` |
| Fondo de introducciones | `#F8EDDC` |
| Texto principal | `#211A17` |
| Texto secundario | `#593A31` |
| Campos y tarjetas de opciones | Blanco |
| Márgenes laterales del módulo | 20 px lógicos |
| Ancho máximo del contenido | 640 px lógicos, adaptable a smartphone |
| Panel introductorio | Radio de 28 px; padding de 24 px |
| Tarjetas de opciones | Radio de 20 px; separación inferior de 10 px |
| Campos de formulario | Radio de 18 px; padding horizontal 16 y vertical 18 px |
| Separación entre campos | 16 px |
| Botón principal | Rojo, texto blanco; forma de píldora; altura mínima 52 px |
| Jerarquía | `headlineSmall`, `titleLarge`, `titleMedium` y textos del tema Material |
| Iconos | Material Design; avatar de Perfil local sin foto remota |

No hay una familia tipográfica personalizada en el código; no afirmar que se usa
una fuente de marca específica. Inspeccionar la tipografía del proyecto Stitch
antes de resolver diferencias. No aplicar un tema global a los módulos del equipo.

Todas las pantallas incluyen el aviso:

> Proyecto académico SENATI · No oficial. Datos, beneficios e interacciones demostrativos.

La sincronización debe reproducir las pantallas de la app, incluida su AppBar de
retorno y el desplazamiento vertical. No añadir una barra inferior a las pantallas
complementarias: Flutter conserva la barra anterior en Inicio, no dentro de Perfil.

## Contenido y estados por pantalla

### Mi perfil

Título **Mi perfil**, avatar rojo, **Alex Parrilla**, **alex@ejemplo.com**,
**Cuenta de demostración**, chip **450 coronas · Demo** y sección **Tu cuenta y más**.

Opciones, en el mismo orden que Flutter:

1. **Registro** — Prueba crear una cuenta.
2. **Guía rápida** — Conoce la app en cuatro pasos.
3. **Contacto** — Simula una consulta.
4. **Newsletter** — Novedades y promociones.
5. **Notificaciones** — Configura tus preferencias.
6. **Compartir aplicación** — Invita con una interacción simulada.

El nombre y correo son informativos. **No existe una pantalla para editar datos
de perfil**; no diseñar un botón de edición como si estuviera implementado.

### Registro

AppBar **Crear cuenta** e introducción **¡Tu próxima corona te espera!**.
Campos **Nombre completo**, **Correo electrónico**, **Celular peruano (9 dígitos)**,
**Contraseña**, **Confirmar contraseña**. Ambas contraseñas tienen control para
mostrar u ocultar. Enlace **Leer términos de la demostración**, checkbox
**Acepto los términos de la demostración.** y botón **Registrarme**.

Representar el formulario inicial y estados de error con los mensajes del código:

- Nombre vacío: **Este campo es obligatorio.**
- Correo vacío: **Ingresa tu correo electrónico.**
- Correo incorrecto: **Ingresa un correo válido, por ejemplo: nombre@correo.com.**
- Celular incorrecto: **Ingresa 9 dígitos de un celular peruano que empiece con 9.**
- Contraseña vacía: **Ingresa una contraseña.**
- Contraseña corta: **Usa al menos 8 caracteres.**
- Confirmación vacía: **Confirma tu contraseña.**
- Confirmación distinta: **Las contraseñas no coinciden.**
- Términos sin aceptar: **Debes aceptar los términos para continuar.**

Éxito: diálogo **¡Registro simulado completado!**, texto aclarando que no se crea
cuenta real ni se envían o guardan datos, botón **Entendido**. Los campos se limpian
antes del diálogo; al cerrarlo se regresa a Login o Perfil, según la ruta previa.
El enlace de términos muestra **Términos de la demostración** con botón **Cerrar**.

### Guía rápida

AppBar **Guía rápida**. Representar cuatro estados del mismo recorrido:

1. **Explora nuestro menú**.
2. **Personaliza y agrega productos**.
3. **Confirma tu pedido**.
4. **Acumula coronas y disfruta beneficios**.

Mostrar **Paso 1 de 4** a **Paso 4 de 4**, progreso lineal de 25 %, 50 %, 75 % y
100 %. Botones **Anterior** y **Siguiente**; Anterior está deshabilitado en el
primer paso y Siguiente cambia a **Finalizar** en el cuarto. También se permite
deslizar horizontalmente. Finalizar vuelve a Perfil. No añadir un botón Omitir:
no existe en la implementación.

Usar las descripciones de `lib/quick_guide_screen.dart`; la personalización se
describe para cuando esté disponible el módulo de menú y los pedidos, cobros y
beneficios se identifican como demostrativos.

### Contacto

AppBar **Contacto**, introducción **Queremos escucharte**. Campos **Nombre**,
**Correo electrónico**, selector **Motivo de consulta** con **Mi pedido**,
**Promociones y coronas**, **Sugerencia** y **Otro motivo**; campo multilínea
**Descripción del mensaje**, máximo 1000 caracteres. Botón **Enviar mensaje**.

Validar campos obligatorios y correo; el selector vacío muestra
**Selecciona un motivo de consulta.**. Éxito: diálogo **¡Mensaje simulado enviado!**,
explicación de que no hubo correo real ni almacenamiento y botón **Entendido**.
Después de cerrar el diálogo se permanece en Contacto, con el formulario vacío.

### Newsletter

AppBar **Newsletter**, introducción **¡Novedades recién salidas de la parrilla!**,
campo **Correo electrónico**, checkbox
**Quiero recibir novedades y promociones en esta demostración.** y botón **Suscribirme**.

Usar los mismos mensajes de correo que Registro. Falta de consentimiento:
**Necesitamos tu consentimiento para simular la suscripción.**. Éxito: diálogo
**¡Suscripción simulada completada!**, aclaración de que no se guardó el correo ni
se recibirán mensajes reales, botón **Entendido**. Después se permanece en
Newsletter con correo y consentimiento restablecidos.

### Notificaciones

La AppBar del código dice **Notificaciones**, aunque el objetivo funcional sea
preferencias de notificaciones. Introducción **Elige qué te interesa**.
Tres interruptores independientes, inicialmente desactivados:

- **Promociones y descuentos**.
- **Estado de pedidos**.
- **Nuevos beneficios y coronas**.

Botón **Ver notificación de ejemplo**. Muestra un diálogo
**Notificación de ejemplo**, **Bod Burguer · ¡Una corona más para ti!** y botón
**Cerrar**. Aclarar que la vista previa manual funciona independientemente de los
interruptores y no concede beneficios reales. No representar una notificación
real del sistema operativo ni una solicitud de permisos.

Las preferencias solo duran mientras Perfil permanece abierto en la pila de
navegación; se conservan al volver a Perfil y reabrir Notificaciones. Al salir a
Inicio y abrir Perfil de nuevo se restablecen. No simular persistencia permanente.

### Compartir aplicación

Diálogo sobre Perfil con título **Compartir aplicación**, mensaje de invitación
al prototipo académico, aclaración de que no abre otras aplicaciones ni envía
mensajes y acciones **Cancelar** / **Simular compartir**. La segunda acción cierra
el diálogo y muestra **¡Aplicación compartida de forma simulada!** en un SnackBar.
No añadir contactos, WhatsApp, correo ni enlaces de publicación inexistentes.

## Cómo completar la sincronización pendiente

1. Conectar el MCP oficial `https://stitch.googleapis.com/mcp` y autenticarlo con una
   cuenta con acceso al proyecto existente. Utilizar la
   [guía oficial de configuración de Stitch](https://stitch.withgoogle.com/docs/mcp/setup/).
   Configurar credenciales por el mecanismo seguro del cliente; no incluirlas en
   este repositorio ni pegarlas en el chat. La instalación de habilidades por sí
   sola no autentica el servidor.
2. Ejecutar `get_project` con estos argumentos y comprobar el proyecto devuelto:

   ```json
   {"name":"projects/10605328050222563737"}
   ```

3. Ejecutar `list_screens` con el formato de argumentos comprobado en el servidor:

   ```json
   {"projectId":"10605328050222563737"}
   ```

4. Registrar el inventario y consultar cada pantalla relevante con `get_screen`:

   ```json
   {"name":"projects/10605328050222563737/screens/ID_REAL_DEVUELTO_POR_EL_SERVIDOR"}
   ```

   Inspeccionar imágenes y contenido para identificar colores, tipografía,
   componentes, espaciados y navegación. Incluir Inicio/Login como referencias de
   identidad, sin modificarlos. Identificar y preservar Inicio, Menú, Promociones,
   Carrito, Restaurantes y cualquier diseño de compañeros. No decidir por el nombre
   de una pantalla solamente: verificar su contenido y función.
5. Si ya hay una pantalla de este módulo que corresponda actualizar, usar
   `edit_screens` con `projectId`, los IDs confirmados en `selectedScreenIds` y un
   `prompt` limitado a esa pantalla. Para smartphone, `deviceType: "MOBILE"`.
   No seleccionar diseños ajenos o la totalidad del proyecto.
6. Para una pantalla que realmente falte, usar `generate_screen_from_text` con
   `projectId: "10605328050222563737"`, `deviceType: "MOBILE"` y el contenido exacto
   de esta especificación. Reutilizar el sistema visual inspeccionado; si el
   servidor devuelve un sistema de diseño del proyecto, reutilizar su identificador
   cuando proceda. No crear un proyecto nuevo ni aplicar cambios globales.
7. Trabajar pantalla por pantalla. Representar las validaciones y confirmaciones
   como estados complementarios del módulo, identificados como demostrativos.
   Los cuatro pasos de la guía pueden ser estados o frames separados dentro del
   mismo proyecto si así lo exige Stitch. No inventar funcionalidades adicionales.
8. Tras cada operación, recoger los IDs devueltos y volver a consultar las pantallas
   con `get_screen`. Verificar visualmente campos, etiquetas, botones, colores,
   orden de opciones y estados contra Flutter. Volver a ejecutar `list_screens`
   y comparar con el inventario inicial para confirmar que se mantienen los diseños
   anteriores. No dar por finalizada una generación solo porque se envió la solicitud.
9. Configurar los recorridos si la capacidad disponible lo permite. Si no, documentar
   las conexiones de la sección Reporte A; no afirmar que Stitch ya navega entre
   frames. Los esquemas de las cinco herramientas inspeccionadas no acreditan por
   sí solos una función para enlazar interacciones.
10. Reemplazar los estados pendientes de este documento con los IDs y enlaces
    reales, pantallas creadas/actualizadas, fecha de sincronización completada,
    diferencias verificadas y comprobación de conservación del inventario anterior.

Esquema orientativo para generar una pantalla **solo después del inventario**:

```json
{
  "projectId": "10605328050222563737",
  "deviceType": "MOBILE",
  "prompt": "Sincroniza únicamente la pantalla del módulo identificada, usando el código Flutter y los textos de docs/stitch-sync.md como referencia. Conserva la identidad del proyecto inspeccionado. No cambies ni reemplaces otras pantallas. Incluye el aviso académico y sus estados demostrativos implementados."
}
```

Este ejemplo no se ha ejecutado y requiere concretar qué pantalla falta y su
contenido antes de enviarlo. Para una pantalla existente se debe usar edición,
no este ejemplo de generación.

## Diferencias pendientes y criterios de cierre

| Aspecto | Estado actual / acción pendiente |
| --- | --- |
| Autenticación y permiso de lectura | HTTP 401; conectar una credencial válida y repetir `get_project` |
| Permiso de edición | No verificado; comprobar con la sesión autenticada antes de escribir |
| Inventario del proyecto existente | Desconocido; faltan `list_screens` y `get_screen` |
| Paleta y tipografía originales de Stitch | Sin inspeccionar; contrastar con la referencia Flutter de este documento |
| Seis pantallas equivalentes | Implementadas en Flutter; creación o actualización remota no realizada |
| Validaciones, confirmaciones, guía y compartir en Stitch | Estados remotos pendientes de representación y revisión |
| Recorridos entre frames de Stitch | Pendientes; documentar cualquier interacción que no pueda configurarse |
| Edición de datos de perfil | No implementada en Flutter; no presentarla como función disponible |
| Conservación del trabajo anterior | No hubo escrituras; la futura sincronización requiere inventario antes/después |
| IDs y enlaces individuales | No obtenidos; no se inventan ni se deducen de otros proyectos |

Inicio conserva los desbordamientos móviles preexistentes documentados en
`docs/perfil-funciones-complementarias.md`. La implementación nueva pasó sus
pruebas de adaptación por separado. No se ha probado en un teléfono físico o
emulador Android/iOS ni se ha hecho una comparación visual Flutter–Stitch.

**La tarea global no está terminada:** requiere acceso autenticado, actualización
del proyecto existente y lectura posterior de las pantallas para verificar el
resultado. Este documento prepara esa continuación; no acredita una sincronización.
