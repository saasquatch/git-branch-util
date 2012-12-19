#!/usr/bin/ruby

$:.unshift(File.expand_path(File.dirname(__FILE__)))
require 'shared'

# Updates so we have latest info from origin
pexec "git fetch --all"
pexec "git remote prune origin"

def format_branch(branch, brlist, text)
  if brlist.empty?
    return ''
  end
  brlist.include?(branch) ? text : ' '*text.length
end


show_heading "Staged Merge Status"
inmaster = get_merged('master')
instaging = get_merged('staging')
indev = get_merged('dev')
ordered = inmaster | instaging | indev | remote_branches
$branchLen = ordered.group_by(&:size).max.last[0].length
ordered.each do |branch|
  master = format_branch(branch, inmaster, 'master')
  staging = format_branch(branch, instaging, 'staging')
  dev = format_branch(branch, indev, 'dev')
  puts "%-#{$branchLen}s  %s  %s  %s" % [branch, master, staging, dev]
end

def __status(branch)
  ahead_count = git_count_commits "origin/#{branch}", branch
  behind_count = git_count_commits branch, "origin/#{branch}"
  status = "OK"
  # if synchronize worked correctly, we should never be behind at this point, but we'll still report
  # sanely if we are
  if ahead_count > 0
    status = "ahead #{ahead_count}"
    if behind_count > 0
      status = "#{status}, behind #{behind_count}"
    end
  elsif behind_count > 0
    status = "behind #{behind_count}"
  end
  puts "%-#{$branchLen}s  [%s]" % [branch, status]
end

show_heading "Local Branch Status"
__status "master"
__status "dev"
__status "staging"

local_branches.each do |branch|
  __status branch
end

if git_changes("master").length > 0
  puts "WARNING: There are unmerged changes, a previous merge may have failed with conflicts"
end
