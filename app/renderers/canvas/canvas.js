define(function(require) {
    var helpers = require('./canvas-helpers');

    return function create(canvas, size) {
        var ctx = canvas.getContent('2d');

        Object.keys(helpers).forEach(function(x) {
            ctx[x] = helpers[x];
        });

        ctx.canvas.width = size.x;
        ctx.canvas.height = size.y;

        return {
            get ctx() { return ctx },
            get canvas() { return canvas }
        };
    };
});