#!/usr/bin/env ruby

require_relative 'drupal_user'
require 'awesome_print'

name = ARGV.first

if name.nil?
  puts "Please pass a name to this script to lookup, e.g. #{__FILE__} cam8001"
  exit
end

du = DrupalUser.new(name)
puts "Mapped #{name} to #{du.uid}, #{du.profile_url}"






