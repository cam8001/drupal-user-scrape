#!/usr/bin/env ruby

Encoding.default_external = Encoding::UTF_8

require 'yaml'
require 'json'

map = YAML::load_file('username_uid.yml')

puts map.to_json
