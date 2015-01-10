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
#define abssin(x) abs(sin(x))

uniform float time;
uniform vec2 resolution;
uniform vec2 mouse;
uniform sampler2D tex;
uniform sampler2D backbuffer;
varying vec3 vPos;
varying vec2 vTextureCoord;

void main() {
    vec2 v = gl_FragCoord.xy/resolution;
    vec2 c = vec2(3.5*v.x-2.5, 2.0*v.y-1.0);

    float speed = 10.0;
    float seed = abs(cos(time));
    vec3 zoom = vec3(
        //1.52, 0.0,
        0.77568377, -0.13646737,
        //-0.28693186889504513, -0.014286693904085048,
        //-0.3245046418497685, -0.04855101129280834,
        //-0.28693186889504513, -0.014286693904085048,
        1.0+exp(abs(10.0*seed)));

    zoom.xy += sin(time*5.0)/10000.0;

    c += zoom.xy;
    c /= zoom.z;

    float cosT = cos(time*4.0);
    float sinT = sin(time*1.0);
    c = c * mat2(cosT, -sinT, sinT, cosT);

    c -= zoom.xy;

    vec2 z = c;

    gl_FragColor = vec4(seed);

    float n = 100.0 + 300.0*seed;
    for (float i = 0.0; i >= -1.0; ++i) {
        if (i > n) {
            break;
        }

        z = vec2(z.x*z.x - z.y*z.y, 2.0*z.x*z.y) + c;

        if (dot(z,z) > 4.0 || i > n) {
            float q = length(v+0.5);
            float f = i/n/q;
            //gl_FragColor = vec4(f);
            gl_FragColor = 0.25*pow(1.0+abs(cos(time)), 2.0)*vec4(
                q*abssin(-f*1.5+time*0.5),
                q*abssin( f*2.0+time*2.0),
                q*abssin( f*3.0+time*1.5),
                1.0);
            break;
        }
    }
}
