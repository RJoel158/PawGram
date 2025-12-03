# PawGram - Despliegue en Vercel

## Pasos para desplegar en Vercel

### 1. Preparar el proyecto

Asegúrate de que todos los archivos estén listos:
- ✅ `vercel.json` - Configuración de Vercel
- ✅ `build.sh` - Script de construcción
- ✅ `.gitignore` actualizado

### 2. Configurar Firebase para producción

En la consola de Firebase (https://console.firebase.google.com):

1. Ve a **Authentication** → **Settings** → **Authorized domains**
2. Agrega tu dominio de Vercel: `tu-proyecto.vercel.app`

3. Ve a **Storage** → **Rules** y verifica las reglas CORS
4. Si es necesario, ejecuta de nuevo:
   ```bash
   gsutil cors set cors.json gs://pawg-52e10.firebasestorage.app
   ```

### 3. Instalar Vercel CLI (opcional)

```bash
npm install -g vercel
```

### 4. Desplegar desde GitHub (Recomendado)

1. Ve a https://vercel.com/new
2. Conecta tu repositorio de GitHub
3. Selecciona el proyecto `PawGram`
4. Vercel detectará automáticamente la configuración de `vercel.json`
5. Click en **Deploy**

### 5. Desplegar desde terminal (Alternativa)

```bash
# Login en Vercel
vercel login

# Desplegar
vercel

# Para producción
vercel --prod
```

### 6. Variables de entorno (si usas claves privadas)

Si tienes claves de API privadas, agrégalas en:
- Vercel Dashboard → Settings → Environment Variables

### 7. Configuración de dominio personalizado (Opcional)

1. Ve a tu proyecto en Vercel
2. Settings → Domains
3. Agrega tu dominio personalizado

## Estructura del build

```
build/web/
  ├── index.html
  ├── main.dart.js
  ├── flutter.js
  ├── assets/
  └── canvaskit/
```

## Solución de problemas

### Error: Flutter no encontrado
- Vercel instalará Flutter automáticamente usando el `build.sh`
- El proceso puede tardar 2-5 minutos en el primer deploy

### Error: CORS en Firebase Storage
- Verifica que el dominio de Vercel esté en Firebase authorized domains
- Revisa que CORS esté configurado correctamente en Storage

### Error: Rutas no funcionan
- Flutter web usa rutas hash por defecto (`/#/route`)
- Si quieres rutas limpias, configura rewrites en `vercel.json`

## Optimizaciones para producción

### 1. Comprimir assets
Ya incluido en `flutter build web --release`

### 2. Cachear recursos estáticos
Vercel lo hace automáticamente

### 3. Usar CDN
Vercel CDN está activo por defecto

### 4. Minificación
Flutter minifica automáticamente en modo release

## Comandos útiles

```bash
# Build local para probar
flutter build web --release

# Servir localmente
python -m http.server -d build/web 8000

# Ver logs de Vercel
vercel logs

# Eliminar deployment
vercel remove [deployment-url]
```

## Notas importantes

- ⚠️ El primer deployment puede tardar 5-10 minutos
- ✅ Los siguientes deployments son más rápidos (2-3 minutos)
- 🔄 Vercel hace rebuild automático con cada push a main
- 📱 La app web es responsiva y funciona en móviles
- 🚀 CDN global incluido (rápido en todo el mundo)

## URL de producción

Después del deploy, tu app estará en:
```
https://tu-proyecto.vercel.app
```

## Monitoreo

Vercel provee:
- Analytics de tráfico
- Error tracking
- Performance metrics
- Build logs

Accede en: https://vercel.com/dashboard
