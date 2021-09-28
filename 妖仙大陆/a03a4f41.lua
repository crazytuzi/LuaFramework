




function start(api,need_start)
	step = api.Net.GetStep()
	if not need_start or step == "end" then
		return
	end

	local btn_remake = api.UI.FindComponent('xmds_ui/rework/rework_main.gui.xml','btn_remake')
	if btn_remake then
		api.SetGuideBiStep(1)
		api.PlayGuideSoundByKey('yindao_46')
		api.Wait(Helper.TouchGuide(btn_remake,{textY=-15,force=false,text=api.GetText('guide_remake_1')}))
		api.Net.SendStep('end')

		local btn_save = api.UI.FindComponent('xmds_ui/rework/rework_main.gui.xml','btn_save')
		if btn_save then
			api.SetGuideBiStep(2)
			api.Wait(Helper.TouchGuide(btn_save,{textY=-15,force=false}))
		end

		local btn_close = api.UI.FindComponent('xmds_ui/rework/rework_main.gui.xml','btn_close')
		if btn_close then
			api.SetGuideBiStep(3)
			api.Wait(Helper.TouchGuide(btn_close,{force=false}))
		end
	end
end
