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

class DrupalUser
  # Base URL for Drupal user profiles.
  DRUPAL_USER_PROFILE_URL = 'https://drupal.org/user/'
  # Google Custom Search Engine ID. See https://www.google.com/cse
  GOOGLE_CSE_ID = '<snip>>'
  # API Key for Google Cloud. See https://code.google.com/apis/console
  GOOGLE_CSE_API_KEY = '<snip>'
  # End point for Google Custom Search REST API.
  GOOGLE_CSE_ENDPOINT = 'https://www.googleapis.com/customsearch/v1'

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
    # Use HTTP caching to avoid hitting Google too hard during development/testing.
    # RestClient.enable Rack::Cache
    # Google's public API recommends and IP and referer to mitigate abuse.
    # @todo Convert to use Google CSE.
    if @@username_map.has_key?(name) == false
      puts 'looking up ' + name
      google_url = 'http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=%s'
      user_search_query = sprintf(google_url, URI.escape(name)) + URI.escape(' site:drupal.org')
      google_result = Crack::JSON.parse(RestClient.get(user_search_query, :referer => 'http://camerontod.com'))
      google_result['responseData']['results'].each do |result|
        match = result['url'].match Regexp.quote('drupal.org/user/') + '(\d+)$'
        @@username_map[name] = match[1]
        break
      end
    end

    return @@username_map[name]
  end

  def get_username_map
    # Keep a static cache of username->uid mappings, to avoid looking it up via Google each time.
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
