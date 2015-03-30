---
layout: post
title: Fun With American Fuzzy Lop - A quick tutorial
category: netsec
date: 2015-03-30
tags: Tools
summary: I have recently been playing with AFL by Lcamtuf, a high performance fuzzer that is exceedingly efficient at finding problems in code when you either have or dont have the source code.
published: true
---

<div id="pagemenu">
<ol>
<li><a href="#Summary">Summary</a></li>
<li><a href="#Install">Installing and linking your target</a></li>
<li><a href="#Crashing">Making Test Cases and Fuzzing </a></li>
<li><a href="#Exploring">Exploring Crashes</a></li>
<li><a href="#Reading">Further Reading</a></li>
</ol>
</div>

<div id="pagesummary">
<h2 id="Summary"> <a>Summary </a> </h2>
<p>
{{page.summary}}
</p>
<p>
The most efficient way to use AFL is to recompile your target application using the modified version of GCC, this allows AFL to pick up on hangs and crashes. I wanted to write a little piece on using the fuzzer from installing, choosing test cases, finding a crash in a application to following it through to see if we can do anything "Evil" with it. I chose to have a look at LibreSSL as the codebase is huge and it has multiple places where complex user input is used. AFL has been used to fuz many many projects already, so dont be surprised if you find a crash it may have already been reported! To fuzz a project you need test cases, in this post the test cases will be a Public Certificate, a Certificate Signing Request and a Private Key. 
</p>
</div>
<div id="maincontent">
<h2 id="Install"> <a> Installing and linking your target </a></h2>
<p>
AFL is available pre-compiled on Arch, but anything else all you have to do is grab the source, this is easy enough so we grab it and compile.
{% highlight bash %}
wget http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz
tar -xvf afl-latest.tgz
cd afl*
make
# If you want to move the executables to your path you can also do make install
# make install; 
{% endhighlight %}
</p>
<p>
After this you need to chose something to fuzz. In this mini guide I chose LibreSSL as why not, I was curious on if AFL would be able to create a valid cert that validates in some "weird" way, it also gives lots of mangled SSL certs to throw at Internet Explorer. So lets grab the source and compile it. When installing we change the install DIR as we don't want the rebuilt package effecting the local systems OpenSSL.
</p>
<p>
{% highlight bash %}
wget http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-2.1.6.tar.gz
tar -xvf libressl-2.1.6.tar.gz
cd libressl-2.1.6/
CC=~/afl/afl-1.57b/afl-gcc ./configure
make check
mkdir /root/testing
export DESTDIR=/root/testing/
make install
{% endhighlight %}	
</p>
<h2 id="Crashing"> <a> Making Test Cases and Fuzzing </a></h2>
<p>
Now you have it compiled you need to create some test cases to run against LibreSSL. Here we create a Public certificate, Private Key, and Certificate request, and as by suggestion of the <a href="http://lcamtuf.coredump.cx/afl/README.txt"> Readme</a> we keep the size of them to a minimum. After generating these we feed them into afl and see what it finds. We move each of the user generated files into a in folder for afl to process, and also create a out folder for afl to place its findings. The -- specifies bash to stop processing command flags and the @@ is afl's placeholder where it inserts the test cases. If all goes well AFL will spin up and start churning out other test cases to run through. Before we are able to start AFL we need to export the LD_LIBRARY_PATH environment variable so that LibreSSL uses the compiled library rather than the system ones
</p>
<p>
{% highlight bash %}
export LD_LIBRARY_PATH="/root/testing/usr/local/lib"
/root/testing/usr/local/bin/openssl req -x509 -nodes -days 365 -newkey rsa:512 -keyout privateKey.key -out certificate.crt -out CSR.csr
screen
mkdir incrt inkey incsr outcrt outkey outcsr
~/afl/afl-1.57b/afl-fuzz -i inkey -o outkey -- /root/testing/usr/local/bin/openssl x509 -in @@ -text -noout
~/afl/afl-1.57b/afl-fuzz -i incsr -o outcsr -- /root/testing/usr/local/bin/openssl x509 -in @@ -text -noout
~/afl/afl-1.57b/afl-fuzz -i incrt -o outcrt -- /root/testing/usr/local/bin/openssl x509 -in @@ -text -noout
{% endhighlight %}
</p>

