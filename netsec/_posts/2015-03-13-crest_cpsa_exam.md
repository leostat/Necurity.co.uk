
---
layout: post
title: Studying for and taking the CREST CPSA Exam
category: netsec
date: 2015-03-13
tags: CREST Exams
summary: I Have recently studied for and passed the CREST CPSA Exam, I though I would share some thoughts and my Pre-Exam revision Notes to help other people thinking of taking this new exam from crest as when looked I could not find much about it!
published: true	
---

<div id="pagemenu">
<ol>
<li><a href="#Summary">Summary</a></li>
<li><a href="#whatsit"> What is the CPSA Exam? </a> </li>
<li><a href="#tech"> A Look at the technical Syllabus</a> </li>
<li><a href="#tips"> Generic exam tips and tricks </a></li>
<li><a href="#reading"> Further Reading | Other Resources |Revision notes</a> </li>

</ol>
</div>

<div id="pagesummary">
<h2 id="Summary"> <a>Summary </a> </h2>
<p>
{{page.summary}}
</p>
<p>
First things first though is I would like to highlight that the CPSA exam is under both the <a href="http://www.crest-approved.org/wp-content/uploads/1401-Code-of-Conduct-Individual-v4.0.pdf"> Code of Ethics </a>, and has a NDA over it. This post is NOT about the actual content of the exam. It is merely my experience with the examination process, and the Technical syllabus. A copy of the notes for candidates covering the exam type, question examples and such is available from <a href="http://www.crest-approved.org/wp-content/uploads/crest-notes-for-candidates-CPSA.pdf"> here </a> and the technical syllabus is available <a href="http://www.crest-approved.org/wp-content/uploads/Technical_Syllabus-CREST_Practitioner-v1-1.pdf"> here</a>. Please check the <a href="http://www.crest-approved.org/professional-examinations/practitioner-security-analyst/index.html"> CPSA Page </a> on the crest website for the most upto date version of the notes for candidates and the Technical Syllabus. If anything on this page is deemed against the Code of Ethics or the Non Disclosure agreement or section 1.2 of the notes for candidates then please contact me and so we can discuss what needs removing. As of the 03rd of April no content has been removed.
</p>

<p>
A quick TL;DR for this is that personally I found the exam syllabus interesting and a good intro into the CREST way of doing exams. The hard part of this exam for me was the time management for the 240 questions in the time allocated!. I found it less focused on Exploiting, more focused on Finding.
</p>
</div>

<div id="maincontent">
<h2 id="whatsit"> <a> What is the CPSA Exam?  </a> </h2>
<p>
So what is the CPSA And who should take it? The Crest Certified practitioner security analyst is the minimum required exam for being a crest team member. It sits beneath the CRT exam and looks at your core concepts of Information Security, Networking and System Administration. Focused less around further exploitation and more around being able to locate some pretty basic common security issues such as SQL injection. If you have any background in Info Sec (such as a degree, previous work experience, or just a working interest) you shouldn't find the exam too hard to get through. Its aimed at people starting in the infosec industry, so if you have already been working as a tester for a while you may want to skip straight to the CRT exam. 
</p>


<h2 id="tech"> <a> A Look at the Technical Syllabus  </a> </h2>
<p>
Crest exams give you the required information different from some of the other ones out there, rather than giving you a set resource list and reference material they give you a syllabus to follow and that's about it. The syllabus has 6 sections for the CPSA as quickly outlined below. Theres quite a lot of cross over between this, CISSP, OSCP and CCNA so if you have done any of those before then you will find this quite easy.
</p>

<table>
<tr>
<td>
Core Networking
</td>

<td>
This section covers your basic networking and network services, Do you know your IP address from your MAC address, how routing and networking works, Which IP address are non routable? You should be familiar with this section if you have worked with networks before and you should be relatively OK here. RTFM has a nice network lookup table, and ipcalc is your friend for getting a broadcast and network address.
</td>
</tr>

<tr>
<td>
Security Architecture and Design
</td>

<td>
Covering some of the more common topics around security. Firewalls, Encryption and Architecture should be second nature for any tester. You also need to be familiar with problems with BYOD and you also need to be aware of the Laws of England and how they impact your job as a tester. 
</td>
</tr>

<tr>
<td>
Windows systems
</td>

<td>
The most common operating system you will encounter everyday, knowing which version of windows server shipped with what version of IIS and kernel can be useful from time to time when nmap or nessus cant make up its mind what OS your target is, and knowing what OS windows no longer supports is also good to know. Knowing how windows works, How and what the different functions of AD do and what the most common weaknesses you will encounter are. Also knowing how to harden and fix the problems you find is good to know. Knowing what SID's and RID's are, knowing how file permissions and ACL's work, and knowing about the SMB/CIFS protocol is also a must, and whats a Null session in this context?. Do you know what the difference between LM and NTLM is? And where does kerberos fit into windows authentication?
</td>
</tr>

<tr>
<td>
Unix Systems
</td>

<td>
Although they usually number less in work environment you can do much much more with a Linux server. Being familiar with both RPM based and DEB based systems is a must. Again knowing how UID's and GID's are used, how file percussions work and are controlled ( do you know your chmod from chown). Knowing about NFS, X and GUID and SUID bits are, difference between SSH and Rlogin and Telnet, and all the problems among with all the problems with these services. If you have ever managed Linux servers you should be good to go with this section. 
</td>
</tr>

<tr>
<td>
Penetration testing
</td>

<td>
The more fun topic for most people. This is at a basic level though and is more aimed at do you know the most common web-app problems, when you see id= what do you instantly think? Do you know the characters that commonly trigger XSS, Sql Injection and command injection?. Do you know how to sweep systesm with nmap, query information from database servers, brute force both http simple and http form authentication, brute SNMP and get information from it. How can you find content on web servers, and how do you get valid users from NFS, DB's, SMTP ,Windows, and finger services?  
</td>
</tr>

