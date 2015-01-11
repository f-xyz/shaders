var three = require('three');
var Class = require('better-inherits');
var renderer = require('./renderer');

var App = (function App() {
    console.log('app');

    renderer.init();

}());