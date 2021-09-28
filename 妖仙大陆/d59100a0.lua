




function start(api,need_start)
	step = api.Net.GetClientConfig('guide_guild')

	if not need_start or step == "end" then
		return
	end
	
	

	api.Net.SetClientConfig('guide_guild','end')
	
	
	if api.UI.EntryMenuOpen() == false then
		btn_menu = api.UI.FindHudComponent('xmds_ui/hud/mainhud.gui.xml','btn_menu')
		if btn_menu then
			api.SetGuideBiStep(1)
			api.PlayGuideSoundByKey('yindao_23')
			api.Wait(Helper.TouchGuide(btn_menu,{force=false,text=api.GetText('guide_guild_1')}))
		end
	end
	
	btn_guild = api.UI.FindHudComponent('xmds_ui/hud/newplatform.gui.xml','btn_guild')
	if btn_guild then
		api.SetGuideBiStep(2)
		api.PlayGuideSoundByKey('yindao_24')
		api.Wait(Helper.TouchGuide(btn_guild,{force=false,text=api.GetText('guide_guild_2')}))
	end
	
end
