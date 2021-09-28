
function start(api,need_start)
	step = api.Net.GetStep()
	
	if step == "end" then
		return
	end

	api.Net.SendStep('end')
	if api.Quest.isExistQuest(4033) then
		api.SetGuideBiStep(1)
		api.PlayGuideSoundByKey('yindao_14')
		Helper.QuestHudGuide(4033,{textY=-15,force=false})
		api.Wait()
	end
end
