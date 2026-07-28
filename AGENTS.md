# Instrucciones persistentes del proyecto Flynance

## Android

- Este proyecto **no usa Android Studio**.
- La compilación Android se realiza desde la terminal con el JDK 21 y el Android SDK portátiles ubicados en `.android-build-tools/`.
- Cuando el usuario pida actualizar la aplicación o generar una nueva versión, el agente debe compilar y entregar el APK; no debe indicarle al usuario que abra Android Studio o que lo compile manualmente.
- Durante una etapa de correcciones o mejoras, modificar y probar primero la aplicación web sin generar ni publicar una APK por cada cambio.
- No compilar ni publicar una nueva APK hasta que el usuario confirme que terminó la etapa de cambios con una indicación como “terminamos, compilala”.
- Al recibir esa confirmación, agrupar todos los cambios pendientes en una única versión: aumentar `versionCode` y `versionName`, compilar el APK release, verificar identidad, firma y SHA-256, y publicar juntos el APK y `version.json` en Cloudflare.
- Antes de compilar, ejecutar la compilación web y sincronizar Capacitor con Android.
- El APK entregable se guarda en la raíz del proyecto como `Flynance.apk`.
- La identidad permanente es `com.flynance.app`.
- Las versiones de distribución se compilan con `assembleRelease --no-daemon --no-parallel` y la firma `flynance-release`.
- La clave está en `android/flynance-release.jks` y sus datos locales en `android/keystore.properties`; ambos están ignorados por Git y deben conservarse juntos.
- Para publicar una actualización: aumentar `versionCode` y `versionName`, compilar/sincronizar, generar el APK release, copiarlo a `Flynance.apk` y `dist/updates/Flynance.apk`, recalcular SHA-256 en `dist/updates/version.json`, y finalmente desplegar con Wrangler.
- El manifiesto público es `https://flynance.facundomatiasbono.workers.dev/updates/version.json`.
- Para una actualización instalable sobre una versión anterior se deben conservar `applicationId` y la misma clave de firma, y aumentar `versionCode`.
- No borrar ni sustituir una clave de firma existente. Los archivos de firma no se incorporan a Git.

## Registro del proyecto

- Consultar `CAMBIOS.md` para conocer el trabajo realizado y las decisiones previas.
- Actualizar `CAMBIOS.md` cuando se complete una modificación relevante o una nueva compilación.
