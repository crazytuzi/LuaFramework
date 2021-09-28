




function start(api,need_start)
	step = api.Net.GetStep()
	if not need_start or step == "end" then
		return
	end

	
	
	
	
	
	
	
	
	
	
	
	
	

	local btn_refine = api.UI.FindComponent('xmds_ui/rework/rework_main.gui.xml','btn_refine')
	if btn_refine then
		api.SetGuideBiStep(1)
		api.PlayGuideSoundByKey('yindao_47')
		api.Wait(Helper.TouchGuide(btn_refine,{textY=-15,force=false,text=api.GetText('guide_refine_1')}))
		api.Net.SendStep('end')

		local btn_close = api.UI.FindComponent('xmds_ui/rework/rework_main.gui.xml','btn_close')
		if btn_close then
			api.SetGuideBiStep(2)
			api.Wait(Helper.TouchGuide(btn_close,{force=false}))
		end
	end
end
