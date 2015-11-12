var gulp = require('gulp');
var concat = require('gulp-concat');
var coffee = require('gulp-coffee');
var sass = require('gulp-sass');

gulp.task('default', ['build']);

gulp.task('build', ['js', 'css']);

gulp.task('js', function() {
	return gulp.src([
			'./src/js/core.js.coffee',
			'./src/js/modal.js.coffee',
			'./src/js/notify.js.coffee',
			'./src/js/popover.js.coffee',
			'./src/js/bootstrap.js.coffee',
			'./src/js/quick_script.js.coffee',
		])
		.pipe(coffee())
		.pipe(concat('overlay.js'))
		.pipe(gulp.dest('./dist/js/'))
});

gulp.task('css', function() {
	return gulp.src([
			'./src/css/core.css.sass',
		])
		.pipe(sass())
		.pipe(concat('overlay.css'))
		.pipe(gulp.dest('./dist/css/'))
});

gulp.task('watch', function() {
	gulp.watch('src/js/**/*', ['js']);
	gulp.watch('src/css/**/*', ['css']);
});

