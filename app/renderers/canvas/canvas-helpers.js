define(function(require) {
    var ContextHelpers = {};

    /**
     * Internal. Converts any style object (RGBA, etc.) into string.
     * @param style
     * @returns {String}
     */
    ContextHelpers.prepareStyle = function(style) {
        if (style instanceof RGBA) {
            style = style.toString();
        } else if (style instanceof Gradient) {
            style = style.compile(this);
        }
        return style;
    };

    /**
     * Sets attributes.
     * @param {Object} attrs
     * @returns {CanvasRenderingContext2D} this
     */
    ContextHelpers.attr = function(attrs) {
        for (var key in attrs) {
            if (attrs.hasOwnProperty(key)) {
                var value = attrs[key];
                if (key === "strokeStyle" || key === "fillStyle") {
                    value = this.prepareStyle(value);
                }
                if (key === "opacity") {
                    key = "globalAlpha";
                }
                this[key] = value;
            }
        }

        return this;
    };

    /**
     * Runs fn in a sandbox not affecting canvas state.
     * @param {Function} fn draw func
     */
    ContextHelpers.sandbox = function(fn) {
        this.save();
        fn.call(this);
        this.restore();
    };

    /**
     * beginPath / closePath helper.
     * @param {Function} fn draw func
     * @param {Boolean} [noFillStroke]
     */
    ContextHelpers.path = function(fn, noFillStroke) {
        this.beginPath();
        fn.call(this);
        this.closePath();

        if (!noFillStroke) {
            this.fill();
            this.stroke();
        }
    };

    /**
     * Clears canvas.
     */
    ContextHelpers.clear = function() {
        this.clearRect(0, 0, this.canvas.width, this.canvas.height);
    };

    /**
     * Extended fill() version. Sets fillStyle.
     * @param style string | RGBA
     */
    ContextHelpers.fillWith = function(style) {
        this.fillStyle = this.prepareStyle(style);
        this.fill();
    };

    /**
     * Extended stroke() version. Sets strokeStyle.
     * @param style string | RGBA
     */
    ContextHelpers.strokeWith = function(style) {
        this.strokeStyle = this.prepareStyle(style);
        this.stroke();
    };

    /**
     * Glow effect. Uses shadowBlur. Call without args to disable.
     * @param {Number} [radius]
     * @param {String|RGBA} [color]
     */
    ContextHelpers.glow = function(radius, color) {
        if (radius) {
            this.shadowBlur = radius;
            this.shadowColor = this.prepareStyle(color);
        } else {
            this.shadowBlur = undefined;
            this.shadowColor = undefined;
        }
    };

    /**
     * Sets a pixel.
     * @param {Number} x
     * @param {Number} y
     */
    ContextHelpers.point = function(x, y) {
        this.fillRect(x, y, 1, 1);
    };

    /**
     * Draws a line.
     * @param {Number} x
     * @param {Number} y
     * @param {Number} toX
     * @param {Number} toY
     */
    ContextHelpers.line = function(x, y, toX, toY) {
        this.moveTo(x, y);
        this.lineTo(toX, toY);
    };

    /**
     * Draws a [rounded] rectangle.
     * @param {Number} x
     * @param {Number} y
     * @param {Number} w
     * @param {Number} h
     * @param {Number} [radius] Default: 0;
     */
    ContextHelpers.rectangle = function(x, y, w, h, radius) {
        if (!radius) {
            this.moveTo(x, y);
            this.lineTo(x + w, y);
            this.lineTo(x + w, y + h);
            this.lineTo(x, y + h);
            this.lineTo(x, y);
        } else {
            this.moveTo(x + radius, y);
            this.lineTo(x + w - radius, y);
            this.quadraticCurveTo(x + w, y, x + w, y + radius);
            this.lineTo(x + w, y + h - radius);
            this.quadraticCurveTo(x + w, y + h, x + w - radius, y + h);
            this.lineTo(x + radius, y + h);
            this.quadraticCurveTo(x, y + h, x, y + h - radius);
            this.lineTo(x, y + radius);
            this.quadraticCurveTo(x, y, x + radius, y);
        }
    };

    /**
     * Draws a circle.
     * @param {Number} x
     * @param {Number} y
     * @param {Number} radius
     */
    ContextHelpers.circle = function(x, y, radius) {
        this.arc(x, y, radius, 0, 2 * Math.PI, false);
    };

    /**
     * Draws a text.
     * @param {String} text
     * @param {Number} x
     * @param {Number} y
     * @param {Number} [maxWidth]
     * @param {Number} [lineHeight] Default: 10.
     * @param {Boolean} [adjustLetterSpacing] Default: false.
     */
    ContextHelpers.text = function(text, x, y, maxWidth, lineHeight, adjustLetterSpacing) {

        var width = this.measureText(text).width;
        if (!maxWidth || width <= maxWidth) {

            if (adjustLetterSpacing) {
                this.fillText(text, x, y, width);
            } else {
                this.fillText(text, x, y);
            }

        } else {

            lineHeight = lineHeight || 10;
            text = text.replace(/\s+/g, ' ');

            var lines = text.split(/\s/);
            var offset = 0;
            var rest;

            for (var i = 0; i < lines.length; i++) {
                this.fillText(lines[i], x, y + i * lineHeight, maxWidth);

                offset += lines[i].length + 1;
                rest = text.substr(offset);
                width = this.measureText(rest).width;
                if (width <= maxWidth) {
                    width = adjustLetterSpacing ? width : null;
                    this.fillText(rest, x, y + (i + 1) * lineHeight, maxWidth);
                    break;
                }
            }
        }
    };

    /**
     * Calculate text width.
     * @param {String} text
     * @returns {Number}
     */
    ContextHelpers.measureTextWidth = function(text) {
        return this.measureText(text).width;
    };

    return ContextHelpers;
});