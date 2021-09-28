	
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
	local test_Npc6 = api.World:CreateUnit()
	
	local test_Apc1 = api.World:CreateUnit()
	local test_Apc2 = api.World:CreateUnit()
	
	
	local test_Npc1_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098023}},
			{"Position",{x = 217.99,y = 111.9}},
			{"Direction",{direction = -0.75}},
			{"Birth"},
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=5}},
			{"Animation",{name = "d_summon_in",loop=false}},
			{"Animation",{name = "d_summon",loop=true}},
			{"Delay",{delay=5}},
			{"Animation",{name = "n_idle",loop=true}},
			
			
			
	}
	
	local test_Npc6_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 100980001}},
			{"Position",{x = 224.71,y = 105.24}},
			{"Direction",{direction = 2.3}},
			{"Birth"},



			
	}
	
	local test_Apc1_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 1009800006}},
			{"Position",{x = 224.71,y = 105.24}},
			{"Direction",{direction = 2.3}},
			{"Birth"},



			
	}

	local test_Apc2_event =
	{
		'Sequence',
			{"Delay",{delay=7.1}},
			{"LoadTemplate",{id = 1009800024}},
			{"Position",{x = 224.71,y = 105.24}},
			{"Direction",{direction = 2.3}},
			{"Birth"},



			
	}
	
	
	
	
	
	
	
	
	api.World.RunAction(test_Npc1,test_Npc1_event)
	api.World.RunAction(test_Npc6,test_Npc6_event)
	api.World.RunAction(test_Apc1,test_Apc1_event)
	api.World.RunAction(test_Apc2,test_Apc2_event)	
	

	
	local height = 40
	
	Helper.ComplexCamera(224.71,105.24, height-5,220.1,109.8, height-7.5, -0.5,-0.5, height -3,height -3, 10,15, 0,0, 2.5,3) 
	
	Helper.ComplexCamera(217.99,111.9, height-7.5,217.99,111.9, height-7.5,1.45,1.5, height -3,height -3, 10,10, 0,0, 3,3)
	
	Helper.ComplexCamera(217.99,111.9, height-7.5,224.71,105.24, height-7,1.5,-0.8, height -3,height -2, 10,20, 0,0, 3.8,3)
	
	Helper.ComplexCamera(224.71,105.24, height-7,224.71,105.24, height-6.5, -0.8,-0.8, height -2,height -2.5, 20,16, 0,0, 0.65,3) 
	
	Helper.ComplexCamera(224.71,105.24, height-6.5,224.71,105.24, height-6.5, -0.8,-0.8, height -2.5,height -2.5, 16,16, 0,0, 1.35,3)
	
	Helper.ComplexCamera(224.71,105.24, height-6.5,224.71,105.24, height-6, -0.8,-0.8, height -2.5,height -3, 16,13, 0,0, 0.65,3)
	
	Helper.ComplexCamera(224.71,105.24, height-6,224.71,105.24, height-6, -0.8,-0.8, height -3,height -3, 13,13, 0,0, 1.35,3)
	
	Helper.ComplexCamera(224.71,105.24, height-6,224.71,105.24, height-5.5, -0.8,-0.8, height -3,height -3.5, 13,10, 0,0, 0.65,3)
	
	Helper.ComplexCamera(224.71,105.24, height-5.5,224.71,105.24, height-6.5, -0.8,-0.8, height -3.5,height -3.5, 10,7, 0,0, 0.35,3)
	
	Helper.ComplexCamera(224.71,105.24, height-6.5,224.71,105.24, height-6.5, -0.81,-0.8, height -3.55,height -3.5, 7,7, 0,0, 0.05,3)
	Helper.ComplexCamera(224.71,105.24, height-6.5,224.71,105.24, height-6.5, -0.79,-0.8, height -3.45,height -3.5, 7,7, 0,0, 0.05,3)
	Helper.ComplexCamera(224.71,105.24, height-6.5,224.71,105.24, height-6.5, -0.81,-0.8, height -3.55,height -3.5, 7,7, 0,0, 0.05,3)
	Helper.ComplexCamera(224.71,105.24, height-6.5,224.71,105.24, height-6.5, -0.79,-0.8, height -3.45,height -3.5, 7,7, 0,0, 0.05,3)
	Helper.ComplexCamera(224.71,105.24, height-6.5,224.71,105.24, height-6.5, -0.8,-0.8, height -3.5,height -3.5, 7,7, 0,0, 0.05,3)
	
	Helper.ComplexCamera(224.71,105.24, height-6.5,224,106, height+2, -0.8,-0.8, height -3.5,height -2.5, 7,1.5, 0,0, 0.3,3)
	

	
	Helper.ComplexCamera(220.1,109.8, height-7.5,220.1,109.8, height-7.5, -0.5,-0.501, height -3,height -3, 18,18, 0,0, 0.05,3)
	Helper.ComplexCamera(220.1,109.8, height-7.5,220.1,109.8, height-7.5, -0.501,-0.499, height -3,height -3, 18,18, 0,0, 0.05,3)
	Helper.ComplexCamera(220.1,109.8, height-7.5,220.1,109.8, height-7.5, -0.499,-0.501, height -3,height -3, 18,18, 0,0, 0.05,3)
	Helper.ComplexCamera(220.1,109.8, height-7.5,220.1,109.8, height-7.5, -0.501,-0.499, height -3,height -3, 18,18, 0,0, 0.05,3)
	Helper.ComplexCamera(220.1,109.8, height-7.5,220.1,109.8, height-7.5, -0.499,-0.501, height -3,height -3, 18,18, 0,0, 0.05,3)
	Helper.ComplexCamera(220.1,109.8, height-7.5,220.1,109.8, height-7.5, -0.501,-0.499, height -3,height -3, 18,18, 0,0, 0.05,3)
	Helper.ComplexCamera(220.1,109.8, height-7.5,220.1,109.8, height-7.5, -0.499,-0.501, height -3,height -3, 18,18, 0,0, 0.05,3)
	Helper.ComplexCamera(220.1,109.8, height-7.5,220.1,109.8, height-7.5, -0.501,-0.499, height -3,height -3, 18,18, 0,0, 0.05,3)
	Helper.ComplexCamera(220.1,109.8, height-7.5,220.1,109.8, height-7.5, -0.499,-0.501, height -3,height -3, 18,18, 0,0, 0.05,3)
	Helper.ComplexCamera(220.1,109.8, height-7.5,220.1,109.8, height-7.5, -0.501,-0.499, height -3,height -3, 18,18, 0,0, 0.05,3)
	Helper.ComplexCamera(220.1,109.8, height-7.5,220.1,109.8, height-7.5, -0.499,-0.501, height -3,height -3, 18,18, 0,0, 0.05,3)
	Helper.ComplexCamera(220.1,109.8, height-7.5,220.1,109.8, height-7.5, -0.501,-0.499, height -3,height -3, 18,18, 0,0, 0.05,3)
	
	
	Helper.ComplexCamera(220.1,109.8, height-7.5,220.1,109.8, height-7.5, -0.499,-0.52, height -3,height -3, 18,18, 0,0, 3,3)
	
	
	
	
	
	
	
	
	
	
	
	
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

	api.Scene.HideAllUnit(false)
	
	
	
	Cam.SetOffset(0,0,0)

	
		
	api.SendEndMsg()
	
end
