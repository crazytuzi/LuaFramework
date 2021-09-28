




function start(api,need_start)
	step = api.Net.GetClientConfig('guide_daoyou')
	
	if not need_start or step == "end" then
		return
	end
	
	api.Scene.StopSeek()

	api.Net.SetClientConfig('guide_daoyou','end')
	api.Net.SendSpecificStep('guide_friend', 'end')
	btn_menu = api.UI.FindHudComponent('xmds_ui/hud/mainhud.gui.xml','btn_sociality')
	if btn_menu then
		api.SetGuideBiStep(1)
		api.PlayGuideSoundByKey('yindao_39')
		api.Wait(Helper.TouchGuide(btn_menu,{force=false,text=api.GetText('guide_daoyou_1')}))
	end

	api.Wait(api.UI.WaitMenuEnter('xmds_ui/social/main.gui.xml'))
	tbt_jieyi = api.UI.FindComponent('xmds_ui/social/main.gui.xml','tbt_jieyi')
	if tbt_jieyi then
		api.SetGuideBiStep(2)
		api.Wait(Helper.TouchGuide(tbt_jieyi,{force=false}))
	end
	
end
