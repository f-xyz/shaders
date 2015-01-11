define(function(require) {
    var gl = require('three');

    return function(size, lookAt) {
        var camera = new gl.PerspectiveCamera(
            45,
            size.x / size.y,
            1, 1000
        );
        camera.position.z = 100;
        camera.lookAt(lookAt);
        return camera;
    };
});