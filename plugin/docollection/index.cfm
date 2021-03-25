<!---

This file is part of MuraCFSearch

Copyright 2021 University of Maine at Fort Kent
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

--->

<!---
parameter used to indicate the action to take
possible values:
	install
	update
	delete
--->

<cfparam name="setIndexSchedule" default="" />
<cfparam name="URL.site" default="" />
<cfparam name="siteToIndex" default="#Trim(URL.site)#" />

<!--- get the plugin settings needed for site indexing --->
<cfset indexPrefix = pluginConfig.getSetting('cfSearchIndexPrefix') />
<cfset indexAll = pluginConfig.getSetting('cfSearchAll') />
<cfset indexInterval = pluginConfig.getSetting('cfSearchIndexInterval') />
<cfset indexExclude = pluginConfig.getSetting('cfSearchExclude') />

<cfif setIndexSchedule EQ "install" OR setIndexSchedule EQ "update">
	<!--- get the information of the current site set up in Mura --->
	<cfset siteDomain = $.siteConfig().get('domain') />
	<cfset siteSSL = $.siteConfig().get('usessl') />

	<!--- set the plugin directory --->
	<cfset pluginsLocation = Replace($.GlobalConfig().get('plugindir'),'\','/','all') />
	<cfset pluginDir = ListLast(pluginsLocation,'/') />

	<!--- if the plugin directory value is empty, use the default value --->
	<cfif pluginDir EQ "">
		<cfset pluginDir = 'plugins' />
	</cfif>

	<cfset sitePort = $.globalConfig().get('port') />
	<cfset showIndexInPath = $.globalConfig().get('indexfileinurls') />

	<!--- get the folder for this plugin --->
	<cfset thisPluginDir = pluginConfig.getPackage() />

	<!--- construct the URL for the scheduled task --->
	<cfset indexsiteURL = "http" />
	<cfif siteSSL EQ 1>
		<cfset indexsiteURL = indexsiteURL & "s" />
	</cfif>

	<!--- set the start date and time --->
	<cfif indexInterval EQ "">
		<cfset indexInterval = 72 />
	</cfif>
	<cfset timeoutSec = indexInterval * 60^2 />
	<cfset startDT = DateAdd('n',3,Now()) />
	<cfset indexsiteURL = indexsiteURL & "://" & siteDomain />
	<cfif sitePort NEQ 80 AND sitePort NEQ 443 AND sitePort NEQ "">
		<cfset indexsiteURL = indexsiteURL & ':' & sitePort />
	</cfif>
	<cfif showIndexInPath NEQ 'false'>
		<cfset indexsiteURL = indexsiteURL & "/index.cfm" />
	</cfif>
	<cfset indexsiteURL = indexsiteURL & "/" & pluginDir & "/" & thisPluginDir & "/plugin/docollection/" />

	<!--- create the scheduled task for indexing --->
	<cfschedule action="update" task="Mura Site Index" operation="HTTPRequest" url="#indexsiteURL#" startdate="#DateFormat(startDT,'mm/dd/yyyy')#" starttime="#TimeFormat(startDT,'short')#" interval="#timeoutSec#" resolveurl="true" requesttimeout="43200" />
<cfelseif setIndexSchedule EQ "delete">
	<!--- remove the scheduled task --->
	<cfschedule action="delete" task="Mura Site Index" />
	<cfelse>
		<!--- Perform Site Indexing --->
		<!--- set the value of the collection name --->
		<cfset indexName = '' />
		<cfif siteToIndex NEQ "">
			<cfset indexName = indexPrefix & siteToIndex />
		<cfelseif indexAll EQ "yes">
			<cfset indexName = indexPrefix & 'allsites' />
		</cfif>

		<!--- determine the indexing of a specific site, all sites, or individual sites --->
		<cfif indexName NEQ "">
			<!--- include the file with queries used to build the index --->
			<cfinclude template="siteindexquery.cfm" />
			<cfindex action="refresh" collection="#indexName#" key="contentID" type="custom" query="thisIndex" title="title" custom1="summary" custom2="keywords" custom3="desciption" custom4="url" body="body" />
			<cfelse>
				<!--- get the list of sites to which the plugin is assigned --->
				<cfset indexSites = pluginConfig.getAssignedSites() />

				<!--- index each assigned site individually --->
				<cfloop query="indexSites">
					<cfset indexName = indexPrefix & indexSites.siteid />
					<cfinclude template="siteindexquery.cfm" />
					<cfindex action="refresh" collection="#indexName#" key="contentID" type="custom" query="thisIndex" title="title" custom1="summary" custom2="keywords" custom3="desciption" custom4="url" body="body" />
				</cfloop>
		</cfif>
</cfif>