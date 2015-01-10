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
    //float ratio = resolution.x/resolution.y;
    vec2 v = gl_FragCoord.xy/resolution;
    vec2 c = vec2(3.5*v.x-2.5, 2.0*v.y-1.0);

    const float speed = 10.0;
    vec3 zoom = vec3(
        //0.0, 0.0,
        0.77568377, -0.13646737, // nice
        //-0.1148477157360408, -0.9166666666666666,
        exp(time*speed));
    
    c += zoom.xy;
    c /= zoom.z;
    
    float cosT = cos(time);
    float sinT = sin(time);
    c = c * mat2(cosT,-sinT, sinT, cosT);
    
    c -= zoom.xy;
    
    vec2 z = c;
    
    //gl_FragColor = texture2D(tex, vTextureCoord);
    gl_FragColor = vec4(0.0);

    float n = 100.0;// + (time*1000.0);
    for (float i = 0.0; i > -1.0; i += 1.0) {
        if (i > n) break;
        z = vec2(z.x*z.x - z.y*z.y, 2.0*z.x*z.y) + c;
        if (dot(z,z) > 4.0 || i > n) {
            //gl_FragColor = vec4(i/n*4.0*length(v)/sqrt(2.0));
            //float hue = 0.5*PI*distance(c, vec2(0.5)) / sqrt(2.0);
            //gl_FragColor = vec4(abssin(i), abssin(i), abssin(i), 1.0);
            float q = length(v)/sqrt(2.0);
            float f = i/n*length(v);
            gl_FragColor += 2.0*pow(vec4(
                q*abssin(f*1.0+PI/40.0+time*2.0),
                q*abssin(f*2.0+time*3.0)/2.0,
                q*abssin(f*3.0+time*3.0),
                1.0), vec4(2.0));
            gl_FragColor -= texture2D(tex, vec2(i/100.0,i/100.0));
            break;
        }
    }
}
