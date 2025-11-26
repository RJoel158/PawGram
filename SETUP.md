# 🐾 PawGram - Configuración

PawGram es una red social estilo Instagram diseñada exclusivamente para mascotas. Comparte fotos de tus mascotas, dales like, comenta y disfruta de una comunidad pet-friendly.

## ✨ Características

- 🔐 Autenticación con Firebase (Email/Password)
- 📸 Subir fotos de mascotas
- ❤️ Sistema de likes
- 💬 Comentarios en posts
- 👤 Perfil de usuario personalizable
- 📱 Feed en tiempo real
- 🎨 Interfaz estilo Instagram

## 🚀 Configuración de Firebase

### 1. Crear Proyecto en Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Crea un nuevo proyecto llamado "PawGram" (o el nombre que prefieras)
3. Habilita Google Analytics (opcional)

### 2. Configurar Authentication

1. En Firebase Console, ve a **Authentication** > **Sign-in method**
2. Habilita **Email/Password**
3. Guarda los cambios

### 3. Configurar Realtime Database

1. En Firebase Console, ve a **Realtime Database**
2. Crea una base de datos
3. Selecciona **Start in test mode** (para desarrollo)
4. Cambia las reglas a:

```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": true,
        ".write": "$uid === auth.uid"
      }
    },
    "posts": {
      ".read": true,
      ".write": "auth != null",
      "$postId": {
        ".write": "auth != null"
      }
    },
    "comments": {
      ".read": true,
      ".write": "auth != null"
    },
    "reactions": {
      ".read": true,
      ".write": "auth != null"
    }
  }
}
```

### 4. Configurar Storage

1. En Firebase Console, ve a **Storage**
2. Crea un bucket de almacenamiento
3. Configura las reglas:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /posts/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    match /users/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 5. Agregar App Android

1. En Firebase Console, haz clic en el ícono de Android
2. Package name: `com.example.firebase_pet_social` (o el que tengas en `android/app/build.gradle.kts`)
3. Descarga el archivo `google-services.json`
4. Colócalo en `android/app/`

### 6. Agregar App iOS (Opcional)

1. En Firebase Console, haz clic en el ícono de iOS
2. Bundle ID: obtenerlo de `ios/Runner.xcodeproj`
3. Descarga `GoogleService-Info.plist`
4. Agrégalo al proyecto iOS

## 📦 Instalación

```bash
# Instalar dependencias
flutter pub get

# Configurar Firebase (si no lo has hecho)
# Ya debiste haber colocado google-services.json en android/app/

# Ejecutar la app
flutter run
```

## 🔧 Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada
├── firebase_options.dart        # Configuración de Firebase
├── services/                    # Servicios de Firebase
│   ├── auth_service.dart       # Autenticación
│   ├── post_service.dart       # Posts
│   ├── comments_service.dart   # Comentarios
│   ├── reaction_service.dart   # Likes/Reacciones
│   └── user_service.dart       # Usuario
└── ui/                         # Interfaz de usuario
    ├── main_screen.dart        # Navegación principal
    ├── auth/
    │   ├── login_page.dart     # Pantalla de login
    │   ├── register_page.dart  # Registro
    │   ├── home/
    │   │   ├── feed_page.dart  # Feed principal
    │   │   └── post_card.dart  # Tarjeta de post
    │   ├── posts/
    │   │   ├── create_post_page.dart  # Crear post
    │   │   └── comments_page.dart     # Comentarios
    │   └── profile/
    │       ├── profile_page.dart      # Perfil
    │       └── edit_profile_page.dart # Editar perfil
```

## 🎯 Uso

### Crear una cuenta

1. Abre la app
2. Haz clic en "Create new account"
3. Completa username, email y password
4. Presiona "Create Account"

### Crear un post

1. Inicia sesión
2. Ve a la pestaña de "Create" (ícono +)
3. Selecciona una foto de tu mascota
4. Escribe una descripción
5. Presiona "Publicar"

### Interactuar con posts

- **Like**: Presiona el corazón ❤️
- **Comentar**: Presiona el ícono de comentario 💬
- **Ver perfil**: Presiona en el nombre de usuario

## 🐛 Solución de Problemas

### Error: google-services.json no encontrado

- Asegúrate de haber descargado el archivo desde Firebase Console
- Verifica que esté en `android/app/google-services.json`

### Error al subir imágenes

- Verifica que Firebase Storage esté configurado
- Revisa las reglas de Storage
- Asegúrate de tener permisos en el dispositivo

### Posts no se cargan

- Verifica tu conexión a internet
- Revisa las reglas de Realtime Database
- Comprueba que Firebase esté inicializado correctamente

## 📱 Características Futuras

- [ ] Stories para mascotas
- [ ] Chat entre usuarios
- [ ] Búsqueda de mascotas
- [ ] Filtros para fotos
- [ ] Notificaciones push
- [ ] Seguir a otros usuarios
- [ ] Feed personalizado

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Si tienes ideas para mejorar PawGram, no dudes en crear un issue o pull request.

## 📄 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

---

¡Disfruta compartiendo momentos adorables de tus mascotas! 🐶🐱🐰
