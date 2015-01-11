define(function(require, exports) {
    console.log('# main');

    var gl = require('three');
    var Stats = require('stats');
    var running = false;
    var size = new gl.Vector2(innerWidth, innerHeight);
    var mouse = new gl.Vector2(0, 0);
    var renderer = initGL();
    var backRenderer = initGL();
    document.body.appendChild(renderer.domElement);

    var backbuffer = new gl.Texture(backRenderer.domElement);
//    backbuffer.needsUpdate = true;

    var dt = 0.001;
    var shaderSource =
//             require('text!../shaders/tunnel.glsl')
//             require('text!../shaders/demo.glsl')
//             require('text!../shaders/inside_cube.glsl')
//             require('text!../shaders/cude_madness.glsl')
//             require('text!../shaders/water-raymarching.glsl')
//             require('text!../shaders/raymarching.glsl')
//             require('text!../shaders/sea-raymarching.glsl')
//             require('text!../shaders/8spheres_raymarching.glsl')
//             require('text!../shaders/infinite_balls_raymarching.glsl')
//             require('text!../shaders/salt.glsl')
//             require('text!../shaders/mercury.glsl')
//             require('text!../shaders/blob-chess.glsl')
//             require('text!../shaders/foxy.glsl')
//             require('text!../shaders/gifts.glsl')
//             require('text!../shaders/1.glsl')
         require('text!../shaders/mandel.glsl')
//             require('text!../shaders/texture.glsl')
        .split(/\/{5,}/)
        .map(function (s) { return s.trim(); });

    if (shaderSource.length === 3) {
        var s0 = shaderSource[0];
        shaderSource[0] = s0 + "\n" + shaderSource[1];
        shaderSource[1] = s0 + "\n" + shaderSource[2];
    } else if (shaderSource.length !== 2) {
        var m = 'Shader parser error: length = ' + shaderSource.length;
        throw new RangeError(m);
    }

    var shader = {
        vertexShader: shaderSource[0],
        fragmentShader: shaderSource[1],
        transparent: true,
        uniforms: {
            time:       { type: 'f',  value: 0 },
            resolution: { type: 'v2', value: size },
            mouse:      { type: 'v2', value: mouse },
            tex:        {
                type: 't',
                value: gl.ImageUtils.loadTexture('img/357977_original.jpg')
            },
            backbuffer: {
                type: 't',
                value: backbuffer
            },
            seed: {
                type: 'f',
                value: Math.random()
            }
        }
    };

    //
    console.log(shader);

    var world  = initWorld();
    var camera = initCamera();

    var stats = new Stats();
    stats.setMode(2);
    document.body.appendChild(stats.domElement);
    stats.domElement.style.position = 'fixed';
    stats.domElement.style.right = '10px';
    stats.domElement.style.top = '10px';

    render();

    addEventListener('load', console.log.bind(console, 'load'));
    addEventListener('load', render.bind(this, 'load'));

    function initGL() {
        var renderer = new gl.WebGLRenderer({
            antialias: false
        });
        renderer.setSize(size.x, size.y);
        renderer.autoClear = true;
        renderer.setClearColor(0x000000, 1);
        return renderer;
    }

    function initWorld() {
        var world = new gl.Scene();
        var plane = new gl.Mesh(
            new gl.PlaneGeometry(2, 2),
            new gl.ShaderMaterial(shader));
        world.add(plane);

        world.objects = {
            plane: plane
        };

        return world;
    }

    function initCamera() {
        var camera = new gl.OrthographicCamera(-1, 1, 1, -1, 0.1, 1e4);
    //        var wh = size.x / size.y;
    //        var camera = new gl.PerspectiveCamera(45, wh, 0.1, 1e4);
        camera.position.set(0, 0, 3);
        return camera;
    }

    function start() {
        running = true;
        loop();
    }

    function stop() {
        running = false;
    }

    function loop() {
        if (!running) {
            return;
        }

        requestAnimationFrame(loop.bind(this),
            renderer.domElement);

        render();
    }

    /**
     *
     */
    function render() {
        stats.begin();

    //        renderTarget = new gl.WebGLRenderTarget(
    //            size.x,
    //            size.y, {
    //                minFilter: gl.LinearFilter,
    //                magFilter: gl.NearestFilter,
    //                format: gl.RGBFormat
    //            });

        renderer.render(world, camera);

        shader.uniforms.time.value += dt;
    //        if (shader.uniforms.time.value*1000 > 1200) {
    //            shader.uniforms.time.value = 0;
    //        }

        document.title
            = String(shader.uniforms.time.value*1000);

        //shader.uniforms.backbuffer.value =
            //new gl.Texture(renderer.domElement);

        stats.update();
    }

});
