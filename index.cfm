<cfscript>
/**
*
* This file is part of MuraCFSearch
*
* Copyright 2021 University of Maine at Fort Kent
* Licensed under the Apache License, Version v2.0
* http://www.apache.org/licenses/LICENSE-2.0
*
*/
</cfscript>
<style type="text/css">
	#bodyWrap h2, #bodyWrap p, #bodyWrap div{padding-top:1em;margin-bottom: 0;}
	#bodyWrap ul{padding:1em 0 0 .75em;margin:0 0 0 .75em;}
</style>

<cfsavecontent variable="pluginBody">
<cfoutput>
<div id="bodyWrap">
	<h1><strong>#esapiEncode('html', pluginConfig.getName())# #pluginConfig.getVersion()#</strong></h1>
	<p>This plugin replaces Mura's built-in public search feature with one leveraging the search functionality built into ColdFusion/Lucee.</p>

	<h2><strong>Features in This Version:</strong></h2>
	<ul>
		<li>Option to generate a single search index for all Mura sites assigned to the plugin or have separate indexes for each site</li>
		<li>Indexing automatically ignores hidden pages, restricted pages, and pages excluded from site search</li>
		<li>Collection prefix can either be the automatically generated one or can be set by the administrator during installation</li>
		<li>Option to enable advanced search features:
		<ul>
			<li>Search for words or for entire phrase</li>
			<li>In the case of a word search, search all words or any word</li>
		</ul>
		</li>
		<li>Scheduled task for periodic re-indexing <em>(with an option to set the interval between index updates)</em></li>
		<li>Option to set number of results per page</li>
		<li>Option for pages to inherit parent's site search status</li>
	</ul>

	<h2>Tested With</h2>
	<ul>
		<li>Mura CMS Core Version 7.1+</li>
		<li>Lucee 5.3.7.48</li>
		<li>MySQL 5.7.22</li>
	</ul>
</div>
</cfoutput>
</cfsavecontent>
<cfoutput>
	#$.getBean('pluginManager').renderAdminTemplate(pluginBody)#
</cfoutput>