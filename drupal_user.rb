require 'rubygems'
require 'crack'
require 'open-uri'
require 'rest-client'
require 'restclient/components'
require 'rack/cache'
require 'awesome_print'
require 'benchmark'
require 'resolv'

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
    google_url = 'http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=%s'
    user_search_query = sprintf(google_url, name) + URI.escape(' site:drupal.org')
    google_result = Crack::JSON.parse(RestClient.get(user_search_query, :referer => 'http://camerontod.com'))
    #ap google_result
    google_result['responseData']['results'].each do |result|
      match = result['url'].match Regexp.quote('drupal.org/user/') + '(\d+)$'
      return match[1]
    end
  end

  def get_username_map
    # Keep a static cache of username->uid mappings, to avoid looking it up via Google each time.
    @@username_map ||= Hash.new()
  end

  def get_uid
    return @uid
  end


  protected
  def get_public_ip
    return Resolv.getaddress('home.camerontod.com')
  end
end
