	
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
	api.Scene.HideAllUnit(true)
	api.PauseUser()
	Cam.SetFOV(30)
	
	local test_Npc1 = api.World:CreateUnit()
	local test_Apc3 = api.World:CreateUnit()
	
	
	local test_Npc1_creat =
	{
		'Sequence',
			
			{"LoadTemplate",{id = 10099033}},
			{"Position",{x = 46.03,y = 45.38}},
			{"Direction",{direction = -0.1}},
			{"Birth"},
			
			
			
	}
	
	local test_Npc1_move =
	{
		'Sequence',
			
			{"Animation",{name = "d_show",loop=false}},
			{"Animation",{name = "n_idle",loop=true}},
			
			
			
			
	}	

	
	local test_Apc3_event =
	{
		'Sequence',
			{"Delay",{delay=2.9}},
			{"LoadTemplate",{id = 210990005}},
			{"Position",{x = 46.03,y = 45.38}},
			{"Direction",{direction = -0.3}},
			{"Birth"},
	}		
	
	
	
	
	
	api.World.RunAction(test_Npc1,test_Npc1_creat)
	api.FadeInBackImg(0.01)
	api.Sleep(0.5)
	api.FadeOutBackImg(1)
	api.World.RunAction(test_Apc3,test_Apc3_event)
	api.World.RunAction(test_Npc1,test_Npc1_move)
	
	
	local height = 25
	Helper.ComplexCamera(46.03,45.38, height-3.5,46.03,45.38, height-3.5, 1.2,1.2, height-3 ,height-3 , 12,12, 0,0, 0.5,3) 
	Helper.ComplexCamera(46.03,45.38, height-3.5,46.03,45.38, height-6, 1.2,1.2, height-3 ,height-3 , 12,12, 0,0, 2,3) 
	Helper.ComplexCamera(46.03,45.38, height-6,46.03,45.38, height-6, 1.2,1.2, height-3 ,height-3 , 12,5, 0,0, 0.4,3) 
	Helper.ComplexCamera(46.03,45.38, height-6,46.03,45.38, height-6, 1.2,1.65, height-3 ,height-5 , 5,5, 0,0, 2,3) 
	Helper.ComplexCamera(46.03,45.38, height-6,46.03,45.38, height-6, 1.65,1.65, height-5 ,height-5 , 5,5, 0,0, 3,3) 
	

	
	
	
	
	

	api.Scene.HideAllUnit(false)
	
	
	
	Cam.SetOffset(0,0,0)
	
		
	api.SendEndMsg()
	
end
