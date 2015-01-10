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

uniform float time;
uniform vec2 resolution;
uniform vec2 mouse;
uniform sampler2D tex;
uniform sampler2D backbuffer;
varying vec3 vPos;
varying vec2 vTextureCoord;

#define PI              3.14159265
#define P               1.57079633
#define MAX_STEPS       256
#define MAX_REFLECTIONS 2
#define EPSILON         0.001

// world ==============================

vec2 plane(vec3 v) {
    return vec2(v.y + 10.0, 0.0);
}

vec2 box(vec3 v) {
    return vec2(
        -20.25 + length(max(abs(v) - vec3(40.0), 0.0)),
       2.0
    );
}

vec2 sphere(vec3 p, float r) {
    float d = length(p) - r;
    return vec2(d, 2.0);
}

// ====================================

vec2 join(vec2 m1, vec2 m2) {
    if (m1.x < m2.x) {
        return m1;
    } else {
        return m2;
    }
}

vec2 repeat(vec3 v, vec3 c) {
    vec3 q = mod(v, c) - 0.5*c;
    return box(q);
}

vec2 world(vec3 v) {
    return //join(
        //box(v + 5.0*sin((v.zyz+time*100.0)/10.0));
        sphere(v + 0.2*abs(sin(time))*sin((v.xyz)/1.0), 60.0);
}

// materials ==========================

vec3 materialCheckerBoard(vec3 v) {
    float size = 0.5;
    float x = fract(v.x*size);
    float z = fract(v.z*size);
    if (x > size) {
        if (z > size)   return vec3(0.5, 0.0, 0.8);
        else            return vec3(0.0, 0.0, 0.0);
    }
    else {
        if (z > size)   return vec3(0.0, 0.0, 0.0);
        else            return vec3(0.9, 0.0, 0.6);
    }
}

// main ===============================

void main() {
    vec2 q = gl_FragCoord.xy/resolution;
    vec2 vPos = -1.0 + 2.0*q;
    float ratio = resolution.x/resolution.y;

    // camera
    vec3 vuv = vec3(0.0, 1.0, 0.0); // up vector
    vec3 vrp = vec3(0.0, 0.0, 0.0); // look at
    vec3 prp = vec3(0.0, 0.0, 1.0); // position

    // camera path ^_^
    float angle = time * 1.0;
    prp = vec3(
        -sin(time*5.0)*8.0,
        cos(time*5.0)*8.0,
        10.0*cos(time*10.0));
    float d = 100.0;
    prp = vec3(d*sin(angle), d*-sin(angle), d*cos(angle));

    vec3 vpn = normalize(vrp - prp);
    vec3 u = normalize(cross(vuv, vpn));
    vec3 v = cross(vpn, u);
    vec3 vcv = (prp + vpn);
    vec3 scrCoord = vcv + 1.0*(vPos.x*u*ratio + vPos.y*v);
    vec3 scp = normalize(scrCoord - prp);

    // raymarhing
    const vec3 e = vec3(0.1, 0.0, 0.0);
    const float maxDepth = 100.0;
    vec2 s = vec2(0.1, 0.0);
    vec3 c, p, n;

    float f = 1.0;
    for (int i=0; i<3; i++) {
        if (abs(s.x) < 0.01 || f > maxDepth) break;
        f += s.x;
        p = prp + scp*f;
        s = world(p);
    }

    if (f < maxDepth) {
        if      (s.y == 0.0)    c = materialCheckerBoard(p);
        else if (s.y == 1.0)    c = vec3(
                                    abs(2.0*sin(f+100.0*time)),
                                    0.3,//abs(cos(s.x*1000.0)),
                                    abs(sin(s.x*1000.0+time)));
        else if (s.y == 2.0)    c = vec3(0.3, 0.6, 0.9);
        else                    c = vec3(
                                    abs(2.0*sin(f+100.0*time)),
                                    abs(cos(s.y*1000.0)),
                                    abs(sin(s.x*1000.0+time)));

        n = normalize(vec3(
            s.x - world(p - e.xyy).x,
            s.x - world(p - e.yxy).x,
            s.x - world(p - e.yyx).x));
        float b = pow(dot(n, normalize(prp - p)), 1.7)*1.5;
        // simple phong lighting: light pos. = camera pos.
        gl_FragColor = vec4((b*c + pow(b, 16.0))*(1.0 - f*0.01), 1.0);
    }
    else {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
    }

}
