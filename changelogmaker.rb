#!/usr/bin/ruby
require 'erb'

def pkgname
  originurl = `git config --get remote.origin.url`.strip
  _, pkgname = originurl.match(/\/([a-z0-9\-_]+).git/i).to_a
  pkgname
end

PKGNAME = pkgname

=begin
# Required format for Debian changelogs
# gathered from http://www.debian.org/doc/debian-policy/ch-source.html

package (version) distribution(s); urgency=urgency
      [optional blank line(s), stripped]
  * change details
    more change details
      [blank line(s), included in output of dpkg-parsechangelog]
  * even more change details
      [optional blank line(s), stripped]
 -- maintainer name <email address>[two spaces]  date

=end

def debchangelog(logdata)
  template = <<-EOF
<%=PKGNAME%> (<%=logdata[:tag]%>) unstable; urgency=low

  * <%=logdata[:subj]%>

 -- <%=logdata[:name]%>  <%=logdata[:date]%>

EOF
  ERB.new(template).result(binding)
end

IO.popen(%{git log -n 25 --pretty=format:'hash: %H%nname: %aN <%aE>%ndate: %cD%nsubj: %s'}).readlines.each_slice(4) do |chunk|
  temphash = {}
  chunk.map { |line| line.split(/: /,2) }.each do |type, data|
    temphash[type.to_sym] = data.strip
  end
  temphash[:tag] = `git describe --tags #{temphash[:hash]}`.strip
  
  puts debchangelog(temphash)
  
end