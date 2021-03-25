/*

This file is part of MuraCFSearch

Copyright 2021 University of Maine at Fort Kent
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

*/

// function to load search results into the search container using Mura.js ajax functions
var loadResults = function(url,qstring,page) {
	var loadURL = url + '?' + qstring + '&page=' + page;
	loadContent(loadURL,'siteSearchResults',pageHandler);
	// toggle the css class of the search loader
	toggleClass('loadResults','hideloader');
	goToAnchor('svSearchAgain');
}

var loadContent = function(url,container,callback) {
	// set variables for the content request
	var xmlhttp;
	var infoUrl = url;
	if (window.XMLHttpRequest) {
		// code for IE7+, Firefox, Chrome, Opera, Safari
		xmlhttp = new XMLHttpRequest();
	} else {
		// code for IE6, IE5
		xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
	}
	xmlhttp.onreadystatechange = function() {
		if (xmlhttp.readyState==4 && xmlhttp.status==200) {
			var respTxt = xmlhttp.responseText;
			document.getElementById(container).innerHTML=respTxt;
			if (callback) {
				callback();
			}
		}
	};
	xmlhttp.open("GET",infoUrl,true);
	xmlhttp.setRequestHeader("Content-type","application/x-www-form-urlencoded");
	xmlhttp.send(null);
};

var contentEval = function (container) {
	var scripts = document.getElementById(container).getElementsByTagName("script");
	for(var i=0; i<scripts.length; i++) {
		eval(scripts[i].innerHTML);
	}
};

// set eventlisteners for pagination links to load each pages' results
var pageHandler = function() {
	var pages = document.querySelectorAll('.paging-item');
	if (pages) {
		for (var l = 0; l < pages.length; l++) {
			(function() {
				var item = pages[l];
				var u = item.getAttribute('href');
				var q = item.getAttribute('data-qstring');
				var p = item.getAttribute('data-page');
				var loadURL = u + '?' + q + '&page=' + p;
				item.addEventListener('click', function(e) {
					e.preventDefault();
					loadResults(u,q,p);
				});
			}());

			/*document.getElementById(pid).addEventListener('keypress', (e) => {
				e.preventDefault();
				var thisKey = e.keyCode;
				if (thisKey == 13) {
					toggleClass('loadResults','hideloader');
					var u = item.getAttribute('href');
					var q = item.getAttribute('data-qstring');
					var p = item.getAttribute('data-page');
					loadResults(u,q,p);
				}
			});*/
		}
	}
};

// function to jump to an anchor
var goToAnchor = function (a) {
	window.location = String(window.location).replace(/\#.*$/, "") + "#" + a;
	window.scrollBy(0,-100);
}

// function to toggle CSS classes
var toggleClass = function (e,c) {
	var el = document.getElementById(e);
	el.classList.toggle(c);
}