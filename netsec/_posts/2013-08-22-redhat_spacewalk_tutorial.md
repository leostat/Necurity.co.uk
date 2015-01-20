---
layout: post
title: Redhat Spacewalk Tutorial | Installation, RPM's, Kickstarts and Clients
category: netsec
date: 2014-11-03
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


<main>
<div id="pagesummary">
<h2 id="Summary"> <a>Summary </a> </h2>
<p>
{{page.summary}}
</p><p>
Red Hat Spacewalk is the open source fork of Red Hat Satellite offering the same management functionality, but without the official support. As Spacewalks release cycle is much faster then satellite's it does occasionally get more features than its paid counterpart, however it does lose the ability to manage Red Hat servers. You also must manually import errata auditing information in as this is not included in the CentOS RPM packages. 
</p>

<p>

This is the first in a series of posts on how to use Spacewalk, <a href="/tag/tech/spacewalk">  The Spacewalk tag Index  </a>contains links to the other articles and offers a brief overview of each post, with future posts going through some of the other features such as OSCAP vulnerability reporting, Spacewalk proxies and Enterprise build standardisation.
</p>

<p>
Throughout this I assume that you already have some of the basics needed to use Spacewalk with CentOS, which are, CentOS(!), a DHCP server capable of PXE, a DNS server and client boxes. It will aim to walk you through the installation of the service step by step. 
</p>

<p>
The <a href="/scripts/allinone.txt">"All in one"</a> script at the end aims to do all of this automatically, I don't recommend running this unless you are familiar with bash and read it first. It has a simple check to make sure you don't just run it by accident, which will force you to read the script. It will also call home to my server, (just a wget to allinonespacewalkused) this can be removed by deleting line +250. It uses a hard coded root account, this should be removed before putting into production.
</p>

</div>

<div id="maincontent">
<h2 id="Installation"> <a>Installation </a> </h2>
<p>
Spacewalk like most Linux programs is pretty easy to install and get up running, however the CentOS page on it is out of date! You have a choice of using Oracle (10g+) or Postgres(8.4+) as the database back end and throughout this tutorial Postgres is the one of choice with it being installed on CentOS 6.6, however these instructions should work for any of the CentOS 6 family. Further details on the install of Spacewalk can be found on the Fedora hosted page at the end of this post.The first step is to prepare the server with all the dependencies and RPMs needed for Spacewalk. The repo that holds Spacewalk needs installing, after java needs installing (Tomcat is used as the webserver), and finally the actual RPMs can be installed.
</p>

{% highlight bash %}
# Grab the repo
rpm -Uvh http://yum.spacewalkproject.org/2.2/RHEL/6/x86_64/spacewalk-repo-2.2-1.el6.noarch.rpm
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
#Now edit, changing the required details, like the password!
vim setup.ans
#Check the hostname
hostname
# Set the service up - Disconnected because we are using postgresql
spacewalk-setup --disconnected --answer-file=setup.ans
# Sometimes the setup reports fail when its not actually failed, so list what's what
spacewalk-service status
{% endhighlight %}

<p>
If your organisation uses LDAP to manage user account information Spacewalk is able to integrate into this with ease, it is able to support Active Directory as well as SSSD and in the latest version integrates IPA, and we will use SSSD here. It should be noted at this point that to use LDAP the account must also be created on the Spacewalk server too. To get the server to use a central authentication service first install and configure SSSD and confirm its working and configure the service to query the said server. In this example system-auth will be used, the file name rhn-satellite reference's the files located in /etc/pam.d/ and can be renamed if wished. 
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
After this the Web UI will be available to visit, which will prompt you to set a username and a password for the super user. After which you are good to go! However its a good idea to make a second user with reduced privileges to manage servers. Simple to install right!
</p>
<h2 id="PXE"><a>Content Management and PXE Booting</a></h2>
<p>
Spacewalk is useless without any clients or content, and as the content takes the longest to sync we will start that off first. After syncing OS, Updates, the EPEL (Extra Packages for Enterprise Linux) and the Spacewalk client repo the total space used by all the RPM's is 24GB just for CentOS 6 64bit. Spacewalk will only report on patches needed by systems if the repository that the package is located in is managed by a Spacewalk channel (A channel is a repository). Adding channels to manage systems is a two step process, the first is the adding of the channel, the second is subscribing a external repository to the channel to import the rpm's.
</p>
<h3> Managing Channels and Repositories </h3>
<p>
The easiest way to set up the Channels and repositories is via the command line, the command 
<a href="https://fedorahosted.org/spacewalk/wiki/UploadFedoraContent">spacewalk-common-channels</a> 
allows an administrator to create all channels and repos for supported distros almost instantly. In the below example the channels for fedora 20, the spacewalk client channels and centos 7 are created
</p>
{%highlight bash%}
/usr/bin/spacewalk-common-channels -v -u admin -p pass -a x86_64 -k unlimited 'centos7*' 'fedora20*' 'spacewalk-client*'
{%endhighlight%}

