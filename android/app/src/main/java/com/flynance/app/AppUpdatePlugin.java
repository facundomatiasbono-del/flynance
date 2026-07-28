package com.flynance.app;

import android.content.Intent;
import android.content.pm.PackageInfo;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;

import androidx.core.content.FileProvider;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

import org.json.JSONObject;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.ByteArrayOutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.MessageDigest;
import java.util.Locale;

@CapacitorPlugin(name = "AppUpdate")
public class AppUpdatePlugin extends Plugin {
    private static final String UPDATE_HOST = "flynance.facundomatiasbono.workers.dev";
    private static final String MANIFEST_URL =
        "https://" + UPDATE_HOST + "/updates/version.json";

    @PluginMethod
    public void check(PluginCall call) {
        new Thread(() -> {
            HttpURLConnection connection = null;
            try {
                connection = openHttps(MANIFEST_URL);
                JSONObject manifest;
                try (InputStream input = connection.getInputStream()) {
                    ByteArrayOutputStream output = new ByteArrayOutputStream();
                    byte[] buffer = new byte[8 * 1024];
                    int read;
                    while ((read = input.read(buffer)) != -1) output.write(buffer, 0, read);
                    manifest = new JSONObject(output.toString("UTF-8"));
                }

                int latestCode = manifest.getInt("versionCode");
                PackageInfo packageInfo = getContext().getPackageManager()
                    .getPackageInfo(getContext().getPackageName(), 0);
                long currentCode = Build.VERSION.SDK_INT >= Build.VERSION_CODES.P
                    ? packageInfo.getLongVersionCode()
                    : packageInfo.versionCode;
                JSObject response = new JSObject();
                response.put("available", latestCode > currentCode);
                response.put("currentVersionCode", currentCode);
                response.put("currentVersionName", packageInfo.versionName);
                response.put("versionCode", latestCode);
                response.put("versionName", manifest.getString("versionName"));
                response.put("downloadUrl", manifest.getString("downloadUrl"));
                response.put("sha256", manifest.getString("sha256"));
                response.put("notes", manifest.optString("notes", ""));
                call.resolve(response);
            } catch (Exception error) {
                call.reject("No se pudo comprobar la actualización: " + error.getMessage());
            } finally {
                if (connection != null) connection.disconnect();
            }
        }, "flynance-update-check").start();
    }

    @PluginMethod
    public void downloadAndInstall(PluginCall call) {
        String downloadUrl = call.getString("downloadUrl");
        String expectedSha256 = call.getString("sha256");
        if (downloadUrl == null || expectedSha256 == null) {
            call.reject("Faltan los datos de la actualización.");
            return;
        }

        try {
            URL parsedUrl = new URL(downloadUrl);
            if (!"https".equals(parsedUrl.getProtocol()) || !UPDATE_HOST.equals(parsedUrl.getHost())) {
                call.reject("La dirección de descarga no es válida.");
                return;
            }
        } catch (Exception error) {
            call.reject("La dirección de descarga no es válida.");
            return;
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
            !getContext().getPackageManager().canRequestPackageInstalls()) {
            Intent settingsIntent = new Intent(
                Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                Uri.parse("package:" + getContext().getPackageName())
            );
            getActivity().startActivity(settingsIntent);
            JSObject response = new JSObject();
            response.put("settingsOpened", true);
            call.resolve(response);
            return;
        }

        new Thread(() -> {
            HttpURLConnection connection = null;
            try {
                connection = openHttps(downloadUrl);
                File apk = new File(getContext().getCacheDir(), "Flynance-update.apk");
                MessageDigest digest = MessageDigest.getInstance("SHA-256");
                try (
                    InputStream input = connection.getInputStream();
                    FileOutputStream output = new FileOutputStream(apk)
                ) {
                    byte[] buffer = new byte[64 * 1024];
                    int read;
                    while ((read = input.read(buffer)) != -1) {
                        output.write(buffer, 0, read);
                        digest.update(buffer, 0, read);
                    }
                }

                String actualSha256 = toHex(digest.digest());
                if (!actualSha256.equalsIgnoreCase(expectedSha256)) {
                    apk.delete();
                    throw new SecurityException("la firma SHA-256 del archivo no coincide");
                }

                Uri apkUri = FileProvider.getUriForFile(
                    getContext(),
                    getContext().getPackageName() + ".fileprovider",
                    apk
                );
                Intent installIntent = new Intent(Intent.ACTION_VIEW);
                installIntent.setDataAndType(apkUri, "application/vnd.android.package-archive");
                installIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                installIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                getContext().startActivity(installIntent);

                JSObject response = new JSObject();
                response.put("settingsOpened", false);
                call.resolve(response);
            } catch (Exception error) {
                call.reject("No se pudo descargar la actualización: " + error.getMessage());
            } finally {
                if (connection != null) connection.disconnect();
            }
        }, "flynance-update-download").start();
    }

    private HttpURLConnection openHttps(String address) throws Exception {
        URL url = new URL(address);
        if (!"https".equals(url.getProtocol()) || !UPDATE_HOST.equals(url.getHost())) {
            throw new SecurityException("servidor de actualización no permitido");
        }
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setConnectTimeout(15_000);
        connection.setReadTimeout(60_000);
        connection.setInstanceFollowRedirects(false);
        connection.setRequestProperty("Accept", "application/json, application/vnd.android.package-archive");
        int status = connection.getResponseCode();
        if (status < 200 || status >= 300) {
            connection.disconnect();
            throw new IllegalStateException("el servidor respondió " + status);
        }
        return connection;
    }

    private String toHex(byte[] bytes) {
        StringBuilder result = new StringBuilder(bytes.length * 2);
        for (byte value : bytes) result.append(String.format(Locale.ROOT, "%02x", value));
        return result.toString();
    }
}
