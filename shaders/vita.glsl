uniform float time;
varying vec3 vPos;
varying vec2 vUv;

void main() {
    vPos = position;
    vUv = uv;
    // gl_PointSize = 20.0;
    gl_Position = projectionMatrix 
                * modelViewMatrix 
                * vec4(vPos, 1.0);
}

/////

uniform float time;
uniform vec2 screen;
uniform vec2 resolution;
uniform vec2 mouse;
uniform sampler2D tex;
uniform sampler2D backbuffer;
varying vec3 vPos;
varying vec2 vUv;

#define MAX_STEPS 32
#define MAX_REFLECTIONS 2
#define EPSILON 0.001

struct particle {
    vec4 xy;
    vec4 v;
    vec4 a;
    float t;
};

void main() {

    vec4 debug = vec4(0.0, 0.0, 0.0, 0.0);
    
    vec4 px = vec4(0.0, 0.0, 0.0, 1.0);

    float ratio = resolution.x / resolution.y;

    vec2 mouse = mouse / resolution * 2.0 - 1.0;
    mouse.x =  mouse.x - 1.0;
    mouse.y = -mouse.y / ratio + 0.5;
    

    vec2 xy = gl_FragCoord.xy / resolution * 2.0 - 1.0;
    xy.x *= ratio;    

    float angle = atan(xy.y, xy.x);
    float light = abs(sin(angle + length(xy) - time/10.0));

    // world
    
    px.rb = abs(cos(xy.xy-sin(time)))/4.0;
    px.bg = abs(sin(xy.xy-cos(time)))/4.0;
    
    /*
    // test
    px.r = 10.0*max(0.1 - distance(xy, vec2(0.0, 0.0)), 0.0);
    px.g = 10.0*max(0.1 - distance(xy, mouse), 0.0);
    px.b = 10.0*max(0.1 - distance(xy, vec2(sin(time/10.0), cos(time/10.0))), 0.0);
    */

    // texture
    //px += pow(texture2D(tex, vUv), vec4(6.0))*2.0;

    // debug
    vec2 debugPos = vec2(-1.0*ratio, 1.0);
    float debugSize = 0.1;
    if (length(xy-debugPos) <= debugSize) {
        px = vec4(1.0, 0.0, 1.0, abs(sin(time)));
    }

    gl_FragColor = px;
}
