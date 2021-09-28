

function start(api)
	step = api.Net.GetStep()
	
	if step == "end" then
		return
	end

	api.Scene.StopSeek()

	api.Wait(api.UI.WaitMenuEnter('xmds_ui/activity/background.gui.xml'))
	local sp_list = api.UI.FindComponent('xmds_ui/activity/background.gui.xml','sp_list')
	if sp_list then
		local cell = api.UI.FindChild(sp_list,{Name="问道大会"})
		if cell then
			local btn_go = api.UI.FindChild(cell,"btn_go")
			if btn_go then
				api.Net.SendStep('end')
				api.SetGuideBiStep(1)
				api.PlayGuideSoundByKey('yindao_32')
				api.Wait(Helper.TouchGuide(btn_go,{textX=-15,textY=120,force=false}))
			end
		end
	end
end