<p>
This can also be done through the web interface. However I highly recommend you use the command line. If you wish to use the web interface, first log in and navigate to the Manage Software Channels section under the channels Tab. The first channel that we will make is the parent channel which holds the base OS and ties together all the content from child channels and allows easier management of multiple repositories and clients. 

</p>

<p>
After navigating to the above page, click create new channel, the fields are self explanatory so fill them in and click create.
</p>

<p>
After this create a child channel to be associated with the parent, naming this as the repository it represents. For example you may want to have the Updates, EPEL, and the Spacewalk tools. You will want to go back to the create page and make a few more channels until you have everything you need.
</p>

<p>
Now add the repository, don't forget to add the GPG key for the repo.  The GPG keys will also need to be pushed to clients to allow them to install packages from your server, and can be either installed during kickstart, or manually after client registration. Spacewalk is able to sync with both RPM based systems and APT based ones.
</p>

<p>
Finally the newly added repository needs linking to the created channel, this is done though the manage software channels, and is just another click away.
</p>

<p>
After adding the channels through either the web interface or the command line, begin the long processes of syncing up the RPMs with the Spacewalk server, this can be done either manually as and when needed or by a schedule. 

This  can be done on the command line through <a href="https://fedorahosted.org/spacewalk/wiki/UploadFedoraContent#Repo-sync"> spacewalk-repo-sync</a>
</p>

{%highlight bash%}
/usr/bin/spacewalk-repo-sync --channel $Channel_name
{%endhighlight%}

<p>
To do this through the web interface navigate to the channel you want to sync, Repositories->Sync. An log of progress is available in /var/log/rhn/reposync or through the web interface at "manage software channels->details->last sync time". 
</p>

<p>
You are also able to push your own RPMS to the repositories. The command <a href="https://fedorahosted.org/spacewalk/wiki/UploadFedoraContent#rhnpush">rhn_push</a> can be used. This is useful for adding applications that are either internally generated, pre-downloaded packages such as those on the install media,or are not available through standard repositories such as Nessus
</p>

{%highlight bash%}
/usr/bin/rhnpush -v --channel=$Channel_name --server=https://localhost/APP --dir=.
{%endhighlight%}

<h3>Activation Keys</h3>
<p>
To be able to register clients to the server an activation key needs creating. These keys allow clients access to the different functions of Spacewalk, when creating the key you have the option of creating a universal default key which will be used in the case of a key not being provided when registering clients. You are also able to set a maximum number of times each key can be used. To create a new key navigate to the system tab, then under activation keys the option create new key
</p>

<p>
Activation keys can also be used to automatically install software on systems, and add configuration management. These are one of the many ways Spacewalk offers the grouping of servers.  
</p>


<h3> Kickstarts</h3>
<p>
A kickstart (automated install) can be created now. The overall process to do this is, create a distribution that the server can boot, create individual profiles for computers and then booting them. The kickstart system is provided by Xinet.d and Cobbler. Before making any profiles confirm that the system is able to do a kickstart by confirming cobbler is running and ready. A few times to get PXE working I have also needed to copy the Cobbler menu to the TFTP directory. I am assuming at this point you already have the distribution ISO you wish to use. 
</p>
{% highlight bash %}
# Does it think its okay?
cobbler status
# Does it think it will work?
cobbler check
# You probably want to be able to PXE boot stuff
yum install cobbler-loaders
# Copy files to make it work, remember you already need DHCP in place. This is a known bug and is documented here:
# https://bugzilla.redhat.com/show_bug.cgi?id=872951

