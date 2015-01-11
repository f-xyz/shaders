var gulp = require('gulp'),
    mocha = require('gulp-spawn-mocha'),
    concat = require('gulp-concat'),
    uglify = require('gulp-uglify'),
    debug = require('gulp-debug'),
    sourcemaps = require('gulp-sourcemaps'),
    rename = require('gulp-rename'),
    nodemon = require('gulp-nodemon'),
    source = require('vinyl-source-stream'),
    buffer = require('vinyl-buffer'),
    del = require('del'),
    colors = require('colors'),
    browserify = require('browserify'),
    browserSync = require('browser-sync'),
    async = require('async')
;

gulp.task('default', ['build']);
gulp.task('build', ['clean', 'browserify', 'test']);

gulp.task('clean', function() {
    //del('built/*.*');
    //del('coverage/');
});

gulp.task('browserify', function() {
    var bundler = browserify({
        entries: ['./app/app.js'],
        debug: true
    });
    return bundler
        .bundle()

        .pipe(source(getBundleName('.js')))
        .pipe(gulp.dest('built/'))

        //.pipe(rename({ extname: '.min.js' }))
        //.pipe(buffer())
        //.pipe(sourcemaps.init({ loadMaps: true }))
        //.pipe(uglify())
        //.pipe(sourcemaps.write('./'))
        //.pipe(gulp.dest('dist/'))
    ;
});

gulp.task('test', function() {
    //gulp.src('test/*.*', { read: false })
    //    .pipe(mocha({
    //        R: 'spec',
    //        colors: true,
    //        debug: true,
    //        istanbul: true,
    //        compilers: 'coffee:coffee-script/register'
    //    }));
});

gulp.task('watch', function() {
    nodemon({
        script: './server.js',
        ext: 'js coffee',
        ignore: ['**']
    });
    //browserSync({
    //    server: {
    //        baseDir: './'
    //    }
    //});
    gulp.watch(['app/*', 'shaders/*'], function() {
        gulp.start('browserify');
        //browserSync.reload();
    });
});

gulp.task('bs', function() {
    browserSync({
        server: {
            baseDir: './'
        }
    });
});

function getBundleName(ext) {
    var name = require('./package.json').name;
    var version = require('./package.json').version;
    return name + '-' + version + ext;
}
