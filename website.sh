#!/bin/sh
dropbox start;
dropbox status

cd /home/alex/Dropbox/2\ Websites/Website_Backups/Alex/

for i in `cat _in_progress`;do if [ ! -f $i ]; then echo "Well done on Post :)"; sed -ie "s@$i@@" _in_progress; fi; done; cat _in_progress
sed -ie '/^$/d' _in_progress 

echo "#######"
echo "# Current Drafts"
cat _in_progress
echo "#########"

echo 
ls
