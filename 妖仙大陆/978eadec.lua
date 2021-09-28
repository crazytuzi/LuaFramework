





function Quest_InProgress(api, id)
	api.Wait(api.UI.WaitMenuEnter('xmds_ui/guild/guild_hall.gui.xml'))
	btn_science = api.UI.FindComponent('xmds_ui/guild/guild_hall.gui.xml','btn_science')
	api.Wait(Helper.TouchGuide(btn_science))

	api.Wait(api.UI.WaitMenuEnter('xmds_ui/guild/guild_keji.gui.xml'))
	cvs_skill1 = api.UI.FindComponent('xmds_ui/guild/guild_keji.gui.xml','cvs_skill1')
	btn_upskill = api.UI.FindChild(cvs_skill1,'btn_upskill')
	if api.UI.IsEnable(btn_upskill) then
		api.Wait(Helper.TouchGuide(btn_upskill,{text=api.GetText('guide49'),textX=10,textY=-18}))
	else
		Helper.TouchGuide(nil,{text=api.GetText('guide49'),textX=10,textY=-18})
		api.Sleep(4)
	end
end

function start(api, id, s)
	if s == api.Quest.Status.IN_PROGRESS then
		api.Wait(Helper.WaitScriptEndByType(1))
		Quest_InProgress(api,id)
	end
end
