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
# File: start.sh
#
# Description: Start script to check initial files required for starting the
#              packer build.  At a minimum, the Linux iso and the database zip
#              are required before the packer build will start.  Everything else
#              is optional.
#              if needed pass proxy in, 
#              if needed use the string 'export' to produce an .ova file 
#              (proxy or export in any order)
#################################################################################

#
# Cleanup old builds and remove previous output if it exists.
#
function cleanup {
	rm -rf *.vdi
	rm -rf output_last
	mv output output_last
}

#
# Check that at aminimum, the Linux iso, and the main database install zip
# are present otherwise, there is no point in continuing
#
function check_required_files {
        export varsaccepted=
        if test -f put_files_here/OracleLinux-R7-U3-Server-x86_64-dvd.iso                                            
        then                                                                                                         
                export varsaccepted=" -var iso_downloaded=y "
                cp -n put_files_here/OracleLinux-R7-U3-Server-x86_64-dvd.iso .                                       
        fi
	if test -f put_files_here/linuxx64*122*database.zip
	then
		export varsaccepted=" $varsaccepted -var oracle_database_downloaded=y " 
	fi
	if test "m$2" = "mexport"
	then
	        export varsaccepted=" $varsaccepted -var proxy=$1 -var skip_export=false "
	elif test "m$1" = "mexport"
        then
		export varsaccepted=" $varsaccepted -var proxy=$2 -var skip_export=false "
	else
		export varsaccepted=" $varsaccepted -var proxy=$1 "
	fi
}
#
# start the packer build with a proxy if it is set.
#
function start_packer_build {
	packer build $varsaccepted packerConfig.json
}

#Lets go.
cleanup
check_required_files $1 $2
start_packer_build 
