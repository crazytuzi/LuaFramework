	
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
	
	
    
	
	
	
	
	
	
	api.FadeOutBackImg(4.5)
	Cam.SetOffset(0,0,0)
	Cam.SetDramaCamera(true) 
	api.Scene.HideAllUnit(true)
	api.PauseUser()

	Cam.SetFOV(30)
	
	
	local test_Npc1 = api.World:CreateUnit()
	local test_Npc2 = api.World:CreateUnit()
	local test_Npc3 = api.World:CreateUnit()
	local test_Npc4 = api.World:CreateUnit()
	local test_Npc5 = api.World:CreateUnit()
	local test_Npc6 = api.World:CreateUnit()
	local test_Npc7	= api.World:CreateUnit()
	local test_Npc8 = api.World:CreateUnit()
	local test_Npc9 = api.World:CreateUnit()
	local test_Npc11 = api.World:CreateUnit()
	local test_Npc12 = api.World:CreateUnit()
	local test_Npc13 = api.World:CreateUnit()
	local test_Npc14 = api.World:CreateUnit()
	local test_Npc15 = api.World:CreateUnit()
	local test_Npc16 = api.World:CreateUnit()
	local test_Npc17 = api.World:CreateUnit()
	
	
	

	
	local test_Apc1 = api.World:CreateUnit()	
	local test_Apc2 = api.World:CreateUnit()	
	
	

	
	
	
	local test_Npc1_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 60201}},
			{"Position",{x = 101.76,y = 109.22}},
			{"Direction",{direction = 1.6}},
			{"Birth"},
			{"Animation",{name = "situp",loop=false}},
			{"Animation",{name = "f_idle",loop=true}},

			
			
	}
	
	local test_Npc2_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 60201}},
			{"Position",{x = 105.09,y = 109.75}},
			{"Direction",{direction = 1.7}},
			{"Birth"},
			{"Animation",{name = "situp",loop=false}},
			{"Animation",{name = "f_idle",loop=true}},

	}

	local test_Npc3_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 60201}},
			{"Position",{x = 101.09,y = 105.29}},
			{"Direction",{direction = 1.65}},
			{"Birth"},
			{"Animation",{name = "situp",loop=false}},
			{"Animation",{name = "f_idle",loop=true}},
			
			

	}

	local test_Npc4_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 60201}},
			{"Position",{x = 107.07,y = 105.85}},
			{"Direction",{direction = 1.75}},
			{"Birth"},
			{"Animation",{name = "situp",loop=false}},
			{"Animation",{name = "f_idle",loop=true}},
			
			
	}

	
	
	
	local test_Npc5_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 60202}},
			{"Position",{x = 104.12,y = 92.21}},
			{"Direction",{direction = 1.6}},
			{"Birth"},
			{"Animation",{name = "f_idle",loop=true}},
			{"Delay",{delay=3.15}},
			{"Animation",{name = "f_attack01",loop=false}},
			{"Animation",{name = "f_idle",loop=true}},
			
			
			
	}
	
	local test_Npc6_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 60202}},
			{"Position",{x = 108.45,y = 93.3}},
			{"Direction",{direction = 1.7}},
			{"Birth"},
			{"Animation",{name = "f_idle",loop=true}},
			{"Delay",{delay=3.3}},
			{"Animation",{name = "f_attack01",loop=false}},
			{"Animation",{name = "f_idle",loop=true}},
			
			
	}
	
	local test_Npc7_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 60202}},
			{"Position",{x = 111.21,y = 87.96}},
			{"Direction",{direction = 1.65}},
			{"Birth"},
			{"Animation",{name = "f_idle",loop=true}},
			{"Delay",{delay=3.2}},
			{"Animation",{name = "f_attack01",loop=false}},
			{"Animation",{name = "f_idle",loop=true}},
			
			
	}
	
	local test_Npc8_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 60202}},
			{"Position",{x = 103.19,y = 83.95}},
			{"Direction",{direction = 1.7}},
			{"Birth"},
			{"Animation",{name = "f_idle",loop=true}},
			{"Delay",{delay=3.25}},
			{"Animation",{name = "f_attack01",loop=false}},
			{"Animation",{name = "f_idle",loop=true}},	
			
			
	}
	
	
	
		local test_Npc9_event = 
	{
		'Sequence',
			{"LoadTemplate",{id = 60203}},
			{"Position",{x = 76.48,y = 69.44}},
			{"Direction",{direction = -3}},
			{"Birth"},
			
			
	}
	
	
		local test_Npc10_event = 
	{
		'Sequence',
			{"LoadTemplate",{id = 60203}},
			{"Position",{x = 74.66,y = 72.51}},
			{"Direction",{direction = -3}},
			{"Birth"},
			
			
	}	
	
	
		local test_Npc11_event = 
	{
		'Sequence',
			{"LoadTemplate",{id = 60203}},
			{"Position",{x = 72.97,y = 69.56}},
			{"Direction",{direction = -3}},
			{"Birth"},
			
			
	}	
	
	
		local test_Npc12_event = 
	{
		'Sequence',
			{"LoadTemplate",{id = 60203}},
			{"Position",{x = 68.82,y = 68.93}},
			{"Direction",{direction = -3}},
			{"Birth"},
			
			
	}	
	
	
	
		local test_Npc13_event = 
	{
		'Sequence',
			{"LoadTemplate",{id = 60203}},
			{"Position",{x = 70.71,y = 71.94}},
			{"Direction",{direction = -3}},
			{"Birth"},
			
			
	}	
	
	
		local test_Npc14_event = 
	{
		'Sequence',
			{"LoadTemplate",{id = 60204}},
			{"Position",{x = 52.83,y = 70.56}},
			{"Direction",{direction = -3}},
			{"Birth"},
			
			
	}	
	
	
	
	
	
		local test_Npc15_event = 
	{
		'Sequence',
			{"LoadTemplate",{id = 60204}},
			{"Position",{x = 49.44,y = 73.2}},
			{"Direction",{direction = -3}},
			{"Birth"},
			
			
	}
	
	
	
		local test_Npc16_event = 
	{
		'Sequence',
			{"LoadTemplate",{id = 60204}},
			{"Position",{x = 45.55,y = 70.56}},
			{"Direction",{direction = -3}},
			{"Birth"},
			
			
	}	
	
	
		local test_Npc17_event = 
	{
		'Sequence',
			{"LoadTemplate",{id = 60204}},
			{"Position",{x = 38.15,y = 73.7}},
			{"Direction",{direction = -3}},
			{"Birth"},
			
			
	}	
	
	
	
	
	
	
	
	
	
	
	
		local test_Apc1_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 60205}},
			{"Position",{x = 15.19,y = 72.26}},
			{"Direction",{direction = 0.8}},
			{"Birth"},
			{"Animation",{name = "f_idle",loop=true}},
			{"Delay",{delay=5.5}},
			{"Animation",{name = "f_attack01",loop=false}},
			{"Animation",{name = "f_idle",loop=true}},
			
			
			
	}
	
	
		local test_Apc2_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 60209}},
			{"Position",{x = 13.12,y = 49.74}},
			{"Direction",{direction = 2}},
			{"Birth"},
			{"Animation",{name = "f_idle",loop=true}},
			{"Delay",{delay=6.5}},
			{"Animation",{name = "f_show",loop=false}},
			{"Animation",{name = "f_skill02",loop=false}},
			{"Animation",{name = "f_idle",loop=true}},
			
			
	}
	
	
	
	
	
	
	
	
	
	
	

	
	api.World.RunAction(test_Npc1,test_Npc1_event)
	api.World.RunAction(test_Npc2,test_Npc2_event)
	api.World.RunAction(test_Npc3,test_Npc3_event)
	api.World.RunAction(test_Npc4,test_Npc4_event)
	api.World.RunAction(test_Npc5,test_Npc5_event)
	api.World.RunAction(test_Npc6,test_Npc6_event)
	api.World.RunAction(test_Npc7,test_Npc7_event)
	api.World.RunAction(test_Npc8,test_Npc8_event)
	api.World.RunAction(test_Npc9,test_Npc9_event)
	api.World.RunAction(test_Npc10,test_Npc10_event)
	api.World.RunAction(test_Npc11,test_Npc11_event)	
	api.World.RunAction(test_Npc12,test_Npc12_event)	
	api.World.RunAction(test_Npc13,test_Npc13_event)
	api.World.RunAction(test_Npc14,test_Npc14_event)	
	api.World.RunAction(test_Npc15,test_Npc15_event)
	api.World.RunAction(test_Npc16,test_Npc16_event)	
	api.World.RunAction(test_Npc17,test_Npc17_event)
	
	
	
	api.World.RunAction(test_Apc1,test_Apc1_event)	
	api.World.RunAction(test_Apc2,test_Apc2_event)	
	
	
	
	
	
	
	
	local height = 10
	
	
	Helper.ComplexCamera(106.11,118.24,height - 8.5, 103.5,110.9,height - 8.5, 0,-0.3, height - 7.5,height -7.5, 10,10, 0,-4, 2.5,0)
	
	Helper.ComplexCamera( 105.54,98.71,height - 6.5, 105.54,98.71,height - 6.5, -0.1,-0.15, height - 6,height - 6, 2,2, -4,0, 2.5,0)
	
	Helper.ComplexCamera( 13.37,70.36,height - 10, 13.37,70.36,height - 10, 0.8,0.82, height - 6,height - 5.5, 10,10, 0,0, 1.3,0)
	
	Helper.ComplexCamera( 13.37,70.36,height - 10, 13.37,70.36,height - 10, 0.82,0.7, height - 6,height - 5.5, 10,12, 0,0, 0.3,3)
	
	Helper.ComplexCamera( 13.37,70.36,height - 10, 13.37,70.36,height - 10, 0.7,0.73, height - 6,height - 5.5, 12,12, 0,0, 0.9,0)
	
	Helper.ComplexCamera( 13.12,49.74,height - 8.8, 13.12,49.74,height - 8.8, -0.5,-0.45, height - 5.5,height - 5.5, 10,12, 0,0, 3.8,0)
	
	Helper.ComplexCamera( 13.12,49.74,height - 8.8, 13.12,49.74,height - 8.75, -0.45,-0.455, height - 5.5,height - 5.5, 12,12, 0,0, 0.05,0)
	Helper.ComplexCamera( 13.12,49.74,height - 8.75, 13.12,49.74,height - 8.8, -0.455,-0.45, height - 5.5,height - 5.5, 12,12, 0,0, 0.05,0)
	Helper.ComplexCamera( 13.12,49.74,height - 8.8, 13.12,49.74,height - 8.85, -0.45,-0.445, height - 5.5,height - 5.5, 12,12, 0,0, 0.05,0)
	Helper.ComplexCamera( 13.12,49.74,height - 8.85, 13.12,49.74,height - 8.8, -0.445,-0.45, height - 5.5,height - 5.5, 12,12, 0,0, 0.05,0)
	Helper.ComplexCamera( 13.12,49.74,height - 8.8, 13.12,49.74,height - 8.75, -0.45,-0.455, height - 5.5,height - 5.5, 12,12, 0,0, 0.05,0)
	Helper.ComplexCamera( 13.12,49.74,height - 8.75, 13.12,49.74,height - 8.8, -0.455,-0.45, height - 5.5,height - 5.5, 12,12, 0,0, 0.05,0)
	Helper.ComplexCamera( 13.12,49.74,height - 8.8, 13.12,49.74,height - 8.85, -0.45,-0.445, height - 5.5,height - 5.5, 12,12, 0,0, 0.05,0)
	Helper.ComplexCamera( 13.12,49.74,height - 8.85, 13.12,49.74,height - 8.8, -0.445,-0.45, height - 5.5,height - 5.5, 12,12, 0,0, 0.05,0)
	
	
	
	
	Helper.ComplexCamera( 13.12,49.74,height - 8.8, 13.12,49.74,height - 8.5, -0.45,-0.43, height - 5.5,height - 5.5, 12,14, 0,0, 2,0)
	
	
	


	
	



	
	
	
	api.Scene.HideAllUnit(false)	
	
	Cam.SetOffset(0,0,0)
	api.FadeOutBackImg(1)
	
		
	api.SendEndMsg()
	
end
