FROM	ubuntu:18.04

RUN	apt-get update && \
      apt-get install -y apt-utils tzdata && \
      TERM=xterm TZ=Australia/Sydney apt-get install -y  coreutils unzip wget hercules mc nmap screen iproute2 net-tools c3270 expect && \
      cd /opt && \
      mkdir hercules && \
      cd hercules && \
      wget -nd https://raw.githubusercontent.com/stephen-hocking/Michigan-Terminal-System-Dockerfile/master/d6.0A.zip-aa && \
      wget -nd https://raw.githubusercontent.com/stephen-hocking/Michigan-Terminal-System-Dockerfile/master/d6.0A.zip-ab && \
      wget -nd https://raw.githubusercontent.com/stephen-hocking/Michigan-Terminal-System-Dockerfile/master/d6.0A.zip-ac && \
      wget -nd https://raw.githubusercontent.com/stephen-hocking/Michigan-Terminal-System-Dockerfile/master/d6.0A.zip-ad && \
      wget -nd https://raw.githubusercontent.com/stephen-hocking/Michigan-Terminal-System-Dockerfile/master/d6.0A.zip-ae && \
      cat d6.0A.zip-* > d6.0A.zip && \
      unzip d6.0A.zip && \
      rm d6.0A.zip* && \
      wget -nd https://raw.githubusercontent.com/stephen-hocking/Michigan-Terminal-System-Dockerfile/master/mts-expect && \
      chmod 777 mts-expect && \
      wget -nd http://bitsavers.org/bits/univOfMichigan/mts/d6.0.tar.gz && \
      tar zxf d6.0.tar.gz && \
      rm -f d6.0.tar.gz && \
      mv mts/d6.0/*.aws mts/d6.0/*.txt mts/d6.0A/Tapes && \
      cd mts/d6.0A && \
      echo "ARCHMODE  ESA/390" > hercules.cnf && \ 
      echo "CODEPAGE  819/037" >> hercules.cnf && \
      echo "CPUSERIAL 000611" >> hercules.cnf && \
      echo "CPUMODEL  3090" >> hercules.cnf && \
      echo "CPUVERID  FF" >> hercules.cnf && \
      echo "MAINSIZE  128" >> hercules.cnf && \
      echo "XPNDSIZE 0 " >> hercules.cnf && \
      echo "HTTPPORT 8038 NOAUTH" >> hercules.cnf && \
      echo "NUMCPU   1 " >> hercules.cnf && \
      echo "MAXCPU   1" >> hercules.cnf && \
      echo "SYSEPOCH 1900" >> hercules.cnf && \
      echo "TZOFFSET -0000" >> hercules.cnf && \
      echo "CNSLPORT 3270" >> hercules.cnf && \
      echo "OSTAILOR QUIET" >> hercules.cnf && \
      echo "0000   3287" >> hercules.cnf && \
      echo "0001.7 3270" >> hercules.cnf && \
      echo "0009   1052-C" >> hercules.cnf && \
      echo "001F   3270" >> hercules.cnf && \
      echo "0100   3287" >> hercules.cnf && \
      echo "0101.7 3270" >> hercules.cnf && \
      echo "000C   3505   3505 sockdev ascii eof" >> hercules.cnf && \
      echo "000D   3525   Units/PCH1.txt ascii" >> hercules.cnf && \
      echo "000E   1403   1403 sockdev" >> hercules.cnf && \
      echo "0180   3420   Tapes/d6.0util.aws ro" >> hercules.cnf && \
      echo "0181   3420   Tapes/d6.0dr1.aws  ro" >> hercules.cnf && \
      echo "0182   3420   Tapes/d6.0dr2.aws  ro" >> hercules.cnf && \
      echo "0183   3420   Tapes/d6.0dr3.aws  ro" >> hercules.cnf && \
      echo "0184   3420   Tapes/d6.0t1.aws   ro" >> hercules.cnf && \
      echo "0185   3420   Tapes/d6.0t2.aws   ro" >> hercules.cnf && \
      echo "0186   3420   Tapes/d6.0t3.aws   ro" >> hercules.cnf && \
      echo "0187   3420   Tapes/d6.0t4.aws   ro" >> hercules.cnf && \
      echo "0188   3420   Tapes/d6.0t5.aws   ro" >> hercules.cnf && \
      echo "0189   3420   Tapes/d6.0t6.aws   ro" >> hercules.cnf && \
      echo "018A   3420   Tapes/cmd001.aws" >> hercules.cnf && \
      echo "0260   3380   Disks/mts600.dsk sf=Disks/mts600_*.dsk" >> hercules.cnf && \
      apt-get -y autoclean && apt-get -y autoremove && \
      echo > Units/PCH1.txt && \
      echo '#!/bin/bash' > start_mts.sh && \
      echo "cd /opt/hercules/mts/d6.0A"  >> start_mts.sh && \
      echo "/usr/bin/screen -dm -S herc hercules -f hercules.cnf"  >> start_mts.sh && \
      echo 'nohup $(while :; do ncat -c "cat Units/PCH1.txt; > Units/PCH1.txt" -l 3525 ; done) &' >> start_mts.sh && \
      echo "/bin/bash -i" >> start_mts.sh && \
      chmod 755 start_mts.sh && \
      echo "sh /opt/hercules/mts-expect &" > hercules.rc && \
      echo "pause 1" >> hercules.rc && \
      echo "ipl 260" >> hercules.rc && \
      apt-get -y purge $(dpkg --get-selections | grep deinstall | sed s/deinstall//g) && \
      rm -rf /var/lib/apt/lists/*

EXPOSE      1403 3270 3505 3525 8038
WORKDIR     /opt/hercules/mts/d6.0A
ENTRYPOINT  ["/opt/hercules/mts/d6.0A/start_mts.sh"]
#ENTRYPOINT ["/bin/bash"]
