





function Quest_InProgress(api, id)
	
	step = api.Net.GetStep()
	if step == "end" then
		return
	end

	api.Net.SendStep('end')
	
	api.Scene.StopSeek()

	ib_heroicon = api.UI.FindHudComponent('xmds_ui/hud/heroinfo.gui.xml','ib_heroicon')
	api.SetGuideBiStep(1)
	api.PlayGuideSoundByKey('yindao_40')
	api.Wait(Helper.TouchGuide(ib_heroicon,{force=true,text=api.GetText('guide_1070_1')}))
	api.Wait()

	api.Wait(api.UI.WaitMenuEnter('xmds_ui/character/background.gui.xml'))
	local btn_tupo = api.UI.FindComponent('xmds_ui/character/background.gui.xml','btn_tupo')
	if btn_tupo then
		api.SetGuideBiStep(2)
		api.PlayGuideSoundByKey('yindao_41')
		api.Wait(Helper.TouchGuide(btn_tupo,{textY=-15,force=true,text=api.GetText('guide_1070_2')}))
		api.Wait()
	end

	api.Wait(api.UI.WaitMenuEnter('xmds_ui/character/realm_break.gui.xml'))
	local btn_repair_break  = api.UI.FindComponent('xmds_ui/character/realm_break.gui.xml','btn_repair_break')
	if btn_repair_break then
		api.SetGuideBiStep(3)
		api.PlayGuideSoundByKey('yindao_42')
		api.Wait(Helper.TouchGuide(btn_repair_break,{textY=-15,force=true,text=api.GetText('guide_1070_3')}))
		api.Sleep(0.1)
	end

	local btn_close = api.UI.FindComponent('xmds_ui/character/realm_break.gui.xml','btn_close')
	if btn_close then
		api.SetGuideBiStep(4)
		api.Wait(Helper.TouchGuide(btn_close,{force=false}))
		api.Sleep(0.1)
	end

	local btn_close1 = api.UI.FindComponent('xmds_ui/character/background.gui.xml','btn_close')
	if btn_close1 then
		api.SetGuideBiStep(5)
		api.Wait(Helper.TouchGuide(btn_close1,{force=false}))
		api.Sleep(0.1)
	end
	
	if api.UI.EntryMenuOpen() == false then
		btn_menu = api.UI.FindHudComponent('xmds_ui/hud/mainhud.gui.xml','btn_menu')
		if btn_menu then
			api.SetGuideBiStep(6)
			api.PlayGuideSoundByKey('yindao_43')
			api.Wait(Helper.TouchGuide(btn_menu,{force=true,text=api.GetText('guide_4029_1')}))
		end
		api.Sleep(0.1)
	end
	
	btn_rework = api.UI.FindHudComponent('xmds_ui/hud/newplatform.gui.xml','btn_rework')
	if btn_rework then
		api.SetGuideBiStep(7)
		api.PlayGuideSoundByKey('yindao_44')
		api.Wait(Helper.TouchGuide(btn_rework,{textY=-5,force=true,text=api.GetText('guide_4029_2')}))
		api.Sleep(0.1)
	end

	api.Wait(api.UI.WaitMenuEnter('xmds_ui/rework/rework_main.gui.xml'))
	local tbt_make = api.UI.FindComponent('xmds_ui/rework/rework_main.gui.xml','tbt_make')
	if tbt_make then
		api.SetGuideBiStep(8)
		api.Wait(Helper.TouchGuide(tbt_make,{textY=-15,force=true}))
		api.Sleep(0.1)
	end
	
	local btn_make = api.UI.FindComponent('xmds_ui/rework/rework_main.gui.xml','btn_make')
	if btn_make then
		api.SetGuideBiStep(9)
		api.PlayGuideSoundByKey('yindao_45')
		api.Wait(Helper.TouchGuide(btn_make,{force=true,text=api.GetText('guide_4029_4')}))
		api.Sleep(0.1)
	end

	local btn_close = api.UI.FindComponent('xmds_ui/rework/rework_main.gui.xml','btn_close')
	if btn_close then
		api.SetGuideBiStep(10)
		api.Wait(Helper.TouchGuide(btn_close,{force=false}))
	end
end

function start(api, id)
	s = api.Quest.GetState(id)
	if s == api.Quest.Status.IN_PROGRESS then
		Quest_InProgress(api,id)
	end
end
