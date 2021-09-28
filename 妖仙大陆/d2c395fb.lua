




function start(api,need_start)
	step = api.Net.GetStep()
	if not need_start or step == "end" then
		return
	end

	api.Net.SendStep('end')
	api.Sleep(10)
	local btn_tuichu = api.UI.FindHudComponent('xmds_ui/hud/mainhud.gui.xml','btn_tuichu')
	if btn_tuichu then
		api.SetGuideBiStep(1)
		api.Wait(Helper.TouchGuide(btn_tuichu,{force=false,text=api.GetText('guide_21099_1')}))
	end
end
