
function Quest_New(api, id)

end

function Quest_CanFinish(api, id)

end

function Quest_InProgress(api, id)
	
	api.Scene.StopSeek()

	ib_heroicon = api.UI.FindHudComponent('xmds_ui/hud/heroinfo.gui.xml','ib_heroicon')
	api.Wait(Helper.TouchGuide(ib_heroicon,{force=true,text=api.GetText('guide_4005_1')}))
	api.Wait()

	api.Wait(api.UI.WaitMenuEnter('xmds_ui/character/background.gui.xml'))
	local tbt_strg = api.UI.FindComponent('xmds_ui/character/background.gui.xml','tbt_strg')
	if tbt_strg then
		api.Wait(Helper.TouchGuide(tbt_strg,{force=true,text=api.GetText('guide_4005_2')}))
		api.Wait()
	end
	
	local btn_strengthen = api.UI.FindComponent('xmds_ui/character/background.gui.xml','btn_strengthen')
	if btn_strengthen then
		api.Wait(Helper.TouchGuide(btn_strengthen,{textY=-15,force=true,text=api.GetText('guide_4005_3')}))
		api.Wait()
		api.Wait(Helper.TouchGuide(btn_strengthen,{textY=-15,force=true,text=api.GetText('guide_4005_4')}))
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
