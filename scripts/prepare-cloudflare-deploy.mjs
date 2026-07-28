import { createHash } from 'node:crypto'
import { copyFile, mkdir, readFile, writeFile } from 'node:fs/promises'
import { resolve } from 'node:path'

const root = resolve(import.meta.dirname, '..')
const apkSource = resolve(root, 'Flynance.apk')
const gradleFile = resolve(root, 'android', 'app', 'build.gradle')
const updatesDirectory = resolve(root, 'dist', 'updates')
const apkDestination = resolve(updatesDirectory, 'Flynance.apk')
const manifestDestination = resolve(updatesDirectory, 'version.json')

const [apk, gradle] = await Promise.all([
  readFile(apkSource),
  readFile(gradleFile, 'utf8'),
])

const versionCode = Number(gradle.match(/versionCode\s+(\d+)/)?.[1])
const versionName = gradle.match(/versionName\s+"([^"]+)"/)?.[1]

if (!Number.isInteger(versionCode) || !versionName) {
  throw new Error('No se pudo leer versionCode o versionName de android/app/build.gradle.')
}

await mkdir(updatesDirectory, { recursive: true })
await copyFile(apkSource, apkDestination)

const manifest = {
  versionCode,
  versionName,
  downloadUrl: 'https://flynance.facundomatiasbono.workers.dev/updates/Flynance.apk',
  sha256: createHash('sha256').update(apk).digest('hex'),
  notes: 'Nueva versión de Flynance disponible.',
}

await writeFile(manifestDestination, `${JSON.stringify(manifest, null, 2)}\n`, 'utf8')
console.log(`Actualización Android preparada: Flynance ${versionName} (${versionCode}).`)
