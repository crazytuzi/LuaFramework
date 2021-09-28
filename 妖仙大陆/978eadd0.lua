





function Quest_InProgress(api, id)
	
	
	
	
	

	
	
	
	
	

	api.Wait(Helper.HeroIconTouchGuide({force=true}))
	btn_character = api.UI.FindHudComponent('newplatform.gui.xml','btn_character')
	api.Wait(Helper.TouchGuide(api.UI.GetTranform(btn_character),{force=true}))
	api.Wait(api.UI.WaitMenuEnter('xmds_ui/character/ui_character.gui.xml'))

	tb_juewei = api.UI.FindComponent('xmds_ui/character/ui_character.gui.xml','tb_juewei')
	api.Wait(Helper.TouchGuide(tb_juewei,{force=true}))

	api.Wait(api.UI.WaitMenuEnter('xmds_ui/reputation/reputation.gui.xml'))
	btn_ways = api.UI.FindComponent('xmds_ui/reputation/reputation.gui.xml','btn_ways')
	api.PlaySoundByKey('guide36')
	btn_get = api.UI.FindComponent('xmds_ui/reputation/reputation.gui.xml','btn_get')
	Helper.TouchGuide(btn_get,{text = api.GetText('guide36'),textY=-18})
	api.Wait()
end

function start(api, id, s)
	if s == api.Quest.Status.IN_PROGRESS then
		api.Wait(Helper.WaitScriptEndByType(1))
		Quest_InProgress(api,id)
	end
end
