




function start(api,need_start)
	step = api.Net.GetClientConfig('guide_wendaodahui')

	if not need_start or step == "end" then
		return
	end
	
	api.Net.SetClientConfig('guide_wendaodahui','end')
	
	
	btn_menu = api.UI.FindHudComponent('xmds_ui/hud/mainhud.gui.xml','btn_activity')
	if btn_menu then
		api.SetGuideBiStep(1)
		api.PlayGuideSoundByKey('yindao_31')
		api.Wait(Helper.TouchGuide(btn_menu,{force=false,text=api.GetText('guide_wendaodahui_1')}))
	end

	api.Wait(api.UI.WaitMenuEnter('xmds_ui/activity/background.gui.xml'))
	local sp_list = api.UI.FindComponent('xmds_ui/activity/background.gui.xml','sp_list')
	if sp_list then
		local cell = api.UI.FindChild(sp_list,{Name="问道大会"})
		if cell then
			local btn_go = api.UI.FindChild(cell,"btn_go")
			if btn_go then
				
				api.SetGuideBiStep(2)
				api.PlayGuideSoundByKey('yindao_32')
				api.Wait(Helper.TouchGuide(btn_go,{textX=-15,textY=120,force=false,text=api.GetText('guide_wendaodahui_2')}))
			end
		end
	end
end
