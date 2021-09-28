





function Quest_New(api, id)
	
	
	
	api.SetGuideBiStep(1)
	api.PlayGuideSoundByKey('yindao_01')
	Helper.QuestHudGuide(id,{textY=-15,force=true,text=api.GetText('guide_1001_1')})
	api.SetBlockTouch(true)
	api.Wait()
end

function Quest_CanFinish(api, id)
	
	
	
end

function Quest_InProgress(api, id)
	
	
	
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
