


local arrow_path = '@dynamic_n/effects/guide_direction/guide_direction.xml|guide_direction|guide_direction|0'

function start(api)
	step = api.Net.GetStep()
	
	if not step and api.Scene.GetCurrentSceneID() == 10099 then
		api.SetBlockTouch(true)
		
		api.PlaySoundByKeyExt('guide_start')
		api.UI.HideUGUITextLabel(true)
		api.UI.HideAllHud(true)
		api.Camera.PlayAnimation('aiwenjun_01_01')
		api.Sleep(1.2)
		api.Net.SendStep('hello,world')
		api.ShowSideTool(true)
		ui = api.UI.OpenUIByXml('xmds_ui/hud/hud_lua.gui.xml',false)
		tb_text = api.UI.FindComponent(ui,'tb_text')
		x,y = api.UI.GetPos(tb_text)
		api.UI.AddAction(tb_text,'MoveAction',{Duration=12,TargetX = x,TargetY = 5})
		api.Sleep(5)
		api.Scene.HideAllUnit(true)
		api.Wait()
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	end
end
