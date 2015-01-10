//#define HD
#define PI 3.14159265

#ifdef HD
    #define MAX_STEPS       640.0
    #define MAX_PATH        100.0
    #define MIN_PATH_DELTA  1e-4
    #define REFLECTIONS     3.0
    #define NORMAL_DELTA    1e-3
#else
    #define MAX_STEPS       128.0
    #define MAX_PATH        100.0
    #define MIN_PATH_DELTA  1e-3
    #define REFLECTIONS     3.0
    #define NORMAL_DELTA    1e-2
#endif

uniform float time;
uniform float seed;
uniform vec2 resolution;
uniform vec2 mouse;
uniform sampler2D tex;
uniform sampler2D backbuffer;

varying vec3 vPos;
varying vec2 vTextureCoord;

////////////////////////////////////////

void main() {
    vPos = position;
    vTextureCoord = uv;
    gl_Position = projectionMatrix
                * modelViewMatrix
                * vec4(vPos, 1.0);
}

////////////////////////////////////////

struct Intersection {
    float d;
    float matId;
    float refl;
    float a;
    float fog;
};

float plane(vec3 v, float y)  { return v.y + y; }
float sphere(vec3 v, float r) { return length(v) - r; }
float hollowSphere(vec3 v, float r) { return abs(length(v) - r); }

float torus(vec3 v, vec2 t) {
    vec2 q = vec2(length(v.xz) - t.x, v.y) ;
    return length(q) - t.y;
}

float box(vec3 v, float size) {
    vec3 d = abs(v) - vec3(size);
    return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
}

vec4 chess(vec3 v) {
    if (fract(v.x) > 0.5)
        if (fract(v.z) > 0.5)   return vec4(0.0, 0.0, 1.0, 1.0);
        else                    return vec4(1.0, 0.0, 0.0, 1.0);
    else
        if (fract(v.z) > 0.5)   return vec4(0.0, 1.0, 0.0, 1.0);
        else                    return vec4(1.0, 0.0, 1.0, 1.0);
}

vec4 grid(vec3 v) {
    float d = 0.05;
    float dx = fract(v.x);
    float dz = fract(v.z);
    if (dx <= d || dz <= d)
        return vec4(0.0);
    else
        return vec4(1.0);
}

vec4 net(vec3 v) {
    float d = 0.1;
    float dx = fract(v.x);
    float dz = fract(v.z);
    if (dx <= d || dz <= d)
        return vec4(1.0);
    else
        return vec4(0.0);
}

vec4 invert(vec4 v) {
    return vec4(1.0) - v;
}

vec3 join(vec3 a, vec3 b) {
    float d = a.x - b.x;
    return d < 0.0 ? a : b;
}

vec3 repeat(vec3 v, float s) {
    vec3 rv = v;
    rv = mod(v, vec3(s)) - s/2.0*vec3(1.0, 0.0, 1.0);
    return rv;
}

float hash(float seed) {
    return fract(sin(seed)*94565.6547);
}

float hash(vec2 seed) {
    return hash(dot(seed, vec2(456.133, 231.654)));
}

float noise(vec2 seed) {
    vec2 F = floor(seed);
    vec2 f = fract(seed);
    vec2 e = vec2(1.0, 0.0);

    f *= f * (3.0 - 2.0 * f);

    return mix(
        mix(hash(F + e.yy), hash(F + e.xy), f.x),
        mix(hash(F + e.yx), hash(F + e.xx), f.x), f.y);
}

float fnoise(vec2 seed) {
    seed += vec2(12.0);
    return 0.5 * noise(seed)
        +  0.25 * noise(seed * 1.97)
        +  0.125 * noise(seed * 4.04)
        +  0.0625 * noise(seed * 8.17)
        ;
}

vec3 sat[3];
vec3 world(vec3 v) {
    vec2 e = vec2(0.0, 1.0);
    //vec3 wv = v;
    //wv.y += 0.1*sin(wv.z*2.-time*50.)/**noise(wv.z)*/+0.1*sin(wv.x);
    vec3 w = v;
    float s = 50.0;
    w.y *= s;
    sat[0] = v+e.yyy;
    return join(
        join(
            vec3(sphere(v, 1.0), 1.0, 0.0),
            vec3(torus(w, vec2(1.8, 0.3))/s, 0.0, 0.0)),
            vec3(sphere(sat[0], 0.1), 2.0, 0.0));
}

