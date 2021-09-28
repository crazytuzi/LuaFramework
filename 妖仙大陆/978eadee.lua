





function Quest_InProgress(api, id)
	api.Wait(api.UI.WaitMenuEnter('xmds_ui/guild/guild_hall.gui.xml'))
	btn_qifu = api.UI.FindComponent('xmds_ui/guild/guild_hall.gui.xml','btn_qifu')
	api.Wait(Helper.TouchGuide(btn_qifu,{text=api.GetText('guide51')}))
end

function start(api, id)
	s = api.Quest.GetState(id)
	if s == api.Quest.Status.IN_PROGRESS then
		api.Wait(Helper.WaitScriptEndByType(1))
		Quest_InProgress(api,id)
	end
end
