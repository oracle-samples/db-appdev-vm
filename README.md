Oracle Developer Day VM Builder
===============================

Welcome to the packer build for the Oracle Database 23c Free Developer vm.  
This will build a Oracle Linux server and install a 23c Free Oracle database on the machine.  Follow the download instructions to download the software to install and follow the build instructions to build the machine.  You will need around 30gb of space free to store the downloads and run the build.

There are several directories which are used in the build

1. put_files_here - place ALL downloaded software here
2. output - The resultant VirtualBox OVA will be placed here
3. upload - This directory has all the install scripts for the downloaded software.  

Mandatory Downloads
-------------------
**These two downloads are mandatory**.  If they are not here, the build will not start.

* OracleLinux-R8-U7-x86_64-dvd.iso (needs to be this exactly md5 checked)
* oracle-database-free-23c-1.0-1.el8.x86_64.rpm - Sept 2023 beta - some hardcoding may change for production
* oracle-database-preinstall-23c-1.0-0.5.el8.x86_64.rpm - free initial download - some harcoding may change for production

Optional Downloads
--------------
If these files are available in the **put_files_here** directory, the build will try and install them.  

* jdk-11\*_linux-x64\*.tar.gz - **Oracle JDK**
* sqlcl-\*.zip - **Oracle SQLcl**
* apex_\*.zip - **Oracle Application Express**
* ords\*.zip - **Oracle REST Data Services** 
 
Oracle Internal Files
---------------------
These files may not be available publicly

* mozillablob.zip - **firefox .mozilla for  bookmarks/start URL** - https://artifacthub-phx.oci.oraclecorp.com/artifactory/dbtools-adhoc-artifact/oracle/dbtools/developerday/mozillaBlob.zip.23.3.0.1
* master.zip - **Oracle Sample Schema** old version - https://artifacthub-phx.oci.oraclecorp.com/artifactory/dbtools-adhoc-artifact/oracle/dbtools/developerday/master.zip

Build Instructions
------------------

>**bash start.sh "http://and_proxy_as_first_arg_if_wanted" export**

NOTE Proxy value will be in the logs from bash set -x stored in ~oracle/log 
If you are inside a VPN, the proxy settings allow the VM to contact yum
update servers. optional export to export the ova.

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

Maintenance/Updates
--------------------

* all hardcoding/rework files in upload
* Likely minor change to rpm files to production version names before release.
* Updating Database banner Copy to /home/oracle/Release.html and ~/Desktop/releasename.html TODO currently - 23 Production, is currently used in - 3_1installDbtoolClientTools_inner.sh - Oracle Database 23c Free - Production.html - runTimeEnforceMinScreenSize.sh - and as default page in mozillaBlob.zip - The default page is altersd in mozillaBlob.zip via .mozilla/-/user.js if the mozillablob.zip file is the same size as the oracle default
* Updating to non 23 rpm - hardcodng of rpm file name 3topLevel_inner.sh - hardcoding of 23 - recheck generated config filers
* Updating to ship home/zip database - considerable changes such as rsp files - and undoing some sed for PATH/TWO_TASK/ORACLE_HOME/SERVICE for FREE
* Updating java 11 no change
* Updating beyond java 11 to java 17 - minimal rework buildTimeMoveUserFilesInTmp.sh
* Updating apex and ords - installer options might change check devday_apexords.sh
* Updating master.zip demo schemas, hr and av schemas - master.zip/hr/av builders and helpers are from 2016. Considerable changes - db-sample-schemas are on - https://github.com/oracle-samples/db-sample-schemas
* Updating virtualbox no issues with using in future virtualbox if guest additions reinstalled - not sure about using virtualbox version below virtualbox version at build time.
* Updating major Oracle Linux version. Oracle Linux 7 to Oracle Linux 8 changes new buildTimeConfig.cfg - got a new one from elsewhere/expert in Oracle - trouble getting gnome-classic working i.e. icons on desktop - some trouble getting terminal/firefox working right - currently cat README to terminal and firefox may come up with 2 tabs.  
* User issue - screen display size/font too small may need to magnify 200 percent.
* features under consideration - turn ipv6 off better/right, single disk, set up mongodb listener in ords.
* There is a createnewpdb script which may be brittle if create pdb sql changes.

Peculiarities of build.

* packerConfig.json has all packer instructions of note CPU and RAM sizes and manually updated banner including included software versions.
* upload/buildTimeConfig.cfg is checked in - When I was doing a Linux bootstrap in packerConfig.json I hosted it: http://dbtools.oraclecorp.com/builds/vm122/nonvmbuild/buildTimeConfig.cfg - this will break the no proxy build - so http host locally and update URL in packerConfig.json.
* lots of logging but little or no exit on error.
* build fails 10% of the time as switch to 2 disks failed.

Timings:

Minimum (Oracle Linux + Oracle Database)  
Total time 60 mins.  

Maximum (Including all optional extras APEX/ORDS)  
Total time 113.5 mins.  

Removing the shrink.sh if not exporting - fills disk with 0 for easy compression.  
Run shrink.sh over ssh if subsequently exporting to ova (brings ova file down 60% in size to under 8Gb)
