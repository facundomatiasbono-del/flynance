# Flynance

Aplicación web y Android para registrar gastos manualmente o mediante WhatsApp. La web, la APK y Twilio comparten Supabase como API y base de datos.

## Estado

El código base incluye autenticación, panel mensual, alta y eliminación de gastos, aislamiento multiusuario, webhook firmado de Twilio y configuración de Capacitor para Android.

### Estado de la configuración (21 de julio de 2026)

- La migración `supabase/migrations/001_initial.sql` fue ejecutada correctamente en Supabase.
- La URL y la clave pública de Supabase están configuradas en el archivo local `.env`.
- Se verificaron el registro, el inicio de sesión y la creación y persistencia de gastos.
- La Edge Function `twilio-whatsapp` fue desplegada en Supabase con verificación JWT desactivada.
- Los secretos `TWILIO_AUTH_TOKEN` y `TWILIO_WEBHOOK_URL` fueron guardados en Supabase; sus valores no se almacenan en este repositorio.
- El Sandbox de WhatsApp de Twilio fue vinculado mediante HTTP POST y se comprobó el registro de gastos desde WhatsApp.
- La interfaz incluye selector de tema claro/oscuro, preferencia persistente y una estética oscura basada en superficies negro azulado y acentos azules.
- La interfaz incluye selector persistente de idioma español/inglés.
- Se agregó una página de Ajustes para configurar WhatsApp, ingreso mensual y límite de alerta de gastos.
- La migración `supabase/migrations/002_profile_finances.sql` debe ejecutarse en Supabase para habilitar ingreso y alertas.
- Las categorías son personalizables por usuario desde Ajustes; la migración `supabase/migrations/003_custom_categories.sql` crea y precarga las opciones iniciales.
- El panel incluye un gráfico de barras con vistas por día, mes y categoría, además de un gráfico de dona por categoría.
- Al seleccionar un mes en el gráfico de barras, la dona muestra el detalle de ese período.
- Ajustes permite administrar recordatorios de gastos fijos mensuales; requieren `supabase/migrations/004_fixed_expenses.sql`.
- La última compilación con `npm.cmd run build` terminó correctamente.
- El onboarding posterior al primer inicio de sesión requiere ejecutar
  `supabase/migrations/010_onboarding_preferences.sql` en Supabase.

URL pública del webhook configurado:

```text
https://goxexrlovlechdxgsxbq.supabase.co/functions/v1/twilio-whatsapp
```

## Puesta en marcha local

1. Crear un proyecto en Supabase.
2. Ejecutar `supabase/migrations/001_initial.sql` desde el SQL Editor.
3. Copiar `.env.example` a `.env` y completar la URL y clave pública del proyecto.
4. Ejecutar `npm install` y luego `npm run dev`.

## WhatsApp y Twilio

Desplegar la función pública:

```sh
supabase functions deploy twilio-whatsapp --no-verify-jwt
```

Guardar los secretos. `TWILIO_WEBHOOK_URL` debe coincidir exactamente con la URL configurada en Twilio:

```sh
supabase secrets set TWILIO_AUTH_TOKEN=... TWILIO_WEBHOOK_URL=https://PROYECTO.supabase.co/functions/v1/twilio-whatsapp
```

Configurar esa URL con método HTTP POST en **When a message comes in** del Sandbox de WhatsApp. Nunca colocar `SUPABASE_SERVICE_ROLE_KEY` ni el token de Twilio dentro de `.env` o del código de la app.

## APK Android

Este proyecto no usa Android Studio. La compilación se realiza desde la terminal
con el JDK 21 y el Android SDK portátiles guardados en `.android-build-tools/`.

Cuando se genera una nueva versión, primero se compila la aplicación web, se
sincroniza Capacitor y luego se ejecuta Gradle. El APK entregable actualizado se
guarda en la raíz del proyecto como `Flynance.apk`.

La distribución privada usa el identificador permanente `com.flynance.app` y
una firma release propia. La aplicación consulta automáticamente el manifiesto
de actualización publicado en Cloudflare y permite descargar e instalar una
versión posterior con confirmación del usuario en Android.

Las instrucciones operativas persistentes para los agentes están en `AGENTS.md`.
