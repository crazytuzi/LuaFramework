

function Quest_New(api, id)

end

function Quest_CanFinish(api, id)
	api.SetGuideBiStep(2)
	api.Wait(Helper.QuestNpcGuide(id,{}))
end

function Quest_InProgress(api, id)
	api.Sleep(1.0)
	local sideToolActive = api.RectTransform.TransformActive('DramaSideTool')
	if sideToolActive then
		api.Wait(api.WaitGameObjExit('DramaSideTool'))
	end
	api.SetGuideBiStep(1)
	api.PlayGuideSoundByKey('yindao_02')
	Helper.QuestHudGuide(id,{textY=-15,force=true,text=api.GetText('guide_1002_1')})
	api.Wait()
	api.SetBlockTouch(true)
	
	
	
	
	
	
	
	
	
	
end

function start(api, id, s)
	if s == api.Quest.Status.NEW then
		Quest_New(api,id)
	elseif s == api.Quest.Status.CAN_FINISH then
		Quest_CanFinish(api,id)
	elseif s == api.Quest.Status.IN_PROGRESS then
		Quest_InProgress(api,id)
	end
end
