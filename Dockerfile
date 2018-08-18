FROM	ubuntu:18.04

RUN	apt-get update && \
      apt-get install -y  unzip wget hercules mc screen && \
      cd /opt && \
      mkdir hercules && \
      cd hercules && \
      wget --no-check-certificate 'https://drive.google.com/uc?authuser=0&id=0B4t_NX-QeWDYN2QwMGU4NWMtMTRiYS00ZTc5LWIyOWUtNTg0YjQyOWIxY2I4&export=download' -O d6.0A.zip && \
      unzip d6.0A.zip && \
      rm d6.0A.zip && \
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
      echo "HTTPPORT 8038" >> hercules.cnf && \
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
      echo "018A 3420 Tapes/cmd001.aws" >> hercules.cnf && \
      echo "0260   3380   Disks/mts600.dsk sf=Disks/mts600_*.dsk" >> hercules.cnf && \
      apt-get -y autoclean && apt-get -y autoremove && \
      echo '#!/bin/bash' > start_mts.sh && \
      echo "cd /opt/hercules/mts/d6.0A"  >> start_mts.sh && \
      echo "/usr/bin/screen -dm -S herc hercules -f hercules.cnf"  >> start_mts.sh && \
      echo "/bin/bash -i" >> start_mts.sh && \
      chmod 755 start_mts.sh && \
      apt-get -y purge $(dpkg --get-selections | grep deinstall | sed s/deinstall//g) && \
      rm -rf /var/lib/apt/lists/*

EXPOSE      1403 3270 3505 8038
WORKDIR     /opt/hercules/mts/d6.0A
ENTRYPOINT  ["/opt/hercules/mts/d6.0A/start_mts.sh"]
#ENTRYPOINT ["/bin/bash"]
