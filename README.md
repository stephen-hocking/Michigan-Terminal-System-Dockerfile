# Michigan Terminal System Running in a Docker Container

This is my 1st cut at getting MTS running in a container. It should boot to a stage where jobs can be submiited to the card reader, terminals attached and used to log in, output received from the printer, and files copied out via the card punch. 

The following network ports are exposed:

* 8038, for a web-based interface to the Hercules console
* 1403, for the line printer interface
* 3505, for the card reader interface
* 3525, for the card punch interface
* 3270, for console & subsequent terminal interfaces

You will need access to netcat or an equivalent program. ncat is preferred.

To get it running, do the following:

* docker run -dit shocking/mts-3090 


To access printer output, fire up an instance of `ncat` pointed at port 1403 on  the IP address of the container. This will echo whatever's printed. Redirect it to a file as required, if you wish to save the contents.

A helper shell script, mts.sh, can be used to submit jobs of various sorts, and will do a lot of the fiddling with ncat for you. All you have to do is capture stdout to see the results. The script is intended to be copied to somewhere in your path, and then can be symlinked to other names, mts-gpss (for submitting GPSS jobs), mts-copyto (to copy files to the container), and mts-copyfrom (to copy files from the container to the virtual card punch, and hopefully, with a bit of netcat trickery, to take those card images and copy them locally). The script in its various forms has a number of optional arguments, which can be set via the command line or environment variables. These are listed below.

* `-h | --host somehost`. THe corresponding enviroment variable is `MTS_HOST`. The default is 172.17.0.2, which is usually the 1st local docker container.
* `-u | --user someuser`. The corresponding environment variable is `MTS_USER`. The default is `st01`, which the 1st of 4 user accounts, the others being `st02`, `st03` and `st04`.
* `-p | --password somepassword`. The corresponding environment variable is `MTS_PASSWORD`. The default is `st01`. Guessing what the passwords are for the other users is left as an exercise for the reader.
* `--rdr-port somenum`. This is the port number of the card reader, which is used to submit jobs. The corresponding environment variable is `MTS_CARD_RDR_PORT`. The default is `3505`.
* `--pch-port somenum`. This is the port that the card punch will output to. The corresponding environment variable is `MTS_CARD_PCH_PORT`. The default is `3525`.
* `-t | --terminal-port somenum`. This is the port that the container listens on to deliver terminal services. The corresponding environment variable is `MTS_TERMINAL_PORT`. The default is `3270`. Use `x3270` or `c3270` to connect to this port.
* `--printer-port somenum`. This is the port which printer output is sent to. The corresponding environment variable is `MTS_PRINTER_PORT`. The default is `1403`.

Depending on how it is invoked, it will act in the following ways:

* When invoked as `mts-gpss` it requires one argument, which is the name of a file that contains GPSS code. It will create a job deck, submit it to the card reader, and wait for the output from the printer port and send that to stdout.
* Invoked as `mts-copyto`, it requires one argument, that is the name of a file to be copied to the container. It will create a job deck, send it to the card reader, and look for any printer out of the job. 
* Invoked as `mts-copyfrom`, it requires one argument, that is the name of a file to be copied out of the container. It will create a job deck, send it to the card reader, wait for operator input (as described in https://try-mts.com/extracting-files-using-the-card-punch/) and send the file to the card punch. Dealing with the card punch can involve a complicated dance with commands entered at the web interface of the machine, as well as the console.
* Invoked as anything else, it requires one argument, which is the name of a file containing a job deck.

The definitive reference can be found at [https://try-mts.com/why-try-mts/]() 
