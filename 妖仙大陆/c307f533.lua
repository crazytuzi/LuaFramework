





function start(api,need_start)
	step = api.Net.GetStep()
	if not need_start or step == "end" then
		return
	end

	local btn_combine = api.UI.FindComponent('xmds_ui/bag/bag.gui.xml','btn_combine')
	if btn_combine then
		api.SetGuideBiStep(1)
		api.PlayGuideSoundByKey('yindao_33')
		api.Wait(Helper.TouchGuide(btn_combine,{textY=-15,force=true,text=api.GetText('guide_compound_1')}))
		api.Net.SendStep('end')
		
		local btn_close = api.UI.FindComponent('xmds_ui/bag/bag.gui.xml','btn_close')
		if btn_close then
			api.SetGuideBiStep(2)
			api.Wait(Helper.TouchGuide(btn_close,{force=false}))
		end
	end
end
