---
layout: post
title: Redhat Spacewalk Tutorial  :- Installation and Client Management How To
category: netsec
date: 2013-08-22
tags: spacewalk patching management
summary:
 Redhat's Spacewalk is a management solution to allow controlled patch deployment, maintenance of configuration files, system deployment through PXE for both virtual and bare-metal systems while also offering monitoring of system status, the automatic inventory cataloguing of registered clients and security auditing of systems all in a centralised manner. This post will go through the installation of the program as well as the set up of a repository, PXE booting and client registration. 
---

<div id="pagemenu">
<ol>
<li><a href="#Summary">Summary</a></li>
<li><a href="#Installation">Installation </a> </li>
<li><a href="#PXE">Content Management and PXE Booting</a></li>
<li><a href="#Clients">Client Management</a></li>
<li><a href="#Backup">Backing it all up</a></li>
<li><a href="#Resources">Useful resources and Troubleshooting </a> </li>
<li><a href="#All"> The All in one Spacewalk script</a> </li>
</ol>
</div>

<h1> ! Unfinished Content Below!</h1>
<p> Appologies people, The content below isnt finished yet, its close to but not there yet, I "lived" this so i can see what a proper blog post looks like in the new layout of my site, Sorry for any incoviance caused! In the mean time feel free to drop a comment at the bottom, or a email to myself if you think there is something wrong / missing / confusing!</p>
<div id="pagesummary">
<h2 id="Summary"> <a>Summary </a> </h2>
<p>
{{page.summary}}
</p><p>
Red Hat Spacewalk is the open source fork of Red Hat Satellite offering the same management functionality, but without the official support. As Spacewalks release cycle is much faster then satellite's it does occasionally get more features than its paid counterpart, however it does lose the ability to manage Red Hat servers. You also must manually import errata auditing information in as this is not included in the CentOS RPM packages. This is the first in a series of posts on how to use Spacewalk, <a href="/tag/tech/spacewalk"> The Spacewalk tag Index </a> contains links to the other articles and offers a brief overview of each post, with future posts going through some of the other features such as OSCAP vulnerability reporting, Spacewalk proxies and Enterprise build standardisation.
</p>
<p>
This guide assumes that you already have some of the basics needed to use Spacewalk with CentOS, which are, CentOS(!), a DHCP server capable of PXE, a DNS server and client boxes. It will aim to walk you through the installation of the service step by step.
</p>
</div>

<div id="maincontent">
<h2 id="Installation"> <a>Installation </a> </h2>
<p>
Spacewalk like most linux programs is pretty easy to install and get up running, however the Centos page on it is out of date! You have a choice of using Oracle (10g+) or Postgres(8.4+) as the database back end and throughout this tutorial postgres is the one of choice with it being installed on Centos 6.4, however these instuctions should work for any of the CentOS 6 family. Further details on the install of Spacewalk can be found on the Fedora hosted page at the end of this post.The first step is to prepare the server with all the dependencies and RPMs needed for Spacewalk. The repo that holds Spacewalk needs installing, after java needs installing (Tomcat is used as the webserver), and finally the actual RPMs can be installed.
</p>

{% highlight bash %}
# Grab the Repo
rpm -Uvh http://yum.spacewalkproject.org/2.0/RHEL/6/x86_64/spacewalk-repo-2.0-3.el6.noarch.rpm
# Enable Open JDK to be installed on centos
rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
# Jpacakge Dependancys (Spacewalk needs Java to work properly)
cat > /etc/yum.repos.d/jpackage-generic.repo << EOF
[jpackage-generic]
name=JPackage generic
#baseurl=http://mirrors.dotsrc.org/pub/jpackage/5.0/generic/free/
mirrorlist=http://www.jpackage.org/mirrorlist.php?dist=generic&type=free&release=5.0
enabled=1
gpgcheck=1
gpgkey=http://www.jpackage.org/jpackage.asc
EOF
# Install spacewalk - Postgress packages
yum install spacewalk-setup-postgresql spacewalk-postgresql
{% endhighlight %}

