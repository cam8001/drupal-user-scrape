# Very lightweight and simple cache implementation for caching calls to
# Drupal.org.
#
# TODO find a suitable library somewhere.
# TODO work out how to override the core open() method (modules/mixins)
# eg: https://github.com/tigris/open-uri-cached
# see also source of open_uri.
#
require 'logger'
require 'open-uri'

class DOrgCache

  # String appended to cache items.
  DORG_CACHE_SUFFIX = '.dorg.cache'

  # Initialize an object, setting the cache store directory.
  #
  # cache_dir - String - path to use as cache directory.
  #
  def initialize(cache_dir=File.dirname(File.expand_path(__FILE__)) + '/dorgcache', cache_timeout=86400)
    @cache_dir = cache_dir
    @cache_timeout = cache_timeout
    @logger = Logger.new(STDOUT)
  end

  # Public: fetch a URL from Drupal.org and cache it locally to disk for a
  # fixed time.
  #
  # url - String - the URL to fetch.
  # expire - Integer - a timeout in seconds after which to expire the cache.
  #
  def fetch(url, expire=@cache_timeout)
    # For now, the only data we will ever cache is nodes and user profiles,
    # so we can have a simple filename structure:
    #
    # https://drupal.org/node/123 becomes node-123.dorg.cache
    # https://drupal.org/user/129588 becomes user-129588.dorg.cache
    # NOTE: Check this out in irb: 'https://drupal.org/node/123'[/\d+/]
    match = url.match(%r"(node|user)/(\d+)")
    file_path = File.join(@cache_dir, "#{match[1]}-#{match[2]}#{DORG_CACHE_SUFFIX}")

    if File.exists? file_path and File.size(file_path) > 0
      @logger.info(self.class) {"Returning url #{url} from local cache #{file_path}."}
      return open(file_path) if Time.now-File.mtime(file_path)<expire
    end

    @logger.info(self.class) {"Fetching document from #{url} and writing to #{file_path}"}
    # Fetch the document and write it to a local cache file.
    begin
      File.open(file_path, 'w') {|file| file.write(open(url).read)}
    rescue OpenURI::HTTPError=>e
      @logger.warn(self.class) {"Error opening URL, #{e}"}
    end
    r = Random.new
    sleepytime = r.rand(8...20)
    easyness = %w(chill sleep smoke shower drink eat).sample
    puts "Now we have saved #{File.basename(file_path)}, gonna take it easy and #{easyness} for #{sleepytime} seconds :)"
    sleep(sleepytime)

    open(file_path)

  end

end
