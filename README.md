#MuraCFSearch

This plugin replaces Mura's built-in public search feature with one leveraging the search functionality built into ColdFusion/Lucee.


##Features in This Version:
* Option to generate a single search index for all Mura sites assigned to the plugin or have separate indexes for each site
* Indexing automatically ignores hidden pages, restricted pages, and pages excluded from site search
* Collection prefix can either be the automatically generated one or can be set by the administrator during installation
* Option to enable advanced search features:
	* Search for words or for entire phrase
	* In the case of a word search, search all words or any word
* Scheduled task for periodic re-indexing (with an option to set the interval between index updates)
* Option to set number of results per page
* Option for pages to inherit parent's site search status


##Tested With
* Mura CMS Core Version 7.1+
* Lucee 5.3.7.48
* MySQL 5.7.22 


##License
Copyright 2021 University of Maine at Fort Kent

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this work except in compliance with the License. You may obtain a copy of the License in the LICENSE file, or at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.