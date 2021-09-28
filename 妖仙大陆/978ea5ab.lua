





function Quest_New(api, id)

end

function Quest_CanFinish(api, id)

end

function Quest_InProgress(api, id)
	step = api.Net.GetStep()
	if step and step == "end" then
		return
	end
	api.Net.SendStep('end')
	
	api.SetGuideBiStep(1)
	api.PlayGuideSoundByKey('yindao_14')
	Helper.QuestHudGuide(id,{textY=-15,force=false,text=api.GetText('guide_4033_1')})
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
