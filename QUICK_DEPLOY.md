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
4. Click en **Deploy** (Vercel detectará automáticamente `vercel.json`)

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
**Solución**: El primer build puede tardar 5-10 minutos. Ten paciencia.

### ❌ Auth no funciona
**Solución**: Agrega el dominio de Vercel en Firebase Console → Authentication → Authorized domains

---

## Recursos

- 📖 [Guía completa](VERCEL_DEPLOY.md)
- ✅ [Checklist completo](DEPLOYMENT_CHECKLIST.md)
- 🔥 [Firebase Console](https://console.firebase.google.com)
- ⚡ [Vercel Dashboard](https://vercel.com/dashboard)

---

**Tiempo estimado**: 10-15 minutos
**Costo**: $0 (100% gratis con Vercel + Firebase free tier)
