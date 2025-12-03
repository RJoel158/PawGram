# ✅ Checklist de Deployment - PawGram en Vercel

## Pre-deployment

### 1. Código
- [x] Todos los archivos committeados en Git
- [x] Sin errores de compilación
- [x] Tests pasando (si los hay)
- [x] Warnings de deprecación corregidos

### 2. Archivos de configuración
- [x] `vercel.json` creado
- [x] `build.sh` creado y con permisos de ejecución
- [x] `.vercelignore` creado
- [x] `.gitignore` actualizado
- [x] `web/index.html` actualizado con metadata correcta
- [x] `web/manifest.json` actualizado con información de PawGram

### 3. Firebase - Configuración inicial
- [ ] Proyecto Firebase creado: `pawg-52e10`
- [ ] Authentication habilitada (Email/Password)
- [ ] Realtime Database creada con reglas
- [ ] Storage configurado
- [ ] `firebase_options.dart` generado

## Durante el Deployment

### 4. Vercel - Primera vez
- [ ] Cuenta creada en https://vercel.com
- [ ] Repositorio conectado desde GitHub
- [ ] Proyecto importado en Vercel
- [ ] Build completado exitosamente

### 5. Firebase - Actualizar para producción
- [ ] Agregar dominio de Vercel a Firebase Authentication:
  - Firebase Console → Authentication → Settings → Authorized domains
  - Agregar: `tu-proyecto.vercel.app`
  
- [ ] Configurar CORS para Storage:
  ```bash
  gsutil cors set cors.json gs://pawg-52e10.firebasestorage.app
  ```

### 6. Verificar CORS
Actualizar `cors.json` con el dominio de producción:
```json
[
  {
    "origin": ["https://tu-proyecto.vercel.app", "http://localhost:*"],
    "method": ["GET", "HEAD", "PUT", "POST", "DELETE"],
    "maxAgeSeconds": 3600
  }
]
```

## Post-deployment

### 7. Testing en producción
- [ ] Abrir app en Vercel URL
- [ ] Registrar nuevo usuario
- [ ] Login funciona correctamente
- [ ] Subir una foto (verificar CORS)
- [ ] Crear un post
- [ ] Dar like a un post
- [ ] Comentar un post
- [ ] Editar perfil
- [ ] Buscar usuarios
- [ ] Ver perfil de otro usuario
- [ ] Editar/Eliminar propio post

### 8. Optimizaciones
- [ ] Verificar tiempos de carga (PageSpeed Insights)
- [ ] Verificar en móvil
- [ ] Verificar en diferentes navegadores
- [ ] Configurar dominio personalizado (opcional)

### 9. Monitoreo
- [ ] Configurar Vercel Analytics
- [ ] Revisar logs de errores
- [ ] Configurar alertas (opcional)

## Comandos útiles

### Build local para probar antes de deploy
```bash
flutter build web --release --web-renderer html
python -m http.server -d build/web 8000
```

### Deploy manual con Vercel CLI
```bash
vercel login
vercel --prod
```

### Ver logs de Vercel
```bash
vercel logs
```

### Actualizar CORS en Firebase Storage
```bash
gsutil cors set cors.json gs://pawg-52e10.firebasestorage.app
gsutil cors get gs://pawg-52e10.firebasestorage.app
```

## Solución de problemas comunes

### ❌ "Failed to load image" en Storage
**Causa**: CORS no configurado correctamente
**Solución**: 
1. Verificar dominio en Firebase authorized domains
2. Ejecutar `gsutil cors set cors.json gs://bucket-name`

### ❌ "Build failed" en Vercel
**Causa**: Flutter no se instaló correctamente
**Solución**: 
1. Verificar que `build.sh` tenga permisos correctos
2. Revisar logs de Vercel para ver error específico

### ❌ Rutas no funcionan al recargar
**Causa**: Flutter web usa rutas hash por defecto
**Solución**: Está bien, es comportamiento esperado con hash routes

### ❌ "Authentication failed"
**Causa**: Dominio no autorizado en Firebase
**Solución**: Agregar dominio de Vercel en Firebase Console

## URLs importantes

- 🔗 Vercel Dashboard: https://vercel.com/dashboard
- 🔗 Firebase Console: https://console.firebase.google.com
- 🔗 GitHub Repo: https://github.com/RJoel158/PawGram
- 🔗 App en producción: https://tu-proyecto.vercel.app

## Próximos pasos (opcional)

- [ ] Configurar dominio personalizado (www.pawgram.com)
- [ ] Agregar Google Analytics
- [ ] Implementar notificaciones push
- [ ] Agregar más categorías de mascotas
- [ ] Sistema de followers/following
- [ ] Chat directo entre usuarios
- [ ] Modo oscuro

---

**Fecha del checklist**: 2025-12-03
**Estado**: ✅ Listo para deployment
