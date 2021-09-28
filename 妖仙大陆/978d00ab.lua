





function Quest_CanFinish(api, id)
	api.Wait(Helper.QuestHudGuide(id))
end

function Quest_InProgress(api, id)
	api.Wait(Helper.HeroIconTouchGuide({force=true}))
	
	btn_rework = api.UI.FindHudComponent('newplatform.gui.xml','btn_rework')
	api.Wait(Helper.TouchGuide(btn_rework,{force=true}))

	api.UI.WaitMenuEnter('xmds_ui/inherit/inherit_main.gui.xml')
	api.Wait()
	sp_eqmsee = api.UI.FindComponent('xmds_ui/inherit/inherit_main.gui.xml','sp_eqmsee')

	proName = api.GetProKey()
	con = api.UI.FindChild(sp_eqmsee)

	itshow = api.UI.FindItemShow(con,{static={Type = '主手',Pro = proName}})
	if not itshow then
		return 
	end
	Helper.TouchGuide(itshow,{text=api.GetText('guide29')})
	api.Wait()
	sp_itsee = api.UI.FindComponent('xmds_ui/inherit/inherit_main.gui.xml','sp_itsee')
	con = api.UI.FindChild(sp_itsee)
	itshow = api.UI.FindItemShow(con,{static={Type = '主手',Pro = proName, LevelReq=40}})
	if not itshow then
		return 
	end
	
	api.Wait(Helper.TouchGuide(itshow))
	api.Sleep(0.5)
	btn_determine = api.UI.FindComponent('xmds_ui/inherit/inherit_main.gui.xml','btn_determine')
	api.Wait(Helper.TouchGuide(btn_determine))

	
	
	
	
	

	
	
	
end

function start(api, id)
	s = api.Quest.GetState(id)
	if s == api.Quest.Status.CAN_FINISH then
		Quest_CanFinish(api,id)
	elseif s == api.Quest.Status.IN_PROGRESS then
		Quest_InProgress(api,id)
	end
end
