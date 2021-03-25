<!---

This file is part of MuraCFSearch

Copyright 2021 University of Maine at Fort Kent
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

--->

<!--- values for generating result pages --->
<cfparam name="URL.page" default="1" />
<cfparam name="URL.indexname" default="" />
<cfparam name="URL.criteria" default="" />
<cfparam name="request.page" default="#URL.page#" />

<cfset resultsPerPage = pluginConfig.getSetting('cfSearchPageRecords') />
<cfif StructKeyExists(request,"indexname") AND StructKeyExists(request,"criteria")>
	<cfset indexname = request.indexname />
	<cfset criteria = DecodeForHTML(request.criteria) />
	<cfelse>
		<cfset indexname = URL.indexname />
		<cfset criteria = DecodeForHTML(URL.criteria) />
</cfif>
<cfset qstring = 'indexname=' & indexname & '&criteria=' & criteria />

<!--- set start and end record values --->
<cfset start_record = request.page * resultsPerPage - resultsPerPage + 1 />
<cfset end_record = request.page * resultsPerPage />


<!--- query to get the results for this page --->
<cfsearch collection="#indexname#" name="searchResults" status="searchStatus" contextHighlightBegin="<strong>" contextHighlightEnd="</strong>" criteria="#criteria#" contextPassages="5" contextBytes="1000" maxRows="1000" suggestions="3" />

<cfset totalResultVal = searchStatus.found />

<!--- if the total results is less than the end record value, change the end record value to match --->
<cfif end_record GT totalResultVal>
	<cfset end_record = totalResultVal />
</cfif>

<!--- maximum number of pages to display --->
<cfset pages_nav_num = 10 />
<cfset pages_mid_num = ceiling((pages_nav_num/2)-1) />
<cfset offset_prev = request.page - ceiling((pages_nav_num/2)-1) />
<cfset offset_next = request.page + ceiling((pages_nav_num/2)-1) />
<cfset num_pages = ceiling(totalResultVal/resultsPerPage) />

