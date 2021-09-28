	
function start(api,...)

	
	api.World.Init()

	
	api.UI.HideMFUI(true)

	api.UI.HideUGUITextLabel(true)

	api.UI.HideUGUIHpBar(true)

	
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
	
	
	
	local test_Npc1 = api.World:CreateUnit()
	local test_Npc2 = api.World:CreateUnit()
	local test_Npc3 = api.World:CreateUnit()
	local test_Npc4 = api.World:CreateUnit()
	local test_Npc5 = api.World:CreateUnit()
	local test_Npc6 = api.World:CreateUnit()
	local test_Npc7	= api.World:CreateUnit()
	local test_Npc8 = api.World:CreateUnit()
	local test_Npc9 = api.World:CreateUnit()
	local test_Npc10 = api.World:CreateUnit()	
	local test_Npc11 = api.World:CreateUnit()	
	local test_Npc12 = api.World:CreateUnit()	
	local test_Apc1 = api.World:CreateUnit()	
	
	
	

	
	
	
	
	
	local test_Npc1_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 50011}},
			{"Position",{x = 55.04,y = 74.68}},
			{"Direction",{direction = 2}},
			{"Birth"},
			{"Delay",{delay=-1.5}},
			{"Animation",{name = "d_threat",loop=true}},
			
		
			
			
			
	}
	
	
	
	
	
	
	local test_Npc2_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 50011}},
			{"Position",{x = 51.43,y = 73.48}},
			{"Direction",{direction = 1.85}},
			{"Birth"},
			{"Delay",{delay=-0.9}},
			{"Animation",{name = "d_threat",loop=true}},

	}

	
	
	
	
	
	local test_Npc3_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 50011}},
			{"Position",{x = 52,y = 70.79}},
			{"Direction",{direction = 1.95}},
			{"Birth"},
			{"Delay",{delay=-1.4}},
			{"Animation",{name = "d_threat",loop=true}},

	}

	
	
	
	
	
	local test_Npc4_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 50011}},
			{"Position",{x = 54.33,y = 72.42}},
			{"Direction",{direction = 2.05}},
			{"Birth"},
			{"Delay",{delay=-1.9}},
			{"Animation",{name = "d_threat",loop=true}},
			
			
	}

	
	
	
	
	
	local test_Npc5_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 50011}},
			{"Position",{x = 56.87,y = 72.84}},
			{"Direction",{direction = 1.9}},
			{"Birth"},
			{"Delay",{delay=-1.2}},
			{"Animation",{name = "d_threat",loop=true}},

			
			
	}
	
	
	
	
	
	
	local test_Npc6_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 50011}},
			{"Position",{x = 55.74,y = 70.3}},
			{"Direction",{direction = 2.1}},
			{"Birth"},
			{"Delay",{delay=-0.5}},
			{"Animation",{name = "d_threat",loop=true}},

			
			
	}
	
	
	
	
	
	
	local test_Npc7_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099004}},
			{"Position",{x = 100,y = 116.1}},
			{"Direction",{direction = 2.7}},
			{"Birth"},
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=2.75}},

			
			
	}
	
	
	
	
	
	
	local test_Npc8_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099006}},
			{"Position",{x = 97.6,y = 115.7}},
			{"Direction",{direction = 2.35}},
			{"Birth"},
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=2.85}},

			
			
	}
	
	
	
	
	
	
	local test_Npc9_event = 
	{
			'Sequence',
			{"LoadTemplate",{id = 100990001}},
			{"Position",{x = 91.9,y = 120.4}},
			{"Direction",{direction = -3}},
			{"Birth"},
			
			
	}
	
	
	
	
	
	
	local test_Npc10_event = 
	{
			'Sequence',
			{"LoadTemplate",{id = 100990001}},
			{"Position",{x = 91.9,y = 120.4}},
			{"Direction",{direction = -3}},
			{"Birth"},
			
			
	}
	
	
	
	
	
	
	local test_Npc11_event = 
	{
			'Sequence',
			{"LoadTemplate",{id = 100990001}},
			{"Position",{x = 91.9,y = 120.4}},
			{"Direction",{direction = -3}},
			{"Birth"},
			
			
	}
	
	
	
	
	
	
	local test_Npc11_event = 
	{
			'Sequence',
			{"LoadTemplate",{id = 100990001}},
			{"Position",{x = 91.9,y = 120.4}},
			{"Direction",{direction = -3}},
			{"Birth"},
			
			
	}
	
	
	
	
	
	
	local test_Npc12_event = 
	{
			'Sequence',
			{"LoadTemplate",{id = 100990001}},
			{"Position",{x = 91.9,y = 120.4}},
			{"Direction",{direction = -3}},
			{"Birth"},
			
			
	}
	
	

	
	
	
		local test_Apc1_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099015}},
			{"Delay",{delay=6.5}},
			{"Position",{x = 91.9,y = 120.4}},
			{"Direction",{direction = -0.3}},
			{"Birth"},
			{"Animation",{name = "f_show",loop=false}},
			{"Animation",{name = "d_talk",loop=false}},
			{"Animation",{name = "n_talk",loop=false}},
			{"Animation",{name = "f_skill01",loop=false}},
			{"Animation",{name = "n_idle",loop=true}},
			
			
			
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
	api.World.RunAction(test_Apc1,test_Apc1_event)
	
	
	
	
	
	
	
	
	local height = 25
	
	Cam.SetFOV(30)
	Helper.ComplexCamera(48.61,81.39,height -10 ,53.56,73.72,height - 9, 0, 0, height ,height -8, 15,6, 0,7, 2,0)
	
	Helper.ComplexCamera(53.56,73.72,height -9 ,53.56,73.72,height - 9, 0, -0.5, height - 8 ,height - 8 , 6,6, 7,8, 2,3)
	

	

	
	
	
	
	
	api.Scene.HideAllUnit(false)
	Cam.SetOffset(0,0,0)
	api.FadeOutBackImg(1)
	
		
	api.SendEndMsg()
	
end
