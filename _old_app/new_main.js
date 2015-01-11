'use strict';

require.config({
    baseUrl: 'app',
    paths: {
        'text': '../lib/requirejs-text/text',
        'three': '../lib/threejs/build/three',
        'stats': '../lib/stats.js/src/Stats'
    },
    shim: {
        'three': { exports: 'THREE' },
        'stats': { exports: 'Stats' }
    }
});

define(function(require) {

    console.log('# main');

    var gl = require('three');


    function App() {

        this.running = false;
        this.size = new gl.Vector2(innerWidth, innerHeight)
            .divideScalar(1);
        this.mouse = new gl.Vector2(0, 0);


        this.dt = 0.001;




        this.render();

        addEventListener('load', console.log.bind(console, 'load'));
        addEventListener('load', this.render.bind(this, 'load'));
    }

    window.app = new App();
});

//////////////////////////////////////////////////////////

define('Controls', function (require) {

    function Controls() {
        this.mouse = null;

        var self = this;

        ['keydown',
         'mousemove',
         'click',
         'mousewheel'
        ].forEach(function(event) {
            addEventListener(event, function () {
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
        //app.shader.uniforms.time.value += wheel * app.dt;
        //app.render();
    };

    Controls.prototype.keydown = function(e) {
        console.log(['keypress', e.keyCode,
            String.fromCharCode(e.keyCode), e]);

        if (e.keyCode === 32) {
            //if (app.running) {
            //    console.log('stop');
            //    app.stop();
            //} else {
            //    console.log('start');
            //    app.start();
            //}
        } else if (e.keyCode === 13) {
            //console.log('next');
            //app.render();
        }
    };

    Controls.prototype.mousemove = function(e) {
        //app.mouse.set(e.clientX, e.clientY);
    };

    Controls.prototype.click = function(e) {
        var x = e.clientX;
        var y = e.clientY;

        //x /= app.size.x;
        //y /= app.size.y;

        //console.log(['click', x, y, e]);
    };

    return Controls;
});

define('ShaderCompiler', function (require) {
    var gl = require('three');

    function ShaderCompiler(source) {
        var shader =
//             require('text!../shaders/tunnel.glsl')
//             require('text!../shaders/demo.glsl')
//             require('text!../shaders/inside_cube.glsl')
//             require('text!../shaders/cude_madness.glsl')
             require('text!../shaders/raymarching.glsl')
//             require('text!../shaders/salt.glsl')
//             require('text!../shaders/mercury.glsl')
//             require('text!../shaders/blob-chess.glsl')
//             require('text!../shaders/foxy.glsl')
//             require('text!../shaders/gifts.glsl')
//             require('text!../shaders/1.glsl')
//             require('text!../shaders/mandel.glsl')
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

        this.shader = {
            vertexShader: shader[0],
            fragmentShader: shader[1],
            transparent: true,
            uniforms: {
                time:       { type: 'f',  value: 0 },
                resolution: { type: 'v2', value: this.size },
                mouse:      { type: 'v2', value: this.mouse },
                tex:        {
                    type: 't',
                    value: gl.ImageUtils.loadTexture('img/357977_original.jpg')
                },
                backbuffer: {
                    type: 't',
                    value: this.backbuffer
                },
                seed: {
                    type: 'f',
                    value: Math.random()
                }
            }
        };

        //
        console.log(this.shader);
    }

    return ShaderCompiler;

});

define('Renderer', function (require) {
    var gl = require('three');
    var Stats = require('stats');

    function Renderer(w, h) {
        this.position = new gl.Vector2();
        this.size = new gl.Vector2(w, h).divideScalar(1);

        this.renderer = this.initGL();

        this.world  = this.initWorld();
        this.camera = this.initCamera();

        this.stats = new Stats();
        this.stats.setMode(2);
        document.body.appendChild(this.stats.domElement);
        this.stats.domElement.style.position = 'fixed';
        this.stats.domElement.style.right = '10px';
        this.stats.domElement.style.top = '10px';

        this.render();

        addEventListener('load', console.log.bind(console, 'load'));
        addEventListener('load', this.render.bind(this, 'load'));
    }

        App.prototype.initGL = function() {
        var renderer = new gl.WebGLRenderer({
            antialias: false
        });
        renderer.setSize(this.size.x, this.size.y);
        renderer.autoClear = true;
        renderer.setClearColor(0x000000, 1);
        return renderer;
    };

    App.prototype.initWorld = function() {
        var world = new gl.Scene();
        var plane = new gl.Mesh(
            new gl.PlaneGeometry(2, 2),
            new gl.ShaderMaterial(this.shader));
        world.add(plane);

        world.objects = {
            plane: plane
        };

        return world;
    };

    App.prototype.initCamera = function() {
        var camera = new gl.OrthographicCamera(-1, 1, 1, -1, 0.1, 1e4);
//        var wh = this.size.x / this.size.y;
//        var camera = new gl.PerspectiveCamera(45, wh, 0.1, 1e4);
        camera.position.set(0, 0, 3);
        return camera;
    };

    App.prototype.start = function() {
        this.running = true;
        this.loop();
    };

    App.prototype.stop = function() {
        this.running = false;
    };

    App.prototype.loop = function() {
        if (!this.running) {
            return;
        }

        requestAnimationFrame(this.loop.bind(this),
            this.renderer.domElement);

        this.render();
    };

    /**
     *
     */
    App.prototype.render = function() {
        this.stats.begin();

//        this.renderTarget = new gl.WebGLRenderTarget(
//            this.size.x,
//            this.size.y, {
//                minFilter: gl.LinearFilter,
//                magFilter: gl.NearestFilter,
//                format: gl.RGBFormat
//            });

        this.renderer.render(this.world, this.camera);

        this.shader.uniforms.time.value += this.dt;
//        if (this.shader.uniforms.time.value*1000 > 1200) {
//            this.shader.uniforms.time.value = 0;
//        }

        document.title
            = String(this.shader.uniforms.time.value*1000);

        //this.shader.uniforms.backbuffer.value =
            //new gl.Texture(this.renderer.domElement);

        this.stats.update();
    };

    return Renderer;
});

define('Stats', function () {
    var Stats = require('stats');
    //this.stats = new Stats();
    //this.stats.setMode(2);
    //document.body.appendChild(this.stats.domElement);
    //this.stats.domElement.style.position = 'fixed';
    //this.stats.domElement.style.right = '10px';
    //this.stats.domElement.style.top = '10px';
});