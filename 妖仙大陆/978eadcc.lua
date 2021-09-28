
function start(api, id, s)
	if s == api.Quest.Status.IN_PROGRESS then
		api.Wait(Helper.WaitScriptEndByType(1))
		api.Wait(Helper.HeroIconTouchGuide({force=true}))

		btn_sociality = api.UI.FindHudComponent('newplatform.gui.xml','btn_sociality')
		api.Wait(Helper.TouchGuide(api.UI.GetTranform(btn_sociality),{force=true}))

		api.Wait(api.UI.WaitMenuEnter('xmds_ui/social/social_friend.gui.xml'))
		btn_addfriend = api.UI.FindComponent('xmds_ui/social/social_friend.gui.xml','btn_addfriend')
		api.Wait(Helper.TouchGuide(btn_addfriend))
		api.Wait(api.UI.WaitMenuEnter('xmds_ui/social/social_addfriend.gui.xml'))
		btn_addall = api.UI.FindComponent('xmds_ui/social/social_addfriend.gui.xml','btn_addall')
		
		
		

		
		

		if api.UI.IsEnable(btn_addall) and api.UI.IsValid(btn_addall) then
			api.Wait(Helper.TouchGuide(btn_addall))
		end
	end
end
