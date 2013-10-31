require_relative 'drupal_user'
require 'test/unit'

class TestDrupalUser < Test::Unit::TestCase
  def test_uid_lookup
    du = DrupalUser.new('cam8001')
    assert_match('129588', du.uid, 'Username matched to drupal.org uid.')
  end
end