<tr>
<td>
Incident response and analysis
</td>

<td>
Dont let the title fool you, this is about reading logs, PCAPS and knowing how to use strings and hexdump. Can you read the reports from Linux and Windows and can you understand what the reports are telling you?
</td>
</tr>

</table>

<p>
It can look a bit daunting if you don't recognise everything on there, but it doesn't take that long to read up on everything. Around a month would be plenty of time to get comfortable with it, depending on how long you spend reading and how much you already know of course. Don't get bogged down in knowing everything around every topic either, remember this is a higher level exam then the CRT, for example you need to know how to find a SQL injection, how to use it, and what maybe a tool you could use to exploit it further, and on the windows side you may need to know what the different versions of IIS Microsoft launched along with what platforms along with the major security changes, but not all the nitty gritty details about how IIS works.
</p>

<h2 id="tips"> <a> Generic Exam Tips and Tricks  </a> </h2>
<p>
CPSA is a open book exam, don't be afraid to take in your condensed revision notes or a book or two. Although its open book time is very tight so you wont want to be having to look through pages and pages of notes and a few books so only take in things that you will need! Going into the exam make sure that your laptop is set up how you use it every day. The laptop gets wiped at the end of the exam (make sure you can take the drive out!) so it may be tempting to just stick something like Kali or the fedora security spin on there and be done with it, but keep in mind that this may not have all the tools on or set up and ready to use (why did they take finger and r login out by default!).</p>

<p> The CPSA page suggests some of the books to read before the exam, and there is one on their list I like to keep around for quick reference and that is the Red Team Field Manual <a href="http://www.amazon.co.uk/Rtfm-Red-Team-Field-Manual/dp/1494295504">RTFM</a>), over time working as a tester you will probably write your own version of this anyway, but its a great starting point covering some common tools, networking, generic Windows / Linux "stuff", and a couple of common old CVE's that you may still see on engagements. </p>

<p>Keep an eye on your time in the exam, Crest recommend up to a hour on the questions then the rest of the time on the practical exercise, how you use your time is up to you but keep in mind the practical is over double the size of the questions as its not just recall of which answer is correct. Dont spend too long on questions, if you dont know an answer mark it with a star, colour, flag or whatever and come back to it on your second pass of the paper, if you still dont know it is take a educated guess, there is no negative marking so apply your brain and pick what looks right. </p>

<p>With the practical make you have all the information gathering done at the beginning as you don't want to get halfway through and realise you have not got a clue where the web servers are! Also dont be afraid to ask your examiner questions if something seems "wrong", for example if a service your meant to be querying is being super super slow or not replying at all, ask, your heavy handed scanning at the begging may have made the service slow or unresponsive. </p>

<p>
And lastly Keep Calm don't panic, its easy really! And once you've finished start revising for the CRT ;) 
</p>

<h2 id="reading"> <a> Further Reading | Other Resources | Revision Notes  </a> </h2>
<p>
One of the ways I personally study for exams is I keep a note of headings of everything I need to know. This allows for quick reference in the exam (its open book after all) and an insight into what I need to know. I have attached my KeepNote notebook to this page in case anybody finds it useful. This is following the 1.0 syllabus ONLY, it has not been modified with anything taken from the exam paper itself. You will notice if you open it that it is not indexed, lots of spelling mistakes and most likely repeated content, its just how I keep my notes! These are currently <a href="https://necurity.co.uk/other/CSPA-2015-04-03.rar">Here </a> But notice theres loads missing and lots of spelling mistakes . . . deal with it ;) I will improve them later.
</p>

<p>
There are also some other super useful resources I found to help my revising. I have linked to them below with a quick explanation of why I found it useful. 
<table>
<tr>
<td> Resource </td>
<td> Whats it good for? </td>
<tr>
<td> Wikipedia pages </td>
<td> Wiki'ing the topic in question is the quickest way to learn about it. Wikipedia has loads of well written tech pages to read through and digest </td>
</tr>

<tr>
<td> <a href="http://www.ucs.cam.ac.uk/support/windows-support/winsuptech">Cambridge AD Information</a></td>
<td> Cambridge University publishes information about setting up and managing windows domains. Although this is aimed at the university systems the information is generic and helped me wrap my brain around Windows Domains</td>
</tr>

<tr>
<td>
<a href="http://pwndizzle.blogspot.co.uk/2014/12/crest-crt-exam-preparation.html"> Other peoples Blogs</a>
</td>

<td> Other people that have taken the Crest exams usualy blog about it, some people make useful snippet guides so have a Google and see what you can find.</td>
</tr>

<tr>
<td>
<a href="https://technet.microsoft.com/en-gb/">Technet </a></td>
<td> If you ever need more information around windows systems technet will have have the answers for you</td>
</tr>

<tr>
<td> <a href="https://www.owasp.org/index.php/Category:OWASP_Top_Ten_Project"> OWASP</td>
<td> The Open Web Application Security Project covers as the name says common web app problems. Knowing the top ten is always good to know, and the testing guide has a wealth of information to absorb</td>
</tr>
<tr>
<td> <a href="http://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-857-network-and-computer-security-spring-2014/">MIT Open Courseware </a></td>
<td> MIT recently open sourced their CS undergrad course. I highly recommend at least watching the youtube series, its great for the unix security part of cpsa </d>
</tr>
<tr>
<td> <a href="http://www.noexcuselist.com/"> Other course materials </a>  </td> 
<td> MIT isnt alone in opening up learning materials many other universities  do the same!</td>
<tr>
</table>
</p>
</div>
