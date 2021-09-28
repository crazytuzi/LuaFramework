
function start(api, id, s)
	if s == api.Quest.Status.IN_PROGRESS then
		api.Wait(Helper.WaitScriptEndByType(1))
		api.Wait(Helper.HeroIconTouchGuide({force=true}))
		btn_sociality = api.UI.FindHudComponent('newplatform.gui.xml','btn_sociality')
		api.Wait(Helper.TouchGuide(api.UI.GetTranform(btn_sociality),{force=true}))

		api.Wait(api.UI.WaitMenuEnter('xmds_ui/social/social_main.gui.xml'))

		tbt_changeshop = api.UI.FindComponent('xmds_ui/social/social_main.gui.xml','tbt_changeshop')
		eid = Helper.TouchGuide(api.UI.GetTranform(tbt_changeshop),{noDestory=true})
		api.Wait(api.UI.PointerClick(tbt_changeshop))
		api.StopEvent(eid)
		api.Sleep(0.3)
		Helper.TouchGuide(nil,{text=api.GetText('guide46')})
		api.Sleep(2.5)
	end
end
