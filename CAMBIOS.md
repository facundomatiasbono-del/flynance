# Estado actual de Flynance

## Inicio

- Registro manual de gastos con importe, categoría y detalle.
- Palabras clave personales vinculadas a cada categoría.
- Las palabras clave se pueden crear, seleccionar, renombrar y eliminar.
- Al seleccionar una palabra clave, se agrega automáticamente al detalle.
- Recordatorios mensuales de gastos fijos en una sección plegable.
- Los pagos fijos se pueden marcar como realizados y se agregan automáticamente a los gastos del mes.
- Actividad con filtros discretos por fecha o categoría.
- Iconos personalizados para las categorías en los últimos gastos.
- La actividad muestra el mes y el año actuales y únicamente los gastos de ese mes.
- Edición integrada de cada gasto, sin ventanas emergentes, para cambiar detalle, categoría e importe.
- Los botones de la edición integrada muestran únicamente los iconos de cancelar y guardar.
- Cada gasto se puede desplegar para consultar fecha, hora, origen (App o WhatsApp), categoría, detalle e importe.
- Los gastos editados muestran la versión inmediatamente anterior y la fecha de la edición.

## Análisis

- Distribución por categoría con importe y porcentaje.
- Filtros por fecha, categoría, mes o palabra clave.
- Los filtros se aplican simultáneamente a las barras de distribución y al gráfico donut.
- Los importes, porcentajes y el total del donut se recalculan con los gastos filtrados.
- Gráfico donut del mes actual a la derecha de la distribución.
- Iconos personalizados en la distribución por categoría.
- Los iconos de “Distribución por categoría” usan el color asociado a su segmento del donut.
- El donut incluye el icono de cada categoría dentro de su segmento.
- Los iconos internos conservan el color de la categoría y utilizan un fondo adaptado al panel y al tema visual.

## Ajustes

- Selector de tema blanco o negro mediante interruptor deslizable.
- Selector de idioma mediante botones visibles ES y EN.
- Selector de moneda con monedas sudamericanas, USD, EUR y TRY.
- Botón independiente, alineado a la derecha, para guardar la moneda seleccionada.
- Configuración de ingreso mensual y alerta de gastos.
- Administración de gastos fijos; el formulario para agregar aparece al final de la sección.
- Administración de categorías; el formulario para agregar aparece al final de la sección.
- Edición integrada del nombre y el icono de cada categoría, sin ventanas emergentes.
- Selector visual de iconos para categorías predeterminadas y personalizadas.
- Configuración de WhatsApp ubicada como última sección.

## Navegación

La barra superior siempre muestra estos accesos, en este orden:

1. Inicio.
2. Análisis.
3. Ajustes.
4. Cerrar sesión.

## Migraciones de Supabase

Además de las migraciones iniciales, deben ejecutarse en orden:

1. `005_fixed_expense_payments.sql`: pagos mensuales de gastos fijos.
2. `006_expense_keywords.sql`: palabras clave por categoría.
3. `007_profile_currency.sql`: moneda seleccionada por el usuario.
4. `008_category_icons.sql`: iconos personalizables para categorías.
5. `009_expense_edit_history.sql`: estado anterior y fecha de la última edición de cada gasto.
6. `010_onboarding_preferences.sql`: onboarding completado, tema e idioma sincronizados.

Los archivos están en `supabase/migrations/`.

## Ejecutar localmente

Desde CMD:

```cmd
cd /d C:\Users\cengi\Desktop\Python\flynance
npm run dev
```

Abrir la dirección mostrada por Vite, normalmente `http://localhost:5173`.

## Mejoras visuales y funcionales recientes

- El botón “Guardar gasto” tiene un tamaño compacto y está alineado a la derecha.
- En Análisis se agregó un gráfico de área con los gastos realizados por día, los importes en el eje Y y los días del mes en el eje X.
- El gráfico de área responde a los filtros aplicados y muestra el importe exacto de cada día.
- Los botones para editar y quitar categorías comparten el estilo visual de los controles de gastos fijos.
- Cuando una cuenta de WhatsApp está vinculada, el número queda bloqueado y se muestra un indicador de confirmación.
- El botón “Editar” habilita el número sin guardarlo automáticamente; los cambios solo se vinculan al presionar “Guardar cambios”.

## Actualización de Analytics y experiencia de uso

