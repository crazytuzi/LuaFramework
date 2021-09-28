




	
	
	
	
	
	


function start(api,need_start)
	step = api.Net.GetStep()
	if not need_start or step == "end" then
		return
	end

	btn_up = api.UI.FindComponent('xmds_ui/ride/culture.gui.xml','btn_up')
	if btn_up then
		api.Net.SendStep('end')
		api.SetGuideBiStep(1)
		api.PlayGuideSoundByKey('yindao_12')
		api.Wait(Helper.TouchGuide(btn_up,{textY=-15,force=false,text=api.GetText('guide_ride_1')}))
		api.Wait()
	end

	
	
	
	
	
end
