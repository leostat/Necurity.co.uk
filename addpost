#!/bin/sh
###
# Add Post Script - As im lazy!
# Author : Alexander Innes
# This is made to support multiblog sites only, want the same for single blog sites? Ask :-)
###
while true; do
echo "What blog?"
read blog
if [[ ! -d $blog ]]; then
  echo "Blog not found - Make sure the folder exists"
  else
  break
  fi
done

while true; do 
echo "enter title"
read title
if [[ $title == "" ]]; then
   echo "Please enter a title"
   else
   break
   fi
done 

#Ahem no spaces on the web please
sane=`echo "$title" | sed s/" "/"_"/g`

post=`date +%Y-%m-%d`-$sane.md

if [ -f ./$blog/_drafts/$post ]
  then
    echo "Abort Abort : File Exists"
    exit 1
fi


if [ -f ./$blog/_posts/$post ]
  then
    echo "Abort Abort : File Exists"
    exit 1
fi

if [ "${#post}" -gt 35 ] 
   then
   echo "Thats a bit long want to change the path? if not enter the same again"
   read post
fi

#Ahem no spaces on the web please
sane=`echo "$post" | sed s/" "/"_"/g`
post=`date +%Y-%m-%d`-$sane.md

echo "Making post $post in blog $blog"
echo "Sure you want to? (y to continue)"
read choice
if [[ "$choice" != 'y' ]]; then 
   echo "Abort Abort : User Decline";
   exit 1
   fi

touch $blog/_drafts/$post
cat <<EOF >> $blog/_drafts/$post 
---
layout: post
title: $title
category: $blog
date: `date +%Y-%m-%d`
EOF

if [[ "$blog" == 'personal' ]]; then
sed -i s/'layout: post'/'layout: perspost'/g $blog/_drafts/$post
fi

echo "Enter any tags below space sepperated  (Leave blank for no comments)"
read tags
if [[ "$tags" != '' ]]; then
   cat <<EOF >>  $blog/_drafts/$post
tags: $tags
EOF
fi

echo "Please enter a summary for this post (Leave blank for no summary)"
read summary
cat <<EOF >>  $blog/_drafts/$post
summary:
 $summary
EOF


echo "Do you want to live this new post? (y)"
read live
if [ "$live" == 'y' ]; then
   echo "Post will be live"
   else # drop it into the drafts
   touch _in_progress
   echo "./$blog/_drafts/$post" >> ./_in_progress
   cat <<EOF >>  $blog/_drafts/$post
published: false
draft:true
EOF
   fi

cat <<EOF >>  $blog/_drafts/$post
---

EOF

cat <<EOF>> $blog/_drafts/$post
<div id="pagemenu">
<ol>
<li><a href="#Summary">Summary</a></li>
<li><a href="#"></a> </li>
<li><a href="#"></a></li>
<li><a href="#"></a></li>
<li><a href="#"></a></li>
<li><a href="#"></a> </li>
<li><a href="#"></a> </li>
</ol>
</div>

<div id="pagesummary">
<h2 id="Summary"> <a>Summary </a> </h2>
<p>
{{page.summary}}
</p>
<p>
<!-- Continue the page summary-->
</p>
</div>
<div id="maincontent">
<h2 id=""> <a>   </a> </h2>
<p>
</p>
</div>
EOF

echo "Awsome - Opening for editing in 2"
sleep 2
vim ./$blog/_drafts/$post +

if [ "$live" == 'y' ]; then
   mv ./$blog/_drafts/$post ./$blog/_posts/$post
   fi

echo "doneded - finish up the post!"
