




function start(api,need_start)
	step = api.Net.GetStep()
	if not need_start or step == "end" then
		return
	end
	
	local btn_Scurbing = api.UI.FindComponent('xmds_ui/rework/rework_main.gui.xml','btn_Scurbing')
	if btn_Scurbing then
		api.SetGuideBiStep(1)
		api.PlayGuideSoundByKey('yindao_38')
		api.Wait(Helper.TouchGuide(btn_Scurbing,{textY=-15,force=false,text=api.GetText('guide_scurbing_1')}))
		api.Net.SendStep('end')

		
		
		
		
		

		
		
		
		
		
	end
end
