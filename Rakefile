require "logger"
require "fileutils"
require "pathname"
require "sprockets"
require "sprockets-sass"

ROOT        = Pathname(File.dirname(__FILE__))
LOGGER      = Logger.new(STDOUT)
BUNDLES     = %w( overlay.css overlay.js )
BUILD_DIR   = ROOT.join("dist")
SOURCE_DIR  = ROOT.join("src")

desc 'Compile assets.'
task :compile do
  sprockets = Sprockets::Environment.new(ROOT) do |env|
    env.logger = LOGGER
  end

  # init directories
  ['js', 'css', 'img'].each do |dir|
    path = File.join(BUILD_DIR, dir)
    FileUtils.remove_dir(path) if File.exists?(path)
    FileUtils.mkdir_p path
  end

  sprockets.append_path(SOURCE_DIR.join('javascripts').to_s)
  sprockets.append_path(SOURCE_DIR.join('stylesheets').to_s)

	# javascript
	full_js = sprockets.find_asset('overlay.js').to_s
	#compressed_js = Uglifier.compile(full_js)
	File.open(BUILD_DIR.join('js', 'overlay.js'), 'w') do |f|
		f.write(full_js)
	end
	
	# stylesheets
	full_css = sprockets.find_asset('overlay.css')
	full_css.write_to(BUILD_DIR.join('css', 'overlay.css'))

  # images
  images_src = SOURCE_DIR.join('images/overlay')
  images_dst = BUILD_DIR.join('img')
  FileUtils.cp_r(Dir["#{images_src}/*"], images_dst)
end

