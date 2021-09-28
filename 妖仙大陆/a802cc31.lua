	
function start(api,...)

	
	api.World.Init()

	
	api.UI.HideMFUI(true)

	api.UI.HideUGUITextLabel(true)

	api.UI.HideUGUIHpBar(true)
	
	api.SetNeedSendEndMsg()  

	
	api.UI.HideAllHud(true)

	
	api.UI.CloseAllMenu(true)


	
	

	
	api.SetBlockTouch(true)

	
	local user = api.GetUserInfo()

	
 	local x,y = user.x, user.y

 	
	local Cam = api.Camera

	
	api.ShowSideTool(true)
	
	
    
	
	
	
	
	
	Cam.SetOffset(0,0,0)
	Cam.SetDramaCamera(true) 
	api.FadeOutBackImg(1)
	api.Scene.HideAllUnit(true)
	
	Cam.SetFOV(30)

	local test_Npc1 = api.World:CreateUnit()
	
	
	
		local test_Npc1_event =
	{
		'Sequence',
			{"Delay",{delay=1}},
			{"LoadTemplate",{id = 100980002}},
			{"Position",{x = 145,y = 276.3}},
			{"Direction",{direction = 2.5}},
			{"Birth"},
	
	
	}	
	
	
	api.World.RunAction(test_Npc1,test_Npc1_event)
	


	
	local height = 20
	
	Helper.ComplexCamera(145,276.3,height - 13, 145,276.3,height - 13, 0.6,-0.9, height +1,height -2.5, 18,15, 0,0, 8,3)


	api.Scene.HideAllUnit(false)

	Cam.SetOffset(0,0,0)

	
		
	api.SendEndMsg()
	
end