<p> Then after a while your hoping for some crashes, the files will be stored in the out directory we specified before.  </p>
<h2 id="Exploring"> <a> Exploring Crashes </a></h2>

{% highlight bash %}
~/afl/afl-1.57b/afl-fuzz -i incrash -o outcrash -- /root/testing/usr/local/bin/openssl x509 -in @@ -text -noout
                       american fuzzy lop 1.57b (openssl)

┌─ process timing ─────────────────────────────────────┬─ overall results ─────┐
│        run time : 3 days, 1 hrs, 27 min, 38 sec      │  cycles done : 0      │
│   last new path : 0 days, 0 hrs, 15 min, 11 sec      │  total paths : 1830   │
│ last uniq crash : 0 days, 0 hrs, 18 min, 41 sec      │ uniq crashes : 108    │
│  last uniq hang : 0 days, 3 hrs, 54 min, 39 sec      │   uniq hangs : 18     │
├─ cycle progress ────────────────────┬─ map coverage ─┴───────────────────────┤
│  now processing : 1708 (93.33%)     │    map density : 5453 (8.32%)          │
│ paths timed out : 0 (0.00%)         │ count coverage : 3.07 bits/tuple       │
├─ stage progress ────────────────────┼─ findings in depth ────────────────────┤
│  now trying : bitflip 1/1           │ favored paths : 318 (17.38%)           │
│ stage execs : 854/4176 (20.45%)     │  new edges on : 511 (27.92%)           │
│ total execs : 40.1M                 │ total crashes : 71.0k (108 unique)     │
│  exec speed : 138.9/sec             │   total hangs : 249 (18 unique)        │
├─ fuzzing strategy yields ───────────┴───────────────┬─ path geometry ────────┤
│   bit flips : 714/1.41M, 100/1.41M, 100/1.41M       │    levels : 6          │
│  byte flips : 2/175k, 8/170k, 4/172k                │   pending : 1424       │
│ arithmetics : 312/9.30M, 2/247k, 0/14.1k            │  pend fav : 41         │
│  known ints : 14/1.08M, 2/6.31M, 10/8.60M           │ own finds : 1829       │
│  dictionary : 0/0, 0/0, 174/4.97M                   │  imported : n/a        │
│       havoc : 439/4.70M, 0/0                        │  variable : 1023       │
│        trim : 12.33%/86.6k, 3.65%                   ├────────────────────────┘
└─────────────────────────────────────────────────────┘             [cpu: 76%]

[root@fw ~]# ls /root/testing/usr/local/outkey/crashes/
id:000000,sig:11,src:000000,op:flip1,pos:32           id:000028,sig:11,src:000065,op:flip1,pos:59            id:000056,sig:11,src:000748,op:flip2,pos:82            id:000084,sig:11,src:001255,op:flip1,pos:57
id:000001,sig:11,src:000000,op:flip1,pos:58           id:000029,sig:11,src:000065,op:flip1,pos:59            id:000057,sig:11,src:000748,op:flip2,pos:470           id:000085,sig:11,src:001255,op:flip1,pos:61

{% endhighlight %}

