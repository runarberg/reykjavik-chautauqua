gulp = require 'gulp'

autoprefixer = require 'autoprefixer-stylus'
browserify = require 'browserify'
source = require 'vinyl-source-stream'
stylus = require 'gulp-stylus'

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

gulp.task 'default', ['browserify', 'stylus']
