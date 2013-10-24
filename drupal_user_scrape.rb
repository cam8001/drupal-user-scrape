require 'rubygems'
require 'nokogiri'
require_relative 'dorg_cache'
require 'awesome_print'

# TODO make this extend DrupalUser to populate the appropriate fields.
class DrupalUserScrape
  # Base URL for Drupal user profiles.
  DRUPAL_USER_PROFILE_URL = 'https://drupal.org/user/'

  def initialize(uid)
    @uid = uid
    @dorg_cache = DOrgCache.new()
    @page ||= Nokogiri::HTML(@dorg_cache.fetch(DRUPAL_USER_PROFILE_URL + @uid))
    self.scrape
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
    company = @page.css('dd.profile-profile_current_company_organization a')
    company.children.each do |element|
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
      # TODO
    end

    def scrape_country
      @country = @page.css('dd.profile-country.grid-6.omega a').first.text
    end

    def scrape_job_title
      # XPath copied straight out of Firefox web inspector.
      @job_title = @page.xpath('/html/body/div[3]/div/div[2]/div/div/div/div/dl[3]/dd').first.text
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
