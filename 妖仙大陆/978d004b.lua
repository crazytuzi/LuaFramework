





function Quest_New(api, id)
	step = api.Net.GetStep()
	if step and step == "end" then
		return
	end

	api.Net.SendStep('end')

	api.Scene.StopSeek()
	api.Wait(api.UI.WaitMenuExit('xmds_ui/npc/npc.gui.xml'))

	api.Wait(Helper.NewGoodEquipGuide({textY=-15,force=true,text=api.GetText('guide_newgood')}))
	api.SetBlockTouch(true)

	local ib_heroicon = api.UI.FindHudComponent('xmds_ui/hud/heroinfo.gui.xml','ib_heroicon')
	if ib_heroicon then
		api.SetGuideBiStep(2)
		api.PlayGuideSoundByKey('yindao_05')
		api.Wait(Helper.TouchGuide(ib_heroicon,{force=true,text=api.GetText('guide_1018_2')}))
	end

	api.Wait(api.UI.WaitMenuEnter('xmds_ui/character/background.gui.xml'))
	local tbt_strg = api.UI.FindComponent('xmds_ui/character/background.gui.xml','tbt_strg')
	if tbt_strg then
		api.SetGuideBiStep(3)
		api.PlayGuideSoundByKey('yindao_06')
		api.Wait(Helper.TouchGuide(tbt_strg,{force=true,text=api.GetText('guide_1018_3')}))
	end

	
	
	
	
	
	
	
	
	

	local btn_strengthen = api.UI.FindComponent('xmds_ui/character/background.gui.xml','btn_strengthen')
	if btn_strengthen then
		api.SetGuideBiStep(5)
		api.PlayGuideSoundByKey('yindao_08')
		api.Wait(Helper.TouchGuide(btn_strengthen,{textY=-15,force=true,text=api.GetText('guide_1018_5')}))
		api.SetGuideBiStep(6)
		api.PlayGuideSoundByKey('yindao_09')
		api.Wait(Helper.TouchGuide(btn_strengthen,{textY=-15,force=true,text=api.GetText('guide_1018_6')}))
		api.SetGuideBiStep(7)
		api.PlayGuideSoundByKey('yindao_10')
		api.Wait(Helper.TouchGuide(btn_strengthen,{textY=-15,force=true,text=api.GetText('guide_1018_7')}))
	end

	local btn_close = api.UI.FindComponent('xmds_ui/character/background.gui.xml','btn_close')
	if btn_close then
		api.SetGuideBiStep(8)
		api.PlayGuideSoundByKey('yindao_11')
		api.Wait(Helper.TouchGuide(btn_close,{force=true,text=api.GetText('guide_1018_8')}))
	end

	api.SetGuideBiStep(9)
	Helper.QuestHudGuide(id,{textY=-15,force=false})
	api.Wait()
end

function Quest_CanFinish(api, id)

end

function Quest_InProgress(api, id)
	api.SetGuideBiStep(10)
	Helper.QuestHudGuide(id,{textY=-15,force=false})
	api.Wait()
end

function start(api, id)
	s = api.Quest.GetState(id)
	if s == api.Quest.Status.NEW then
		Quest_New(api,id)
	elseif s == api.Quest.Status.CAN_FINISH then
		Quest_CanFinish(api,id)
	elseif s == api.Quest.Status.IN_PROGRESS then
		Quest_InProgress(api,id)
	end
end