<!--- get the plugin base location --->
<cfset pluginsLocation = Replace($.GlobalConfig().get('plugindir'),'\','/','all') />
<cfset pluginDir = ListLast(pluginsLocation,'/') />

<!--- if the plugin directory value is empty, use the default value --->
<cfif pluginDir EQ "">
	<cfset pluginDir = 'plugins' />
</cfif>

<!--- get the folder for this plugin --->
<cfset thisPluginDir = pluginConfig.getPackage() />

<cfset pluginBase = "/" & pluginDir & "/" & thisPluginDir />
<cfset pageLink = pluginBase & "/extensions/dspSearchResults.cfm" />

<cfoutput>
	<div>
	<!--- display the search results --->
	<cfif totalResultVal EQ 0>
		<p class="alert alert-danger center">
		<em>Your search yielded no results. Please use different search parameters and try again.</em>
		</p>
		<cfelse>
			<h2 class="bottomLine"><strong>Search Results</strong></h2>
			<div class="margin-bottom">
				<strong>Displaying #start_record# to #end_record# of #totalResultVal# Results</strong>
			</div>
			<cfif StructKeyExists(searchStatus,'suggestedQuery')>
				<p>
				<em>Did you mean <strong>#searchStatus.suggestedQuery#</strong>?</em>
				</p>
			</cfif>
			<!--- set the result counter --->
			<cfset resCount = 0 />
			<cfloop query="searchResults">
				<cfset resCount = resCount + 1 />
				<cfif resCount GTE start_record>
					<div class="margin-bottomlg">
						<h3><a href="#searchResults.custom4#">#searchResults.title#</a></h3>
						<p>#searchResults.summary#</p>
						<p class="small"><strong>Relevance:</strong> #NumberFormat(searchResults.score * 100,'.__')#%</p>
					</div>
				</cfif>
				<cfif resCount EQ end_record>
					<cfbreak />
				</cfif>
			</cfloop>

			<!--- display pagination --->
			<div class="center">
				<ul class="pagination">
					<!--- previous button --->
					<cfif request.page EQ 1>
						<li class="navPrev na"><a href="##">« Prev</a></li>
						<cfelse>
							<li class="navPrev"><a href="#pageLink#" data-qstring="#qstring#" data-page="#request.page - 1#" class="paging-item" id="pagePrev">« Prev</a></li>
					</cfif>

					<!--- display the pagination links between the next and previous buttons --->
					<cfif request.page LTE pages_mid_num AND num_pages LTE pages_nav_num>
						<cfloop from="1" to="#num_pages#" index="pnum">
							<cfif request.page EQ pnum><li class="active"><a href="##" class="active">#pnum#</a></li><cfelse><li><a href="#pageLink#" data-qstring="#qstring#" data-page="#pnum#" class="paging-item" id="page#pnum#">#pnum#</a></li></cfif>
						</cfloop>

					<cfelseif request.page LTE pages_mid_num AND num_pages GT pages_nav_num>
						<cfloop from="1" to="#pages_nav_num#" index="pnum">
							<cfif request.page EQ pnum><li class="active"><a href="##" class="active">#pnum#</a></li><cfelse><li><a href="#pageLink#" data-qstring="#qstring#" data-page="#pnum#" class="paging-item" id="page#pnum#">#pnum#</a></li></cfif>
						</cfloop>
						<li class="na"><a href="##">...</a></li>
						<li><a href="#pageLink#" data-qstring="#qstring#" data-page="#num_pages#" class="paging-item" id="page#num_pages#">#num_pages#</a></li>

					<cfelseif request.page GT pages_mid_num AND num_pages GT offset_next>
						<li><a href="#pageLink#" data-qstring="#qstring#" data-page="1" class="paging-item">1</a></li><cfif offset_prev GT 2><li class="na"><a href="##">...</a></li></cfif>
						<cfloop from="#offset_prev#" to="#offset_next#" index="pnum">
							<cfif request.page EQ pnum><li class="active"><a href="##" class="active">#pnum#</a></li><cfelse><li><a href="#pageLink#" data-qstring="#qstring#" data-page="#pnum#" class="paging-item" id="page#pnum#">#pnum#</a></li></cfif>
						</cfloop>
						<cfif offset_next LT num_pages - 1><li class="na"><a href="##">...</a></li></cfif><li><a href="#pageLink#" data-qstring="#qstring#" data-page="#num_pages#" class="paging-item" id="page#num_pages#">#num_pages#</a></li>

					<cfelseif request.page GT pages_mid_num AND offset_next GTE num_pages>
						<li><a href="#pageLink#" data-qstring="#qstring#" data-page="1" class="paging-item">1</a></li><cfif offset_prev GT 2><li class="na"><a href="##">...</a></li></cfif>
						<cfif pages_nav_num LT num_pages>
							<cfset last_pages = num_pages - pages_nav_num>
							<cfelse>
								<cfset last_pages = 2>
						</cfif>
						<cfloop from="#last_pages#" to="#num_pages#" index="pnum">
							<cfif request.page EQ pnum><li class="active"><a href="##" class="active">#pnum#</a></li><cfelse><li><a href="#pageLink#" data-qstring="#qstring#" data-page="#pnum#" class="paging-item" id="page#pnum#">#pnum#</a></li></cfif>
						</cfloop>
					</cfif>

					<!--- next button --->
					<cfif request.page EQ num_pages>
						<li class="navNext na"><a href="##">Next »</a></li>
						<cfelse>
							<li class="navNext"><a href="#pageLink#" data-qstring="#qstring#" data-page="#request.page + 1#" class="paging-item" id="pageNext">Next »</a></li>
					</cfif>
				</ul>
			</div>
	</cfif>
	<!--- include file to display search results loader --->
	<div class="loading hideloader" id="loadResults"><span class="fas fa-circle-notch fa-spin fa-3x graytext margin-top margin-bottom" title="loading" aria-hidden="true"></span><span class="sr-only">Loading...</span></div>
	</div>
</cfoutput>

<script>
if (document.readyState === "complete" || document.readyState !== "loading") {
	pageHandler();
} else {
	document.addEventListener("DOMContentLoaded", pageHandler);
}
</script>