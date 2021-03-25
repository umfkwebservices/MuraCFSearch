<!---

This file is part of MuraCFSearch

Copyright 2021 University of Maine at Fort Kent
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

--->
<cfparam name="siteToIndex" default="" />

<!--- query used to generate URLs for indexing --->
<cfquery name="pagesToIndex" datasource="#$.GlobalConfig().get('datasource')#">
SELECT `tsettings`.`domain`, `tsettings`.`usessl`, `tcontent`.`Title` AS `title`, `tcontent`.`tags`, `tcontent`.`metadesc` AS `description`, `tcontent`.`metakeywords` AS `keywords`, `tcontent`.`Summary` AS `summary`, `tcontent`.`Body` AS `body`, `tcontent`.`filename`, `tcontent`.`contentID`, `tcontent`.`searchExclude`, `tcontent`.`display`, `tcontent`.`path`, `tcontent`.`Restricted`, LENGTH(`tcontent`.`filename`)-LENGTH(REPLACE(`tcontent`.`filename`, "/", "")) AS `depth` FROM `tsettings` LEFT JOIN `tcontent` ON `tsettings`.`siteid` = `tcontent`.`siteid` WHERE `tcontent`.`active` = 1 AND `tcontent`.`Type` != 'Plugin' AND `tcontent`.`Type` != 'Module' AND `tcontent`.`Type` != 'Component'
<cfif siteToIndex NEQ "">
	 AND `tcontent`.`siteid`= <cfqueryparam value="#siteToIndex#" />
</cfif>
 ORDER BY `depth` ASC, `tcontent`.`filename` ASC
</cfquery>

<!--- loop through the above query to begin indexing --->
<cfset ignoreList = "" />
<cfset indexCols = "contentID,title,summary,keywords,description,body,url" />
<cfset thisIndex = QueryNew(indexCols) />
<cfset sitePort = $.globalConfig().get('port') />
<cfset showIndexInPath = $.globalConfig().get('indexfileinurls') />
<cfloop query="pagesToIndex">
	<cfif pagesToIndex.searchExclude EQ 1 OR pagesToIndex.Restricted EQ 1 OR pagesToIndex.display EQ 0>
		<cfset ignoreList = ignoreList & pagesToIndex.path & "^;^" />
		<cfelse>
			<cfset ignorePage = 0 />

			<!--- if the plugin is set for subpages to inherit their parent's search exlcude setting, honor that setting --->
			<cfif indexExclude EQ "yes">
				<cfloop list="#ignoreList#" delimiters="^;^" index="i">
					<cfif pagesToIndex.path CONTAINS i>
						<cfset ignorePage = 1 />
						<cfbreak />
					</cfif>
				</cfloop>
			</cfif>

			<!--- if this page is not excluded from the search, add the page to the index --->
			<cfif ignorePage EQ 0>
				<cfset thisURL = "http" />
				<cfif pagesToIndex.usessl EQ 1>
					<cfset thisURL = thisURL & "s" />
				</cfif>

				<cfset thisURL = thisURL & "://" & pagesToIndex.domain />
				<cfif sitePort NEQ 80 AND sitePort NEQ 443 AND sitePort NEQ "">
					<cfset thisURL = thisURL & ':' & sitePort />
				</cfif>
				<cfif Left(pagesToIndex.filename,1) EQ "/">
					<cfset pagePath = Right(pagesToIndex.filename,Len(pagesToIndex.filename)-1) />
					<cfelse>
						<cfset pagePath = pagesToIndex.filename />
				</cfif>
				<cfif pagesToIndex.filename NEQ "">
					<cfset thisURL = thisURL & "/" & pagePath & "/" />
				</cfif>

				<!--- combine the keywords and tags from the query into a single keywords value --->
				<cfif pagesToIndex.tags NEQ "">
					<cfset keywordsVal = pagesToIndex.keywords & ',' & pagesToIndex.tags />
					<cfelse>
						<cfset keywordsVal = pagesToIndex.keywords />
				</cfif>

				<!--- add a row to the temporary query being created to store the index data --->
				<cfset tmp = QueryAddRow(thisIndex) />
				<cfloop list="#indexCols#" delimiters="," index="c">
					<cfswitch expression="#c#">
						<cfcase value="keywords">
							<cfset colVal = keywordsVal />
						</cfcase>
						<cfcase value="url">
							<cfset colVal = thisURL />
						</cfcase>
						<cfcase value="body">
							<!--- if the body contains mura tags, process the dynamic content --->
							<cfset item = $.getBean('content').loadBy(filename='#pagesToIndex.filename#') />
							<cfset request.currentFilename = pagesToIndex.filename />
							<cfset request.currentFilenameAdjusted = pagesToIndex.filename />
							<cfset request.muraDynamicContentError = false />
							<cfset $.announceEvent('onSiteRequestStart') />
							<cfset $.event('contentBean',item) />
							<cfset $.event('crumbdata',item.getCrumbArray()) />
							<cfset $.getHandler("standardSetContentRenderer").handle($) />
							<cfset $.getHandler("standardSetPermissions").handle($) />
							<cfset $.getHandler("standardSetIsOnDisplay").handle($) />
							<cfset $.announceEvent('onRenderStart') />
							<cfset r = $.event('r') />
							<cfset r.allow = 1 />
							<cftry>
								<cfset bodyVal = Trim($.setDynamicContent(item.getValue('body'))) />
								<cfif request.muraDynamicContentError>
									<cfset bodyVal = "" />
									<cfelse>
										<cfset bodyVal = $.addCompletePath(itemcontent,item.getSiteID()) />
								</cfif>
								<cfcatch>
									<cfset bodyVal = "" />
								</cfcatch>
							</cftry>
							<cfif bodyVal EQ "">
								<cfset bodyVal = pagesToIndex.body />
							</cfif>
							<cfset summaryVal = Trim($.setDynamicContent(item.getValue('summary'))) />
							<cfset colVal = stripMarkUp(pagesToIndex.title) & Chr(13) & Chr(10) & Chr(13) & Chr(10) & stripMarkUp(bodyVal) & stripMarkUp(summaryVal) & Chr(13) & Chr(10) & keywordsVal />
						</cfcase>
						<cfdefaultcase>
							<cfset colVal = pagesToIndex[c] />
						</cfdefaultcase>
					</cfswitch>
					<cfset tmp = QuerySetCell(thisIndex,c,colVal) />
				</cfloop>
			</cfif>
	</cfif>
</cfloop>