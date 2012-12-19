#!/usr/bin/ruby

$:.unshift(File.expand_path(File.dirname(__FILE__)))
require 'synchronize'

show_heading "Merging Master to *"
git_merge "master", "staging"
local_branches.each do |branch|
  git_merge "master", "#{branch}"
end

