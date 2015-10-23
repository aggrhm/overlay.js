var gulp = require('gulp');
var concat = require('gulp-concat');
var coffee = require('gulp-coffee');
var sass = requre('gulp-sass');

gulp.task('default', ['build']);

gulp.task('build', ['js', 'css']);

gulp.task('js', function() {
	gulp.src([
			'./src/js/core.js.coffee',
			'./src/js/bootstrap.js.coffee',
			'./src/js/quick_script.js.coffee',
		])
		.pipe(concat('overlay.js'))
		.pipe(coffee())
		.pipe(gulp.dest('./dist/js/')
});

gulp.task('css', function() {
	gulp.src([
			'./src/css/core.css.sass',
		])
		.pipe(concat('overlay.css'))
		.pipe(sass())
		.pipe(gulp.dest('./dist/css/')
});

