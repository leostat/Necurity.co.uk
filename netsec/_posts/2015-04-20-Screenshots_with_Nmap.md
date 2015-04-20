---
layout: post
title: Screenshots with Nmap
category: netsec
date: 2015-04-20
tags: Tools
summary: When scanning a large number of servers it is nice to have a screenshot handy for either quickly flicking through and identifying what's on the server (Page Titles dont always give a good representation of what can be found on the server!). 
published: true
---

<div id="pagemenu">
<ol>
<li><a href="#Summary">Summary</a></li>
<li><a href="#Install">Installing And using</a></li>
<li><a href="#Bugs">Bugs and Improvements</a></li>
</ol>
</div>

<div id="pagesummary">
<h2 id="Summary"> <a>Summary </a> </h2>
<p>
{{page.summary}}
</p>
<p>
There are a few tools that do this already such as Peeping Tom (Using Phantom JS). But me being me I wanted it to be included in the first nmap sweep of the range so i'm not having to run a second command (Yes im lazy, So?). This post / Script is based on <a href="https://www.trustwave.com/Resources/SpiderLabs-Blog/Using-Nmap-to-Screenshot-Web-Services/"> Spider Labs</a> nmap script that is available from <a href="https://github.com/SpiderLabs/Nmap-Tools"> GIT</a>. I liked the idea of this script but I had problems scanning HTTPS sites with it, websites that operated on non standard ports and also it fell over when faced with V-Hosts, Uh oh! Using there script as a base i have given it a bit of a make face lift to allow it to do these things, I need to open a Pull request for it after more testing! Without further ado here is <a href="https://raw.githubusercontent.com/leostat/Necurity.co.uk/master/scripts/http-screenshot.nse"> Http Screenshot V2</a>.
</p>
</div>
<div id="maincontent">
<h2 id="Install"> <a> Installing and Using </a> </h2>
<p>
Installing Nmap Plugins is quite simple, Before you can use this script though there are some external dependencies that need to be installed, this is because I use wkhtml to image to do the screen shots.
{% highlight bash %}
#We need to grab the package
# For Kali
wget http://downloads.sourceforge.net/wkhtmltopdf/wkhtmltox-0.12.2.1_linux-wheezy-amd64.deb
dkpg -i install wkhtmltox-0.12.2.1_linux-wheezy-amd64.deb

# For Centos 6
yum install -y http://downloads.sourceforge.net/wkhtmltopdf/wkhtmltox-0.12.2.1_linux-centos6-amd64.rpm
{% endhighlight %}

Now we grab the script, drop it to the nmap plugins directory, then update the DB. 
{% highlight bash %}
wget -O /usr/share/nmap/scripts/http-screenshot.nse https://raw.githubusercontent.com/leostat/Necurity.co.uk/master/scripts/http-screenshot.nse 
nmap --script-updatedb
{% endhighlight %}
</p>

<p>
Once we have done this we can start scanning all the websites! (okay maybe not all the websites). As the script is not included in the default set it needs specifying in the nmap command.
{% highlight bash %}
cat > scope << EOF
necurity.co.uk
lg.lc
149.255.102.118
192.168.0.1
EOF
nmap -n -iL scope -oA scan1 -v -sC --script=http-screenshot
Nmap scan report for necurity.co.uk (149.255.102.118)
Host is up (0.029s latency).
Not shown: 990 filtered ports
PORT     STATE  SERVICE
80/tcp   open   http
| http-screenshot:
|_  Saved to screenshot-nmap-necurity.co.uk.80.png
443/tcp  open   https
| http-screenshot:
|_  Saved to screenshot-nmap-necurity.co.uk.443.png

Nmap scan report for 192.168.0.1
Host is up (0.0016s latency).
Not shown: 998 filtered ports
PORT   STATE SERVICE
80/tcp open  http
| http-screenshot:
|   Fail :( (Is wkhtmltoimage-i386 in path | Is the service not detecting SSL?)
|_     * I tried do do this : wkhtmltoimage -n http://192.168.0.1:80 screenshot-nmap-192.168.0.1.80.png 2> /dev/null   >/dev/null

Nmap scan report for lg.lc (149.255.102.118)
Host is up (0.035s latency).
Not shown: 990 filtered ports
PORT     STATE  SERVICE
80/tcp   open   http
| http-screenshot:
|_  Saved to screenshot-nmap-lg.lc.80.png
443/tcp  open   https
| http-screenshot:
|_  Saved to screenshot-nmap-lg.lc.443.png

Nmap scan report for 149.255.102.118
Host is up (0.041s latency).
PORT     STATE  SERVICE
80/tcp   open   http
| http-screenshot:
|_  Saved to screenshot-nmap-149.255.102.118.80.png
443/tcp  open   https
| http-screenshot:
|_  Saved to screenshot-nmap-149.255.102.118.443.png

{% endhighlight %}
A couple of quick comments about the nmap command, I always scan from a file using iL (input list) as its great to have a track of what I have looked into, and I always output all three types as I usually need to do some post processing on the results to feed them into other tools. Also note the inclusion of the IP address along side the hostnames, hosts can act different when accessed through the IP address rather than the hostname so its always worth a check. 

Once the scan finishes we will (hopefully) have a few PNG's to look through to see what the landscape is like. To quickly browse through them you could add a simple HTML page to the directory as below. You can also see one of the bugs, where above Wkhtml says fail, but its actually worked.
{% highlight bash %}
root@kali:~# ls
scan1.gnmap  scope                                    screenshot-nmap-192.168.0.1.80.png  screenshot-nmap-necurity.co.uk.443.png
scan1.nmap   screenshot-nmap-149.255.102.118.443.png  screenshot-nmap-lg.lc.443.png       screenshot-nmap-necurity.co.uk.80.png
scan1.xml    screenshot-nmap-149.255.102.118.80.png   screenshot-nmap-lg.lc.80.png

# Yoink from spider labs again, for if you want previews
#!/bin/bash
printf "<HTML><BODY><BR>" > preview.html
ls -1 *.png | awk -F : '{ print $1":"$2"\n<BR><IMG SRC=\""$1"%3A"$2"\" width=400><BR><BR>"}' >> preview.html
printf "</BODY></HTML>" >> preview.html
{% endhighlight %}

Using the data you have gathered you can start then looking at whatever caught your eye. Easy right? Again thanks to spider labs for the original code!

</p>

<h2 id="Bugs"> <a> Bugs and Improvements </a> </h2>
<p>
My code never has bugs, honest <!-- Lies, Ive caused so many bugs it would make your eyes bleed, so dont go looking ;) -->, so here is a list of quirks and a list of things I may or May Not get around to doing to improve the script. If you notice a way to improve the script feel free to berate me into fixing it or fork it and let me know so I can point to you! 
<p> Known Quirks</p>
<ul>
<li> Sometimes SSL detection Fails, My lua probabley</li>
<li> It Whktml to image's response codes are not the best. Need to work around this.</li>
<li> Troll command injection? </li>
</ul>
<p> The TODO List</p>
<ul>
<li> Fix the bugs </li>
<li> Maybe add a outdir flag? </li>
<li> Better Fail handling </li>
<li> Add verbosity support </li>
<li> Make it make a preview page? </li>
</ul>
</p>
</div>
