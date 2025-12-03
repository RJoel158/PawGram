# 🐾 PawGram - Instagram para Mascotas

Red social diseñada especialmente para compartir los momentos más adorables de tus mascotas. Construida con Flutter y Firebase.

![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Realtime%20DB-FFA611?logo=firebase)
![Vercel](https://img.shields.io/badge/Deploy-Vercel-000000?logo=vercel)

## ✨ Características

- 📸 **Compartir fotos** de tus mascotas con descripción
- 🏷️ **Etiquetas por categoría** (Perros, Gatos, Conejos, Pájaros, etc.)
- ❤️ **Sistema de likes** con animación de patitas
- 💬 **Comentarios** en tiempo real
- 🔍 **Búsqueda** por usuario y etiquetas
- 👤 **Perfiles públicos** para ver las publicaciones de otros usuarios
- ✏️ **Editar y eliminar** tus propias publicaciones
- 📱 **Responsivo** - Funciona en web y móvil
- 🌐 **Multilenguaje** - Interfaz en español

## 🚀 Demo en vivo

🔗 **[Ver Demo](https://tu-proyecto.vercel.app)** *(Actualizar después del deploy)*

## 🛠️ Tecnologías

- **Frontend**: Flutter 3.9.2
- **Backend**: Firebase Realtime Database
- **Auth**: Firebase Authentication
- **Storage**: Firebase Storage (con CORS configurado)
- **Hosting**: Vercel
- **Packages**: 
  - `cached_network_image` - Optimización de imágenes
  - `image_picker` - Selección de fotos (web + mobile)
  - `firebase_core`, `firebase_auth`, `firebase_database`, `firebase_storage`

## 📋 Requisitos

- Flutter SDK 3.9.2 o superior
- Dart SDK 3.0+
- Firebase CLI (para configuración)
- Node.js (para Vercel CLI - opcional)

## 🏃 Instalación y desarrollo

1. **Clonar el repositorio**
```bash
git clone https://github.com/RJoel158/PawGram.git
cd PawGram
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Ejecutar en web**
```bash
flutter run -d chrome
```

4. **Ejecutar en Android/iOS**
```bash
flutter run
```

## 🌐 Deploy en Vercel

### Opción 1: Deploy desde GitHub (Recomendado)

1. Push tu código a GitHub
2. Ve a [Vercel](https://vercel.com/new)
3. Importa tu repositorio
4. Vercel detectará automáticamente `vercel.json`
5. Click en **Deploy**

### Opción 2: Deploy desde CLI

```bash
npm install -g vercel
vercel login
vercel --prod
```

📖 **[Guía completa de deployment](VERCEL_DEPLOY.md)**

## 🔧 Configuración de Firebase

1. **Authentication**
   - Habilita Email/Password en Firebase Console
   - Agrega tu dominio de Vercel en "Authorized domains"

2. **Realtime Database**
   - Configura las reglas de seguridad (ver `firebase.json`)

3. **Storage**
   - Configura CORS para permitir el dominio de Vercel
   ```bash
   gsutil cors set cors.json gs://tu-bucket.appspot.com
   ```

📖 **[Guía de configuración CORS](CORS_SETUP.md)**

## 📱 Plataformas soportadas

- ✅ Web (Chrome, Firefox, Safari, Edge)
- ✅ Android
- ✅ iOS
- ⚠️ Windows/Linux/macOS (no probado)

## 🎨 Estructura del proyecto

```
lib/
├── main.dart                 # Entry point
├── models/
│   └── post_tag.dart        # Modelo de etiquetas
├── services/
│   ├── auth_service.dart    # Autenticación
│   ├── post_service.dart    # CRUD de posts
│   ├── user_service.dart    # Gestión de usuarios
│   ├── comments_service.dart # Sistema de comentarios
│   └── reaction_service.dart # Likes
├── ui/
│   ├── auth/
│   │   ├── login_page.dart
│   │   ├── register_page.dart
│   │   ├── home/
│   │   │   ├── feed_page.dart
│   │   │   ├── post_card.dart
│   │   │   └── search_page.dart
│   │   ├── posts/
│   │   │   ├── create_post_page.dart
│   │   │   ├── edit_post_page.dart
│   │   │   └── comments_page.dart
│   │   └── profile/
│   │       ├── profile_page.dart
│   │       ├── edit_profile_page.dart
│   │       ├── public_profile_page.dart
│   │       └── user_feed_page.dart
│   └── theme/
│       └── app_colors.dart
```

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Si encuentras un bug o tienes una sugerencia:

1. Fork el proyecto
2. Crea tu feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la branch (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto es de código abierto y está disponible bajo la [MIT License](LICENSE).

## 👨‍💻 Autor

**RJoel158**
- GitHub: [@RJoel158](https://github.com/RJoel158)

## 🙏 Agradecimientos

- Flutter Team por el increíble framework
- Firebase por los servicios backend
- Vercel por el hosting gratuito
- Comunidad de desarrolladores de Flutter

---

⭐ Si te gusta este proyecto, ¡dale una estrella en GitHub!
