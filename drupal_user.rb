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
require_relative 'dorg_cache'

class DrupalUser
  # Base URL for Drupal user profiles.
  DRUPAL_USER_PROFILE_URL = 'https://drupal.org/user/'
  # File to store resolved username->uids.
  # TODO make configurable.
  USERNAME_UID_YAML_PATH = File.dirname(File.expand_path(__FILE__)) + '/username_uid.yml'


  def initialize(params)
    # The class can be initialized with either a username, a uid, or both. Any
    # value not provided is looked up via a scrape.
    @logger = Logger.new(STDOUT)
    @dorg_cache = DOrgCache.new()

    @@username_map = get_username_map
    @username = params[:username]
    @uid = params[:uid]

    @uid ||= self.get_uid_from_name(@username)
    @username ||= self.get_username_from_uid(@uid)
    #if (@username.nil? && @uid.nil?)
    #  raise ArgumentError 'You must supply either a uid or username.'
    #  # Throw an exception.
    #end

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
        result_page = Nokogiri::HTML(@dorg_cache.fetch(drupal_user_search_url + URI.escape(name)))
        result_page.css('dl.user_search-results a').each do |a|
          # Match only on exact names.
          if a.text == name
            match = a['href'].match Regexp.quote('drupal.org/user/') + '(\d+)$'
            @@username_map[name] = match[1]
            @logger.info(self.class) {"Matched user #{name} to uid #{@@username_map[name]}."}
          end
        end
      end

      return @@username_map[name]
    rescue NoMethodError=>e
      @logger.info(self.class) {"Cannot find user #{name}. Perhaps their name has changed?"}#" Error: #{e}."
    end
  end

  def get_username_from_uid(uid)
    unless @@username_map.invert[uid.to_s].nil?
      return @@username_map.invert[uid.to_s]
    end
  end

  def get_username_map
    # Keep a static cache of username->uid mappings, to avoid looking it up via Google each time.
    # the path.
    unless defined? @@username_map
      @@username_map = Hash.new(0)
      if File.exists?(USERNAME_UID_YAML_PATH)
        @@username_map = YAML::load_file(USERNAME_UID_YAML_PATH)
        @logger.info(self.class) {"Loaded #{USERNAME_UID_YAML_PATH}, #{@@username_map.count()} names already resolved."}
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

  def username
    @username
  end


  protected
    def get_public_ip
      Resolv.getaddress('home.camerontod.com')
    end
end
