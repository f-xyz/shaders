var Class = require('better-inherits');
var gl = require('three');

//var Rend = new Class({
    //constructor: function() {
    //}
//});

var Renderer = (function Renderer() {

    console.log('renderer');

    /**
     * @param {HTMLCanvasElement} canvas
     */
    return function init(canvas) {

        var running = false;
        var size = new gl.Vector2(
            canvas.clientWidth,
            canval.clientHeight
        );

        var renderer = new gl.WebGLRenderer({
            antialias: false
        });
        renderer.setSize(size.x, size.y);
        renderer.autoClear = true;
        renderer.setClearColor(0x000000, 1);
        //document.body.appendChild(renderer.domElement);

        var world = new gl.Scene();
        var plane = new gl.Mesh(
            new gl.PlaneGeometry(2, 2),
            new gl.ShaderMaterial(shader));
        world.add(plane);

        world.objects = {
            plane: plane
        };
    };

}());