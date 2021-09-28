
function Quest_New(api, id)
	step = api.Net.GetStep()
	if step == "end" then
		return
	end
	api.Net.SendStep('end')

	api.SetGuideBiStep(1)
	api.PlayGuideSoundByKey('yindao_03')
	api.Wait(Helper.NewGoodEquipGuide({textY=-15,force=true,text=api.GetText('guide_newgood')}))
	api.SetBlockTouch(true)

	api.SetGuideBiStep(2)
	Helper.QuestHudGuide(id,{textY=-15,force=true})
	api.Wait()
end

function Quest_CanFinish(api, id)

end

function Quest_InProgress(api, id)

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
