define(function(require) {
    var gl = require('three');

    return function createRenderer(canvas, size) {
        var renderer = new gl.WebGLRenderer({
            canvas: canvas,
            antialias: true
        });
        renderer.setSize(size.x, size.y);
        renderer.autoClear = true;
        renderer.setClearColor(0x000000, 1);

        return renderer;
    };
});