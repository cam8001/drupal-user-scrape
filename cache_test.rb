require_relative 'dorg_cache'
require 'awesome_print'

fetcher = DOrgCache.new
url = 'https://drupal.org/user/129588'

fetcher.fetch(url)
