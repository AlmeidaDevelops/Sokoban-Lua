# 🌀 Sokoban con Portales

¡Un giro moderno al clásico juego de puzzles Sokoban, inspirado en la mecánica de portales del juego Portal! Empuja las cajas a sus destinos, pero ahora con la ayuda (y el desafío) de portales que te teletransportan a ti y a las cajas por el nivel.

Este proyecto está escrito en **Lua** y se ejecuta en la terminal.

![Ejemplo de Gameplay](file:///C:/Users/USER/Desarrollo/Juegos/Demos/Sokoban/Demo.gif) 

## 📦 Características

* **Lógica Clásica de Sokoban:** Empuja cajas, no puedes tirar de ellas.
* **Mecánica de Portales:** Entra por un portal naranja (👉) y sal por el azul (➡️). ¡Las cajas también viajan!
* **Niveles Editables:** Crea tus propios puzzles fácilmente modificando el archivo `levels.lua`.
* **Interfaz de Terminal con Emojis:** Una experiencia de juego retro pero con un toque visual moderno y amigable.

## ⚙️ Instalación

Para jugar, necesitas tener **Lua 5.4** instalado en tu sistema.

### Windows

La forma más sencilla es usar un gestor de paquetes como [Winget](https://learn.microsoft.com/es-es/windows/package-manager/winget/) (incluido en Windows 10 y 11).

```powershell
winget install -e --id Lua.Lua
```

### macOS

Puedes usar [Homebrew](https://brew.sh/index_es):

```bash
brew install lua
```

### Linux (Debian/Ubuntu)

Usa el gestor de paquetes `apt`:

```bash
sudo apt-get update
sudo apt-get install lua5.4
```

## ▶️ Cómo Jugar

1. Clona o descarga este repositorio.

2. Abre una terminal en la carpeta del proyecto.

3. Ejecuta el siguiente comando:
   
   ```bash
   lua game.lua
   ```

4. ¡A jugar!

### Controles

* **W, A, S, D:** Mover al jugador (Arriba, Izquierda, Abajo, Derecha).
* **R:** Reiniciar el nivel actual.
* **Q:** Salir del juego.

### Objetivo

El objetivo es empujar todas las cajas (`📦`) hasta sus casillas de destino (`❎`). Cuando una caja está en su destino, se convierte en `🎯`. El nivel se completa cuando todas las cajas están en sus destinos.
