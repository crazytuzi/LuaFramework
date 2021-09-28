

function start(api,need_start)
	step = api.Net.GetStep()

	if not need_start or step == "end" then
		return
	end

	if api.UI.EntryMenuOpen() == false then
		btn_menu = api.UI.FindHudComponent('xmds_ui/hud/mainhud.gui.xml','btn_menu')
		if btn_menu then
			api.Wait(Helper.TouchGuide(btn_menu,{force=true,text=api.GetText('guide_4029_1')}))
		end
		api.Sleep(0.2)
	end
	
	btn_rework = api.UI.FindHudComponent('xmds_ui/hud/newplatform.gui.xml','btn_rework')
	if btn_rework then
		api.Wait(Helper.TouchGuide(btn_rework,{textY=-5,force=true,text=api.GetText('guide_4029_2')}))
		api.Sleep(0.2)
	end

	api.Wait(api.UI.WaitMenuEnter('xmds_ui/rework/rework_main.gui.xml'))
	local tbt_make = api.UI.FindComponent('xmds_ui/rework/rework_main.gui.xml','tbt_make')
	if tbt_make then
		api.Wait(Helper.TouchGuide(tbt_make,{textY=-15,force=true,text=api.GetText('guide_4029_3')}))
		api.Sleep(0.2)
	end
	
	local btn_make = api.UI.FindComponent('xmds_ui/rework/rework_main.gui.xml','btn_make')
	if btn_make then
		api.Wait(Helper.TouchGuide(btn_make,{force=true,text=api.GetText('guide_4029_4')}))
		api.Sleep(0.2)
	end

	local btn_close = api.UI.FindComponent('xmds_ui/rework/rework_main.gui.xml','btn_close')
	if btn_close then
		api.Wait(Helper.TouchGuide(btn_close,{force=false}))
	end
end
