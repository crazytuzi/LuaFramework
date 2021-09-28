






function Quest_InProgress(api, id)
	api.Wait(Helper.HeroIconTouchGuide({force=true}))
	btn_achievement = api.UI.FindHudComponent('newplatform.gui.xml','btn_achievement')
	api.Wait(Helper.TouchGuide(btn_achievement,{force=true}))
	api.SetBlockTouch(false)
	api.Wait(api.UI.WaitMenuEnter('xmds_ui/achievement/achievement.gui.xml'))
	cvs_aboutnecklace = api.UI.FindComponent('xmds_ui/achievement/achievement.gui.xml','cvs_aboutnecklace')
	btn_get = api.UI.FindChild(cvs_aboutnecklace,'btn_get')
	api.Wait(Helper.TouchGuide(btn_get,{textX=-16,textY=-16,text=api.GetText('guide69')}))

end

function start(api, id, s)
	if s == api.Quest.Status.IN_PROGRESS then
		Quest_InProgress(api,id)
	end
end
