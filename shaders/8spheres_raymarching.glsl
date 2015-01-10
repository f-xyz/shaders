//#define HD
#define PI 3.14159265

#ifdef HD
    #define MAX_STEPS       320.0
    #define MAX_PATH        10.0
    #define MIN_PATH_DELTA  1e-4
    #define REFLECTIONS     3.0
    #define NORMAL_DELTA    1e-1
#else
    #define MAX_STEPS       16.0
    #define MAX_PATH        10.0
    #define MIN_PATH_DELTA  1e-2
    #define REFLECTIONS     2.0
    #define NORMAL_DELTA    1e-1
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

float plane(vec3 v, float y)  { return v.y + y; }
float sphere(vec3 v, float r) { return length(v) - r; }
float box(vec3 v, float size) {
    vec3 d = abs(v) - vec3(size);
    return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
}

vec4 chess(vec3 v) {
    if (fract(v.x) > 0.5)
        if (fract(v.z) > 0.5)
            return vec4(0.0, 0.0, 1.0, 1.0);
        else
            return vec4(1.0, 0.0, 0.0, 1.0);
    else
        if (fract(v.z) > 0.5)
            return vec4(0.0, 1.0, 0.0, 1.0);
        else
            return vec4(1.0, 0.0, 1.0, 1.0);
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

vec2 join(vec2 a, vec2 b) {
    float d = a.x - b.x;
    return d < 0.0 ? a : b;
}

vec3 repeat(vec3 v, float s) {
    vec3 rv = v;
    rv = mod(v, vec3(s)) - s/2.0*vec3(1.0, 0.0, 1.0);
    return rv;
}

vec2 world(vec3 v) {
    //v.x += 6.0;
    float dist = 7.0;
    float angle = 100.0*time + 3.925; // magic
    vec3 e = vec3(dist*sin(angle), dist*cos(angle), 0.0);
    float r = 2.0;
    return join(join(join(join(join(join(
        vec2(sphere(v, 4.0),     0.0),
        vec2(sphere(v+e.xyz, r), 0.2)),
        vec2(sphere(v+e.xzy, r), 0.2)),
        vec2(sphere(v+e.yxz, r), 0.2)),
        vec2(sphere(v+e.yzx, r), 0.2)),
        vec2(sphere(v+e.zxy, r), 0.2)),
        vec2(sphere(v+e.zyx, r), 0.2));
}

void main() {

    vec2 pos01 = gl_FragCoord.xy/resolution;
    vec2 pos = 2.*pos01 - 1.;
    float ratio = resolution.x/resolution.y;

    vec3 up     = vec3(0.0, 1.0, 0.0);
    vec3 eye    = vec3(0.0, 0.0, 1.0);
    vec3 lookAt = vec3(0.0, 0.0, 0.0);

    float dist = 10.0;
    float freq = 10.0;
    float a = freq*time;
    eye.x += dist*sin(a*freq*0.7);
    eye.y += dist*cos(a*freq*0.7);
    eye.z += dist*cos(a*freq*0.7);

    vec3 forward = normalize(lookAt - eye);
    vec3 x = normalize(cross(up, forward)); // x
    vec3 y = cross(forward, x); // y
    vec3 o = eye + forward; // screen center point
    vec3 ro = o + pos.x*x*ratio + pos.y*y; // ray origin
    vec3 rd = normalize(ro - eye); // ray direction

    // ray marching

    float steps;
    const float maxSteps = MAX_STEPS;
    float path = 0.0; // depth = ray path length
    float maxPath = MAX_PATH;
    float minPathD = MIN_PATH_DELTA;
    float matId; // material ID

    gl_FragColor = vec4(0.0);

    vec3 e = vec3(NORMAL_DELTA, 0.0, 0.0); // gradient delta
    vec3 normal;
    vec3 v; // voxel
    for (float refl = 0.0; refl < REFLECTIONS; refl++)
        for (float i=0.0; i<maxSteps; ++i) {
            v = ro + path*rd; // current voxel
            vec2 w = world(v);
            float deltaZ = w.x; // distance to the closest surface
            path += deltaZ;
            matId = w.y; // material ID
            steps = i;

            if (deltaZ < minPathD) { // the ray hits

                normal = normalize(vec3(
                    world(v + e.xyy).x - world(v - e.xyy).x,
                    world(v + e.yxy).x - world(v - e.yxy).x,
                    world(v + e.yyx).x - world(v - e.yyx).x));

                rd = normalize(reflect(rd, normal));
                ro = v;// + rd*1.0*minPathD;

                vec3 light = eye;//vec3(10, 10, 20);
                float phong  =
                    //max(0.0, dot(normal, normalize(light.xzy - v))) +
                    //max(0.0, dot(normal, normalize(light.yxz - v))) +
                    max(0.0, dot(normal, normalize(light.xyz - v)));

                vec4 matC;
                if      (matId == 0.8) matC = grid(v);
                else if (matId == 0.1) matC = vec4(0.6, 0.6, 0.6, 1.0);
                else if (matId == 0.2) matC =
                    vec4(
                        sin(time*130.0),
                        cos(time*170.0),
                       -sin(time*110.0),
                        1.0);
                else matC = vec4(1.0);

                gl_FragColor += matC*phong;

                break;
            }
        }

    //gl_FragColor *= 1.0 - z/maxPath;
    //gl_FragColor = 1.2*brightness*gl_FragColor;
}
