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

uniform float time;
uniform vec2 resolution;
uniform vec2 mouse;
uniform sampler2D tex;
uniform sampler2D backbuffer;
varying vec3 vPos;
varying vec2 vTextureCoord;

#define PI              3.14159265
#define P               1.57079633
#define MAX_STEPS       256
#define MAX_REFLECTIONS 2
#define EPSILON         0.001

// world ==============================

vec2 plane(vec3 v) {
    return vec2(v.y + 10.0, 0.0);
}

vec2 box(vec3 v) {
    return vec2(
        -0.25 + length(max(abs(v) - vec3(2.0), 0.0)),
        1.0
    );
}

vec2 sphere(vec3 p, float r) {
    float d = length(p) - 6.0;
    return vec2(d, 0.0);
}

// materials ==========================

vec3 materialCheckerBoard(vec3 v) {
    float size = 0.5;
    float x = fract(v.x*size);
    float z = fract(v.z*size);
    if (x > size) {
        if (z > size)   return vec3(0.5, 0.0, 0.8);
        else            return vec3(0.0, 0.0, 0.0);
    }
    else {
        if (z > size)   return vec3(0.0, 0.0, 0.0);
        else            return vec3(0.9, 0.0, 0.6);
    }
}

// ====================================

vec2 join(vec2 model1, vec2 model2) {
    if (model1.x < model2.x) {
        return model1;
    } else {
        return model2;
    }
}

vec2 world(vec3 pos) {
    vec3 z = pos;
	float dr = 1.0;
	float r = 1.5;
    float Bailout = 1.0;
    float Power = 10.;
	for (int i = 0; i < 3; i++) {
		r = length(z);
		if (r>Bailout) break;

		// convert to polar coordinates
		float theta = acos(z.z/r);
		float phi = atan(z.y,z.x);
		dr =  pow( r, Power-1.0)*Power*dr + 1.0;

		// scale and rotate the point
		float zr = pow( r,Power);
		theta = theta*Power;
		phi = phi*Power;

		// convert back to cartesian coordinates
		z = zr*vec3(sin(theta)*cos(phi), sin(phi)*sin(theta), cos(theta));
		z+=pos;
	}
	return vec2(.5*log(r)*r/dr, 4.0);
}

// main ===============================

void main() {
    vec2 q = gl_FragCoord.xy/resolution;
    vec2 vPos = -1.0 + 2.0*q;
    float ratio = resolution.x/resolution.y;

    // camera
    vec3 vuv = vec3(0.0, 1.0, 0.0); // up vector
    vec3 vrp = vec3(0.0, 0.0, 0.0); // look at
    vec3 prp = vec3(0.0, 0.0, 1.0); // position

    // camera path
    prp = vec3(-sin(time)*8.0, 6.0, cos(time)*8.0);

    vec3 vpn = normalize(vrp - prp);
    vec3 u = normalize(cross(vuv, vpn));
    vec3 v = cross(vpn, u);
    vec3 vcv = (prp + vpn);
    // vec3 scrCoord = vcv +     (vPos.x*u*ratio + vPos.y*v);
    vec3 scrCoord = vcv + 0.1*(vPos.x*u*ratio + vPos.y*v);
    vec3 scp = normalize(scrCoord - prp);

    // raymarhing
    const vec3 e = vec3(0.1, 0.0, 0.0);
    const float maxDepth = 100.0;
    vec2 s = vec2(0.1, 0.0);
    vec3 c, p, n;

    float f = 1.0;
    for (int i=0; i<256; i++) {
        if (abs(s.x) < 0.01 || f > maxDepth) break;
        f += s.x;
        p = prp + scp*f;
        s = world(p);
    }

    if (f < maxDepth) {
        if (s.y == 0.0)         c = materialCheckerBoard(p);
        else if (s.y == 1.0)    c = vec3(0.9, 0.5, 0.6);
        else                    c = vec3(0.1, 0.5, 0.6);

        n = normalize(vec3(
            s.x - world(p - e.xyy).x,
            s.x - world(p - e.yxy).x,
            s.x - world(p - e.yyx).x));
        float b = dot(n, normalize(prp - p));
        // simple phong lighting: light pos. = camera pos.
        gl_FragColor = vec4((b*c + pow(b, 8.0))*(1.0 - f*0.00001), 1.0);
    }
    else {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
    }

}
