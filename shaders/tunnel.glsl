uniform float time;
varying vec3 vPos;
varying vec2 vTextureCoord;

void main() {
    vPos = position;
    vTextureCoord = uv;
    gl_Position = projectionMatrix 
                * modelViewMatrix 
                * vec4(vPos, 1.0);
}

////////////////////////////////////////

#define PI 3.14159265

uniform float time;
uniform vec2 resolution;
uniform vec2 mouse;
uniform sampler2D tex;
uniform sampler2D backbuffer;
varying vec3 vPos;
varying vec2 vTextureCoord;

// world ==============================

vec2 plane(vec3 v) {
    return vec2(v.y + 10.0, 0.0);
}

vec2 box(vec3 v, vec3 s) {
    return vec2(
        length(max(abs(v) - s, 0.0)),
        2.0
    );
}

vec2 sphere(vec3 v, float r) {
    float d = length(v) - r;
    return vec2(d, 0.0);
}

// ====================================

vec2 join(vec2 a, vec2 b) {
    if (a.x < b.x)  return a;
    else            return b;
}

vec2 subst(vec2 a, vec2 b) {
    a.x = -a.x;
    if (a.x > b.x)  return a;
    else            return b;
}

vec2 blend(vec3 v, vec2 a, vec2 b) {
    float s = smoothstep(length(v), 0.0, 1.0);
    float d = mix(a.x, b.x, s);
    return vec2(d, 2.0);
}

vec2 repeat(vec3 v, vec3 c) {
    vec3 q = mod(v, c) - 0.5*c;
    return vec2(0.0, 0.0);
}

vec2 storm(vec3 v, float amp) {
    float r = sin(amp*v.x+time*10.0) * 
              sin(amp*v.y+time*10.0) * 
              sin(amp*v.z+time*10.0);
    return vec2(r, 0);
}

vec2 world(vec3 v) {
    return 
        1.0 * sphere(v-vec3(0.0, 0.0, -2.0), 5.0) + 
        storm(v, 1.0);
}

// materials ==========================

vec3 materialCheckerBoard(vec3 v) {
    float size = 0.5;
    float x = fract(v.x*size);
    float z = fract(v.z*size);
    if (x > size) {
        if (z > size)   return vec3(0.5, 0.0, 0.8);
        else            return vec3(0.0, 0.0, 0.0);
    } else {
        if (z > size)   return vec3(0.0, 0.0, 0.0);
        else            return vec3(0.9, 0.0, 0.6);
    }
}

/*
float trace(vec3 from, vec3 dir) {
    float prec = 0.01; // min. distance
    float dist = 0.0; // total distance
    int steps = 0;
    int maxSteps = 100; // max. steps
    for (steps = 0; steps < maxSteps; steps++) {
        vec3 pos = from + dist*dir;
        float stepDist = world(pos).x;
        dist += stepDist;
        if (stepDist < prec) break;
    }
    return 1.0 - float(steps)/float(maxSteps);
}
*/

// main ===============================

void main() {

    vec2 vPos = -1.0 + 2.0*gl_FragCoord.xy/resolution;
    float ratio = resolution.x/resolution.y;
    
    // camera
    vec3 camUp  = vec3(0.0, 1.0, 0.0); // up vector
    vec3 camDir = vec3(0.0, 0.0, 0.0); // looking at
    vec3 camPos = vec3(0.0, 0.0, 1.0); // position
    
    // camera path ^_^ 
    float camDist = 8.0*abs(cos(time*2.0));
    camPos = vec3(-sin(time)*camDist, camDist, cos(time)*camDist);
    
    vec3 vpn = normalize(camDir - camPos);
    vec3 u = normalize(cross(camUp, vpn));
    vec3 v = cross(vpn, u);
    vec3 vcv = (camPos + vpn);
    vec3 coord = vcv + (vPos.x*u*ratio + vPos.y*v);
    //vec3 coord = vcv + 0.8*(vPos.x*u*ratio + vPos.y*v);
    vec3 scp = normalize(coord - camPos);

    // raymarching
    const vec3 e = vec3(0.1, 0.0, 0.0);
    const float maxDepth = 100.0;
    vec2 s = vec2(0.1, 0.0); // [distance, material]
    vec3 c, // color
         p, // current position
         n; // normal

    float f = 1.0;
    for (int i = 0; i < 100; i++) {
        if (abs(s.x) < 0.01 || f > maxDepth) break;
        f += s.x;
        p = camPos + scp*f;
        s = world(p);
    }

    if (f < maxDepth) {

        if      (s.y == 0.0)    c = materialCheckerBoard(p);
        else if (s.y == 1.0)    c = pow(0.75 * vec3(
                                    abs(sin(f)), 
                                    abs(sin(s.x*10.0-1.57)), 
                                    abs(cos(s.x*10.0))), vec3(3.0));
        else                    c = vec3(0.1, 0.5, 0.6);
        
        n = normalize(vec3(
            s.x - world(p - e.xyy).x,
            s.x - world(p - e.yxy).x,
            s.x - world(p - e.yyx).x));
        
        // brightness: light pos = camera pos
        float b = dot(n, normalize(camPos - p));
        gl_FragColor = vec4((b*c + pow(b, 16.0))*(1.0 - f*0.01), 1.0);
    }
    else {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
    }   
    
}
