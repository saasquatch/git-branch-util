
CONST_BRANCHES = ["master","staging"]

def show_heading(msg)
  puts "\n**** #{msg} ****"  
end

# execute, ignoring and hiding all output, and return exit status code
def pexec(cmd)
  `#{cmd} 2>&1`
  $?
end

def __branch_cmd(cmd)
  `git branch #{cmd} | sed -e 's/[ \*]//g'`.split("\n").sort
end

def local_branches
  __branches("-l")
end

def remote_branches
  __branches("-r")
end

# get all branches which are fully contained in the given branch
def get_merged(br)
  __branches "-l --merged #{br}"
end

def __branches(arg)
  branches = __branch_cmd arg
  branches.each do |branch|
    branch.gsub!("origin/","")
    branch.strip!
  end
  #the =~ master gets rid of HEAD->master
  branches.delete_if {|branch| CONST_BRANCHES.include? branch or branch =~ /master/ }
end

def git_count_commits(from, to)
  `git log --oneline #{from}..#{to}`.split("\n").length
end

def git_state()
  `git status --porcelain`.strip.split("\n")
end


def git_changes(branch)
  pexec "git checkout #{branch}"
  `git status --porcelain`.strip.split("\n")
end

def git_merge(from, to)
  # git merge doesn't output anything useful for tracking number of commits merged on ff merges
  # just compare the number of commits between before and after the merge (number of lines on a log --online between before and after version)
  pexec "git checkout #{to}"
  version = `git rev-parse #{to}`.strip
  output = `git merge --ff-only #{from} 2>&1`
  count = git_count_commits version, to
  if output.include? "CONFLICT"
    puts "merge #{from} => #{to} [#{count} commits: CONFLICT!!]"
  else
    if count > 0
      puts "merge #{from} => #{to} [#{count} commits]"
    else
      puts "merge #{from} => #{to} [None]"
    end
  end
end

