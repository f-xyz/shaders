uniform float time;
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


#define PI 3.14159265

float plane(vec3 v, float y)  { return v.y + y; }
float sphere(vec3 v, float r) { return length(v) - r; }
float hollowSphere(vec3 v, float r) { return abs(length(v) - r); }
float box(vec3 v, float size) {
    vec3 d = abs(v) - vec3(size);
    return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
}

vec2 join() { return vec2(0.0); }

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

vec2 join(vec2 ad, vec2 bd) { return ad.x < bd.x ? ad : bd; }
vec2 cut(vec2 ad, vec2 bd) { return ad.x > bd.x ? ad : bd; }

vec3 rotateX(vec3 v, float speed) {
    float t = time*speed;
    return v * vec3(cos(t) + cos(t), -sin(t) + cos(t), 1.0);
}

vec2 world(vec3 v) {
    vec3 c = vec3(1);
    float sphere1 = sphere(mod(v, c)-0.5*c, 0.1);
    return vec2(sphere1, 0.2);
}

void main() {
    vec2 pos01 = gl_FragCoord.xy/resolution;
    vec2 pos = 2.*pos01 - 1.;

    vec3 eye = vec3(0.0, 0.0, -1.0);

    float amp = 2.0;
    float freq = 1.0;
    eye.x += amp*cos(time*freq) + amp*sin(time*freq);
    eye.y += amp*sin(time*freq) - amp*cos(time*freq);

    vec3 up      = vec3(0.0, 1.0, 0.0);
    vec3 right   = vec3(1.0, 0.0, 0.0);
    vec3 forward = vec3(0.0, 0.0, 1.0);

    float screenDistance = 1.0;
    vec3 rayOrigin = eye + forward*screenDistance + right*pos.x + up*pos.y;
    vec3 rayDirection = rayOrigin - eye;

    float steps;
    const float maxSteps = 100.0;
    float z = 0.0; // depth = ray path length
    float maxZ = 10.0;
    float minDeltaZ = 0.01;
    float matId; // material ID

    vec3 v; // voxel
    for (float i=0.0; i<maxSteps; ++i) {
        v = rayOrigin + z*rayDirection; // voxel

        vec2 tmp = world(v);
        // tmp.x -> distance to closest surface
        // tmp.y -> material ID
        float deltaZ = tmp.x;

        z += deltaZ;

        matId = tmp.y;
        steps = i;

        if (deltaZ < minDeltaZ)
            break;
    }


    vec3 light = vec3(-20.0, -30.0, -1.0);
    vec3 gradientDelta = vec3(0.01, 0.0, 0.0);
    vec3 normal = normalize(vec3(
        z - world(v - gradientDelta.xyy).x,
        z - world(v - gradientDelta.yxy).x,
        z - world(v - gradientDelta.yyx).x));
    float brightness = pow(dot(normal, normalize(light - v)), 10.0);

    vec3 light2 = vec3(-20.0, -20.0, -10.0);
    float violet = pow(dot(normal, normalize(light2 - v)), 10.0);

    gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);

    if (matId == 0.0)
        gl_FragColor = chess(v);

    else if (matId == 0.1)
        gl_FragColor = vec4(1.0-z/0.5, 0.0, 1.0-z/0.5, 1.0);
    else
        gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);

    gl_FragColor = brightness*gl_FragColor +
        0.5*violet*vec4(0.7, 0.1, 0.9, 1.0)*gl_FragColor;
}
