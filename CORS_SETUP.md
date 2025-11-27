# 🔧 Solución a Problemas de CORS en Firebase Storage

## Problema

Al ejecutar la app en Flutter Web, las imágenes no cargan debido a errores de CORS:

```
Access to XMLHttpRequest has been blocked by CORS policy
```

## Solución

### Opción 1: Configurar CORS usando Google Cloud Shell (Recomendado)

1. **Abre Google Cloud Console**

   - Ve a: https://console.cloud.google.com/
   - Selecciona tu proyecto de Firebase

2. **Abre Cloud Shell**

   - Haz clic en el ícono de terminal en la parte superior derecha
   - O ve a: https://shell.cloud.google.com/

3. **Ejecuta estos comandos:**

```bash
# Crea el archivo cors.json
cat > cors.json << 'EOF'
[
  {
    "origin": ["*"],
    "method": ["GET", "HEAD", "PUT", "POST", "DELETE"],
    "maxAgeSeconds": 3600,
    "responseHeader": ["Content-Type", "Access-Control-Allow-Origin"]
  }
]
EOF

# Aplica la configuración (reemplaza TU_BUCKET con tu bucket de Firebase)
gsutil cors set cors.json gs://pawg-52e10.firebasestorage.app
```

4. **Verifica la configuración:**

```bash
gsutil cors get gs://pawg-52e10.firebasestorage.app
```

### Opción 2: Usar gsutil localmente

1. **Instala Google Cloud SDK**

   - Windows: https://cloud.google.com/sdk/docs/install
   - Mac: `brew install google-cloud-sdk`
   - Linux: `curl https://sdk.cloud.google.com | bash`

2. **Autentica tu cuenta**

```bash
gcloud auth login
gcloud config set project pawg-52e10
```

3. **Aplica la configuración CORS**

```bash
gsutil cors set cors.json gs://pawg-52e10.firebasestorage.app
```

### Encontrar el nombre de tu bucket

Tu bucket de Firebase Storage tiene este formato:

- `gs://[PROJECT_ID].appspot.com`
- O `gs://[PROJECT_ID].firebasestorage.app`

Para encontrarlo:

1. Ve a Firebase Console > Storage
2. Mira la URL en la parte superior
3. También puedes verlo en `firebase_options.dart` → `storageBucket`

## Configuración del archivo cors.json

El archivo `cors.json` ya está incluido en el proyecto con esta configuración:

```json
[
  {
    "origin": ["*"],
    "method": ["GET", "HEAD", "PUT", "POST", "DELETE"],
    "maxAgeSeconds": 3600,
    "responseHeader": ["Content-Type", "Access-Control-Allow-Origin"]
  }
]
```

### Para producción (más seguro):

Reemplaza `"*"` con tus dominios específicos:

```json
[
  {
    "origin": ["https://tudominio.com", "http://localhost:*"],
    "method": ["GET", "HEAD", "PUT", "POST", "DELETE"],
    "maxAgeSeconds": 3600,
    "responseHeader": ["Content-Type", "Access-Control-Allow-Origin"]
  }
]
```

## Verificar que funciona

Después de aplicar la configuración:

1. **Limpia el caché del navegador** (Ctrl + Shift + Delete)
2. **Recarga la app** (F5 o Ctrl + R)
3. Las imágenes deberían cargar correctamente

## Mejoras implementadas en el código

✅ Uso de `CachedNetworkImage` para mejor manejo de imágenes
✅ Placeholders mientras cargan las imágenes
✅ Manejo de errores visual y amigable
✅ Soporte completo para Flutter Web

## Comandos rápidos de referencia

```bash
# Ver configuración actual
gsutil cors get gs://TU_BUCKET

# Aplicar nueva configuración
gsutil cors set cors.json gs://TU_BUCKET

# Eliminar configuración CORS
gsutil cors set /dev/null gs://TU_BUCKET
```

## Problemas comunes

### Error: "AccessDeniedException: 403"

- Verifica que estés autenticado: `gcloud auth login`
- Verifica que tengas permisos de administrador en el proyecto

### Los cambios no se aplican

- Limpia el caché del navegador
- Espera 1-2 minutos para que los cambios se propaguen
- Verifica la configuración: `gsutil cors get gs://TU_BUCKET`

### Todavía no funciona en localhost

- Asegúrate de incluir `http://localhost:*` en origin
- O usa `"*"` para desarrollo (solo para pruebas)

---

💡 **Nota importante**: La configuración CORS con `"*"` permite cualquier origen. Para producción, especifica solo tus dominios autorizados.
