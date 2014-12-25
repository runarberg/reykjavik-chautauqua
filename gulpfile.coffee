gulp = require 'gulp'

autoprefixer = require 'autoprefixer-stylus'
browserSync = require 'browser-sync'
browserify = require 'browserify'
source = require 'vinyl-source-stream'
stylus = require 'gulp-stylus'

reload = browserSync.reload

gulp.task 'browser-sync', () ->
    browserSync proxy: 'localhost:5000'

gulp.task 'browserify-main', () ->
    browserify
        entries: './static-src/scripts/main.coffee'
        extensions: ['.coffee']
    .bundle()
    .pipe source 'main.js'
    .pipe gulp.dest './static/scripts'

gulp.task 'browserify-themes', () ->
    browserify
        entries: './static-src/scripts/themes.coffee'
        extensions: ['.coffee']
    .bundle()
    .pipe source 'themes.js'
    .pipe gulp.dest './static/scripts'

gulp.task 'browserify', ['browserify-main', 'browserify-themes']

gulp.task 'fonts', () ->
    gulp.src './static-src/fonts/**/*.{woff,ttf,otf}'
    .pipe gulp.dest './static/fonts'

gulp.task 'img', () ->
    gulp.src './static-src/img/**/*.{jpeg,png,svg}'
    .pipe gulp.dest './static/img'

gulp.task 'stylus', () ->
    gulp.src './static-src/stylesheets/**/*.styl'
    .pipe stylus
        paths: [__dirname+"/static-src/common"]
        use: autoprefixer()
    .pipe gulp.dest './static/stylesheets'
    .pipe reload stream: true

gulp.task 'default', ['browserify', 'fonts', 'img', 'stylus']
gulp.task 'watch', [
    'browserify', 'fonts', 'img', 'stylus', 'browser-sync'
    ], () ->
    gulp.watch './static-src/stylesheets/**/*.styl', ['stylus']
    gulp.watch './static-src/fonts/**/*.{woff,ttf,otf}', ['fonts']
    gulp.watch './static-src/img/**/*.{jpeg,png}', ['img', reload]
    gulp.watch './static-src/scripts/**/*.coffee', ['browserify', reload]
    gulp.watch './lib/**/*.coffee', ['browserify', reload]
