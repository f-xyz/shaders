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

struct lambertMaterial {
    vec3 diffuse;
    float specular;
};

lambertMaterial wmaterial(vec3 a) {
    lambertMaterial mat = lamberMaterial(vec3(0.5, 0.56, 1.0), 200.0);
    float closest = sBall(a); 
}

float world(vec3 at) {
    /*
        # doc #
            
        Sphere   : length(at) - R
        Plane    : dot(at, N) - D
        Box      : length(max(abs(at)-size), 0)
        Cilinder : length(at.xz) - R
            
        Union     : min(f, g)
        Intersect : max(f, g)
        Minus     : max(f, -g)
        
        Translation : at - vec3(position) 
        Rotation    : at * mat3(rotation matrix)
            
    */
//    return length(at) - 1.0; // sphere
    return min(length(at) - 1.0, at.y + 1.0); // sphere & ground
}

vec3 light(vec3 at, vec3 normal, vec3 diffuse, vec3 lColor, vec3 lPos) {
    // direction from current point to the light source
    vec3 lDir = lPos - at;
    return diffuse * lColor * max(0.0, dot(normal, normalize(lDir))) / dot(lDir, lDir);
}

vec3 wnormal(vec3 a) {
    vec2 e = vec2(0.001, 0.0);
    float w = world(a);
    return normalize(vec3(
        world(a+e.xyy) - w,
        world(a+e.yxy) - w,
        world(a+e.yyx) - w));
}

float occlusion(vec3 at, vec3 normal) {
    float b = 0.0;
    for (int i = 1; i <= 4; i++) {
        float L = 0.06 * float(i);
        float d = world(at + normal * L);
        b += max(0.0, L - d);
    }
    return min(b, 1.0);
}

float trace(vec3 O, vec3 D) {
    float L = 0.0;
    for (int i = 0; i < MAX_STEPS; i++) {
        float d = world(O + D*L);
        L += d;
        if (d < EPSILON) break;
    }
    return L;
}

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
    
    // zero point
    vec3 O = vec3(0.0, 0.0, 3.0);
    
    // looking at
    vec3 D = normalize(vec3(xy, -2.0));
    
    // ray tracing
    for (int i = 0; i < MAX_REFLECTIONS; i++) {
        
        float path = trace(O, D);
        if (path < 0.0) {
            break;
        }
        
        vec3 pos = O + D * path;
        vec3 nor = wnormal(pos);
        
        lambertMaterial mat = wmaterial(pos); 
        
    }
    
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
