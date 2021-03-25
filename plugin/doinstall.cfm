<!---

This file is part of MuraCFSearch

Copyright 2021 University of Maine at Fort Kent
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

--->

<!---
variable defining which action to take
possible values:
	installPlugin
	uninstallPlugin
--->
<cfparam name="setAction" default="installPlugin" />

<!--- do the following when installing or updating the plugin --->
<cfif setAction EQ "installPlugin">
	<!--- get a list of the sites assigned ot this plugin --->
	<cfset indexSites = pluginConfig.getAssignedSites() />

	<!--- get the plugin settings needed for the creation of collections --->
	<cfset indexPrefix = pluginConfig.getSetting('cfSearchIndexPrefix') />
	<cfset indexAll = pluginConfig.getSetting('cfSearchAll') />

	<!--- check the existence of necessary directories, create them if they don't exist, and remove any unnecessary directories --->
	<cfset collectionsLocation = '../collections/' />
	<cfif NOT DirectoryExists(collectionsLocation)>
		<cfdirectory action="create" directory="#collectionsLocation#" />
	</cfif>
	<cfif indexAll EQ 'yes'>
		<!--- if using a single index for all sites/subdomains, create the folder and then remove unnecessary directories --->
		<cfset indexFolder = indexPrefix & 'allsites' />
		<cfset indexDir = collectionsLocation & indexFolder />
		<cfif NOT DirectoryExists(indexDir)>
			<cfcollection action="create" collection="#indexFolder#" path="#indexDir#" />
		</cfif>
		<cfdirectory action="list" directory="#collectionsLocation#" name="collectionFolders" type="dir" recurse="no" />
		<cfloop query="collectionFolders">
			<cfif collectionFolders.name NEQ indexFolder>
				<cfcollection action="delete" collection="#collectionFolders.name#" />
			</cfif>
		</cfloop>
		<cfelse>
			<!--- otherwise, create collection folders for each assigned site (if they don't already exist) --->
			<cfloop query="indexSites">
				<cfset indexFolder = indexPrefix & indexSites.siteid />
				<cfset indexDir = collectionsLocation & indexFolder />
				<cfif NOT DirectoryExists(indexDir)>
					<cfcollection action="create" collection="#indexFolder#" path="#indexDir#" />
				</cfif>
			</cfloop>

			<!--- delete any that are unnecessary --->
			<cfdirectory action="list" directory="#collectionsLocation#" name="collectionFolders" type="dir" recurse="no" />
			<cfloop query="collectionFolders">
				<!--- check if this folder matches that of one of the assigned sites --->
				<cfset isValid = 'no' />
				<cfloop query="indexSites">
					<cfset indexFolder = indexPrefix & indexSites.siteid />
					<cfif collectionFolders.name EQ indexFolder>
						<cfset isValid = 'yes' />
						<cfbreak />
					</cfif>
				</cfloop>
				<cfif isValid EQ "no">
					<cfcollection action="delete" collection="#collectionFolders.name#" />
				</cfif>
			</cfloop>
	</cfif>

<!--- do the following when uninstalling the plugin --->
<cfelseif setAction EQ "uninstallPlugin">
	<!--- delete all search collections --->
	<cfset collectionsLocation = '../collections/' />
	<cfdirectory action="list" directory="#collectionsLocation#" name="collectionFolders" type="dir" recurse="no" />
	<cfloop query="collectionFolders">
		<cfcollection action="delete" collection="#collectionFolders.name#" />
	</cfloop>
</cfif>