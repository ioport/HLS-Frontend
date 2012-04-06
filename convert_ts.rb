#!/usr/bin/env ruby
require 'shell'

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
			system("./create_segmenter_config.rb", tsfname) > STDOUT
		}
	}

}

