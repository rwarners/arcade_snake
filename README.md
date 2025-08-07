# Two-Player Snake Game with CRT Effect

A multiplayer Snake game implementation with controller support and customizable visual effects. Built with Processing 4 for cross-platform deployment.

## Features

- Two-player local multiplayer gameplay
- Game controller and keyboard input support (only tested on iconic arcade on Raspberry Pi 4)
- Real-time CRT monitor effect via shader
- possible to use other shaders from ShaderToy, see https://github.com/SableRaf/Shadertoy2Processing
- Works on Raspberry Pi with Iconic Arcade joysticks

## Controls

**Player 1 (Blue):** WASD keys  
**Player 2 (Orange):** Arrow keys or Controller 2  
**Global:** SPACE/Controller Start (pause), ESC (exit)

## Requirements

- Processing 4.0+
- JInput library (jinput-2.0.10.jar, jinput-2.0.10-natives-all.jar)
- Processing Sound library

## Installation

### Development Environment

1. Install Processing 4 from processing.org
2. Add JInput libraries by dragging JAR files into Processing IDE
3. for Mac: Extract natives from `jinput-2.0.10-natives-all.jar` to `code/` directory 
4. Install Processing Sound library via Library Manager


### Raspberry Pi Deployment

```bash
# Prepare system
ssh <username>@raspberrypi.local
sudo apt update && sudo apt upgrade
sudo apt install default-jdk 
//these get the right jni/.so files that works on raspberry 4, the ones in jinput-2.0.10-natives-all.jar do not work on Rasp. pi.
sudo apt install default-jdk libjinput-java libjinput-jni

# Export from Processing as Linux ARM64
# Add to launch script: -Dnet.java.games.input.librarypath=/usr/lib/jni

# Transfer files
scp -r ~/Documents/Processing/yourproject <username>@raspberrypi.local:/home/<username>/Downloads
```

## Shader System

The game uses fragment shaders for post-processing effects. The CRT effect is implemented using a custom GLSL shader that processes the game canvas.

### ShaderToy Compatibility

To use ShaderToy shaders in Processing, apply this conversion pattern:

```glsl
// ShaderToy input
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = fragCoord/iResolution.xy;
    // shader code here
    fragColor = vec4(color, 1.0);
}

// Processing conversion
#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 iResolution;
uniform sampler2D iChannel0;
varying vec2 vertTexCoord;

void main() {
    vec2 fragCoord = vertTexCoord * iResolution;
    vec2 uv = fragCoord/iResolution.xy;
    // shader code here (same as ShaderToy)
    gl_FragColor = vec4(color, 1.0);
}
```

Replace `fragCoord` with `vertTexCoord * iResolution` and `fragColor` with `gl_FragColor`. The `iChannel0` uniform provides access to the game canvas texture.

## Architecture

### Performance Optimization
- Dual-resolution rendering: Game logic at 50% canvas resolution, upscaled via shader
- Decoupled update loops: Input polling (40ms intervals), game logic (150ms intervals)
- Efficient collision detection with spatial awareness

### Input System
- Multi-controller support with fallback handling
- Analog and digital input processing
- Direction buffering prevents invalid moves within movement frames

### Technical Implementation
- State machine architecture (PLAYING, PAUSED, GAME_OVER)
- Modular audio system with graceful degradation
- Food spawning algorithm prevents snake collision
- Edge-wrapping movement system

## Game Mechanics

Players control snakes that grow by consuming food items. Game ends when any snake collides with itself or another snake. Score is shared between players. Snakes wrap around screen boundaries.

## Troubleshooting

**Controller Issues:** Verify JInput installation and library path configuration  
**Audio Problems:** Check file presence in data directory, game continues without audio  
**Performance:** Reduce canvas resolution or disable shader effects  
**Shader Errors:** Ensure GLSL file exists and graphics drivers support fragment shaders

## Development

Project follows standard Processing sketch structure with external libraries in `code/` directory and assets in `data/` directory. Core game loop separates input handling, game logic updates, and rendering phases.

## License

Open source project. See LICENSE file for details.