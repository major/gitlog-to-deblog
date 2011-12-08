#!/usr/bin/ruby
require 'erb'

# Determines package name from the origin url on github. It's hackish, but it
# works (mostly).
def pkgname
  originurl = `git config --get remote.origin.url`.strip
  _, pkgname = originurl.match(/\/([a-z0-9\-_]+).git/i).to_a
  pkgname
end

# Accepts a hash of git log data and returns a properly formatted debian 
# changelog entry.
def debchangelog(logdata)
  template = <<-EOF
<%=PKGNAME%> (<%=logdata[:tag]%>) unstable; urgency=low

  * <%=logdata[:subj]%>

 -- <%=logdata[:name]%>  <%=logdata[:date]%>

EOF
  ERB.new(template).result(binding)
end

# Checks to see if the repository has any tags already.
def repo_has_tag?
  `git describe --tags 2>&1`
  return ($? == 0)? true : false
end

# If the repository has no tags, we need to make one called 'initial' so we 
# can get some kind of versioning number for the changelog.
def make_temporary_tag
  firstcommit = `git log --format=%H | tail -1`.strip
  `git tag initial #{firstcommit}`
end

# Removes the tag we added if the repo had no tags.
def cleanup_temporary_tag
  `git tag -d initial`
end

# Basic setup before we start the loop
PKGNAME = pkgname.downcase
if repo_has_tag?
  # the repo has at least one tag already
  DOTAGCLEANUP = false
else
  # the repo has no tags, so we need to make one
  DOTAGCLEANUP = true
  make_temporary_tag
end

# Loop through the git log output and grab four lines at a time to parse.
gitlogcmd = %{git log -n 25 --pretty=format:'hash: %H%nname: %aN <%aE>%ndate: %cD%nsubj: %s'}
IO.popen(gitlogcmd).readlines.each_slice(4) do |chunk|

  temphash = {}

  # split each line on the first colon and use what's on the left as the 
  # symbols within the hash
  chunk.map { |line| line.split(/: /,2) }.each do |type, data|
    temphash[type.to_sym] = data.strip
  end

  # dig up the most recent tag which contains the commit
  temphash[:tag] = `git describe --tags #{temphash[:hash]}`.strip

  puts debchangelog(temphash)
end

# If we added a temporary tag, let's remove it
cleanup_temporary_tag if DOTAGCLEANUP