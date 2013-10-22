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
  # File to store resolved username->uids.
  # TODO make configurable.
  USERNAME_UID_YAML_PATH = File.dirname(File.expand_path(__FILE__)) + '/username_uid.yml'

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
    begin
      if @@username_map.has_key?(name) == false
        puts 'looking up ' + name
        drupal_user_search_url = 'https://drupal.org/search/user_search/'
        result_page = Nokogiri::HTML(open(drupal_user_search_url + URI.escape(name)))
        match = result_page.css('dl.user_search-results a').first['href'].match Regexp.quote('drupal.org/user/') + '(\d+)$'
        @@username_map[name] = match[1]
        puts 'Found them! uid is ' + @@username_map[name]
        puts 'Sleeping for 5 seconds...'
        sleep(5)
      else
        puts 'Already have ' + name
      end
        return @@username_map[name]
    rescue NoMethodError=>e
      puts "YAML file not loaded correctly. Error: #{e}."
    end
  end

  def get_username_map
    # Keep a static cache of username->uid mappings, to avoid looking it up via Google each time.
    # the path.
    unless defined? @@username_map
      @@username_map = Hash.new(0)
      if File.exists?(USERNAME_UID_YAML_PATH)
        @@username_map = YAML::load_file(USERNAME_UID_YAML_PATH)
        puts "Loaded #{USERNAME_UID_YAML_PATH}, #{@@username_map.count()} names already resolved."
      end
    end

    return @@username_map
  end

  def get_uid
    return @uid
  end


  protected
  def get_public_ip
    return Resolv.getaddress('home.camerontod.com')
  end
end
