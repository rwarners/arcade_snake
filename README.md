# Two-Player Snake Game with CRT Effect

A multiplayer Snake game implementation with controller support and customizable visual effects. Built with Processing 4 for cross-platform deployment.

## Features

- Processing app that works on Raspberry Pi 4 with Iconic Arcade joysticks!
- Did not test it yet with other USB gamepads
- Works on https://batocera.org/
- Two-player local multiplayer gameplay
- Game controller and keyboard input support (only tested on iconic arcade on Raspberry Pi 4)
- Real-time CRT monitor effect via shader

## Installation

### Development Environment

1. Install Processing 4 from processing.org
2. Install Processing Sound library via Library Manager

### Raspberry Pi Deployment

```bash
# Prepare system
ssh <username>@raspberrypi.local
sudo apt update && sudo apt upgrade
//install java
//default-jre instead of default-jdkshould be enough (but did not test it)
sudo apt install default-jdk 
//these get the right jni/.so files that works on raspberry 4, the ones in jinput-2.0.10-natives-all.jar do not work on Rasp. Pi. 4
//i included the correct .so binary file in the /data folder and the start.sh points to it so no need to do this anymore
//sudo apt install libjinput-java libjinput-jni

# Export from Processing as Linux ARM64
// Add to launch script: -Dnet.java.games.input.librarypath=<path to libjinput-linux64.so>

# Transfer files (Bat
scp -r ~/yourproject root@batocera.local:/userdata/roms/ports
```

## Shader System

The game uses fragment shaders for post-processing effects. The CRT effect is implemented using a custom GLSL shader
This is at this moemnt disabled iwhen running on linux/rasp pi because of performacen issues. Processing itself performance is bad when screne is big or fullscreen.
Check this out if you want to use shaders from shaderToy: https://github.com/SableRaf/Shadertoy2Processing

## License

Open source project. See LICENSE file for details.
