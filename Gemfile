source "https://rubygems.org"

gem "jekyll", "~> 4.2"

gem "minima", "~> 2.5" # TODO: can remove?
gem "mini_magick", "~> 4.11"
gem "image_optim", "~> 0.28.0"
gem "image_optim_pack", "~> 0.7.0.20210206"

group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.15.1"
  gem "jekyll-paginate", '~> 1.1'
  gem "jekyll-seo-tag", "~> 2.7", ">= 2.7.1"
  gem "jekyll-assets", :git => 'https://github.com/envygeeks/jekyll-assets', :ref => '056d2c8'
  gem 'jekyll-sitemap', '~> 1.4'
end

platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", "~> 1.2"
  gem "tzinfo-data"
end

gem "wdm", "~> 0.1.1", :platforms => [:mingw, :x64_mingw, :mswin]

