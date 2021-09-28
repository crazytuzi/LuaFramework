




function start(api,need_start)
	
	step = api.Net.GetStep()
	if not need_start or step == "end" then
		return
	end
	
	api.Net.SendStep('end')

	api.Scene.StopSeek()
	
	api.Wait(api.UI.WaitMenuExit('xmds_ui/npc/npc.gui.xml'))

	if api.UI.EntryMenuOpen() == false then
		btn_menu = api.UI.FindHudComponent('xmds_ui/hud/mainhud.gui.xml','btn_menu')
		if btn_menu then
			api.SetGuideBiStep(1)
			api.PlayGuideSoundByKey('yindao_25')
			api.Wait(Helper.TouchGuide(btn_menu,{textY=-5,force=true,text=api.GetText('guide_pet_1')}))
		end
		api.Sleep(0.1)
	end
	
	btn_pet = api.UI.FindHudComponent('xmds_ui/hud/newplatform.gui.xml','btn_pet')
	if btn_pet then
		api.SetGuideBiStep(2)
		api.PlayGuideSoundByKey('yindao_26')
		api.Wait(Helper.TouchGuide(btn_pet,{textY=-5,force=true,text=api.GetText('guide_pet_2')}))
	end
	api.Sleep(0.1)

	btn_call = api.UI.FindComponent('xmds_ui/pet/main.gui.xml','btn_call')
	if btn_call then
		api.SetGuideBiStep(3)
		api.PlayGuideSoundByKey('yindao_27')
		api.Wait(Helper.TouchGuide(btn_call,{textY=-15,force=true,text=api.GetText('guide_pet_3')}))
	end
	api.Sleep(0.2)

	btn_yes = api.UI.FindComponent('xmds_ui/ride/congratulation.gui.xml','btn_yes')
	if btn_yes then
		api.SetGuideBiStep(4)
		api.Sleep(0.5)
		api.PlayGuideSoundByKey('yindao_28')
		api.Wait(Helper.TouchGuide(btn_yes,{force=true,text=api.GetText('guide_pet_4')}))
	end

	local btn_evolution = api.UI.FindComponent('xmds_ui/pet/main.gui.xml','btn_evolution')
	if btn_evolution then
		api.SetGuideBiStep(5)
		api.PlayGuideSoundByKey('yindao_29')
		api.Wait(Helper.TouchGuide(btn_evolution,{textY=-15,force=true,text=api.GetText('guide_pet_5')}))
		api.Sleep(0.1)
	end
	local sp_updata = api.UI.FindComponent('xmds_ui/pet/levelup.gui.xml','sp_updata')
	if sp_updata then
		local cell = api.UI.FindChild(sp_updata,{Name="cvs_updata1"})
		if cell then
			local btn_use = api.UI.FindChild(cell,"btn_use")
			if btn_use then
				api.SetGuideBiStep(6)
				api.PlayGuideSoundByKey('yindao_30')
				api.Wait(Helper.TouchGuide(btn_use,{textY=-15,force=true,text=api.GetText('guide_pet_6')}))
			end
		end
	end
	
	local btn_close = api.UI.FindComponent('xmds_ui/pet/levelup.gui.xml','btn_close')
	if btn_close then
		api.SetGuideBiStep(7)
		api.Wait(Helper.TouchGuide(btn_close,{force=false}))
	end
	
	
	
	
	
end
