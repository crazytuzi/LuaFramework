












function start(api,need_start)
	step = api.Net.GetStep()
	if not need_start or step == "end" then
		return
	end

	
	
	
	local qualityCan = api.UI.FindComponent('xmds_ui/bag/bag.gui.xml','cvs_choose1')
	if qualityCan then
		local qualityBtn = api.UI.FindChildByCom(qualityCan,"tbt_gou")
		if qualityBtn then
			api.SetGuideBiStep(1)
			api.PlayGuideSoundByKey('yindao_18')
			api.Wait(Helper.TouchGuide(qualityBtn,{textX=60,textY=225,force=true,text=api.GetText('guide_melt_1')}))
			local btn_smelt = api.UI.FindComponent('xmds_ui/bag/bag.gui.xml','btn_smelt')
			if btn_smelt then
				api.SetGuideBiStep(2)
				api.PlayGuideSoundByKey('yindao_19')
				api.Wait(Helper.TouchGuide(btn_smelt,{textY=-15,force=true,text=api.GetText('guide_melt_2')}))
				api.Net.SendStep('end')
			end
		end
	end

	local btn_close = api.UI.FindComponent('xmds_ui/bag/bag.gui.xml','btn_close')
	if btn_close then
		api.SetGuideBiStep(3)
		api.Wait(Helper.TouchGuide(btn_close,{force=false}))
	end
end
