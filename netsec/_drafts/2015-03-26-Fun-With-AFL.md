---
layout: post
title: Fun With American Fuzzy Lop - A quick tutorial
category: netsec
date: 2015-03-26
tags: Tools
summary:
 I have recently been playing with AFL by Lcamtuf, a high performance fuzzer that is exceedingly efficient at finding problems in code when you either have or dont have the source code.
published: false
draft:true
---

<div id="pagemenu">
<ol>
<li><a href="#Summary">Summary</a></li>
<li><a href="#Install"></a></li>
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
The most efficient way to use AFL is to recompile your target application using the modified version of GCC, this allows AFL to pick up on hangs and crashes. 
</p>
</div>
<div id="maincontent">
<h2 id="Install"> <a> Installing and linking your target </a></h2>
<p>
AFL is available pre-compiled on Arch, but anything else all you have to do is grab the source, this is easy enough so we grab it and compile.
{% highlight bash %}
wget http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz
tar -xvf 
wget http://lcamtuf.coredump.cx/afl/releases/af
cd afl*
make
# If you want to move the executables to your path you can also do make install
# make install; 
{% endhighlight %}
</p>
<p>
After this you need to chose something to fuzz. In this mini guide I chose LibreSSL as why not, I was curious on if AFL would be able to create a valid cert that validates in some "weird" way. So lets grab the source and compile it.
</p>
{% highlight bash %}
wget http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-2.1.6.tar.gz
tar -xvf libressl-2.1.6.tar.gz
cd libressl-2.1.6/
CC=~/afl/afl-1.57b/afl-gcc ./configure
make check
mkdir /root/testing
export DESTDIR=/root/testing/

{% endhighlight %}
</div>
