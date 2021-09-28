
function start(api, id, s)
	if s == api.Quest.Status.IN_PROGRESS then
		api.Wait(Helper.WaitScriptEndByType(1))
		api.Wait(api.UI.WaitMenuEnter('xmds_ui/social/social_friend.gui.xml'))
		btn_allfocus = api.UI.FindComponent('xmds_ui/social/social_friend.gui.xml','btn_allfocus')
		api.Sleep(1)
		if api.UI.IsValid(btn_allfocus) and api.UI.IsEnable(btn_allfocus) then
			api.Wait(Helper.TouchGuide(btn_allfocus,{textX=-10,textY=-16,text=api.GetText('guide45')}))
		else
			Helper.TouchGuide(nil,{text=api.GetText('guide45')})
			api.Sleep(4)
		end
	end
end
