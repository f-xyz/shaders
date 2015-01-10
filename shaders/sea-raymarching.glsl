//#define HD
#define PI 3.14159265

#ifdef HD
    #define MAX_STEPS       64.0
    #define MAX_PATH        10.0
    #define MIN_PATH_DELTA  1e-6
    #define REFLECTIONS     3.0
    #define NORMAL_DELTA    1e-2
#else
    #define MAX_STEPS       16.0
    #define MAX_PATH        100.0
    #define MIN_PATH_DELTA  1e-4
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

float plane(vec3 v, float y)  { return v.y + y; }
float sphere(vec3 v, float r) { return length(v) - r; }
float hollowSphere(vec3 v, float r) { return abs(length(v) - r); }

float box(vec3 v, float size) {
    vec3 d = abs(v) - vec3(size);
    return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
}

float infCross(vec3 v, vec3 s) {
    return 1.0;
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

vec4 invert(vec4 v) {
    return vec4(1.0) - v;
}

float smin(float a, float b) {
#if 1
	float k = 32.0;
	float res = exp(-k*a) + exp(-k*b);
    return -log( res )/k;
#else
    float k = 0.1;
	float h = clamp(0.5 + 0.5*(b-a)/k, 0.0, 1.0);
	return mix(b, a, h) - k*h*(1.0-h);
#endif
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

float noise(vec3 v, float time) {
    return fract(sin(length(v))*25641.48995464+time*6541.48995464);
}

vec2 world(vec3 v) {
    vec3 e = vec3(1.0, 0.0, 0.0);
    float r = 1.0;
    float s = abs(sin(time+1.57));
    float el = 2.0-abs(sin(time*4.0));
    float repl = 1.0;
    //vec3 bounceV = mod(vec3(v.x, v.y/**el*/, v.z)/*/el*/, repl) - 0.5*repl;
    vec3 seaV = v+vec3(0.0);
    return join(//join(join(join(join(
        vec2(sphere(v, 0.5), 1.0),
        //vec2(sphere(v + 1.5*e.xyy, 0.5), 2.0)),
        //vec2(sphere(v - e.xyy, 0.5), 1.0)),
        //vec2(sphere(v + e.yyx, 0.5), 1.0)),
        //vec2(sphere(v - e.yyx, 0.5), 1.0)),
        vec2(plane(seaV, 0.5), 0.5));
}

void main() {

    vec2 pos01 = gl_FragCoord.xy/resolution;
    vec2 pos = 2.*pos01 - 1.;
    float ratio = resolution.x/resolution.y;

    vec3 up     = vec3(0.0, 1.0, 0.0);
    vec3 eye    = vec3(0.0, 0.0, 1.0);
    vec3 lookAt = vec3(0.0, 0.0, 0.0);

    float a = 10.0*time;
    float dist = 1.5+0.5*abs(sin(a/2.0));
    eye.x = dist*sin(a);
    eye.y = dist*abs(cos(a));
    eye.z = dist*cos(a);

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

    //gl_FragColor = exp(abs(pow(pos.y, 3.0))*vec4(1.0))/3.0 - vec4(0.2);
    gl_FragColor = exp(abs(pow(pos.y, 3.0))*vec4(1.0))/3.0 - vec4(0.2);

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
                ro = v;// - 1.0*rd;

                vec3 light = eye;
                float phong =
                    //max(0.0, dot(normal, normalize(light.xzy - v))) +
                    //max(0.0, dot(normal, normalize(light.yxz - v))) +
                    max(0.0, dot(normal, normalize(light.xyz - v)));

                vec4 matC;
                a = time*.0;
                if      (matId == 0.0) matC = grid(v);
                if      (matId == 0.5) matC = invert(grid(v));
                else if (matId == 1.0) matC = invert(
                    vec4(
                      sin(a+1.57),
                      cos(a+1.57),
                     -sin(a+1.57),
                      1.0)/2.0);
                else if (matId == 2.0) matC =
                    vec4(
                      sin(a),
                      cos(a),
                     -sin(a),
                      1.0)/2.0;
                else if (matId == 3.0) matC =
                    vec4(
                      sin(a+0.785),
                      cos(a+0.785),
                     -sin(a+0.785),
                      1.0)/2.0;
                else matC = vec4(1.0)/6.0;

                float iter = 1.0-steps/maxSteps;
                //float refl = (REFLECTIONS-refl)*REFLECTIONS;
                gl_FragColor += matC*phong/*iter**//**refl*/;

                break;
            }
        }

    //gl_FragColor *= 1.0 - z/maxPath;
    //gl_FragColor = 1.2*brightness*gl_FragColor;
}
