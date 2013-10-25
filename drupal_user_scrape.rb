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
    @company, @company_logo, @country, @job_title, @fullname, @website = ''
    begin
      @page ||= Nokogiri::HTML(@dorg_cache.fetch(DRUPAL_USER_PROFILE_URL + @uid))
      self.scrape
    rescue  TypeError=>e
      @logger.info(self.class) {"Couldn't parse #{e}"}
    end
  end

  #def company=(newCompany)
  #  @company = newCompany
  #end
  #
  #def job_title=(newJobTitle)
  #  @job_title = newJobTitle
  #end
  #
  #def fullname=(newFullName)
  #  @fullname = newFullName
  #end

  def company
    @company
  end

  def company_logo
    @company_logo
  end

  def country
    @country
  end

  def job_title
    @job_title
  end

  def scrape
    self.scrape_company
    self.scrape_fullname
    self.scrape_job_title
    self.scrape_country
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

    def scrape_fullname
      @page.css('profile-profile_full_name grid-6 omega').each do |element|
        @fullname = element.text
      end
    end

    def scrape_country
      @page.css('dd.profile-country.grid-6.omega a').each do |element|
        @country = element.text
      end
    end

    def scrape_job_title
      @page.css('dd.profile-profile_job.grid-6').each do |element|
        @job_title = element.text
      end
    end

    def scrape_website
      @page.css('profile-homepage grid-6 omega a').each do |element|
        @website = element.text
      end
    end

    # Get a page object suitable for parsing.
    # @link http://tomdoc.org/
    #
    # TODO: When I am less tired read the following link more carefully and
    # review visibility. Protected is NOT the same as in Java/PHP.
    #
    # http://blog.zerosum.org/2007/11/22/ruby-method-visibility

  end

end