- El gráfico de área se movió debajo de los gráficos de distribución y utiliza una curva suave.
- Se agregaron las vistas “Mensual” y “Anual”, sin desplazamiento horizontal.
- La vista mensual muestra todos los días, el límite de gasto y el punto interactivo donde se alcanzó.
- La distribución por categoría y la dona comparten una selección interactiva: elegir una categoría en cualquiera de las dos resalta la misma información.
- La dona muestra los porcentajes dentro de sus segmentos.
- Analytics permite descargar el reporte filtrado en CSV o compartirlo mediante las aplicaciones disponibles en el dispositivo.
- Los filtros se cierran al hacer clic fuera, ocultan su configuración después de aplicarse y ofrecen la opción “Restablecer”.
- Los detalles de los últimos gastos incluyen origen, hora, importe y gasto acumulado hasta ese momento.
- Las acciones de editar y eliminar aparecen únicamente dentro del detalle desplegado.
- Las filas de gastos, gastos fijos, categorías y distribución comparten estados visuales redondeados al pasar el mouse.
- La planificación mensual muestra “Guardar cambios” solamente cuando se modifica el ingreso o el límite de gasto.
- El selector de categorías incluye diez iconos adicionales.
- Se actualizaron el icono de la marca y el favicon con un gráfico ascendente.

## Android y recuperación de acceso

- Se preparó una instalación portátil de JDK 21 y Android SDK para compilar sin Android Studio.
- Se generó el APK de prueba `Flynance-debug.apk`, firmado y apto para instalación manual.
- La web compilada se sincroniza con Android mediante Capacitor.
- Se agregó “Olvidé mi contraseña” en la pantalla de ingreso.
- El usuario puede solicitar por correo un enlace seguro de recuperación.
- Al abrir el enlace se muestra una pantalla para establecer una contraseña nueva.
- Las contraseñas existentes no se pueden consultar porque Supabase las almacena como hashes irreversibles.
- Analytics permite descargar un reporte CSV o compartirlo mediante las aplicaciones disponibles en el dispositivo.

## Seguridad y planificación mensual

- Los campos de contraseña incluyen un botón para mostrar u ocultar el contenido.
- La aplicación Android conserva la sesión y protege el acceso mediante huella, rostro, PIN o patrón del dispositivo.
- El bloqueo se activa al iniciar nuevamente la aplicación o regresar desde segundo plano.
- “Planificación mensual” permanece cerrada por defecto y utiliza un interruptor para mostrar u ocultar su contenido.
- Los valores de ingreso y límite de gasto están bloqueados hasta presionar el botón de edición.
- Durante la edición se muestran una “X” para cancelar y un tilde para guardar.
- Estos cambios fueron incorporados a la compilación release del 28/07/2026.

## Identidad Flynance y actualizaciones privadas (28/07/2026)

- Se cambió la identidad Android de `com.misgastos.app` a `com.flynance.app`.
- Se creó la clave permanente `flynance-release`, almacenada localmente fuera de Git.
- Se agregó comprobación automática de actualizaciones al iniciar la APK.
- Ajustes incluye la opción para buscar actualizaciones manualmente.
- La descarga nativa solo acepta HTTPS desde el Worker oficial de Flynance.
- Antes de abrir el instalador, la APK descargada se valida mediante SHA-256.
- Android solicita autorización para instalar aplicaciones desde Flynance y confirmación para cada actualización.
- Se generó `Flynance.apk` como release 1.0 (versionCode 1), firmado con el certificado de Flynance.
- El APK y `version.json` se publicaron en Cloudflare Workers.
- Despliegue comprobado: `d2cef921-585c-4b91-82da-a4d6997cdd4b`.
- SHA-256 del APK: `D747FF57B02755656C45FE6CCF3344190F7D75A4ECDAAB6A0301909851AB0ADF`.

## Onboarding y preferencias sincronizadas

- Se agregó un onboarding que aparece después del primer inicio de sesión confirmado.
- El recorrido permite elegir idioma, tema claro/oscuro/sistema y moneda.
- La planificación mensual, ingreso, alerta de gasto y WhatsApp son opcionales.
- En Android se puede elegir si se activa el bloqueo mediante seguridad del dispositivo.
- El tema se aplica inmediatamente durante el recorrido.
- La opción “Sistema” responde a cambios del tema del teléfono o la computadora.
- Idioma y tema también se pueden modificar desde Ajustes y se sincronizan con el perfil.
- La finalización se guarda en Supabase para no repetir el recorrido en otros dispositivos.
- Se agregó `supabase/migrations/010_onboarding_preferences.sql`.
- `npm.cmd run build` terminó correctamente.
- Estos cambios todavía no fueron incorporados a una nueva APK, según el flujo de compilación acordado.

