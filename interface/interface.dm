//Please use mob or src (Nãot usr) in these procs. This way they can be called in the same fashion as procs.
/client/verb/wiki(query as text)
	set name = "wiki"
	set desc = "Digite o que você quer saber.  Isso vai abrir a wiki no seu navegador. Digite nada e você irá a página inicial."
	set hidden = TRUE
	var/wikiurl = CONFIG_GET(string/wikiurl)
	if(wikiurl)
		if(query)
			var/output = wikiurl + "/index.php?title=Special%3ASearch&profile=default&search=" + query
			src << link(output)
		else if (query != null)
			src << link(wikiurl)
	else
		to_chat(src, span_danger("Wiki URL não foi configurado no servidor."))
	return

/client/verb/forum()
	set name = "forum"
	set desc = "Visite o forum."
	set hidden = TRUE
	var/forumurl = CONFIG_GET(string/forumurl)
	if(forumurl)
		if(tgui_alert(src, "isso vai abrir o forum no seu navegador. Tem certeza?",, list("Sim","Não"))!="Sim")
			return
		src << link(forumurl)
	else
		to_chat(src, span_danger("Forum URL não foi configurado no servidor."))
	return

/client/verb/rules()
	set name = "regras"
	set desc = "Mostrar regras do servidor."
	set hidden = TRUE
	var/rulesurl = CONFIG_GET(string/rulesurl)
	if(rulesurl)
		if(tgui_alert(src, "isso vai abrir as regras no seu navegador. Tem certeza?",, list("Sim","Não"))!="Sim")
			return
		src << link(rulesurl)
	else
		to_chat(src, span_danger("Regras URL não foi configurado no servidor."))
	return

/client/verb/github()
	set name = "github"
	set desc = "Visite o Github"
	set hidden = TRUE
	var/githuburl = CONFIG_GET(string/githuburl)
	if(githuburl)
		if(tgui_alert(src, "isso vai abrir o repositorio no github no seu navegador. Tem certeza?",, list("Sim","Não"))!="Sim")
			return
		src << link(githuburl)
	else
		to_chat(src, span_danger("Github URL não foi configurado no servidor."))
	return

/client/verb/reportissue()
	set name = "reportar-issue"
	set desc = "Reporte uma issue"
	set hidden = TRUE
	var/githuburl = CONFIG_GET(string/githuburl)
	if(!githuburl)
		to_chat(src, span_danger("Github URL não foi configurado no servidor."))
		return

	var/testmerge_data = GLOB.revdata.testmerge
	var/has_testmerge_data = (length(testmerge_data) != 0)

	var/message = "Isso vai abrir o reportador de Issue no github em seu navegador. Tem certeza?"
	if(has_testmerge_data)
		message += "<br>As seguintes mudanças experimentais estão ativas e possivelmente poderão causar problemas com a sua experiencia. Se possivel, tente achar uma thread especifica de seu problema invez de postar no issue tracker geral:<br>"
		message += GLOB.revdata.GetTestMergeInfo(FALSE)

	// We still use tgalert here because some people were concerned that if someone wanted to report that tgui wasn't working
	// then the report issue button being tgui-based would be problematic.
	if(tgalert(src, message, "Reporte Issue","Sim","Não") != "Sim")
		return

	var/base_link = githuburl + "/issues/new?template=bug_report_form.yml"
	var/list/concatable = list(base_link)

	var/client_version = "[byond_version].[byond_build]"
	concatable += ("&reporting-version=" + client_version)

	// the way it works is that we use the ID's that are baked into the template YML and replace them with values that we can collect in game.
	if(GLOB.round_id)
		concatable += ("&round-id=" + GLOB.round_id)

	// Insert testmerges
	if(has_testmerge_data)
		var/list/all_tms = list()
		for(var/entry in testmerge_data)
			var/datum/tgs_revision_information/test_merge/tm = entry
			all_tms += "- \[[tm.title]\]([githuburl]/pull/[tm.number])"
		var/all_tms_joined = jointext(all_tms, "%0A") // %0A is a newline for URL encoding because i don't trust \n to Nãot break

		concatable += ("&test-merges=" + all_tms_joined)

	DIRECT_OUTPUT(src, link(jointext(concatable, "")))


/client/verb/changelog()
	set name = "Changelog"
	set category = "OOC"
	if(!GLOB.changelog_tgui)
		GLOB.changelog_tgui = new /datum/changelog()

	GLOB.changelog_tgui.ui_interact(mob)
	if(prefs.lastchangelog != GLOB.changelog_hash)
		prefs.lastchangelog = GLOB.changelog_hash
		prefs.save_preferences()
		winset(src, "infowindow.changelog", "font-style=;")

/client/verb/hotkeys_help()
	set name = "Ajuda Teclas de atalho"
	set category = "OOC"

	if(!GLOB.hotkeys_tgui)
		GLOB.hotkeys_tgui = new /datum/hotkeys_help()

	GLOB.hotkeys_tgui.ui_interact(mob)
