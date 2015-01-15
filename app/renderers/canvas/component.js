define(function(require) {

    return function(options) {
        var config = {
            data: {},
            onDraw: function(ctx, size) {
                ctx.beginPath();
                ctx.circle(size.scale(0.5));
                ctx.closePath();
                ctx.fill('red');
            }
        };
        Object.keys(options).forEach(function(key) {
            config[key] = options[key];
        });
    };

});