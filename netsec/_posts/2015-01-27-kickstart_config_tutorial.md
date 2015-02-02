---
layout: post
title: Redhat Spacewalk Tutorial | Kickstarts and Configuration Management
category: netsec
date: 2015-01-27
tags: spacewalk management standardisation
summary:
 Spacewalk offers the ability to generate and deploy Kickstarts (standard builds, keep an eye on packages that are installed on the system as well as compare any file that is on the remote machine to a local copy, giving I.T management a overview of which systems require patching or are not conforming to standards`. In this post I will go through the kickstart creation process and Spacewalks configuration management 
---

<div id="pagemenu">
<ol>
<li><a href="#Summary">Summary</a></li>
<li><a href="#config">Configuration Files</a> </li>
<li><a href="#kickstart">Kickstarts</a> </li>
<li><a href="#profiles">Package Profiles</a></li>
<li><a href="#compare">Comparing Files</a></li>
<li><a href="#res">Other Resources</a> </li>
</ol>
</div>

<div id="pagesummary">
<h2 id="Summary"> <a>Summary </a> </h2>
<p>
{{page.summary}}
</p><p>
This is a continuation of the <a href="/tag/tech/spacewalk"> Spacewalk series </a>, more information such as the initial setup and other features is available from the tag index. The establishment of standards and baselines in an enterprise environment is a important step toward improving the general state of information security. It allows the assurance that all systems used within the business meet minimum security requirements. 
</p>
</div>
<div id="maincontent">
<h2 id="config"> <a> Configuration files  </a> </h2>
<p>
Configuration files are group by channels, and configuration channels are assigned to systems through activation keys. By grouping config's and activation keys by function, management of servers becomes a breeze!. Configuration files can be managed via either the web interface under the configuration tab or via spacecmd. Spacecmd offers the following config management functions as of spacewalk 2.2. I highly recommend becoming familiar with the use of spacecmd as it makes spacewalk management much easier

{% highlight bash %}
spacecmd {SSM:0}> configchannel_
configchannel_addfile      configchannel_create       configchannel_diff         configchannel_forcedeploy  configchannel_listfiles    configchannel_sync
configchannel_backup       configchannel_delete       configchannel_export       configchannel_import       configchannel_listsystems  configchannel_updatefile
configchannel_clone        configchannel_details      configchannel_filedetails  configchannel_list         configchannel_removefiles  configchannel_verifyfile
{% endhighlight %}

Configuration channels can hold any files, however by default there is a maximum file size that it is able to hold, this can be modified by setting the variables   maximum_config_file_size and web.maximum_config_file_size in /etc/rhn/rhn.conf. This will be required if you wish to store larger files such as file archives within spacewalk. <br>

When creating files through the web interface it is possible to set the file ownership, permissions and SELinux context, setting these correctly can save hours of headache in the future!.
</p>
<p>
Once you have uploaded all the files you wish to be managed by spacewalk you must assign your configuration channel to an activation key. You are able to have multiple configuration channels per activation key, if there are conflicting files within two configuration channels then the channel with the higher priority within the activation key will be used. If registering a system with multiple activation keys then the order of activation keys is used to decide the channel priority with the first activation key being used as the primary source of files, secondary key's configuration files will be deployed but will not overide any files managed from the first activation key.   
</p>
<p>
To use the configuration file deployment within activation keys the permission must be set within the key, this can be done by setting the Provisioning and Monitoring entitlements, followed by adding the configuration file permission. 
</p>

<h2 id="kickstart"> <a> KickStarts  </a> </h2>
<p>
Once adding all you configuration files to the channel, and assigning the channel to the activation key you are then able to move onto creating a kickstart to get a standard build process moving. In the web interface browse to Systems -> Kickstarts -> Profiles and click the create new kickstart. Follow the wizard choosing your settings, when setting the root password keep in mind that although it is stored in a hashed format, it is publicly available to anyone who has access to the spacewalk server, so setting a strong but deault password is recommend.
</p>
<p>
Under the Details tab, check the logging options and preserve ks.cfg to save a log to the booted server for future reference. Go through selecting all te options you want, such as enabling configuration management, selecting activation keys and adding Pre / post scripts. And thats all there really is to kickstarts!
</p>

</div>
