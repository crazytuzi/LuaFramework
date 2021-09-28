





function Quest_InProgress(api, id)
	api.Wait(api.UI.WaitMenuEnter('xmds_ui/jjc/jjc_reward.gui.xml'))
	btn_enter = api.UI.FindComponent('xmds_ui/jjc/jjc_reward.gui.xml','btn_enter')
	api.Wait(Helper.TouchGuide(btn_enter,{textX=-10,textY=-10,text=api.GetText('guide53')}))
end

function start(api, id, s)
	if s == api.Quest.Status.IN_PROGRESS then
		api.Wait(Helper.WaitScriptEndByType(1))
		Quest_InProgress(api,id)
	end
end
