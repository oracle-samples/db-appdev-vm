Oracle Developer Day VM Builder
===============================

Welcome to the packer build for the Oracle Developer Day vm.  
This will build a Oracle Linux server and install a 18.3 Oracle database on the machine.  Follow the download instructions to download the software to install and follow the build instructions to build the machine.  You will need around 30gb of space free to store the downloads and run the build.

There are several directories which are used in the build

1. put_files_here - place ALL downloaded software here
2. output - The resultant VirtualBox OVA will be placed here
3. upload - This directory has all the install scripts for the downloaded software.  

Mandatory Downloads
-------------------
**These two downloads are mandatory**.  If they are not here, the build will not start.

* OracleLinux-R7-U3-Server-x86_64-dvd.iso (needs to be this exactly md5 checked)
* LINUX.X64_180000_db_home.zip (183 has been verified - silent install may be incompatible with later versions)

Optional Downloads
--------------
If these files are available in the **put_files_here** directory, the build will try and install them.  

* jdk-8u\*-linux-x64.tar.gz - **Oracle JDK**
* sqldeveloper-\*-no-jre.zip - **Oracle SQL Developer**
* datamodeler-\*-no-jre.zip **Oracle SQLDeveloper Data Modeler**
* sqlcl-\*.zip - **Oracle SQLcl**
* apex\_\*.zip - **Oracle Application Express** 
* ords\*.zip - **Oracle REST Data Services** 
 
Oracle Internal Files
---------------------
These files may not be available publicly

* demos.zip - **Oracle Hands on Labs demos**
* reset_xmldbjson ** Reset XMLdb demos**
* master.zip - **Oracle Sample Schema**
* mozillablob.zip - **firefox .mozilla for (json viewer) plugins and or bookmarks**
* storm.zip - **exp dump of non sensative material. For geo location optional demo.**

Build Instructions
------------------

>**bash start.sh "http://and_proxy_as_first_arg_if_wanted" export**

NOTE Proxy value will be in the logs from bash set -x stored in ~oracle/log 
If you are inside a VPN, the proxy settings allow the VM to contact yum
update servers. optional export to export the ova.

![packer build](images/packerbuild.png)

Build Structure
--------------------

1. 1updateLinux.sh PROGRESS: 1/4 1updateLinux.sh - first script run - from plain iso. Set up second drive. Yum Updates. Reboot
2. 2afterFirstReboot.sh  PROGRESS: 2/4 2afterFirstReboot.sh - after first reboot - before any oracle database software installed. install virtual box guest additions.
3. 3topLevel.sh PROGRESS: 3/4 3topLevel.sh - main kick off script e.g. yum and call subscripts
4. 3_1installDbtoolClientTools.sh PROGRESS: 3_1/4 3_1installDbtoolClientTools.sh - install dbtools client tools
5. 3_2installDatabase.sh PROGRESS: 3_2/4 3_2installDatabase.sh - install the database with silent install
6. 3_3passwordDoNotExpire.sh PROGRESS: 3_3/4 3_3passwordDoNotExpire.sh - Database post install updates - e.g. passwords do not expire.
7. 3_4enableGeoRaster.sh PROGRESS: 3_4/4 3_4enableGeoRaster.sh - post database install and patches (if required)
8. 3_5unzipLabDemos.sh PROGRESS: 3_5/4 3_5unzipLabDemos.sh - demos (labs)
9. 3_6apexInstall.sh PROGRESS: 3_6/4 3_6apexInstall.sh - apex install
10. 3_7ORDSInstall.sh PROGRESS: 3_7/4 3_7ORDSInstall.sh - ords install
11. 3_8setupDemos.sh PROGRESS: 3_8/4 3_8setupDemos.sh - set up demos and run reset scripts
12. PROGRESS: END OF SCRIPT: 4/4 for tracing information see local file log.zip

Timings:

Minimum (Oracle Linux + Oracle Database)  
Total time 60 mins (accounted for time + 7 mins rounding error / ignore <2 minute).  

boot,8  
yum update,14  
reboot ,3  
run database software install (not database build),3   
dbca (database build),7  
password and 32kvarchar2,6  
shrink (fill disk with 0 for easy compression),3  
1 x 3 minute reboot + shutdown + minor <1 minute stuff,10  

Maximum (Including all optional extras APEX/ORDS/((internal) demos)  
Total time 113.5 mins (Accounted for time + 10.5 mins rounding error / ignore <2 minute).  
boot,9  
yum update,14  
reboot,3  
run database software install (not database build),4  
dbca (database build),8  
password and 32kvarchar <should be same as minimum?>,18  
apex install ,16  
ords install ,4  
set up demos and run demo reset,18  
shrink (fill disk with 0 for easy compression),2  
1 x 3 minute reboot + shutdown + minor <1 minute stuff - this is too long,9  

Removing the shrink.sh if not exporting - fills disk with 0 for easy compression.  
Run shrink.sh over ssh if subsequently exporting to ova (brings ova file down 60% in size to under 8Gb)

## Contributing

This project is not accepting external contributions at this time. For bugs or enhancement requests, please file a GitHub issue unless it’s security related. When filing a bug remember that the better written the bug is, the more likely it is to be fixed. If you think you’ve found a security vulnerability, do not raise a GitHub issue and follow the instructions in our [security policy](./SECURITY.md).

## Security

Please consult the [security guide](./SECURITY.md) for our responsible security vulnerability disclosure process

## License

Copyright (c) 2017, 2023 Oracle and/or its affiliates.
