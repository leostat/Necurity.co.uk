---
layout: post
title: Connection Refeused with Hydra against TLS
category: netsec
date: 2015-03-24
tags: Tools
summary:
 Just a super quick one today. During a test I noticed some strange behaviour with the standard Hydra which ships with Kali (Version 8.1) when scanning sites with no SSLv3 support.
---

<div id="pagesummary">
<h2 id="Summary"> <a>Summary </a> </h2>
<p>
{{page.summary}}
</p>
<p>
So if you see something along the lines of this
{% highlight bash %}
root@kali:~# hydra -s 443 -S -l admin -p adminpass necurity.co.uk  https-post-form  "/php/a:user=^USER^&pass=^PASS^:DENIED"
[VERBOSE] Could not create an SSL session: error:14077410:SSL routines:SSL23_GET_SERVER_HELLO:sslv3 alert handshake failure
1 of 1 target completed, 0 valid passwords found
Hydra (http://www.thc.org/thc-hydra) finished at 2015-03-24 21:52:57
{% endhighlight %}

Then grab the latest version from git and enjoy breaking in once more

{% highlight bash %}
root@kali:~/git# git clone git@github.com:vanhauser-thc/thc-hydra.git
root@kali:~/git# cd thc-hydra/
root@kali:~/git/thc-hydra# ./configure 

root@kali:~/git/thc-hydra# ./hydra -s 443 -S -l admin -p adminpass necurity.co.uk  https-post-form  "/php/a:user=^USER^&pass=^PASS^:DENIED"
[443][http-post-form] host: necurity.co.uk   login: admin   password: adminpass
1 of 1 target successfully completed, 1 valid password found
Hydra (http://www.thc.org/thc-hydra) finished at 2015-03-24 21:57:29
{% endhighlight %}
</p>

<p>
So why is this? Its because by default hydra used to just use a SSLv3 hello no matter what as thats what everyone supported, but since SSLv3 has been depreciated and has found itself in the sights of PCI you will find more and more sites turning SSLv3 off. You may encounter this in other tools as well, most of the time they just need rebuilding or a extra flag adding. As a side bug once you try and fail to use sslv3 on one of these servers Hydra will skitz out and start flooding the target with requests, OOPS!
</p>
</div>