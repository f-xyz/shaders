uniform float time;
varying vec3 pos;
varying vec2 vUv;

void main() {
    pos = position;
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
}

/////

uniform float time;
uniform vec2 resolution;
uniform sampler2D tex;
uniform sampler2D backbuffer;
varying vec3 pos;
varying vec2 vUv;

void main() {
    vec2 uv = gl_FragCoord.xy / resolution;
    gl_FragColor = .5* (
        texture2D(tex, uv)/2. +
        vec4(pow(length(texture2D(tex, uv)), 2.))/2.);
}
