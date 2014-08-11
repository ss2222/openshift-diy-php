#!/usr/bin/env ruby

# rewrites any environment variable enclosed like so - $PATH$ - as it's string value.
# usage: ruby -pi.bak env2string.rb nginx.conf

gsub(/\${1}\w+\${1}/) do |e|
  ENV[e.gsub!('$', '')]
end
