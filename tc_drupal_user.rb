require_relative 'drupal_user'
require 'test/unit'

class TestDrupalUser < Test::Unit::TestCase

  def test_scrape
    assert_match('124982', DrupalUser.new(:username => 'David_Rothstein').uid.to_s, 'Username matched to drupal.org uid.')
    assert_match('david_rothstein', DrupalUser.new(:uid => '124982').username, 'drupal.org uid matched to username.')

    # Test for scraping of specific fields.
    du = DrupalUser.new(:uid => '124982')
    assert_match('David', du.firstname)
    assert_match('United States', du.country)
  end




end
