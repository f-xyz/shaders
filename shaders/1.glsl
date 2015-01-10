uniform float time;
varying vec3 p;

void main() {
    //float a = 0.2;
    p = position;
    //p.x += a*cos(time*0.5 + p.y/25.0);
    //p.y += a*sin(time*0.5 + p.x/25.0);
    //p.x += a*sin(time) + a*cos(time);
    gl_Position = projectionMatrix * modelViewMatrix * vec4(p, 1.0);
}

/////

uniform float time;
uniform vec2 resolution;
varying vec3 p;

float world(vec2 v, vec2 speed, float i) {
    vec2 xy = gl_FragCoord.xy;
    float a = atan(xy.x, xy.y);

    float size = 200.;// + 50.*sin(time+1.57*i);
    float f = time*5e2 + 5e5;
    vec2  pos = vec2(
        v.x + resolution.x/2. + f - size,
        v.y + resolution.y/2. + f - size
    );

    float modX = mod(pos.x, resolution.x);
    float modY = mod(pos.y, resolution.y);

    float hopsX = floor(pos.x / resolution.x);
    float hopsY = floor(pos.y / resolution.y);

    if (mod(hopsX, 2.) == 0.) {
        pos.x = modX;
    } else {
        pos.x = resolution.x - modX;
    }

    if (mod(hopsY, 2.) == 0.) {
        pos.y = modY;
    } else {
        pos.y = resolution.y - modY;
    }

    float world = abs(length(vec2(xy.x-pos.x, xy.y-pos.y)) - size);
    float width = 20.;

    return width - world;
}

float noize(vec2 seed) {
    return fract(sin(dot(seed.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {

    vec4 px = vec4(0., 0., 0., 1.);
    gl_FragColor = vec4(0., 0., 0., 1.);

    for (float i = 0.; i < 50.; i++) {

        float f = world(
            vec2(resolution.x * i / 15.,
                 resolution.y * i / 15.),
            vec2(resolution.x * i / 10000.,
                 resolution.y * i / 10000.),
            i
        );

        if (f > 0.) {
            float k = 100.0/(i+1.);
            float q = mod(time*100., 49.) - i;
            vec4 ringColor = abs(q) < 5.0 ? 0.1*(5.0-q)*vec4(
                sin(10000.0+time*k+0.785)/2.+1.5,
                sin(10000.0+time*k+1.57)/2.+1.5,
                sin(10000.0+time*k)/2.+1.5,
                1.
            ) : vec4(.1);
            px += f/40.*ringColor;
        }
    }

    gl_FragColor = px;
}
