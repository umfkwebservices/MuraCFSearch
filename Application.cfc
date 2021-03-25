<!---/**
*
* This file is part of MuraCFSearch
*
* Copyright 2021 University of Maine at Fort Kent
* Licensed under the Apache License, Version v2.0
* http://www.apache.org/licenses/LICENSE-2.0
*
*/ --->
component accessors=true output=false {

	property name='$';

	local.pluginPath = GetDirectoryFromPath(GetCurrentTemplatePath());
	local.muraroot = Left(local.pluginPath, Find('plugins', local.pluginPath, 1) - 1);

	if (DirectoryExists(local.muraroot & 'core')) {
		this.muraAppConfigPath = '../../core/appcfc/';
	} else {
		this.muraAppConfigPath = '../../config/';
	}
	include 'plugin/settings.cfm';
	include this.muraAppConfigPath & 'applicationSettings.cfm';
	try {
		include this.muraAppConfigPath & 'mappings.cfm';
		include '../mappings.cfm';
	} catch(any e) {}

	public any function onApplicationStart() {
		if (this.muraAppConfigPath CONTAINS 'core/') {
			include this.muraAppConfigPath & 'onApplicationStart_include.cfm';
		} else {
			include this.muraAppConfigPath & 'appcfc/onApplicationStart_include.cfm';
		}
		return true;
	}

	public any function onRequestStart(required string targetPage) {
		if (this.muraAppConfigPath CONTAINS 'core/') {
			include this.muraAppConfigPath & 'onRequestStart_include.cfm';
		} else {
			include this.muraAppConfigPath & 'appcfc/onRequestStart_include.cfm';
		}
		return true;
	}

	public void function onRequest(required string targetPage) {
		var $ = get$();
		var pluginConfig = $.getPlugin(variables.settings.pluginName);
		include arguments.targetPage;
	}


	// ----------------------------------------------------------------------
	// HELPERS

	private struct function get$() {
		if ( !StructKeyExists(arguments, '$') ) {
			var siteid = StructKeyExists(session, 'siteid') ? session.siteid : 'default';

			arguments.$ = StructKeyExists(request, 'murascope')
				? request.murascope
				: StructKeyExists(application, 'serviceFactory')
					? application.serviceFactory.getBean('$').init(siteid)
					: {};
		}

		return arguments.$;
	}

	public boolean function inPluginDirectory() {
		var uri = getPageContext().getRequest().getRequestURI();
		return ListFindNoCase(uri, 'plugins', '/') && ListFindNoCase(uri, variables.settings.package,'/');
	}


	public any function stripMarkUp(required string str) {
		var body = ReReplace(arguments.str, "<[^>]*>","","all");
		var regex1 = "(\[sava\]|\[mura\]|\[m\]).+?(\[/sava\]|\[/mura\]|\[/m\])";
		var finder = ReFindNoCase(regex1,body,1,"true");
		while (finder.len[1]) {
			body = ReplaceNoCase(body,mid(body, finder.pos[1], finder.len[1]),'');
			finder = ReFindNoCase(regex1,body,1,"true");
		}
		return body;
	}

}
