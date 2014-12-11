gulp = require 'gulp'

autoprefixer = require 'autoprefixer-stylus'
browserSync = require 'browser-sync'
browserify = require 'browserify'
source = require 'vinyl-source-stream'
stylus = require 'gulp-stylus'

reload = browserSync.reload

gulp.task 'browser-sync', () ->
    browserSync proxy: 'localhost:5000'

gulp.task 'browserify', () ->
    browserify(
            entries: './static-src/scripts/themes.coffee'
            extensions: ['.coffee']
        )
        .bundle()
        .pipe(source 'themes.js')
        .pipe(gulp.dest './static/scripts')

gulp.task 'stylus', () ->
    gulp.src('./static-src/stylesheets/*.styl')
        .pipe(stylus
            use: autoprefixer()
        )
        .pipe(gulp.dest './static/stylesheets')
        .pipe(reload stream: true)

gulp.task 'default', ['browserify', 'stylus']
gulp.task 'watch', ['browserify', 'stylus', 'browser-sync'], () ->
    gulp.watch './static-src/stylesheets/**/*.styl', ['stylus']
    gulp.watch './static-src/scripts/**/*.coffee', ['browserify', reload]
    gulp.watch './lib/**/*.coffee', ['browserify', reload]
