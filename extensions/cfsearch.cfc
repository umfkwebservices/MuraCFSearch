<!---

This file is part of MuraCFSearch

Copyright 2021 University of Maine at Fort Kent
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

--->
<cfcomponent extends="mura.plugin.pluginGenericEventHandler">
	<cfscript>
		if ( !IsDefined('$') ) {
			siteid = session.keyExists('siteid') ? session.siteid : 'default';
			$ = application.serviceFactory.getBean('m').init(siteid);
		}
	</cfscript>
	<cffunction name="onSiteSearchRender">
		<cfargument name="indexPrefix" type="string" required="true" default="#pluginConfig.getSetting('cfSearchIndexPrefix')#" />
		<cfargument name="indexAll" type="string" required="true" default="#pluginConfig.getSetting('cfSearchAll')#" />
		<cfargument name="advancedOptions" type="string" required="true" default="#pluginConfig.getSetting('cfSearchAdvanced')#" />
		<cfargument name="keywords" type="string" required="true" default="#request.keywords#" />
		<cfargument name="wordsPhrase" type="string" required="false" default="words" />
		<cfargument name="allAny" type="string" required="false" default="all" />
		<cfargument name="siteID" type="string" required="true" default="#variables.$.event('siteID')#" />
		<!--- get plugin configuration settings needed for searching --->
		<cfif IsDefined('request.wordsPhrase')>
			<cfset arguments.wordsPhrase = request.wordsPhrase />
		</cfif>
		<cfif IsDefined('request.allAny')>
			<cfset arguments.allAny = request.allAny />
		</cfif>

		<!--- get the plugin directory --->
		<cfset pluginsLocation = Replace($.GlobalConfig().get('plugindir'),'\','/','all') />
		<cfset pluginDir = ListLast(pluginsLocation,'/') />

		<!--- if the plugin directory value is empty, use the default value --->
		<cfif pluginDir EQ "">
			<cfset pluginDir = 'plugins' />
		</cfif>

		<!--- get the folder for this plugin --->
		<cfset thisPluginDir = pluginConfig.getPackage() />

		<!--- get the collection name to search based on the settigns above --->
		<cfif IsDefined('indexAll') AND indexAll EQ "yes">
			<cfset indexName = indexPrefix & 'allsites' />
			<cfelse>
				<cfset indexName = indexPrefix & Trim(arguments.siteID) />
		</cfif>

		<!--- first, determine whether there is more than one word in the Keywords argument --->
		<cfset kword = Trim(arguments.keywords) />
		<cfset kwordLen = ListLen(kword,' ') />

		<cfset searchCriteria = '' />
		<!--- if the keywords exist, use the plugin settings to generate the search criteria --->
		<cfif Len(request.keywords)>
			<!--- if so, determine the type of search (word or phrase, all or any word, etc.) --->
			<cfif kwordLen GT 1 AND arguments.wordsPhrase EQ "words">
				<cfswitch expression="#arguments.allAny#">
					<cfcase value="any">
						<cfset wordCt = 0 />
						<cfloop list="#kword#" delimiters=" " index="words1">
							<cfset wordCt = wordCt + 1 />
							<cfset searchCriteria = searchCriteria & words1 & '~0.8' />
							<cfif wordCt LT kwordLen>
								<cfset searchCriteria = searchCriteria & ' OR ' />
							</cfif>
						</cfloop>
					</cfcase>
					<cfdefaultcase>
						<cfset wordCt = 0 />
						<cfloop list="#kword#" delimiters=" " index="words1">
							<cfset wordCt = wordCt + 1 />
							<cfset searchCriteria = searchCriteria & words1 & '~0.8' />
							<cfif wordCt LT kwordLen>
								<cfset searchCriteria = searchCriteria & ' AND ' />
							</cfif>
						</cfloop>
					</cfdefaultcase>
				</cfswitch>
			<cfelseif kwordLen GT 1 AND arguments.wordsPhrase EQ "phrase">
				<cfset searchCriteria = searchCriteria & '"""' & kword & '"""' & '~0.8' />
				<cfelse>
					<cfset searchCriteria = searchCriteria & kword & '~0.8' />
			</cfif>
		</cfif>

		<cfset pluginBase = "/" & pluginDir & "/" & thisPluginDir />
		<cfset dspSearch = '<script src="' & pluginBase & '/assets/js/muracfsearch.js"></script>
		<link rel="stylesheet" type="text/css" href="' & pluginBase &'/assets/css/muracfsearch.css" />' />
		<cfsavecontent variable="showForm">
			<cfinclude template="#pluginBase#/extensions/dspSearchForm.cfm" />
			<cfparam name="request.indexname" default="#indexName#" />
			<cfparam name="request.criteria" default="#searchCriteria#" />
			<div id="siteSearchResults" class="margin-toplg">
				<cfinclude template="#pluginBase#/extensions/dspSearchResults.cfm" />
			</div>
		</cfsavecontent>
		<cfset dspSearch = dspSearch & showForm />
		<cfreturn dspSearch />
	</cffunction>
</cfcomponent>