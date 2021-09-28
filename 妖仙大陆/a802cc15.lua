	
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
			{"LoadTemplate",{id = 100990002}},
			{"Position",{x = 45.6,y = 36.9}},
			{"Direction",{direction = -3}},
			
			
	}
	
	
	api.World.RunAction(test_Npc1,test_Npc1_event)

	
	local height = 25
	Helper.ComplexCamera(49.5,38.8,height - 8, 49.5,38.8,height - 8, 0.68,0.4, height -0.5,height +2.5, 12,20, 0,0, 7,0)
	
	
	
	
	

	api.Scene.HideAllUnit(false)
	
	Cam.SetOffset(0,0,0)
	api.FadeOutBackImg(1)
	
		
	api.SendEndMsg()
	
end
