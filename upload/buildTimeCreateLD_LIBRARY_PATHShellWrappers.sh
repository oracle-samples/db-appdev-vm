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
# File: buildTimeCreateLD_LIBRARY_PATHShellWrappers.sh
#
# Description: LD_LIBRARY_PATH workaround so oracle shipped libraries only used when necessary
#
#################################################################################


rm -rf ~/LDLIB/
. ~/bin/dbenv
cd $ORACLE_HOME/bin
if ! test -d ~/LDLIB/
then
 mkdir ~/LDLIB/
 for f in *; do
  if test "$f" != 'oracle'
  then
  if test "$f" != 'sql'
  then
   echo '#!/bin/bash
 . ~/bin/dbenv
 $ORACLE_HOME/bin/'"$f"' "$@"'>~/LDLIB/$f
   fi
  fi
 done
 chmod 755  ~/LDLIB/*
 rm ~/LDLIB/oraenv
 rm ~/LDLIB/coraenv
fi
