#!/bin/sh
if [ -z "$1" ]
  then
    echo "I would supply a user personally"
    exit 1;
fi

ejekyll build
# If im blogging in 2100 .. well
#echo "Splitting files :- \n"
#for n in $(for i in {2013..2099}; do find . -wholename "./_site/$i/*index.html"; done); do x=`dirname $n`; sh -c "cd $x; csplit index.html /XOSXOSXOS/"; done
#Abox is a Hax for more than one blog it makes xx files
#echo "Splitting finnished \n"

echo "Prep for Archives"
for file in $(for i in {2013..2015}; do find . -wholename "./_site/$i/*"; done);
do
#   if [[ "$file" == *xx00* ]]
#      then
         newdir=`dirname $file`
	 dirdest="./archive/tech/"
	 stripdir=`echo $newdir|cut -d'/' -f3-`
         dirdest2="./netsec/"
         dirdest3="./linux/"
	 mv $file $newdir/index.html
	 mkdir -p "_site/$dirdest$stripdir"
         sh -c "cp $newdir/index.html _site/$dirdest$stripdir/index.html"
	 echo "sh -c\"cp $newdir/index.html _site/$dirdest$stripdir/index.html\""
	 sh -c "cp $newdir/index.html _site/$dirdest2$stripdir/index.html"
	 sh -c "cp $newdir/index.html _site/$dirdest3$stripdir/index.html"
#      fi

#   if [[ "$file" == *xx01* ]]
#      then
#         newdir=`dirname $file`
#         stripdir=`echo $newdir|cut -d'/' -f3-`
#        dirdest="./archive/pers/"
#         dirdest2="./personal/"
#         mv $file $newdir/index.html
#         mkdir -p "_site/$dirdest$stripdir"
#         sh -c "cp $newdir/index.html _site/$dirdest$stripdir/index.html"
#         echo "sh -c\"cp $newdir/index.html _site/$dirdest$stripdir/index.html\""
#	 sh -c "cp $newdir/index.html _site/$dirdest2$stripdir/index.html"
#	 sed -i /XOSXOSXOS/d _site/$dirdest2$stripdir/index.html
#         sed -i /XOSXOSXOS/d _site/$dirdest$stripdir/index.html
#      fi
done
echo "Finished Site Generation"
echo "Minififization begin"
#find _site  -name "*.html" -exec sed -i '/^\(\s*\)\/\//d' {} \;
#find _site  -name "*.html" -exec sed -i 's/^[ \t]*//g; s/[ \t]*$//g;' {} \;
#find _site  -name "*.html" -exec sed -i ':a;N;$!ba;s/\n/ /g' {} \;

#find _site  -name "*.css" -exec sed -i '/^\(\s*\)\/\//d' {} \;
#find _site  -name "*.css" -exec sed -i 's/^[ \t]*//g; s/[ \t]*$//g;' {} \;
#find _site  -name "*.css" -exec sed -i ':a;N;$!ba;s/\n/ /g' {} \;

echo "done"
echo ""

#scp -r _site/* .htaccess $1@149.255.102.118:/home/$1/www/public
rsync -avPz -e ssh _site/ $1@necurity.co.uk:/home/$1/www/public --size-only 
