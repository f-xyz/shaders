define(function(require) {
    var Stats = require('stats');
    var stats = new Stats();

    stats.setMode(2);

    document.body.appendChild(stats.domElement);
    stats.domElement.style.position = 'fixed';
    stats.domElement.style.zIndex = 1;
    stats.domElement.style.left = '0';
    stats.domElement.style.top = '0';

    return stats;
});