## Validación de correos duplicados

- El registro detecta la respuesta ofuscada que Supabase devuelve cuando el correo ya pertenece a una cuenta confirmada.
- En lugar de indicar que se envió una confirmación, Flynance avisa que el correo ya está registrado y ofrece ingresar o recuperar la contraseña.
- Los correos se normalizan quitando espacios exteriores y convirtiéndolos a minúsculas antes de autenticar.
- El mensaje de estado se limpia al alternar entre registro e inicio de sesión.
- La aplicación web compiló correctamente; todavía no se generó una nueva APK.
- La web actualizada se publicó en Cloudflare Workers con la versión `a0851608-dc6c-4482-9f2d-85f2d2e0a009`.

## Continuidad del onboarding

- El botón “Atrás” utiliza el mismo estilo principal que “Continuar”.
- El paso actual y los campos temporales del onboarding se conservan por usuario durante la sesión del navegador.
- Minimizar y restaurar la ventana, renovar la sesión de Supabase o remontar el componente no reinicia el recorrido.
- El borrador temporal se elimina al finalizar correctamente el onboarding.
- La web compiló correctamente; no se generó una nueva APK.

## Corrección de URL de autenticación en Cloudflare

- Se detectó que Workers Builds tenía `VITE_SUPABASE_URL` apuntando al Worker de Flynance en vez de Supabase.
- Esa configuración enviaba el registro a una ruta incorrecta y provocaba `Unexpected end of JSON input`.
- El cliente ahora valida que la URL use HTTPS y pertenezca a `supabase.co`.
- Si la variable está ausente o es inválida, utiliza la URL pública correcta del proyecto Flynance.
- La web compiló correctamente; no se generó una nueva APK.

## Orden de monedas

- Los selectores de moneda del onboarding y Ajustes muestran primero ARS, luego USD y EUR, seguidos por el resto de las monedas.
- No se modificó la moneda predeterminada, que continúa siendo ARS.

## Nuevos idiomas

- Se agregaron francés, italiano y alemán a los idiomas disponibles, junto con español e inglés.
- Los cinco idiomas se pueden elegir durante el onboarding, desde Ajustes y desde la pantalla de acceso.
- La preferencia se conserva localmente y se sincroniza con el perfil del usuario.
- Las fechas, los meses y los importes usan el formato regional del idioma seleccionado.
- Se agregó `supabase/migrations/011_add_profile_languages.sql` para permitir los nuevos códigos de idioma en perfiles existentes.
- La aplicación web compiló correctamente; todavía no se generó una nueva APK.

## Categorías traducidas e iconos

- Los nombres de las categorías predeterminadas se muestran en el idioma elegido en formularios, actividad, análisis, filtros y Ajustes.
- Los valores internos de las categorías permanecen estables para no separar ni perder gastos existentes al cambiar de idioma.
- Los iconos predeterminados se asignan por significado y también reconocen nombres habituales en español, inglés, francés, italiano y alemán.
- El selector de iconos vuelve a mostrar cada opción real sin que el nombre de la categoría reemplace su vista previa.
- Se agregó `supabase/migrations/012_category_icon_catalog.sql` para habilitar todo el catálogo de iconos y corregir los iconos de las categorías predeterminadas.

## Movimientos excluidos de los totales

- Al editar un movimiento desde Actividad se puede activar “Excluir de los totales”.
- El movimiento permanece visible con la etiqueta “No contabilizado” y conserva su importe original.
- Los movimientos excluidos no afectan el total mensual, el dinero disponible, las alertas, los gráficos, las distribuciones ni los reportes.
- Se agregó `supabase/migrations/013_excluded_expenses.sql` para guardar esta preferencia en cada movimiento.
- La nueva APK continúa pendiente hasta finalizar el conjunto de cambios.
- La opción de exclusión se presenta en una sola línea y con un recuadro compacto para ocupar el menor alto posible.
