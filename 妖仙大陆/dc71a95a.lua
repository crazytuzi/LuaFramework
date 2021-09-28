


function start(api,params)
	tb_autofight = api.UI.FindHudComponent('xmds_ui/hud/mainhud.gui.xml','tb_autofight')
	if tb_autofight then
		api.Wait(Helper.TouchGuide(tb_autofight))
	end
end
