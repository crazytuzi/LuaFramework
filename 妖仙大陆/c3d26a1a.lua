

function start(api,...)
	

		

		local ui = api.UI.OpenUIByXml('xmds_ui/solo/solo_daojishi.gui.xml',false)
		local anim = api.UI.FindComponent(ui,'ef_daojishi')

		local x = api.UI.GetPosX(anim)

		api.Wait(api.UI.PlayAnimation(anim))
		
	end