void main() {

    float ratio = resolution.x/resolution.y;
    vec2 pos01 = gl_FragCoord.xy/resolution;

    // x, y E [-1, 1]
    vec2 pos = (2.*pos01 - 1.) * vec2(ratio, 1.0);

    vec3 up     = vec3(0.0, 1.0, 0.0);
    vec3 eye    = vec3(0.0, 0.0, 1.0);
    vec3 lookAt = vec3(0.0, 0.0, 0.0);

    float dist = 4.0;
    float a = 10.0*time+0.785;
    eye.x = dist*cos(a+0.785);
    eye.y = 1.0+dist*sin(a+1.57);
    eye.z = dist*sin(a+0.785);

    vec3 forward = normalize(lookAt - eye);
    vec3 x = normalize(cross(up, forward)); // x
    vec3 y = cross(forward, x); // y
    vec3 o = eye + forward; // screen center point
    vec3 ro = o + pos.x*x + pos.y*y; // ray origin
    vec3 rd = normalize(ro - eye); // ray direction

    // ray marching

    float path = 0.0; // depth = ray path length
    float maxPath = MAX_PATH;
    float minPathD = MIN_PATH_DELTA;

    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);

    float posNoise = hash(5.0*pos);
    if (posNoise < 0.01) {
        gl_FragColor = vec4(1.0, 1.0, 1.0, posNoise*50.0);
    }

    float meteor = abs(0.1 - mod(time, 0.1));
    if (meteor < 0.001)
        ;//gl_FragColor = vec4( );

    vec2 e = vec2(NORMAL_DELTA, 0.0); // gradient delta
    vec3 normal;
    vec3 v; // voxel
    float matId; // material ID
    vec4 matC; // material color
    float rayPower = 1.0;

    for (float refl = 0.0; refl < REFLECTIONS; refl++)
        for (float i = 0.0; i < MAX_STEPS; ++i) {
            v = ro + path*rd; // current voxel
            vec3 w = world(v);
            float deltaZ = w.x; // distance to the closest surface
            path += deltaZ;
            matId = w.y; // material ID

            if      (path > maxPath) break;
            else if (deltaZ < minPathD) { // the ray hits

                normal = normalize(vec3(
                    world(v + e.xyy).x - world(v - e.xyy).x,
                    world(v + e.yxy).x - world(v - e.yxy).x,
                    world(v + e.yyx).x - world(v - e.yyx).x));

                rd = normalize(reflect(rd, normal));
                ro = v + 2.0*minPathD*rd;

                vec3 light = eye;
                float phong =
                    max(0.0, dot(normal, normalize(sat[0].xyz - v)));
                    //max(0.0, dot(normal, normalize(light.xyz - v)));

                if (matId == 0.0) {
                    //matC = net(pow(v, vec3(4.0))*4.0);
                   float r = sqrt(v.x*v.x + v.z*v.z);
                   float q = atan(v.z/v.x);
                   matC = vec4(fnoise(vec2(r,1.)*10.));
                   matC.a = 0.01;
                }
                else if (matId == 0.5) matC = grid(v);
                else if (matId == 1.0) {
                    matC = 5.0 * fnoise(4.0*v.zy) * vec4(
                        0.6*abs(sin(v.x)),
                        0.5*abs(sin(v.y+0.785)),
                        0.4*abs(sin(v.z+1.57)),
                        1.0
                    );
                } else {
                    matC = 0.25 * vec4(
                        0.2,
                        0.6,
                        0.8,
                        4.0
                    );
                }

                vec4 c = rayPower*matC*phong;
                if (refl == 0.0)
                    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);

                if (matId == 2.0) {
                    float q = path/MAX_PATH;
                    gl_FragColor += mix(c, vec4(0,0,0,1), q);
                } else {
                    gl_FragColor += c;
                }
                rayPower = w.z;
                break;
            }
        }

     // dynamic fog
    gl_FragColor += 5.0
        * vec4(pow(fnoise(pos.xy*0.5+1.0), 4.0)) // brightness
        * vec4(sin(pos.x), cos(pos.x), 1.0, 1.0); // hue
}