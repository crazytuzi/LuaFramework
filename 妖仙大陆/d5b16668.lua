












function start(api,need_start)
	step = api.Net.GetStep()
	if not need_start or step == "end" then
		return
	end

	local sp_gem_list = api.UI.FindComponent('xmds_ui/character/background.gui.xml','sp_gem_list')
	if sp_gem_list then
		local cell = api.UI.FindChild(sp_gem_list,{Name="inlayCell_1"})
		if cell then
			local btn_equip = api.UI.FindChild(cell,"btn_equip")
			if btn_equip then
				api.SetGuideBiStep(1)
				api.PlayGuideSoundByKey('yindao_20')
				api.Wait(Helper.TouchGuide(btn_equip,{textY=-15,textY=80,force=true,text=api.GetText('guide_inlay_1')}))
				api.Net.SendStep('end')
				api.Wait()
				local btn_close = api.UI.FindComponent('xmds_ui/character/background.gui.xml','btn_close')
				if btn_close then
					api.SetGuideBiStep(2)
					api.Wait(Helper.TouchGuide(btn_close,{force=true}))
				end
			end
		end
	end
end
