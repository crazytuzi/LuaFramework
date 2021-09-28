function start(api,...)

	

	
	local world = api.World
	
	
	local ui = api.UI
	
	
	local camera = api.Camera
	
	
	local scene = api.Scene
	
	
	local player = api.GetUserInfo()

	
	local ux,uy = player.x, player.y
	
	
	
	
	world.Init()
	
	
	ui.HideMFUI(true)
	
	ui.HideUGUITextLabel(true)

	ui.HideUGUIHpBar(true)
	
	
	ui.HideAllHud(true)
	
	
	ui.CloseAllMenu(true)
	
	
	scene.HideAllUnit(true)
	
	
	api.SetBlockTouch(true)
	
	
	api.ShowSideTool(true)
	
	
	api.SetNeedSendEndMsg()
	
	
	
	camera.SetDramaCamera(true) 
	api.FadeOutBackImg(10)
	
	

	api.Sleep(10)
	api.FadeOutBackImg(1)
	api.StopBGM()

	
	api.SendEndMsg()
end
