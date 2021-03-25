/**
*
* This file is part of MuraCFSearch
*
* Copyright 2021 University of Maine at Fort Kent
* Licensed under the Apache License, Version v2.0
* http://www.apache.org/licenses/LICENSE-2.0
*
*/
component accessors=true extends='mura.plugin.plugincfc' output=false {

	// pluginConfig is automatically available as variables.pluginConfig
	include 'settings.cfm';

	// make the Mura scope available for installation
	if ( !IsDefined('$') ) {
		siteid = session.keyExists('siteid') ? session.siteid : 'default';
		$ = application.serviceFactory.getBean('$').init(siteid);
	}

	public void function install() {
		var setAction = "installPlugin";
		include 'doinstall.cfm';

		// create the scheduled task to handle automatic indexing of the site(s)
		var setIndexSchedule = 'install';
		include 'docollection/index.cfm';
	}

	public void function update() {
		var setAction = "installPlugin";
		include 'doinstall.cfm';

		// update the scheduled task to handle automatic indexing of the site(s)
		var setIndexSchedule = 'update';
		include 'docollection/index.cfm';
	}

	public void function delete() {
		var setAction = "uninstallPlugin";
		include 'doinstall.cfm';

		// delete the scheduled task created by the plugin
		var setIndexSchedule = 'delete';
		include 'docollection/index.cfm';
	}

	// public void function toBundle(pluginConfig, bundle, siteid) output=false {
		// Do custom toBundle stuff
	// }

	// public void function fromBundle(bundle, keyFactory, siteid) output=false {
		// Do custom fromBundle stuff
	// }

	// access to the pluginConfig should available via variables.pluginConfig
	public any function getPluginConfig() {
		return StructKeyExists(variables, 'pluginConfig') ? variables.pluginConfig : {};
	}

}