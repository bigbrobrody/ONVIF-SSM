@echo off
@REM Batch file to play video from a source-specific multicast source using ffplay and SDP information embedded in the command line
setlocal EnableDelayedExpansion
echo %TIME%

set ip_address=192.168.1.121
set multicast_address=224.1.0.0
set multicast_port=40000

@REM Windows batch file method to generate CRLF
set LF=^


@REM TWO empty lines are required above

@REM Generate SDP information including CRLF (for minimum required SDP see RFC 8866)
set SDP=
set SDP=!SDP!v=0!LF!
set SDP=!SDP!o=- %RANDOM% %RANDOM% IN IP4 !multicast_address!!LF!
set SDP=!SDP!s=MinSDP!LF!
set SDP=!SDP!t=0 0!LF!
set SDP=!SDP!c=IN IP4 !multicast_address!!LF!
set SDP=!SDP!a=source-filter: incl IN IP4 !multicast_address! !ip_address!!LF!
set SDP=!SDP!m=video !multicast_port! RTP/AVP 96!LF!
set SDP=!SDP!a=rtpmap:96 H264/90000!LF!

echo SDP:
echo !SDP!

@REM Generate data string (input to ffplay)
set input=data:application/sdp;charset=UTF-8,!SDP!
echo input:
echo !input!

echo %TIME%
ffplay -protocol_whitelist rtp,udp,data -fflags nobuffer -flags low_delay -framedrop -i "!input!"
echo %TIME%

@REM Other options, including highest verbosity (trace) log 
@REM ffplay -protocol_whitelist rtp,udp,data -fflags nobuffer -flags low_delay -probesize 32 -analyzeduration 1 -strict experimental -framedrop -v trace -i "!input!"
