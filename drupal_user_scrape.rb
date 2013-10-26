require 'rubygems'
require 'nokogiri'
require_relative 'dorg_cache'
require 'awesome_print'
require 'logger'

# TODO make this extend DrupalUser to populate the appropriate fields.
class DrupalUserScrape
  # Base URL for Drupal user profiles.
  DRUPAL_USER_PROFILE_URL = 'https://drupal.org/user/'

  def initialize(uid)
    @uid = uid
    @logger = Logger.new(STDOUT)
    @dorg_cache = DOrgCache.new()
    # Initialize all fields to empty strings to avoid nil errors later.
    @company, @company_logo, @country, @job_title, @fullname, @first_name,
    @surname, @website = ''

    begin
      @page ||= Nokogiri::HTML(@dorg_cache.fetch(DRUPAL_USER_PROFILE_URL + @uid))
    rescue TypeError=>e
      @logger.info(self.class) {"Couldn't parse #{e}"}
    end
  end

  # Public: scrape elements that contain text and return their contents.
  #
  # css_selector - A CSS selector String for the element to be scraped.
  #
  def scrape_text_element(css_selector)
    @page.css(css_selector).each do |element|
      return element.text
    end
  end

  # Public: scrape a typical user field.
  #
  # The majority of fields follow a simple CSS pattern. This function
  # allows access to profile fields by passing only the unique part of the CSS
  # identifier.
  #
  # fieldname: String, unique component of a CSS string.
  #
  def scrape_field(fieldname)
    css_selector = "dd.profile-profile_#{fieldname}.grid-6.omega"
    self.scrape_text_element(css_selector)
  end

  def company
    # Company is a trickier parse, because it may be either a logo or an anchor.
    if @company == ''
      self.scrape_company
    end
    @company
  end

  def company_logo
    self.company
    @company_logo
  end

  def country
    @country ||= self.scrape_text_element('dd.profile-country.grid-6.omega a')
  end

  def job_title
    @job_title ||= self.scrape_field('job')
  end

  def fullname
    @fullname ||= self.scrape_field('full_name')
  end

  def firstname
    @first_name ||= self.scrape_field('first_name')
  end

  def surname
    @surname ||= self.scape_field('last_name')
  end

  def website
    @website ||= self.scrape_text_element('profile-homepage.grid-6.omega a')
  end

  def scrape_company
    @page.css('dd.profile-profile_current_company_organization a').children.each do |element|
      # Some companies have logos on Drupal.org; dome do not.
      case element.name
        when 'text'
          @company = element.text
        when 'img'
          @company_logo = element['src']
          @company = element['alt']
      end
    end
  end

  # @link http://tomdoc.org/
  #
  # TODO: When I am less tired read the following link more carefully and
  # review visibility. Protected is NOT the same as in Java/PHP.
  #
  # http://blog.zerosum.org/2007/11/22/ruby-method-visibility


end
