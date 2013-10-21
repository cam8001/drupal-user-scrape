require 'rubygems'
require 'crack'
require 'open-uri'
require 'rest-client'
require 'restclient/components'
require 'rack/cache'
require 'awesome_print'
require 'benchmark'
require 'resolv'
require 'yaml'
require 'nokogiri'

class DrupalUser
  # Base URL for Drupal user profiles.
  DRUPAL_USER_PROFILE_URL = 'https://drupal.org/user/'

  def initialize(username)
    @username = username
    @@username_map = get_username_map
    @uid = self.get_uid_from_name(@username)
  end

  def username=(newUsername)
    @username = newUsername
  end

  def uid=(newUid)
    @uid = newUid
  end

  def profile_url
    return DRUPAL_USER_PROFILE_URL + @uid
  end

  def get_uid_from_name(name)
    # TODO Keep a static cache of results.
    # Use HTTP caching to avoid hitting Drupal.org too hard during development/testing.
    RestClient.enable Rack::Cache
    if @@username_map.has_key?(name) == false
      puts 'looking up ' + name
      drupal_user_search_url = 'https://drupal.org/search/user_search/'
      result_page = Nokogiri::HTML(open(drupal_user_search_url + URI.escape(name)))
      match = result_page.css('dl.user_search-results a').first['href'].match Regexp.quote('drupal.org/user/') + '(\d+)$'
      @@username_map[name] = match[1]
      puts 'Found them! uid is ' + @@username_map[name]
      puts 'Sleeping for 10 seconds...'
      sleep(10)
    else
      puts 'Already have ' + name
    end

    return @@username_map[name]
  end

  def get_username_map
    # Keep a static cache of username->uid mappings, to avoid looking it up via Google each time.
    # TODO fix this so we can use the current directory of this class, or make it configurable, rather than hardcoding
    # the path.
    #if @@username_map.nil? && File.exists?('username_uid.yml')
      @@username_map ||= YAML.load_file('/Users/cameron.tod/Sites/drupalcontribscrape/username_uid.yml')
    #end
    return @@username_map
    #@@username_map ||= Hash.new()
  end

  def get_uid
    return @uid
  end


  protected
  def get_public_ip
    return Resolv.getaddress('home.camerontod.com')
  end
end
