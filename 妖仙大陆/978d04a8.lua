






Fb_name = '海格废墟一层'

function Quest_InProgress(api, id)
	local function Logic1()
		tb_shouhui = api.UI.FindHudComponent('xmds_ui/hud/mainhud.gui.xml','tb_shouhui')
		if api.UI.IsChecked(tb_shouhui) then
			api.Wait(Helper.TouchGuide(tb_shouhui,{force=true}))
			api.Sleep(0.2)
		end
		btn_bosshome = api.UI.FindHudComponent('xmds_ui/hud/mainhud.gui.xml','btn_bosshome')
		api.Wait(Helper.TouchGuide(btn_bosshome,{force=true}))
		api.UI.WaitMenuEnter('xmds_ui/bosshome/bosshome.gui.xml')
		api.Wait()		
	end

	
	
	
	
	
	

	
	
	Logic1()
	tbt_digong = api.UI.FindComponent('xmds_ui/bosshome/bosshome.gui.xml','tbt_digong')
	api.Wait(Helper.TouchGuide(tbt_digong))
	
	
	
	
	
	
	
	
	
	
	
	

	
	
	
	
	
	btn_killboss = api.UI.FindComponent('xmds_ui/bosshome/bosshome.gui.xml','btn_killboss')
	api.Wait(Helper.TouchGuide(btn_killboss))
end

DO_MAP = 51004
function start(api, id, s)
	if s == api.Quest.Status.IN_PROGRESS and api.Scene.GetCurrengMapID() ~= DO_MAP then
		Quest_InProgress(api,id)
	end
end
