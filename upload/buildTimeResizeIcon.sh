#!/bin/bash

#
# Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved. 
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License. 
# 

#################################################################################
#
# File: buildTimeResizeIcon.sh
#
# Description: after first boot 'in gnome' script - set icon large
#
#################################################################################


#allow for 50 retries 500 for first xrandr and error out on 7 seconds.
#set -x
doseveral() {
	export start=`date -u +%s`
	#export exe="$1"
	export tries=$2
	export SOFAR=0;
	#echo $exe
	while true
	do 
	 result=`bash -x ~/repeat.setsize` 
	 if test "m$?" = "m0" 
	 then
	  echo "RESULT=$result"
	  break;
	 else
	  echo "RESULT=$result"
	  export SOFAR=`expr $SOFAR + 1`
	  if test "m$SOFAR" = "m$tries"
	  then
	   exit 1
	  fi
	  export now=`date -u +%s`
	  export diff=`expr $now - $start`
	  if test $diff -gt $3
	  then 
	   exit 1
	  fi
	  #sleep for a fraction of a second otherwise all our retries will be time of failure
	  sleep 0.05
	 fi
	done
}
#echo 'echo iconsizesetup skupped as no longer on desktop>> ~oracle/setsize.log 2>&1' > ~/repeat.setsize
echo '(gvfs-set-attribute ~/Desktop/"Click here to Start.desktop" metadata::icon-scale "5.58333333333"&&gvfs-set-attribute ~/Desktop/"Click here to Start.desktop" metadata::nautilus-icon-position "20,222" )>> ~oracle/setsize.log 2>&1' > ~/repeat.setsize
#echo '(echo gvfs-set-attribute ~/Desktop/"Click here to Start.desktop" metadata::nautilus-icon-scale "5.58333333333"&&gvfs-set-attribute ~/Desktop/"Click here to Start.desktop" metadata::icon-scale "5.58333333333"&&echo gvfs-set-attribute ~/Desktop/"Click here to Start.desktop" metadata::nautilus-icon-position "20,222" )>> ~oracle/setsize.log 2>&1' > ~/repeat.setsize
doseveral x 50 7
echo xrandr > ~/repeat.setsize
doseveral x 500 7
echo result="$result" >>  ~oracle/setsize.log 

export result=`echo "$result" | grep -e " connected [^(]" | sed -e "sX\([A-Z0-9a-z/_-]\+\) connected.*X\1X"`
echo GREPRESULT="$result" >>  ~oracle/setsize.log
echo 'xrandr --output '"$result"' --mode 800x600 >> ~oracle/setsize.log 2>&1' > ~/repeat.setsize
doseveral x 50 7
#echo 'echo size set skipped not on desktop >> ~oracle/setsize.log 2>&1' > ~/repeat.setsize
echo '(gvfs-set-attribute ~/Desktop/"Click here to Start.desktop" metadata::icon-scale "5.58333333333"&&gvfs-set-attribute ~/Desktop/"Click here to Start.desktop" metadata::nautilus-icon-position "20,222" )>> ~oracle/setsize.log 2>&1' > ~/repeat.setsize
doseveral x 50 7

if test -f ~/runTimeEnforceMinScreenSize.sh.redoicon
then
	echo icon move already done once
else
	cp ~/runTimeEnforceMinScreenSize.sh ~/runTimeEnforceMinScreenSize.sh.redoicon
	cat ~/runTimeEnforceMinScreenSize.sh.redoicon | sed 's/gvfs-set-attribute/echo gvfs-set-attribute/g' > ~/runTimeEnforceMinScreenSize.sh
	chmod 755 ~/runTimeEnforceMinScreenSize.sh
fi

