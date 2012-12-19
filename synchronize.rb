#!/usr/bin/ruby

$:.unshift(File.expand_path(File.dirname(__FILE__)))
require 'shared'

if git_state().length > 0
  puts "\nERROR\n\n"
  puts "There are unmerged changes in your working copy. Commit or stash them before running the git helper scripts\n\n"
  puts "You can use 'git clean -f' if you're confident your local copy is just junk\n\n"
  abort("Script stopped");
end

# make sure we are up to date with the remote repo
#puts "Synchronizing with remote"
pexec "git fetch --all"
pexec "git remote prune origin"
remote_br = remote_branches + CONST_BRANCHES
local_br = local_branches + CONST_BRANCHES
local_only = local_br - remote_br
local_only.each do |branch|
  puts " == Cleaning up local-only branch #{branch}"
  pexec "git branch -d #{branch}" or puts "Local branch (#{branch}) has non-merged changes"
end
remote_br.each do |branch|
  if local_br.include? branch
    #puts "Update #{branch}"
    pexec "git checkout #{branch}"
    # --ff  = no merge message on fast forward
    # --ff-only = don't attempt complex merges (only allows fast-forward)
    pexec "git merge --ff --ff-only origin/#{branch}"
  else
    #puts "Checkout #{branch}"
    pexec "git checkout -t origin/#{branch}"
  end
end

