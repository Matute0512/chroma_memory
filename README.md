# 🧠 ChromaMemory - Juego de Memoria Cromática

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)](https://flutter.dev)
[![CI/CD](https://github.com/tu-usuario/ChromaMemory/actions/workflows/main.yml/badge.svg)](https://github.com/tu-usuario/ChromaMemory/actions)

## 📖 Descripción
**ChromaMemory** es un juego hipercasual de memorización de colores y secuencias, diseñado con una experiencia premium y accesible.
- **Modo Clásico**: Secuencias crecientes en velocidad y longitud (estilo Simon).
- **Desafío Diario**: Reto único global cada 24 horas.
- **Modo Zen**: Sin límite de tiempo ni penalizaciones.
- **Accesibilidad**: Texturas/patrones para daltónicos (protanopía, deuteranopía, tritanopía).
- **Monetización ética**: Solo banners en menús y rewarded ads opcionales (sin intersticiales intrusivos).

## 🛠 Tecnologías
- **Frontend**: Flutter (Dart) – renderizado nativo a 60/120 FPS.
- **Arquitectura**: Clean Architecture + MVVM (separación en capas: presentación, dominio, datos).
- **Estado**: Riverpod (o Bloc) para gestión reactiva.
- **Almacenamiento**: SharedPreferences + Hive para datos locales.
- **CI/CD**: GitHub Actions (lint, tests, build .aab firmado).

## 📁 Estructura del Proyecto