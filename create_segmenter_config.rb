#!/usr/bin/env ruby
require 'optparse'

options = {}
opt = OptionParser.new
begin
	opt.parse!(ARGV)
rescue
	print "unknown option\n"
	exit
end

if ARGV.size < 2 then
	print "no input file or output path is spedified\n"
	exit
end

inputfile=ARGV[0]
outputpath=ARGV[1]

if !File.exist?(inputfile) then
	print "input file does not exist\n"
	exit
end
inputbasename = File.basename(inputfile, ".*")

print <<EOCONFIG
temp_dir: '/tmp/'
segment_prefix: '#{inputbasename}'
index_prefix: '#{inputbasename}'

# type of logging: STDOUT, FILE
log_type: 'STDOUT'
#log_type: 'FILE'
#log_file: '/tmp/streamer.log'
# levels: DEBUG, INFO, WARN, ERROR
log_level: 'WARN'

# where the origin video is going to come from
#input_location: '-'
input_location: '#{inputfile}'

# segment length in seconds
segment_length: 10 

# this is the URL where the stream (ts) files will end up
# if this location is the same as the location where the m3u8 
# index is then leave it blank
url_prefix: 

# how many segments to keep in the index
index_segment_count: 1000

# this command is used for multirate encodings and is what pushes the encoders
source_command: 'cat %s'

# This is the location of the segmenter
segmenter_binary: './live_segmenter'

# the encoding profile to use
encoding_profile: [ 'cell_16x9_150k', 'cell_16x9_240k', 'wifi_16x9_640k' ]

# The upload profile to use
transfer_profile: 'copy_dev'

#
# Encoding profiles
#
cell_16x9_150k: 
  ffmpeg_command: "ffmpeg -er 4 -i %s -f mpegts -acodec libmp3lame -ar 32000 -ab 48k -s 400x224 -vcodec libx264 -b 110k -flags +loop+mv4 -cmp 256 -partitions +parti4x4+partp8x8+partb8x8 -subq 7 -trellis 1 -refs 5 -coder 0 -me_range 16 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -bt 110k -maxrate 110k -bufsize 110k -rc_eq 'blurCplx^(1-qComp)' -qcomp 0.6 -qmin 10 -qmax 51 -qdiff 4 -level 30 -aspect 16:9 -r 10 -g 30 -async 2 - | %s %s %s %s %s"
  bandwidth: 158000

cell_16x9_240k: 
  ffmpeg_command: "ffmpeg -er 4 -i %s -f mpegts -acodec libmp3lame -ar 32000 -ab 48k -s 400x224 -vcodec libx264 -b 200k -flags +loop+mv4 -cmp 256 -partitions +parti4x4+partp8x8+partb8x8 -subq 7 -trellis 1 -refs 5 -coder 0 -me_range 16 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -bt 200k -maxrate 200k -bufsize 200k -rc_eq 'blurCplx^(1-qComp)' -qcomp 0.6 -qmin 10 -qmax 51 -qdiff 4 -level 30 -aspect 16:9 -r 15 -g 45 -async 2 - | %s %s %s %s %s"
  bandwidth: 248000

wifi_16x9_440k: 
  ffmpeg_command: "ffmpeg -er 4 -i %s -f mpegts -acodec libmp3lame -ar 32000 -ab 48k -s 400x224 -vcodec libx264 -b 400k -flags +loop+mv4 -cmp 256 -partitions +parti4x4+partp8x8+partb8x8 -subq 7 -trellis 1 -refs 5 -coder 0 -me_range 16 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -bt 400k -maxrate 400k -bufsize 400k -rc_eq 'blurCplx^(1-qComp)' -qcomp 0.6 -qmin 10 -qmax 51 -qdiff 4 -level 30 -aspect 16:9 -r 30 -g 90 -async 2 - | %s %s %s %s %s"
  bandwidth: 448000

wifi_16x9_640k: 
  ffmpeg_command: "ffmpeg -er 4 -i %s -f mpegts -acodec libmp3lame -ar 32000 -ab 48k -s 400x224 -vcodec libx264 -b 600k -flags +loop+mv4 -cmp 256 -partitions +parti4x4+partp8x8+partb8x8 -subq 7 -trellis 1 -refs 5 -coder 0 -me_range 16 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -bt 600k -maxrate 600k -bufsize 600k -rc_eq 'blurCplx^(1-qComp)' -qcomp 0.6 -qmin 10 -qmax 51 -qdiff 4 -level 30 -aspect 16:9 -r 30 -g 90 -async 2 - | %s %s %s %s %s"
  bandwidth: 648000

#
# Transfer profiles
#
s3_dev:
  transfer_type: 's3'
  bucket_name: 'bucket'
  key_prefix: 'stream0001'
  aws_api_key: 'key'
  aws_api_secret: 'secret'

ftp_dev:
  transfer_type: 'ftp'
  remote_host: '192.168.1.1'
  user_name: 'user'
  password: 'pass'
  directory: 'html/streamingvideo'

scp_dev:
  transfer_type: 'scp'
  remote_host: '192.168.1.1.'
  user_name: 'root'
  #password: 'pass'
  directory: '/web/sites/test.com/html/streamingvideo'

copy_dev:
  transfer_type: 'copy'
  directory: '#{outputpath}'
EOCONFIG