<p>
Setting the initial config for Spacewalk can be done in two ways, either interactively or by providing an answers file for automated install, as i'm a fan of automation the answers file is used (if you don't want to you just run the command minus answer file flag). You need to make sure that the server has a FQDN as well as its hostname set, whatever the hostname of the box is currently set to when you start the install will decide what Cname is used in the SSL certificate. If you are in possession of something like a * certificate you are able to use this and can install it later. 
</p>
{% highlight bash%}
# Edit this in a second - At least change the passwords
cat > setup.ans << EOF
admin-email = root@localhost
ssl-set-org = Spacewalk Org
ssl-set-org-unit = spacewalk
ssl-set-city = London
ssl-set-state = Ovum Pascha
ssl-set-country = GB
ssl-password = spacewalk_secure_PA55WORD!
ssl-set-email = root@localhost
ssl-config-sslvhost = Y
db-backend=postgresql
db-name=spaceschema
db-user=spaceuser
db-password=secure_spacepw
db-host=host
db-port=5432
enable-tftp=Y
EOF
#Now edit, changing the required details
vim setup.ans
#Check the hostname
hostname
# Set the service up - Disconnected becasue we are using postgresql
spacewalk-setup --disconnected --answer-file=setup.ans
# Sometimes the setup reports fail when its not actually failed, so list what's what
spacewalk-service status
{% endhighlight %}

<p>
If your organisation uses LDAP to manage user account information Spacewalk is able to integrate into this with ease, it is able to support Active Directory as well as SSSD, and we will use the latter here. It should be noted at this point that to use LDAP the account must also be created on the Spacewalk server too. To get the server to use a central authentication service first install and configure SSSD and confirm its working and configure the service to query the said server. In this example system-auth will be used, the file name rhn-satellite reference's the files located in /etc/pam.d/ and can be renamed if wished. 
</p>
{% highlight bash %}
# Tell Spacewalk to use LDAP
# Locate the line  "pam_auth_service"
# change this to "pam_auth_service = rhn-satellite"
vim /etc/rhn/rhn.conf
#Populate the file with the required config
#Here we use system auth, but AD can also be used
cat > /etc/pam.d/rhn-satellite << EOF
#%PAM-1.0
auth		include		system-auth
account		include		system-auth
password	substack	system-auth
EOF
{% endhighlight %}
<p>
After this the Web UI will be available to visit, which will prompt you to set a username and a password for the super user. After which you are good to go! However its a good idea to make a second user with reduced privileges to manage servers. So simple to install right!
</p>
<h2 id="PXE"><a>Content Management and PXE Booting</a></h2>
<p>
Spacewalk is useless without any clients or content, and as the content takes the longest to sync we will start that off first. After syncing OS, Updates, the EPEL (Extra Packages for Enterprise Linux) and the Spacewalk client repo the total space used by all the RPM's is 24GB just for CentOS 6 64bit. Spacewalk will only report on patches needed by systems if the repository that the package is located in is managed by a Spacewalk channel (A channel is a repository). Adding channels to manage systems is a two step process, the first is the adding of the channel, the second is subscribing a external repository to the channel to import the rpm's.
</p>
<h3> Managing Channels and Repositories </h3>
<p>
To mirror a Repository through the web interface, first log in and navigate to the Manage Software Channels section under the channels Tab. The first channel that we will make is called the parent channel. This channel ties together all the content from child channels and allows easier management of multiple repositories and clients. 
</p>

IMG GOES HERE

<p>
After navigating to the above page, click create new channel, the fields are self explanatory so fill them in and click create.
</p>

IMG GOES HERE

<p>
After this create a child channel to be associated with the parent, naming this as the repository it represents. For example you may want to have the OS, updates, EPEL, and the Spacewalk tools. You will want to go back to the create page and make a few more channels until you have everything you need.
</p>

IMG GOES HERE
<p>
Now add the repository, don't forget to add the GPG key for the repo. These will also need to be pushed to clients to allow them to install packages from your server, and can be either installed during kickstart, or manually after client registration.
</p>

<p>
Finally the newly added repository needs linking to the created channel, this is done though the manage software channels, and is just another click away.
</p>

IMG HERE,

<p>
Now begin the long processes of syncing up the files with the Spacewalk server, this can be done either manually or by a schedule. To do this navigate to the channel you want to sync, Repositories->Sync. An online log is available under manage software channels->details->last sync time. If you have RPMS that you would like to push to the repositories then the command rhn_push can be used, which will be covered below.
</p>

IMG HERE

<h3>Activation Keys</h3>
<p>
To be able to register clients to the server an activation key needs creating. These keys allow clients access to the different functions of Spacewalk, when creating the key you have the option of creating a universal default key which will be used in the case of a key not being provided when registering clients. You are also able to set a maximum number of times each key can be used. To create a new key navigate to system, activation keys create new keys</p>

Img HERE

<p> When creating the key you must provide some </p>

<p>Activation keys can also be used to automatically install software on systems, and add configuration management. These are one of the many ways Spacewalk offers the grouping of servers. 
</p>