<p>
After we have a crash we need to generate other test cases around this crash, this allows us to see if we have any control over registers. (Really at this point we should chuck it through GDB to see what the crash is but i'm skipping this till later). It just happens that most of these are all the same crash after analysis so copy any across on to the folder then to start the fuzzing we pass the -C flag on afl. What this does is keep the program in a crashing state while creating other test cases with cause a similar crash. We create new folders and start the fuzzing again. 
</p>

<p>
{% highlight bash %}
                      peruvian were-rabbit 1.57b (openssl)

┌─ process timing ─────────────────────────────────────┬─ overall results ─────┐
│        run time : 2 days, 2 hrs, 20 min, 10 sec      │  cycles done : 0      │
│   last new path : 0 days, 0 hrs, 4 min, 13 sec       │  total paths : 564    │
│ last uniq crash : 0 days, 1 hrs, 35 min, 0 sec       │ uniq crashes : 235    │
│  last uniq hang : 0 days, 20 hrs, 50 min, 36 sec     │   uniq hangs : 5      │
├─ cycle progress ────────────────────┬─ map coverage ─┴───────────────────────┤
│  now processing : 559 (99.11%)      │    map density : 2190 (3.34%)          │
│ paths timed out : 0 (0.00%)         │ count coverage : 1.63 bits/tuple       │
├─ stage progress ────────────────────┼─ findings in depth ────────────────────┤
│  now trying : havoc                 │ favored paths : 145 (25.71%)           │
│ stage execs : 16.0k/30.0k (53.21%)  │  new edges on : 228 (40.43%)           │
│ total execs : 28.1M                 │   new crashes : 7.59M (235 unique)     │
│  exec speed : 155.4/sec             │   total hangs : 373 (5 unique)         │
├─ fuzzing strategy yields ───────────┴───────────────┬─ path geometry ────────┤
│   bit flips : 169/938k, 41/938k, 41/938k            │    levels : 15         │
│  byte flips : 0/117k, 11/114k, 19/115k              │   pending : 300        │
│ arithmetics : 94/6.19M, 0/178k, 0/3083              │  pend fav : 5          │
│  known ints : 20/715k, 7/4.22M, 18/5.79M            │ own finds : 563        │
│  dictionary : 0/0, 0/0, 53/897k                     │  imported : n/a        │
│       havoc : 318/6.87M, 0/0                        │  variable : 0          │
│        trim : 2.49%/56.1k, 3.84%                    ├────────────────────────┘
└─────────────────────────────────────────────────────┘             [cpu: 78%]

{% endhighlight %}
</p>

<p>
Once we have left it generating test cases for a while we can chuck them through GDB to get more information about the crash. 
</p>
{% highlight bash %}
export LD_LIBRARY_PATH="./lib"
gdb ./bin/openssl
(gdb) set args rsa -in "./crashout/crashes/id:000049,sig:11,src:000000,op:havoc,rep:2" -check
(gdb) r
Starting program: /root/testing/usr/local/bin/openssl rsa -in "./crashout/crashes/id:000049,sig:11,src:000000,op:havoc,rep:2" -check
Missing separate debuginfos, use: debuginfo-install glibc-2.20-8.fc21.x86_64

Program received signal SIGSEGV, Segmentation fault.
0x00007ffff74b4117 in pkey_cb (operation=2, pval=0x7fffffffd938, it=<optimized out>, exarg=0x0) at asn1/p8_pkey.c:71
71                      if (key->pkey->value.octet_string)
(gdb) i r
rax            0x74a8c0 7645376
rbx            0x7ffff7ab4e40   140737348587072
rcx            0x0      0
rdx            0x0      0
rsi            0x7fffffffd938   140737488345400
rdi            0x2      2
rbp            0x7fffffffd938   0x7fffffffd938
rsp            0x7fffffffd838   0x7fffffffd838
r8             0x74a610 7644688
r9             0xfffffffffffffffc       -4
r10            0x748bb0 7637936
r11            0xd000000        218103808
r12            0x7ffff74b4050   140737342292048
r13            0x2      2
r14            0x2      2
r15            0x7ffff7ac6410   140737348658192
rip            0x7ffff74b4117   0x7ffff74b4117 <pkey_cb+199>
eflags         0x10246  [ PF ZF IF RF ]
cs             0x33     51
ss             0x2b     43
ds             0x0      0
es             0x0      0
fs             0x0      0
gs             0x0      0
{% endhighlight %}

<p> After throwing a few test cases through GDB we can see that we dont have control over any registers (Boo) so there isnt much evil to be done here. Still crashes are worth reporting. In this case the bug had already been reported <a href="">Here</a>, Oh well! Also if we look at the function that is being called, all that is happening is explicit BZero, nothing interesting even if we go through the if statement.</p>


<p>
As a little amusing side fact I found another blog with a similar piece and very similar title while writing this one, I guess great minds  <a href="http://0x90909090.blogspot.co.uk/2015/01/lets-have-some-fun-with-afl.html"> think alike</a>. 
</p>
<h2 id="Reading"> <a> Further Reading </a></h2>
<p> 
If youd like to know more about afl its worth checking the <a href="http://lcamtuf.coredump.cx/afl/"> AFL Homepage</a>. There is also a pretty active <a href="https://groups.google.com/forum/#!forum/afl-users"> Google Group </a> where you can ask any questions or just follow it to keep upto date with whats going on with the project. AFL has the ability to fuz programs where the source is unavialable using either Qemu mode or the new Afl-dyninst. I may do a bit arounf these next! I wonder if it could fuzz Internet Explorer?
</p>
</div>
