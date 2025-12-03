# 🚀 Deploy Rápido a Vercel - PawGram

## Opción 1: Deploy desde GitHub (MÁS FÁCIL) ⭐

### Paso 1: Push a GitHub

```bash
git add .
git commit -m "Ready for Vercel deployment"
git push origin main
```

### Paso 2: Conectar con Vercel

1. Ve a https://vercel.com/new
2. Click en "Continue with GitHub"
3. Selecciona el repositorio `PawGram`
4. Click en **Deploy**
5. ⏳ **IMPORTANTE**: El primer deploy tardará 10-15 minutos
   - Vercel instalará Flutter desde cero (~500MB)
   - Esto solo ocurre en el primer deploy
   - Siguientes deploys: 2-3 minutos

### Paso 3: Configurar Firebase

Una vez que tengas tu URL de Vercel (ej: `pawgram.vercel.app`):

1. **Firebase Console** → Authentication → Settings → Authorized domains

   - Agrega: `pawgram.vercel.app` (tu dominio real)

2. **Actualizar CORS** - Edita `cors.json`:

   ```json
   {
     "origin": ["https://pawgram.vercel.app", "http://localhost:*"],
     "method": ["GET", "HEAD", "PUT", "POST", "DELETE"],
     "maxAgeSeconds": 3600
   }
   ```

3. **Aplicar CORS**:
   ```bash
   gsutil cors set cors.json gs://pawg-52e10.firebasestorage.app
   ```

### ✅ ¡Listo!

Tu app estará en: `https://pawgram.vercel.app`

---

## Opción 2: Deploy con Vercel CLI

### Instalar Vercel CLI

```bash
npm install -g vercel
```

### Deploy

```bash
vercel login
vercel --prod
```

---

## Verificar que todo funciona

Después del deploy, prueba:

- [ ] Registrar usuario
- [ ] Login
- [ ] Subir foto (verificar CORS)
- [ ] Crear post
- [ ] Dar like
- [ ] Comentar
- [ ] Ver perfil de otro usuario

---

## Problemas comunes

### ❌ Imágenes no cargan

**Solución**: Verifica que agregaste el dominio de Vercel en Firebase y aplicaste CORS

### ❌ Build falla

**Solución**:

- El primer build tarda 10-15 minutos (instalando Flutter)
- Revisa los logs en Vercel para ver el progreso
- Si falla, intenta "Redeploy" desde el dashboard de Vercel

### ❌ "flutter: command not found"

**Solución**: Asegúrate que `build.sh` tiene permisos de ejecución y `vercel.json` está configurado correctamente

### ❌ Auth no funciona

**Solución**: Agrega el dominio de Vercel en Firebase Console → Authentication → Authorized domains

---

## Recursos

- 📖 [Guía completa](VERCEL_DEPLOY.md)
- ✅ [Checklist completo](DEPLOYMENT_CHECKLIST.md)
- 🔥 [Firebase Console](https://console.firebase.google.com)
- ⚡ [Vercel Dashboard](https://vercel.com/dashboard)

---

**Tiempo estimado**:

- Primer deploy: 10-15 minutos (instalando Flutter)
- Siguientes deploys: 2-3 minutos
  **Costo**: $0 (100% gratis con Vercel + Firebase free tier)