<h3> Kickstarts</h3>
<p>
A kickstart (automated install) can be added now. The overall process to do this is, create a distribution that the server can boot, create individual profiles for computers and then booting them. The kickstart system is provided by Xinet.d and Cobbler. Before making any profiles confirm that the system is able to do a kickstart by confirming cobbler is running and ready. A few times to get PXE working I have also needed to copy the Cobbler menu to the TFTP directory. I am assuming at this point you already have the distribution ISO you wish to use. 
</p>
{% highlight bash %}
# Does it think its okay?
cobbler status
# Does it think it will work?
cobbler check
# You probably want to be able to PXE boot stuff
yum install cobbler-loaders
# Copy files to make it work if needed, remember you already need DHCP in place
cp /etc/cobbler/pxe/menu.c32  /etc/cobbler/pxe/pxelinux.0  /var/lib/tftpboot/
# Mount the Disk - The path needs to match what is set below in the distribution
mkdir -p /var/distro-trees/centos-64-64/
mount -o loop ~/CentOS-6.4-x86_64-bin-DVD1.iso /var/distro-trees/centos-64-64/
{% endhighlight %}
<p>
After this create the distribution though the interface (systems -> kickstarts -> distributions -> create new distribution ).
</p>
IMG HERE

<p>
 If you already have some kickstart files you would like to use (great!) then you can chose to upload and use these, if not then crack on, click create and select all the options you want. There are kickstarts available online for most situations, for example NIST offer a workstation build based on RH5. After adding the kickstart, its just a case of PXE booting whatever device is needed and your done. It should be noted at this point that if you would like clients to be able to install software out of the repository they must have the keys for the packages installed else this will cause a error. More information about kickstarts is available in other blog posts to keep the size of this one down.
</p>
<p>
However as stated earlier anything that can be done through the command line, the process below is exactly the same as above, using CentOS 6 32 bit as a example.
</p>

{% highlight bash %}
#Comming soon! Sorry
#If you really want to know, you use spacecmd which is a fancy python wrapper for the API
#
{% endhighlight %}

<h2 id="Clients"><a>Client Management</a></h2>
<p>
You will probably already have systems that are you wish to be managed by Spacewalk, and these are easily registered. All you have to do is install the client program on a server and provide it with an activation key that you have created previously. You need to make sure that you download the SSL certificate from the spacewalk server before you register the system. Sending actions over http is not reccomended for the obvius security implications.
</p>

{% highlight bash %}
# Grab the needed Repo
# Grab the client
# Grab the ssl cert from the server, drop it to the default location
# Register clients
{% endhighlight %}
<p>
During the clients registration any actions that are associated with the key are carried out, actions that have completed are available under the history tab of the system on the web interface. And now that the client is registered it will check in every 240 minutes (4 hours) by default. All the client actions are initiated from the client not the server, and will take place over either port 80 or 443.
</p>


<h2 id="Backup"><a>Backing It all up</a></h2>
<p>
Managing the backup of Spacewalk is pretty easy, everything the system does is stored in its database, dumping this and then subsequently restoring it will have the Spacewalk server back up and running in no time at all. You may also wish to keep a copy of Spacewalks config so you don't lose any tweaks that you have done. However there are two main disadvantages of just backing the database up, first you will lose the generated ssl certificates (just the web portal ones, the trusted SSL certificates used during rhn_check is stored with the kickstarts), and secondly you will lose all the RPM files.
</p>
{% highlight bash %}
#Stop Spacewalk
# Start postgres
# Save the database
# Start Spacewalk
{% endhighlight %}


<h2 id="Resources"><a>Useful resources And Troubleshooting</a></h2>
<p>
The <a href="https://fedorahosted.org/spacewalk/">Fedora Hosted</a> page and corresponding wiki contains everything you need to get up and started. Its one of the best resources to check documentation as its the official home! Another great place to check is the <a href="https://access.redhat.com/site/documentation/Red_Hat_Network_Satellite/"> official RedHat Satellite Documentation</a>, its free to view and is still relevant to Spacewalk (as the two are essentially the same product). If your stuck on something and needing a hand then you can always check out the <a href="https://www.redhat.com/archives/spacewalk-list/"> official Spacewalk mailing list </a>.
</p>
<h2 id="All"><a>The all in one Spacewalk Script</a></h2>
<p>
I had to install Spacewalk a few times when I was testing it so I wrote a script to do everything for me that this post covers located below, you may find it useful as a reference point when you are installing the service.
</p>
<hr>
</div>