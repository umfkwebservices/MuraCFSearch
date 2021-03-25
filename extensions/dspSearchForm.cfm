<!---

This file is part of MuraCFSearch

Copyright 2021 University of Maine at Fort Kent
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

--->

<cfoutput>
	<form id="svSearchAgain" name="searchForm" role="search" method="post" action="<cfif $.globalConfig().get('indexfileinurls') NEQ 'false'>/index.cfm</cfif>#CGI.PATH_INFO#">
		<div class="ui-tabs ui-widget ui-widget-content ui-corner-all">
			<div class="ui-widget-header" style="padding: .6em;">
			<strong><label for="txtKeywords">#variables.$.rbKey('search.search')#</label></strong>
			</div>
			<div class="ui-dialog-content">
				<div class="input-group">
					<input type="text" name="Keywords" id="txtKeywords" class="form-control" value="#EncodeForHTML(arguments.keywords)#" placeholder="#variables.$.rbKey('search.search')#" />
					<span class="input-group-btn">
						<button type="submit" class="btn btn-default">
							#$.rbKey('search.search')#
						</button>
					</span>
				</div>
				<!--- if the advanced search option is enabled, display a box with the advanced search form --->
				<cfif arguments.advancedOptions EQ "yes">
					<div class="row margin-top">
						<div class="col-md-6 col-sm-6 center">
							<fieldset>
								<legend>Search individual words or whole phrase?</legend>
								<input type="radio" name="wordsPhrase" id="wordsPhraseWords" value="words"<cfif arguments.wordsPhrase EQ "words"> checked="checked"</cfif> /> <label for="wordsPhraseWords">Words</label>
								<input type="radio" name="wordsPhrase" id="wordsPhrasePhrase" class="margin-left" value="phrase"<cfif arguments.wordsPhrase EQ "phrase"> checked="checked"</cfif> /> <label for="wordsPhrasePhrase">Whole Phrase</label>
							</fieldset>
						</div>
						<div class="col-md-6 col-sm-6 center">
							<fieldset>
								<legend>Search all or any words entered? &sup1;</legend>
								<input type="radio" name="allAny" id="allAnyAll" value="all"<cfif arguments.allAny EQ "all"> checked="checked"</cfif> /> <label for="allAnyAll">All Words</label>
								<input type="radio" name="allAny" id="allAnyAny" class="margin-left" value="any"<cfif arguments.allAny EQ "any"> checked="checked"</cfif> /> <label for="allAnyAny">Any Word</label>
							</fieldset>
							<div class="small">&sup1; <em>applies to word search only</em></div>
						</div>
					</div>
				</cfif>
				<input type="hidden" name="display" value="search" />
				<input type="hidden" name="newSearch" value="true" />
				<input type="hidden" name="noCache" value="1" />
			</div>
		</div>
	</form>
</cfoutput>