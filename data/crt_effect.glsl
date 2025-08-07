#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

// Processing texture shader uniforms
uniform sampler2D texture;
uniform vec2 texOffset;

// Only the uniforms we actually use
uniform vec3 iResolution;

// Processing texture shader varyings
varying vec4 vertColor;
varying vec4 vertTexCoord;

// Toggle effects - set to 0 to disable
#define SCANLINES 1
#define CHROMATIC_ABERRATION 1
#define VIGNETTE 1
#define DISTORT 1

// Pre-calculated constants
const float CA_STRENGTH = 3.0;
const float CORNER_OFFSET = 0.81;
const float CORNER_MASK_INTENSITY_MULT = 16.0;
const float BORDER_OFFSET = 0.02;
const float K1 = 0.04;

// Pre-calculated values
const vec2 CA_OFFSET_POS = vec2(1.0 + CA_STRENGTH);
const vec2 CA_OFFSET_NEG = vec2(1.0 - CA_STRENGTH);
const float SCALE_FACTOR = 1.0 - K1; // Since K1 < 1.0
const float SCALE_OFFSET = SCALE_FACTOR * 0.5;

void main()
{
    vec2 uv = vertTexCoord.xy;
    
#if DISTORT
    // Optimized Brown Conrady distortion
    vec2 centered = uv * 2.0 - 1.0;
    float r2 = dot(centered, centered); // More efficient than x*x + y*y
    centered *= 1.0 + K1 * r2;
    uv = centered * 0.5 + 0.5;
    uv = uv * SCALE_FACTOR - SCALE_OFFSET + 0.5;
#endif
    
    vec3 result;
    
#if CHROMATIC_ABERRATION
    // Optimized chromatic aberration with fewer calculations
    vec2 offset = CA_STRENGTH / iResolution.xy;
    vec2 uvCentered = uv - 0.5;
    
    result.g = texture2D(texture, uv).g;
    result.r = texture2D(texture, uvCentered * CA_OFFSET_POS / iResolution.xy * CA_STRENGTH + uv).r;
    result.b = texture2D(texture, uvCentered * CA_OFFSET_NEG / iResolution.xy * CA_STRENGTH + uv).b;
#else
    result = texture2D(texture, uv).rgb;
#endif
    
#if SCANLINES
    // Simplified scanlines - single sin wave is often sufficient
    result *= 0.5 + 0.5 * abs(sin(iResolution.y * uv.y));
#endif    

#if VIGNETTE
    // Optimized vignette calculation
    vec2 vigUV = uv - 0.5;
    
    // Corner vignette
    float corner = 1.0 - clamp((length(vigUV) - CORNER_OFFSET) * CORNER_MASK_INTENSITY_MULT, 0.0, 1.0);
    
    // Border vignette
    vec2 border = abs(vigUV) - (0.5 - BORDER_OFFSET);
    vec2 borderMask = 1.0 - smoothstep(0.0, BORDER_OFFSET, border);
    
    result *= corner * borderMask.x * borderMask.y;
#endif
     
    gl_FragColor = vec4(result, 1.0);
}