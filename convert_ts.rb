#!/usr/bin/env ruby
require 'shell'

progdir = File.dirname(File.expand_path($PROGRAM_NAME))

Dir.glob("*.ts").each { |tsfname|
	tsbasename = File.basename(tsfname, ".*")
	lockfname = tsbasename + ".lock"
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
			system("ls", "-l") > STDOUT
			system(progdir + "/create_segmenter_config.rb", tsfname, File.dirname(tsfname)) > STDOUT
		}
	}

}

