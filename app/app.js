/// <reference path="../typings/three.d.ts" />

define(function(require, exports, module) {
    var gl = require('three');
    var stats = require('./renderers/stats');

    var canvas = document.querySelector('canvas');
    var size = new gl.Vector2(
        canvas.clientWidth,
        canvas.clientHeight
    );

    var renderer = require('./renderers/webgl')(canvas, size);

    var world = new gl.Scene();
    world.add(sphere());

    var camera = require('./camera')(size, world.position);

    renderer.render(world, camera);

    function sphere(material) {
        return new gl.Mesh(
            new gl.SphereGeometry(10, 10, 10),
            material || new gl.MeshNormalMaterial({})
        );
    }

    function plane(material) {
        return new gl.Mesh(
            new gl.PlaneGeometry(2, 2, 3),
            material || new gl.MeshNormalMaterial({})
        );
    }
});