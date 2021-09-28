





function Quest_InProgress(api, id)
	api.Wait(api.UI.WaitMenuEnter('xmds_ui/wings/wings_new.gui.xml'))
	btn_culture = api.UI.FindComponent('xmds_ui/wings/wings_new.gui.xml','btn_culture')
	Helper.TouchGuide(btn_culture,{textX=-10,textY=-16,text=api.GetText('guide35')})
	api.PlaySoundByKey('guide35')
	api.Wait()
end

function start(api, id)
	s = api.Quest.GetState(id)
	if s == api.Quest.Status.IN_PROGRESS then
		Quest_InProgress(api,id)
	end
end
