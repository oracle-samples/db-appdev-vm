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
# File: 1updateLinux.sh
#
# Description: Start script to check initial files required for starting the
#              packer build.  At a minimum, the Linux iso and the database zip
#              are required before the packer build will start.  Everything else
#              is optional.
#              if needed pass proxy in as $1 
#################################################################################

function bootstrap_logging {
#
# Copying files to home which decorate logs, ie starting and ending phases.
# buildTimeReportSkippingFile.sh is used when some install zips are not available and buildTimeEndOfAllScripts.sh
# is the final end which will cleanup
#
cp /tmp/1/runTimeStartScript.sh /tmp/1/buildTimeEnd.sh /tmp/1/runTimeStagesText.txt /tmp/1/buildTimeEndOfAllScripts.sh /tmp/1/buildTimeReportSkippingFile.sh ~oracle
touch ~oracle/debug_output.txt
chmod 777 ~oracle/runTimeStartScript.sh ~oracle/buildTimeEnd.sh ~oracle/runTimeStagesText.txt ~oracle/debug_output.txt ~oracle/buildTimeReportSkippingFile.sh ~oracle/buildTimeEndOfAllScripts.sh
chown oracle  ~oracle/runTimeStartScript.sh ~oracle/buildTimeEnd.sh ~oracle/runTimeStagesText.txt ~oracle/debug_output.txt ~oracle/buildTimeReportSkippingFile.sh ~oracle/buildTimeEndOfAllScripts.sh

mkdir ~oracle/log
chmod 777 ~oracle/log
chown oracle ~oracle/log
}

#
# Update linux with YUM
#
function update_linux {
(/tmp/1/1updateLinux_inner.sh "$@" 2>&1) |  tee -a  ~oracle/log/thestdoutlog_`basename $0`_$$ | egrep '^PROGRESS'
}

bootstrap_logging
update_linux "$@"
