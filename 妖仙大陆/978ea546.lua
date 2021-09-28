	
function Quest_InProgress(api, id)
	
	step = api.Net.GetStep()
	if step == "end" then
		return
	end

	api.Scene.StopSeek()
	api.Net.SendStep('end')
	
	api.SetGuideBiStep(1)
	api.PlayGuideSoundByKey('yindao_15')
	api.Wait(Helper.QuestHudGuide(id,{textY=-15,force=false,text=api.GetText('guide_4001_1')}))
end

function start(api, id)
	s = api.Quest.GetState(id)
	if s == api.Quest.Status.IN_PROGRESS then
		Quest_InProgress(api,id)
	end
end
