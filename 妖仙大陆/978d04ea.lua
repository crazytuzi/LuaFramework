






HP_Name = '强效生命药剂'
MP_Name = '强效法力药剂'

function Quest_InProgress(api, id)
	tb_shouhui = api.UI.FindHudComponent('xmds_ui/hud/mainhud.gui.xml','tb_shouhui')
	if api.UI.IsChecked(tb_shouhui) then
		api.Wait(Helper.TouchGuide(tb_shouhui,{force=true}))
		api.Sleep(0.2)
	end
	btn_bosshome = api.UI.FindHudComponent('xmds_ui/hud/mainhud.gui.xml','btn_bosshome')
	api.Wait(Helper.TouchGuide(btn_bosshome,{force=true}))
	api.UI.WaitMenuEnter('xmds_ui/bosshome/bosshome.gui.xml')
	btn_into = api.UI.FindComponent('xmds_ui/bosshome/bosshome.gui.xml','btn_into')
	api.Wait(Helper.TouchGuide(btn_into))
end

function Quest_DONE(api,id)
	tb_shouhui = api.UI.FindHudComponent('xmds_ui/hud/mainhud.gui.xml','tb_shouhui')
	if api.UI.IsChecked(tb_shouhui) then
		api.Wait(Helper.TouchGuide(tb_shouhui))
		api.Sleep(0.2)
	end	
	local function ChangeSelect(name)
		api.UI.WaitMenuEnter('xmds_ui/hangup/hangup_change.gui.xml')
		sp_see = api.UI.FindComponent('xmds_ui/hangup/hangup_change.gui.xml','sp_see')
		lb_potionname = api.UI.FindChild(sp_see,function (uid)
			return api.UI.GetText(uid) == name
		end)
		if lb_potionname then
			cvs = api.UI.GetParent(lb_potionname)
			btn_choose = api.UI.FindChild(cvs,'btn_choose')
			api.Wait(Helper.TouchGuide(btn_choose))
		end
	end

	btn_hangup = api.UI.FindHudComponent('xmds_ui/hud/mainhud.gui.xml','btn_hangup')
	api.Wait(Helper.TouchGuide(btn_hangup))
	api.UI.WaitMenuEnter('xmds_ui/hangup/hangup_main.gui.xml')

	btn_lifechange = api.UI.FindComponent('xmds_ui/hangup/hangup_main.gui.xml','btn_lifechange')
	api.Wait(Helper.TouchGuide(btn_lifechange))
	ChangeSelect(HP_Name)

	btn_magicchange = api.UI.FindComponent('xmds_ui/hangup/hangup_main.gui.xml','btn_magicchange')
	api.Wait(Helper.TouchGuide(btn_magicchange))
	ChangeSelect(MP_Name)

end

function start(api, id, s)
	if s == api.Quest.Status.IN_PROGRESS and 93003 ~= api.Scene.GetCurrentSceneID()  then
		Quest_InProgress(api,id)
	elseif s == api.Quest.Status.DONE then
		Quest_DONE(api,id)
	end
end
