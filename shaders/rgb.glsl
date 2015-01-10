void main() {
    gl_Position = projectionMatrix 
                * modelViewMatrix 
                * vec4(position, 1.0);
}

/////////////////////////////////

uniform float time;
uniform vec2 resolution;
uniform sampler2D backbuffer;
uniform sampler2D tex;

void main() {
    vec2 uv = gl_FragCoord.xy/resolution*2.0 - 1.0;
    uv.x *= resolution.x/resolution.y;
    gl_FragColor = vec4(0.0);
    if (abs(1.0-length(uv)) < 0.01/time) {
        gl_FragColor = vec4(1.0);
    }
    vec4 b = texture2D(backbuffer, uv);
    if (length(b.xyz) > 0.0) {
        gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
    }
}
