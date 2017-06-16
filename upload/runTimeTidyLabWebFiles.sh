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
# File: runTimeTidyLabWebFiles.sh
#
# Description:  minor update to labs web files 
#
#################################################################################


cd ~/Desktop
cp ODDHandsOnLabs.html ODDHandsOnLabs.html.x
chmod 755 ODDHandsOnLabs.html ODDHandsOnLabs.html.x
cat ODDHandsOnLabs.html.x | sed 'sZhref="style.css"Zhref="images/style.css"Zg'|sed 'sZsrc="lab.js"Zsrc="images/lab.js"Zg' > ODDHandsOnLabs.html
rm ODDHandsOnLabs.html.x
chmod 755 ODDHandsOnLabs.html
chmod 755 lab.js labs.json style.css
cp lab.js labs.json style.css images
cd images
cp lab.js lab.js.x
chmod 755 lab.js.x
cat lab.js.x | sed "sZ'labs.json'Z'images/labs.json'Zg" > lab.js
rm lab.js.x
chmod 755 lab.js labs.json style.css
cd ~/Desktop
chmod 755 lab.js labs.json style.css
rm  lab.js labs.json style.css
