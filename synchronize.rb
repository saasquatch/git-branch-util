#!/usr/bin/ruby

$:.unshift(File.expand_path(File.dirname(__FILE__)))
require 'shared'

# make sure we are up to date with the remote repo

#puts "Synchronizing with remote"
pexec "git fetch --all"
pexec "git remote prune origin"
remote_br = remote_branches + CONST_BRANCHES
local_br = local_branches + CONST_BRANCHES
local_only = local_br - remote_br
local_only.each do |branch|
  puts " == Cleaning up local-only branch #{branch}"
  pexec "git branch -d #{branch}" or puts "Failed to delete #{branch}"
end
remote_br.each do |branch|
  if local_br.include? branch
    #puts "Update #{branch}"
    pexec "git checkout #{branch}"
    pexec "git merge origin/#{branch}"
  else
    #puts "Checkout #{branch}"
    pexec "git checkout -t origin/#{branch}"
  end
end

