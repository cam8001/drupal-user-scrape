# Parses a list of Drupal core commiters and matches them up with some metadata as hosted on Drupal.org.
# The original intention of this was to allow companies to say "we have 10 of the top 100 Drupal 8 core commiters"", or
# "We have 100 commits in Drupal 8 core.".
#
# This parses the list generated by Eric Duran at https://github.com/ericduran/drupalcores, uses a Google CSE to link
# the usernames to Drupal uids, then parses Drupal.org profile pages to get metadata about the user.
#
# In the future, it might be prudent to import this data into a Drupal 8 install instead of flat files - then we can
# use Views to mash up the data and create an interesting RESTful API.

require_relative 'drupal_user'
require_relative 'drupal_user_scrape'
require 'awesome_print'

#url='http://en.wikipedia.org/w/api.php?action=opensearch&search=At&namespace=0'
#commiters_url = 'http://ericduran.github.io/drupalcores/data.json'

# Get Eric Duran's list of commiters.
#commit_count=Crack::JSON.parse(RestClient.get(url))

#{commit_count['contributors'].each_pair do |k,v|
#  print k + 'BREAK' + v.to_s + "\n"
#end}

#ap get_profile_url_from_name('xjm')


#uid_map = YAML.load_file('username_uid.yml')
#uid_map.each do |k,v|
#  puts k + ' ' + v
#end
#
#uid_map['chicken'] = '666'
#File.open('username_uid.yml', 'w') do |out|
#  YAML.dump(uid_map, out)
#end



names = %w(matsearle cam8001 chx xjm)
##Benchmark.bm(11) do |b|
# # b.report('lookup') do
    names.each { |name|
      du = DrupalUser.new(name)
      puts name + '  ' + du.profile_url
      dus = DrupalUserScrape.new(du.uid)
      puts %(User #{name} lives in #{dus.country} and works for #{dus.company_name} #{dus.company_logo})
    }
# # end
##end

# TODO figure out a way to automatically write out the username map to YAML when
# all DrupalUser instances are garbage collected (destroyed).
