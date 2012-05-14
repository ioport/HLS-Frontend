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
	print "no output path is spedified\n"
	exit
end

outputpath=ARGV[0]

progdir = File.dirname(File.expand_path($PROGRAM_NAME))

Dir.glob("*.ts").each { |tsfname|
	tsbasename = File.basename(tsfname, ".*")
	lockfname = tsbasename + ".lock"
	configfname = tsbasename + ".config"
	if File.exist?(lockfname) then
		next
	end
	p tsfname;

	File.open(lockfname, File::RDWR|File::CREAT, 0644) { |f|
		f.flock(File::LOCK_EX)

		File.open(tsfname, "r") { |tf|
			tf.flock(File::LOCK_EX)
			print "lock ok. let's proceed\n"
		}
		sh = Shell.new
		sh.transact {
			system(progdir + "/create_segmenter_config.rb", tsfname, outputpath) > configfname 
			system(progdir + "/http_streamer.rb", configfname) > STDOUT
		}
	}
	File.delete(lockfname)
	File.rename(tsfname, tsfname + ".done")
}

