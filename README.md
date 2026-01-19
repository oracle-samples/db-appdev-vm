Oracle Developer Day VM Builder
===============================

Welcome to the packer build for the Oracle AI Database 26ai Free Developer vm.  
This will build a Oracle Linux server and install a 26ai Free Oracle AI database on the machine.  Follow the download instructions to download the software to install and follow the build instructions to build the machine.  You will need around 30GB of space free to store the downloads and run the build.

There are several directories which are used in the build

1. put_files_here - place ALL downloaded software here
2. output - The resultant VirtualBox OVA will be placed here
3. upload - This directory has all the install scripts for the downloaded software.  

Mandatory Downloads
-------------------
**These two downloads are mandatory**.  If they are not here, the build will not start.

* OracleLinux-R8-U10-x86_64-dvd.iso (needs to be this exactly md5 checked)
* oracle-ai-database-free-26ai-23.26.0-1.el8.x86_64.rpm - available from https://www.oracle.com/database/technologies/free-downloads.html
* oracle-ai-database-preinstall-26ai-1.0-1.el8.x86_64.rpm - available from https://yum.oracle.com/repo/OracleLinux/OL8/appstream/x86_64/ 

Optional Downloads
--------------
If these files are available in the **put_files_here** directory, the build will try and install them.  

* jdk-21\*_linux-x64\*.tar.gz - **Oracle JDK**
* sqlcl-\*.zip - **Oracle SQLcl**
* apex_\*.zip - **Oracle Application Express**
* ords-\*.zip - **Oracle REST Data Services** 
 

Build Instructions
------------------

>**bash start.sh "http://and_proxy_as_first_arg_if_wanted" export**

NOTE: Proxy value will be in the logs from bash set -x stored in ~oracle/log 
If you are inside a VPN, the proxy settings allow the VM to contact yum
update servers. optional export to export the ova.

NOTE: The Oracle AI Database 26ai Free Developer vm has been created using VirtualBox 6. 

Build Structure
--------------------

1. 1updateLinux.sh PROGRESS: 1/4 1updateLinux.sh - first script run - from plain iso. Set up second drive. 
2. 2afterFirstReboot.sh PROGRESS: 2/4 2afterFirstReboot.sh  - after first reboot - before any oracle database software installed. (install virtual box guest additions). 
3. 3topLevel.sh PROGRESS: 3/4 3topLevel.sh - main kick off script i.e. yum and call subscripts. 
4. 3_1installDbtoolClientTools.sh PROGRESS: 3_1/4 3_1installDbtoolClientTools.sh - install dbtool client tools. 
5. Install database rpms happens here - log file - 3_0oracleinstall.log in log.zip.
6. 3_3passwordDoNotExpire.sh PROGRESS: 3_3/4 3_3passwordDoNotExpire.sh - minor helper - e.g. passwords do not expire. 
7. 3_7ORDSInstall PROGRESS: 3_7ORDSInstall - ORDS and APEX install. 
8. END OF SCRIPT PROGRESS: END OF SCRIPT: 4/4 for tracing information see local file log.zip.

Timings:

Minimum (Oracle Linux + Oracle AI Database)  
Total time ~60 mins.  

Maximum (Including all optional extras APEX/ORDS)  
Total time ~113.5 mins.  

Removing the shrink.sh if not exporting - fills disk with 0 for easy compression.  
Run shrink.sh over ssh if subsequently exporting to ova (brings ova file down 60% in size to under 8Gb)
