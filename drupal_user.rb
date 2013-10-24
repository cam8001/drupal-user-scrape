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
require 'logger'

class DrupalUser
  # Base URL for Drupal user profiles.
  DRUPAL_USER_PROFILE_URL = 'https://drupal.org/user/'
  # File to store resolved username->uids.
  # TODO make configurable.
  USERNAME_UID_YAML_PATH = File.dirname(File.expand_path(__FILE__)) + '/username_uid.yml'

  def initialize(username)
    @logger = Logger.new(STDOUT)

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
    DRUPAL_USER_PROFILE_URL + @uid
  end

  def get_uid_from_name(name)
    # TODO Keep a static cache of results.
    # Use HTTP caching to avoid hitting Drupal.org too hard during development/testing.
    RestClient.enable Rack::Cache
    begin
      if @@username_map.has_key?(name) == false
        drupal_user_search_url = 'https://drupal.org/search/user_search/'
        result_page = Nokogiri::HTML(open(drupal_user_search_url + URI.escape(name)))
        match = result_page.css('dl.user_search-results a').first['href'].match Regexp.quote('drupal.org/user/') + '(\d+)$'
        @@username_map[name] = match[1]
        @logger.info("Matched user #{name} to uid #{@uid}.")
      end

      return @@username_map[name]
    rescue NoMethodError=>e
      @logger.info("Cannot find user #{name}. Perhaps their name has changed?")#" Error: #{e}."
    end
  end

  def get_username_map
    # Keep a static cache of username->uid mappings, to avoid looking it up via Google each time.
    # the path.
    unless defined? @@username_map
      @@username_map = Hash.new(0)
      if File.exists?(USERNAME_UID_YAML_PATH)
        @@username_map = YAML::load_file(USERNAME_UID_YAML_PATH)
        @logger.info("Loaded #{USERNAME_UID_YAML_PATH}, #{@@username_map.count()} names already resolved.")
      end
    end

    @@username_map
  end

  # Couple of things to learn here:
  # 1. Ruby recognises methods with the same name but different signatures as
  #    separate methods - eg uid=(newUid) and uid are different.
  # 2. Ruby implicitly returns??? Apparently:
  # "Any statement in ruby returns the value of the last evaluated expression."
  def uid
     @uid
  end


  protected
    def get_public_ip
      Resolv.getaddress('home.camerontod.com')
    end
end
