# Michigan Terminal System Running in a Docker Container

This is my 1st cut at getting MTS running in a container. It should boot to a stage where jobs can be submiited to the card reader, terminals attached and used to log in, output received from the printer, and files copied out via the card punch. 

The following network ports are exposed:

* 8038, for a web-based interface to the Hercules console
* 1403, for the line printer interface
* 3505, for the card reader interface
* 3525, for the card punch interface
* 3270, for console & subsequent terminal interfaces

You will need access to netcat or an equivalent program.

To get it running, do the following:

* docker run -dit shocking/mts-3090 


To access printer output, fire up an instance of `netcat` pointed at port 1403 on  the IP address of the container. This will echo whatever's printed. Redirect it to a file as required, if you wish to save the contents.

To submit jobs via the card reader, you'll need to write some simple header cards. An example is in the script `gpssbatch` which is a simple & incomplete shell script that submits gpss programs to the MTS gpss interpreter.


The definitive reference can be found at [https://try-mts.com/why-try-mts/]() 