#!/usr/bin/ruby

$:.unshift(File.expand_path(File.dirname(__FILE__)))
require 'synchronize'

show_heading "Merging * to Dev"
git_merge "staging", "dev"
git_merge "master", "dev"
local_branches.each do |branch|
  git_merge "#{branch}", "dev"
end
