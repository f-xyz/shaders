define(function(require, exports, module) {

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
});