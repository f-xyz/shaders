define(function(require) {
    var helpers = require('./canvas-helpers');

    return function create(canvas, size) {
        var ctx = canvas.getContent('2d');

        Object.keys(helpers).forEach((x) => {
            ctx[x] = helpers[x];
        });

        return {
            get ctx() { return ctx }
        };
    };
});