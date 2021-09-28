
function start(api)
	step = api.Net.GetStep()
	
	if step == "end" then
		return
	end

	api.Net.SendStep('end')
	
	api.Scene.StopSeek()

	api.Wait(api.UI.WaitMenuEnter('xmds_ui/activity/background.gui.xml'))
	local sp_list = api.UI.FindComponent('xmds_ui/activity/background.gui.xml','sp_list')
	if sp_list then
		local cell = api.UI.FindChild(sp_list,{Name="皓月镜"})
		if cell then
			local btn_go = api.UI.FindChild(cell,"btn_go")
			if btn_go then
				api.PlayGuideSoundByKey('yindao_37')
				api.SetGuideBiStep(1)
				Helper.TouchGuide(btn_go,{textX=-15,textY=120,force= not hasteam})
			end
		end
	end

	local hasteam = api.UI.HasTeam()
	if not hasteam then
		api.Wait(api.UI.WaitMenuEnter('xmds_ui/team/main.gui.xml'))
		local btn_create_team = api.UI.FindComponent('xmds_ui/team/main.gui.xml','btn_create_team')
		if btn_create_team then
			api.SetGuideBiStep(2)
			api.Wait(Helper.TouchGuide(btn_create_team,{force=true,text=api.GetText('guide_4011_3')}))
		end

		local btn_shout = api.UI.FindComponent('xmds_ui/team/main.gui.xml','btn_shout')
		if btn_shout then
			api.SetGuideBiStep(3)
			api.Wait(Helper.TouchGuide(btn_shout,{force=true,text=api.GetText('guide_4011_4')}))
		end

		api.Wait(api.UI.WaitMenuEnter('xmds_ui/team/shout.gui.xml'))
		local btn_send = api.UI.FindComponent('xmds_ui/team/shout.gui.xml','btn_send')
		if btn_send then
			api.SetGuideBiStep(4)
			api.Wait(Helper.TouchGuide(btn_send,{force=true}))
		end
	end
end













	





	
































