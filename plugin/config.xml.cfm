<!---

This file is part of MuraCFSearch

Copyright 2021 University of Maine at Fort Kent
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

--->
<cfscript>
include 'settings.cfm';
</cfscript>
<cfoutput>
	<plugin>
		<name>#variables.settings.pluginName#</name>
		<package>#variables.settings.package#</package>
		<directoryFormat>packageOnly</directoryFormat>
		<loadPriority>#variables.settings.loadPriority#</loadPriority>
		<version>#variables.settings.version#</version>
		<provider>#variables.settings.provider#</provider>
		<providerURL>#variables.settings.providerURL#</providerURL>
		<category>#variables.settings.category#</category>
		<autoDeploy>false</autoDeploy>
		<settings>
			<setting>
				<name>cfSearchAll</name>
				<label>Should there be a single index for all subdomains?</label>
				<hint>If set to No, each Mura site will have its own collection</hint>
				<type>select</type>
				<required>true</required>
				<validation>none</validation>
				<optionlist>yes^no</optionlist>
				<optionlabellist>Yes^No</optionlabellist>
				<regex></regex>
				<message></message>
				<defaultvalue>no</defaultvalue>
			</setting>
			<setting>
				<name>cfSearchAdvanced</name>
				<label>Enable advanced search options?</label>
				<hint>If set to Yes, the search page will allow for additional search refinement fields</hint>
				<type>select</type>
				<required>true</required>
				<validation>none</validation>
				<optionlist>yes^no</optionlist>
				<optionlabellist>Yes^No</optionlabellist>
				<regex></regex>
				<message></message>
				<defaultvalue>yes</defaultvalue>
			</setting>
			<setting>
				<name>cfSearchPageRecords</name>
				<label>Records Per Page</label>
				<hint>Sets the number of results per page (defaults to 10)</hint>
				<type>text</type>
				<required>true</required>
				<validation>numeric</validation>
				<regex></regex>
				<message>The entered value must be a valid integer</message>
				<defaultvalue>10</defaultvalue>
			</setting>
			<setting>
				<name>cfSearchIndexInterval</name>
				<label>Reindex Duration</label>
				<hint>The frequency at which the site gets reindexed (in hours)</hint>
				<type>text</type>
				<required>true</required>
				<validation>numeric</validation>
				<regex></regex>
				<message>The entered value must be a valid number of hours</message>
				<defaultvalue>72</defaultvalue>
			</setting>
			<setting>
				<name>cfSearchIndexPrefix</name>
				<label>Collection Name Prefix</label>
				<hint>This prefix is added to a collection's name to ensure uniqueness of the site index</hint>
				<type>text</type>
				<required>true</required>
				<validation>none</validation>
				<regex></regex>
				<message></message>
				<defaultvalue>#CreateUUID()#</defaultvalue>
			</setting>
			<setting>
				<name>cfSearchExclude</name>
				<label>Should each subpage inherit its parent's 'Exclude from Site Search' setting?</label>
				<hint>If set to No, every page within a site must be excluded from the site search individually.</hint>
				<type>select</type>
				<required>true</required>
				<validation>none</validation>
				<optionlist>yes^no</optionlist>
				<optionlabellist>Yes^No</optionlabellist>
				<regex></regex>
				<message></message>
				<defaultvalue>no</defaultvalue>
			</setting>
		</settings>

		<!-- Event Handlers -->
		<eventHandlers>
			<!-- only need to register the eventHandler.cfc via onApplicationLoad() -->
			<eventHandler event="onSiteSearchRender" component="extensions.cfsearch" persist="false" />
		</eventHandlers>

		<displayobjects location="global" />

	</plugin>
</cfoutput>