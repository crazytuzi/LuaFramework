
function Quest_New(api, id)
	
end

function Quest_CanFinish(api, id)

end

function Quest_InProgress(api, id)
	api.SetGuideBiStep(1)
	Helper.QuestHudGuide(id,{textY=-15,force=false})
	api.Wait()
end

function Quest_Done(api, id)
	api.Scene.StopSeek()

	api.Wait(api.UI.WaitMenuEnter('xmds_ui/ride/congratulation.gui.xml'))
	local btn_confirm = api.UI.FindComponent('xmds_ui/ride/congratulation.gui.xml','btn_confirm')
	api.SetGuideBiStep(2)
	api.Sleep(0.5)
	api.PlayGuideSoundByKey('yindao_13')
	api.Wait(Helper.TouchGuide(btn_confirm,{force=true}))
	api.Sleep(0.5)
	
end

function start(api, id)
	s = api.Quest.GetState(id)
	if s == api.Quest.Status.NEW then
		Quest_New(api,id)
	elseif s == api.Quest.Status.CAN_FINISH then
		Quest_CanFinish(api,id)
	elseif s == api.Quest.Status.IN_PROGRESS then
		Quest_InProgress(api,id)
	elseif s == api.Quest.Status.IN_DONE then
		api.UI.OpenSkinChoiceUI()
		Quest_Done(api,id)
	end
end
