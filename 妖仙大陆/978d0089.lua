
function Quest_New(api, id)

end

function Quest_CanFinish(api, id)

end

function Quest_InProgress(api, id)
	step = api.Net.GetStep()
	if step and step == "end" then
		return
	end
	api.Scene.StopSeek()
	api.SetGuideBiStep(1)
	api.PlayGuideSoundByKey('yindao_21')
	Helper.QuestHudGuide(id,{textY=-15,force=true,text=api.GetText('guide_1034_1')})
	api.SetBlockTouch(true)
	api.Wait()

	api.Wait(api.UI.WaitMenuEnter('xmds_ui/activity/background.gui.xml'))
	local sp_list = api.UI.FindComponent('xmds_ui/activity/background.gui.xml','sp_list')
	if sp_list then
		local cell = api.UI.FindChild(sp_list,{Name="师门"})
		if cell then
			local btn_go = api.UI.FindChild(cell,"btn_go")
			if btn_go then
				
				api.Net.SendStep('end')
				api.SetGuideBiStep(2)
				api.PlayGuideSoundByKey('yindao_22')
				api.Wait(Helper.TouchGuide(btn_go,{textY=-15,force=true,text=api.GetText('guide_1034_2')}))
				api.SetBlockTouch(true)
				api.Wait()
			end
		end
	end
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
