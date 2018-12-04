#!/bin/bash
. /home/oracle/.bashrc
newpdbords
9090init
#on ords 9090 reset we want reinstall not uninstall
touch ~/.ordsreinstall
#note 9090init has a 3 minute wait to ensure ords has started
