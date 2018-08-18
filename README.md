# Michigan Terminal System Running in a Docker Container

This is my 1st cut at getting MTS running in a container. There is still too much manual intervention needed before the container can be used for something useful, but it does work.

The following network ports are exposed:

* 8038, for a web-based interface to the Hercules console
* 1403, for the line printer interface
* 3505, for the card reader interface
* 3270, for console & subsequent terminal interfaces

You will need access to netcat or an equivalent program.

To get it running, do the following:

* docker run -dit mts-3090 -p 1403:1403 -p 3270:3270 -p 3505:3505 -p 8038:8038
* Attach a web browser to port 8038 on localhost (if running under Linux) or the IP of the container (found via `docker inspect -f '{{ .NetworkSettings.IPAddress }}' containerid` , where container id can be found by looking at the output of `docker container ls` . 
* Point a 3270 terminal client at port 3270 on localhost or the ip address of the container
* In the web interface, enter `ipl 260`
* The 3270 terminal should now display a message asking you if you want to run the current system. Answer `yes` and press return.
* It'll complain about the time/date being too different, ask you to enter OK if you want to continue. Enter OK.
* It'll then prompt you to enter your initials and a reason for reloading. Anything will do here.
* The system will continue to boot up, and ask to hit cancel after complaing about defined but not online devices. Press `Cancel`, which will be whatever your terminal emulator has mapped to the PA2 key. For x3270, you'll have to press the keyboard image button to get it to pop out the special keys, including PA2.
* Eventually you'll get a message `PEEK INITIALIZATION COMPLETE`. At this point, enter `HASP`. This will load the "Houston Automatic Spooling System".
* Once the message `Enter HASP Requests` comes up, enter `MTS *HSP`. This will start HASP.
* Enter `MTS *LAS` - this will allow other 3270 terminals to connect.
* Finally, enter `$release ex` - this will allowed queued jobs to start.


To access printer output, fire up an instance of `netcat` pointed at port 1403 on either localhost or the IP address of the container. This will echo whatever's printed. Redirect it to a file as required, if you wish to save the contents.

To submit jobs via the card reader, you'll need to write some simple header cards. An example is in the script `gpssbatch` which is a simple & incomplete shell script that submits gpss programs to the MTS gpss interpreter.