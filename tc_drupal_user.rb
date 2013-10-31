require_relative 'drupal_user'
require 'test/unit'

class TestDrupalUser < Test::Unit::TestCase

  def test_scrape
    assert_match('129588', DrupalUser.new(:username => 'cam8001').uid, 'Username matched to drupal.org uid.')
    assert_match('cam8001', DrupalUser.new(:uid => '129588').username, 'drupal.org uid matched to username.')
  end




end
