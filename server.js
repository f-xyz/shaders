#!/usr/bin/env node

var fs = require('fs');
var express = require('express');
var srv = express();
var colors = require('colors');
var argv = require('optimist').argv;

var port = argv.port || 5000;
var root = argv.root || argv._[0] || __dirname;

srv.get('/shaders', function (req, res) {
    var shaders = fs.readdirSync('shaders');
    res.header('Content-Type', 'text/json');
    res.send(JSON.stringify(shaders));
});

//srv.use(express.logger());
srv.use(express.directory(root));
srv.use(express.static(root));
srv.listen(port);

console.log('GSOM-000 HTTP Server'.yellow.underline);
console.log('  * port: '.white + port.toString().green);
console.log('  * root: '.white + root.toString().green + "\n");
console.log(['',
'░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░',
'░░░░░░░░░░▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄░░░░░░░░░',
'░░░░░░░░▄▀░░░░░░░░░░░░▄░░░░░░░▀▄░░░░░░░',
'░░░░░░░░█░░▄░░░░▄░░░░░░░░░░░░░░█░░░░░░░',
'░░░░░░░░█░░░░░░░░░░░░▄█▄▄░░▄░░░█░▄▄▄░░░',
'░▄▄▄▄▄░░█░░░░░░▀░░░░▀█░░▀▄░░░░░█▀▀░██░░',
'░██▄▀██▄█░░░▄░░░░░░░██░░░░▀▀▀▀▀░░░░██░░',
'░░▀██▄▀██░░░░░░░░▀░██▀░░░░░░░░░░░░░▀██░',
'░░░░▀████░▀░░░░▄░░░██░░░▄█░░░░▄░▄█░░██░',
'░░░░░░░▀█░░░░▄░░░░░██░░░░▄░░░▄░░▄░░░██░',
'░░░░░░░▄█▄░░░░░░░░░░░▀▄░░▀▀▀▀▀▀▀▀░░▄▀░░',
'░░░░░░█▀▀█████████▀▀▀▀████████████▀░░░░',
'░░░░░░████▀░░███▀░░░░░░▀███░░▀██▀░░░░░░',
'░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░'].join('\n').rainbow);

