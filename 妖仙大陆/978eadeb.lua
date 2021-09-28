





function Quest_InProgress(api, id)
	api.Wait(api.UI.WaitMenuEnter('xmds_ui/guild/guild_hall.gui.xml'))
	api.Sleep(1)
	btn_gold  = api.UI.FindComponent('xmds_ui/guild/guild_donate.gui.xml','btn_gold')
	if not btn_gold then
		btn_culture  = api.UI.FindComponent('xmds_ui/guild/guild_hall.gui.xml','btn_donate')
		api.Wait(Helper.TouchGuide(btn_culture,{text=api.GetText('guide39'),y=6,textX=-4}))
		api.Wait(api.UI.WaitMenuEnter('xmds_ui/guild/guild_donate.gui.xml'))
		btn_gold  = api.UI.FindComponent('xmds_ui/guild/guild_donate.gui.xml','btn_gold')
		api.Wait(Helper.TouchGuide(btn_gold))
	else
		api.Wait(Helper.TouchGuide(btn_gold,{text=api.GetText('guide39'),textX=10,textY=-18}))
	end
	
end

function start(api, id, s)
	if s == api.Quest.Status.IN_PROGRESS then
		api.Wait(Helper.WaitScriptEndByType(1))
		Quest_InProgress(api,id)
	end
end