cp /etc/cobbler/pxe/menu.c32  /etc/cobbler/pxe/pxelinux.0  /var/lib/tftpboot/
# Mount the Disk - The path needs to match what is set below in the distribution
mkdir -p /var/distro-trees/centos-6/
mount -o loop ~/CentOS-6.6-x86_64-bin-DVD1.iso /var/distro-trees/centos-6/
# If you are booting a centos 7 disk it MUST be the everything ISO
{% endhighlight %}
<p>
After this create the distribution though either the web interface (systems -> kickstarts -> distributions -> create new distribution ), or via the command line.
</p>

<p>
 If you already have some kickstart files you would like to use (great!) then you can chose to upload and use these (they however will be none editable, I am making a tool to fix this though :) ), if not then click create and select all the options you want. There are kickstarts available online for most situations, for example NIST offer a <a href="http://usgcb.nist.gov/usgcb/content/configuration/workstation-ks.cfg">workstation build based on RH5</a>. After adding the kickstart, its just a case of PXE booting whatever device is needed and your done. You must deploy the spacewalk CA certificate and repository GPG keys to the system being kickstarted for the system to install properly. More information about kickstarts is available in other blog posts to keep the size of this one down.
</p>

<hr>

<h2 id="Clients"><a>Client Management</a></h2>
<p>
You will probably already have systems that are you wish to be managed by Spacewalk, and these are easily registered. All you have to do is install the client program on a server and provide it with an activation key that you have created previously. You need to make sure that you download the SSL certificate from the Spacewalk server before you register the system. Sending actions over http is not recommended for the obvious security implications. An always up to date guide is available from <a href="https://fedorahosted.org/spacewalk/wiki/RegisteringClients"> the spacewalk wiki</a>.
</p>

{% highlight bash %}
# Install spacewalk client repository
rpm -Uvh http://yum.spacewalkproject.org/2.2-client/RHEL/6/x86_64/spacewalk-client-repo-2.2-1.el6.noarch.rpm
# Install the Client
yum install rhn-client-tools rhn-check rhn-setup rhnsd m2crypto yum-rhn-plugin
# Install the SSL certificate from the server
yum install http://spacewalk.lan/pub/rhn-org-trusted-ssl-cert-1.0-1.noarch.rpm
# Register clients
rhnreg_ks --serverUrl=https://spacewalk.lan/XMLRPC --sslCACert=/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT --activationkey=1-key --username $spacewalkusername --force
{% endhighlight %}

<p>
During the clients registration any actions that are associated with the key are carried out, actions that have completed are available under the history tab of the system on the web interface. Now that the client is registered it will check in every 240 minutes (4 hours) by default. When triggered the rhn_check command runs and contacts the server to check for actions, and will take place over either port 80 or 443.
</p>

<hr>

<h2 id="Backup"><a>Backing It all up</a></h2>
<p>
Managing the backup of Spacewalk is pretty easy, everything the system does is stored in its database, dumping this and then subsequently restoring it will have the Spacewalk server back up and running in no time at all. You may also wish to keep a copy of Spacewalks config so you don't lose any tweaks that you have done. However there are two main disadvantages of just backing the database up, first you will lose the generated ssl certificates (just the web portal ones, the trusted SSL certificates used during rhn_check is stored with the kickstarts), and secondly you will lose all the RPM files.
</p>
{% highlight bash %}
# Stop Spacewalk
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
I had to install Spacewalk a few times when I was testing it so I wrote a script to do everything for me that this post covers it can be found <a href="/scripts/allinone.txt">"All in one"</a>, you may find it useful as a reference point when you are installing the service.  It calls home on line 250 so feel free to delete it. It also adds a root account, a archer account and a readon only account. Please please please please change the passwords.
</p>
</main>
<hr>


</div>
