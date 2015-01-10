define(function(require, exports) {

    console.log('# main');

    var gl = require('three');
    var Stats = require('stats');

    var running = false;
    //var size = new gl.Vector2(800, 600);
    var size = new gl.Vector2(innerWidth, innerHeight)
        .divideScalar(1);
    var mouse = new gl.Vector2(0, 0);
    var renderer = initGL();
    var backRenderer = initGL();
    document.body.appendChild(renderer.domElement);

    var backbuffer = new gl.Texture(backRenderer.domElement);
//    backbuffer.needsUpdate = true;

    var dt = 0.001;
    var shader =
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

    if (shader.length === 3) {
        var s0 = shader[0];
        shader[0] = s0 + "\n" + shader[1];
        shader[1] = s0 + "\n" + shader[2];
    } else if (shader.length !== 2) {
        var m = 'Shader parser error: length = ' + shader.length;
        throw new RangeError(m);
    }

    var shader = {
        vertexShader: shader[0],
        fragmentShader: shader[1],
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

    /**
    /**
     * User control.
     * @class
     * @constructor
     */
    function Controls() {
        var self = this;

        ['keydown',
         'mousemove',
         'click',
         'mousewheel'
        ].forEach(function(event) {
            addEventListener(event, function() {
                self[event].apply(self, arguments);
            });
        });
    }

    Controls.prototype.mousewheel = function(e) {
        console.log(['mouseeheel', e.wheelDelta, e]);

        var wheel = 10 * e.wheelDelta / 120;
        if (e.shiftKey) {
            wheel *= 10;
        }
        app.shader.uniforms.time.value += wheel * app.dt;
        app.render();
    };

    Controls.prototype.keydown = function(e) {
        console.log(['keypress', e.keyCode,
            String.fromCharCode(e.keyCode), e]);

        if (e.keyCode === 32) {
            if (app.running) {
                console.log('stop');
                app.stop();
            } else {
                console.log('start');
                app.start();
            }
        } else if (e.keyCode === 13) {
            console.log('next');
            app.render();
        }
    };

    Controls.prototype.mousemove = function(e) {
        app.mouse.set(e.clientX, e.clientY);
    };

    Controls.prototype.click = function(e) {
        var x = e.clientX;
        var y = e.clientY;

        x /= app.size.x;
        y /= app.size.y;

        console.log(['click', x, y, e]);
    };

    window.app = new App();
    window.controls = new Controls();
});
