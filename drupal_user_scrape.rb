require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'awesome_print'

# TODO make this extend DrupalUser to populate the appropriate fields.
class DrupalUserScrape
  # Base URL for Drupal user profiles.
  DRUPAL_USER_PROFILE_URL = 'https://drupal.org/user/'

  def initialize(uid)
    @uid = uid
    self.scrape
  end

  def uid=(newUid)
    @uid = newUid
  end

  def company_name=(newCompany)
    @company_name = newCompany
  end

  def job_title=(newJobTitle)
    @job_title = newJobTitle
  end

  def get_company
    return @company_name
  end

  def scrape
    @page = Nokogiri::HTML(open(DRUPAL_USER_PROFILE_URL + @uid))
    # XPath copied straight out of Firefox web inspector.
    @job_title = @page.xpath('/html/body/div[3]/div/div[2]/div/div/div/div/dl[3]/dd').first.text
    self.scrape_company
    #ap @job_title
  end

  def scrape_company
    company = @page.css('dd.profile-profile_current_company_organization a')
    company.children.each do |element|
      # Some companies have logos on Drupal.org; dome do not.
      case element.name
        when 'text'
          @company_name = element.text
        when 'img'
          @company_name = element['alt']
      end
    end


  end

end
