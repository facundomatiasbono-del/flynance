# Despliegue de Flynance en Cloudflare Workers

## Aplicación publicada

- URL: <https://flynance.facundomatiasbono.workers.dev>
- Worker: `flynance`
- Versión comprobada al publicar: `d2cef921-585c-4b91-82da-a4d6997cdd4b`

## Arquitectura

- Cloudflare Workers sirve el frontend estático generado por React y Vite.
- Supabase continúa alojando la autenticación, la base de datos y las Edge Functions.
- Twilio continúa enviando el webhook de WhatsApp a la Edge Function de Supabase.

## Variables del frontend

El archivo local `.env` debe contener:

```env
VITE_SUPABASE_URL=https://goxexrlovlechdxgsxbq.supabase.co
VITE_SUPABASE_ANON_KEY=CLAVE_PUBLICA_ANON_O_PUBLISHABLE
```

`VITE_SUPABASE_ANON_KEY` es una clave pública. No se deben colocar en el frontend,
en `wrangler.jsonc` ni en Git:

```text
SUPABASE_SERVICE_ROLE_KEY
TWILIO_AUTH_TOKEN
```

## Configuración de Wrangler

El archivo `wrangler.jsonc` contiene:

```jsonc
{
  "name": "flynance",
  "compatibility_date": "2026-07-24",
  "assets": {
    "directory": "./dist",
    "not_found_handling": "single-page-application"
  }
}
```

El modo `single-page-application` hace que Cloudflare entregue `index.html` cuando
una ruta no coincide con un archivo estático.

## Publicar una versión nueva

Abrir PowerShell en la carpeta del proyecto:

```powershell
cd C:\Users\cengi\Desktop\Python\flynance
npm.cmd run build
npx.cmd wrangler deploy
```

Se usa `npx.cmd` porque la política de ejecución de PowerShell puede bloquear
`npx.ps1`.

Si Wrangler pierde la autorización:

```powershell
npx.cmd wrangler login
```

Después, volver a ejecutar:

```powershell
npx.cmd wrangler deploy
```

## Configuración de Supabase

En `Authentication → URL Configuration`:

```text
Site URL:
https://flynance.facundomatiasbono.workers.dev
```

En `Redirect URLs`:

```text
https://flynance.facundomatiasbono.workers.dev/**
```

Esto permite que la confirmación de correo y la recuperación de contraseña
regresen a la aplicación publicada.

## Comprobaciones posteriores al despliegue

1. Abrir la URL pública.
2. Crear una cuenta o iniciar sesión.
3. Registrar un gasto y actualizar la página para comprobar su persistencia.
4. Cerrar sesión y volver a entrar.
5. Probar la recuperación de contraseña.
6. Verificar categorías, ingreso mensual, alertas y gastos fijos.
7. Enviar un gasto mediante WhatsApp para comprobar la integración con Twilio.

## Archivos que no deben publicarse en Git

```text
.env
node_modules/
dist/
.android-build-tools/
*.apk
```

Wrangler carga automáticamente los archivos compilados desde `dist`; no es
necesario subirlos manualmente al repositorio.

## APK Android actualizado

La distribución privada de Android está publicada en:

```text
https://flynance.facundomatiasbono.workers.dev/updates/Flynance.apk
```

El manifiesto que consulta la aplicación está en:

```text
https://flynance.facundomatiasbono.workers.dev/updates/version.json
```

Datos de la versión base del actualizador:

```text
Fecha: 28/07/2026
Application ID: com.flynance.app
Versión: 1.0 (versionCode 1)
Tipo: APK release
Firma: CN=Flynance, alias flynance-release
SHA-256 APK: D747FF57B02755656C45FE6CCF3344190F7D75A4ECDAAB6A0301909851AB0ADF
SHA-256 certificado: FA46CAA73A020833B519BF3C94908CE1768A250D8B4E4326CC4A12772FA57DF1
```

Esta versión debe instalarse una vez de forma manual después de desinstalar la
APK antigua `com.misgastos.app`. Las versiones siguientes deberán aumentar
`versionCode`, conservar la clave `android/flynance-release.jks` y se podrán
instalar desde el actualizador integrado.

El frontend se compiló y sincronizó con Capacitor antes de generar una nueva
compilación Android:

```powershell
npm.cmd run android:sync
```

Gradle ejecutó correctamente las 85 tareas de `assembleDebug`. El archivo final
se encuentra en:

```text
Flynance.apk
```

Datos de la compilación:

```text
Fecha: 24/07/2026 10:21
Tamaño: 4.368.144 bytes
Tipo: APK de depuración
SHA-256: 513F4D78E8333457F91DEF85F31DFE494F0022EBEA93D7820CF9737078BC93CE
```

### Diferencia de tamaño respecto del APK anterior

El APK anterior pesaba aproximadamente 7,33 MB y la nueva compilación pesa
aproximadamente 4,37 MB. La reducción se produjo después de forzar una
recompilación completa, que volvió a empaquetar y comprimir los artefactos.

Comprobaciones realizadas sobre el APK nuevo:

- Contiene 456 archivos.
- Incluye el JavaScript y CSS actuales de Flynance.
- `classes.dex` ocupa 8.251.456 bytes sin comprimir y 3.146.386 bytes dentro
  del APK.
- No contiene bibliotecas nativas por arquitectura; esto es normal para la
  configuración actual basada en Capacitor y WebView.
- Gradle terminó con `BUILD SUCCESSFUL`.

El menor tamaño no indica que falten componentes de la aplicación. La versión
anterior fue reemplazada, por lo que no está disponible una comparación interna
archivo por archivo.
