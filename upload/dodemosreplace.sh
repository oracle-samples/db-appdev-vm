if test -f ~oracle/.isXE
then
for f in ./Desktop/readme.txt ./Desktop/Soup_To_Nuts/RebuildScripts/readme.txt ./shrink.sh
do
cp "$f" "$f.OLD"
cat "$f" | sed 'sZORCLCDB/orclZFREE/FREEPDB1Zg' | sed 'sZ/u01/app/oracle/oradata/Z/opt/oracle/oradata/Zg'| sed 'sZorclcdbZfreeZg' | sed 'sZORCLCDBZFREEZg' > "$f"
done
fi
