





function Quest_InProgress(api, id)

	tb_shouhui = api.UI.FindHudComponent('xmds_ui/hud/mainhud.gui.xml','tb_shouhui')
	if api.UI.IsChecked(tb_shouhui) then
		api.Wait(Helper.TouchGuide(tb_shouhui,{force=true}))
		api.Sleep(0.2)
	end
	btn_target = api.UI.FindHudComponent('xmds_ui/hud/mainhud.gui.xml','btn_target')
	api.Wait(Helper.TouchGuide(btn_target,{force=true}))

  api.UI.WaitMenuEnter('xmds_ui/target/daily.gui.xml')
  btn_go = api.UI.FindComponent('xmds_ui/target/daily.gui.xml','btn_go')
	api.Wait(Helper.TouchGuide(btn_go))
end

function start(api, id, s)
	if s == api.Quest.Status.IN_PROGRESS and 110001 ~= api.Scene.GetCurrentSceneID() then
		api.Wait(Helper.WaitScriptEnd('quest_4207'))
		Quest_InProgress(api,id)
	end
end
