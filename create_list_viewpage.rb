#!/usr/bin/env ruby
require 'shell'
require 'optparse'

options = {}
opt = OptionParser.new
begin
	opt.parse!(ARGV)
rescue
	print "unknown option\n"
	exit
end

if ARGV.size < 1 then
	print "no path is spedified\n"
	exit
end

outputpath=ARGV[0]

progdir = File.dirname(File.expand_path($PROGRAM_NAME))

out_f = open(outputpath + "playlist.html", "w")
out_f.print <<EOL
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/x
html1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<meta name="viewport" content="width=device-width, user-scalable=no" />
        <title>playlist</title>
        <link rel = "stylesheet" href = "EdgeToEdge.css" />
	</head>
	<body>
        <!-- Use a single <ul> tag to create the entire list. All the <ul> and <
li> properties are defined in the EdgeToEdge.css file -->
<ul>
EOL
Dir.chdir(outputpath)
Dir.glob("*_multi.m3u8").each { |plfname|
	plbasename = File.basename(plfname, ".*")
	out_f.print "<li> <a href=\"" + plbasename + ".html\">" + plbasename + "</a></li>"
}
out_f.print <<EOL
</ul>
</body>
</html>
EOL

