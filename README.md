# 🌐 LinguaAI — Traducción Inteligente con IA

> PWA móvil de traducción contextual avanzada impulsada por Claude AI · Tarea 6 · SENATI

![Version](https://img.shields.io/badge/versión-1.0.0-5b5fef?style=flat-square)
![PWA](https://img.shields.io/badge/PWA-instalable-34d399?style=flat-square)
![AI](https://img.shields.io/badge/IA-Claude%20Sonnet-a78bfa?style=flat-square)
![License](https://img.shields.io/badge/licencia-MIT-f0f0f8?style=flat-square)

---

## 📌 Descripción

**LinguaAI** es una Progressive Web App (PWA) que permite traducir texto escrito o dictado por voz entre 11 idiomas usando inteligencia artificial contextual. A diferencia de los traductores literales, preserva el tono, el registro formal/informal y las expresiones idiomáticas del texto original.

La app puede instalarse directamente desde el navegador del celular sin pasar por ninguna tienda de aplicaciones.

---

## ✨ Funcionalidades

| Feature | Descripción |
|---|---|
| 🤖 **Traducción con IA** | Integración con Claude API (`claude-sonnet-4-20250514`) para traducciones contextuales |
| 🎤 **Entrada por voz** | Web Speech API con animación de onda sonora en tiempo real |
| 🔊 **Síntesis de voz** | Escucha la traducción con `speechSynthesis` en el idioma destino |
| 🌍 **11 idiomas** | Español, Inglés, Portugués, Francés, Alemán, Italiano, Japonés, Chino, Coreano, Árabe, Ruso |
| 🔁 **Intercambio de idiomas** | Swap animado con un botón |
| 📋 **Copiar al portapapeles** | Con confirmación visual |
| 🕘 **Historial** | Últimas 5 traducciones en `localStorage`, recargables con un toque |
| ⌨️ **Atajo de teclado** | `Ctrl+Enter` / `Cmd+Enter` para traducir |
| 📲 **Instalable como app** | Service Worker + Web App Manifest → pantalla de inicio, modo fullscreen |
| ⚡ **Carga instantánea** | Cache-first con Service Worker |

---

## 🛠️ Stack tecnológico

```
HTML5 · CSS3 · JavaScript Vanilla
Vite (empaquetado)
Claude API — claude-sonnet-4-20250514
Web Speech API (SpeechRecognition)
speechSynthesis API
Service Worker (PWA)
Web App Manifest (PWA)
localStorage
```

---

## 📁 Estructura del proyecto

```
lingua-ai/
├── index.html          # App completa (HTML + CSS + JS en un solo archivo)
├── deploy_github.sh    # Script de despliegue automático a GitHub
└── README.md           # Este archivo
```

---

## 🚀 Instalación y uso local

### 1. Clona el repositorio

```bash
git clone https://github.com/TU_USUARIO/lingua-ai.git
cd lingua-ai
```

### 2. Abre la app

Opción A — Directo en el navegador:
```bash
# Abre index.html en tu navegador
open index.html          # macOS
start index.html         # Windows
xdg-open index.html      # Linux
```

Opción B — Con servidor local (recomendado para probar el SW):
```bash
# Con Python
python -m http.server 5173

# Con Node.js
npx serve .

# Con Vite
npm create vite@latest
```

Luego abre `http://localhost:5173` en tu navegador.

---

## 📲 Instalar como PWA en el celular

1. Abre la app en Chrome (Android) o Safari (iOS)
2. Aparecerá el banner **"Añadir a pantalla de inicio"** automáticamente, o toca el botón **⬇ Instalar** en la cabecera
3. La app se instala con ícono propio, splash screen y modo pantalla completa

> **Requisito:** La app debe estar en un dominio con **HTTPS** para que el Service Worker funcione.

---

## ☁️ Despliegue en GitHub Pages

### Automático (recomendado)

```bash
bash deploy_github.sh
```

El script crea las ramas, hace los commits por operación, crea el tag `v1.0.0` y sube todo a GitHub.

### Manual

```bash
# 1. Inicializar repo
git init -b main
git add .
git commit -m "🚀 init: LinguaAI PWA"

# 2. Conectar a GitHub
git remote add origin https://github.com/TU_USUARIO/lingua-ai.git
git push -u origin main

# 3. Activar GitHub Pages
# GitHub → Settings → Pages → Branch: main → Save
```

La app quedará disponible en:
```
https://TU_USUARIO.github.io/lingua-ai/
```

---

## 🌿 Ramas del proyecto

| Rama | Contenido |
|---|---|
| `main` | Código de producción, versión estable |
| `feature/pwa-setup` | Service Worker y Web App Manifest |
| `feature/ui-design` | Interfaz de usuario, CSS variables, animaciones |
| `feature/claude-api` | Integración Claude API y efecto typewriter |
| `feature/voice-history` | Web Speech API, síntesis de voz e historial |
| `feature/deploy` | Configuración de despliegue y GitHub Pages |

---

## 🏗️ Arquitectura PWA

```
Navegador
│
├── index.html ──────────────── Shell de la app (UI completa)
│   ├── CSS Variables           Sistema de diseño (colores, fuentes, radios)
│   ├── Web App Manifest        Inyectado dinámicamente via blob URL
│   └── Service Worker          Registrado dinámicamente via blob URL
│       └── Cache-first         Precaché de la shell para carga offline
│
├── Claude API (/v1/messages)   Traducción contextual con IA
│   └── claude-sonnet-4-20250514
│
├── Web Speech API              Reconocimiento de voz (entrada)
│   └── SpeechRecognition
│
├── speechSynthesis             Síntesis de voz (salida)
│
└── localStorage                Historial de las últimas 5 traducciones
    └── lingua_history (JSON)
```

---

## 📋 Operaciones implementadas

### Operación 1 — Configuración del proyecto Vite + PWA
Creación del proyecto, registro dinámico del Service Worker con estrategia cache-first y Web App Manifest con iconos SVG, colores de tema y modo `standalone`.

### Operación 2 — Desarrollo de la interfaz de usuario
Diseño dark con orbs animados, tipografías Syne + DM Mono + DM Sans, selector de 11 idiomas, tarjeta de entrada con contador, soporte de `safe-area-inset` para notch.

### Operación 3 — Integración de la API de Claude
Llamada a `claude-sonnet-4-20250514` con system prompt especializado para traducción contextual. Efecto typewriter en el resultado. Manejo de errores con toasts animados.

### Operación 4 — Web Speech API y síntesis de voz
`SpeechRecognition` con `interimResults: true` y animación de onda sonora. `speechSynthesis` con idioma destino. Historial en `localStorage` con recarga por toque.

### Operación 5 — Despliegue como PWA instalable
Despliegue en HTTPS, verificación de criterios de instalabilidad, botón de instalación con `beforeinstallprompt`, ícono propio y pantalla completa en Android e iOS.

---

## 👨‍💻 Autor

**Guillermo De La Cruz Lopez**
Tarea 6 — Desarrollo de Aplicaciones · SENATI

---

## 📄 Licencia

MIT — libre para uso académico y personal.
