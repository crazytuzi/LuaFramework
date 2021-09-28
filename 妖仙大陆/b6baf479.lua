	
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
	api.PauseUser()
	
	api.FadeOutBackImg(1)
	
	
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
			{"Position",{x = 58.26,y = 71.67}},
			{"Direction",{direction = 2}},
			{"Birth"},
			{"Animation",{name = "f_move",loop=true}},
			{"MoveTo",{x=55.04,y=74.68,speed=2.5,noAnimation =true}},
			{"Animation",{name = "d_threat",loop=true}},
			
		
			
			
			
	}
	
	
	
	
	
	
	local test_Npc2_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 50011}},
			{"Position",{x = 52.93,y = 69.21}},
			{"Direction",{direction = 1.85}},
			{"Birth"},
			{"Animation",{name = "f_move",loop=true}},
			{"MoveTo",{x=51.43,y=73.48,speed=2.5,noAnimation =true}},
			{"Animation",{name = "d_threat",loop=true}},

	}

	
	
	
	
	
	local test_Npc3_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 50011}},
			{"Position",{x = 52.3,y = 67.64}},
			{"Direction",{direction = 1.95}},
			{"Birth"},
			{"Animation",{name = "f_move",loop=true}},
			{"MoveTo",{x=52,y=70.79,speed=2.5,noAnimation =true}},
			{"Animation",{name = "d_threat",loop=true}},

	}

	
	
	
	
	
	local test_Npc4_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 50011}},
			{"Position",{x = 56.49,y = 68.92}},
			{"Direction",{direction = 2.05}},
			{"Birth"},
			{"Animation",{name = "f_move",loop=true}},
			{"MoveTo",{x=54.33,y=72.42,speed=2.5,noAnimation =true}},
			{"Animation",{name = "d_threat",loop=true}},
			
			
	}

	
	
	
	
	
	local test_Npc5_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 50011}},
			{"Position",{x = 60.07,y = 69.73}},
			{"Direction",{direction = 1.9}},
			{"Birth"},
			{"Animation",{name = "f_move",loop=true}},
			{"MoveTo",{x=56.87,y=72.84,speed=2.5,noAnimation =true}},
			{"Animation",{name = "d_threat",loop=true}},

			
			
	}
	
	
	
	
	
	
	local test_Npc6_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 50011}},
			{"Position",{x=57.59,y=66.85}},
			{"Direction",{direction = 2.1}},
			{"Birth"},
			{"Animation",{name = "f_move",loop=true}},
			{"MoveTo",{x=55.74,y=70.3,speed=2.5,noAnimation =true}},
			{"Animation",{name = "d_threat",loop=true}},

			
			
	}
	
	
	
	
	
	
	local test_Npc7_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 50012}},
			{"Position",{x = 61.76,y = 54.58}},
			{"Direction",{direction = 1}},
			{"Birth"},
			{"Animation",{name = "f_idle",loop=true}},
			{"Delay",{delay=5}},
			{"Animation",{name = "down",loop=false}},
			{"Animation",{name = "situp",loop=false}},
			{"Animation",{name = "f_attack01",loop=false}},
			{"Animation",{name = "f_idle",loop=true}},
			
	}
	
	
	
	
	
	
	local test_Npc8_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 50012}},
			{"Position",{x = 59.82,y = 52.55}},
			{"Direction",{direction = 1}},
			{"Birth"},
			{"Animation",{name = "f_idle",loop=true}},
			{"Delay",{delay=7.3}},
			{"Animation",{name = "f_attack01",loop=false}},
			{"Animation",{name = "f_idle",loop=true}},
			
	}
	
	
	
	
	
	
	local test_Npc9_event = 
	{
			'Sequence',
			{"LoadTemplate",{id = 50012}},
			{"Position",{x = 63.17,y = 51.94}},
			{"Direction",{direction = 1}},
			{"Birth"},
			{"Animation",{name = "f_idle",loop=true}},
			{"Delay",{delay=5.2}},
			{"Animation",{name = "down",loop=false}},
			{"Animation",{name = "situp",loop=false}},
			{"Animation",{name = "f_attack01",loop=false}},
			{"Animation",{name = "f_idle",loop=true}},
			
			
			
	}
	
	
	
	
	
	
	local test_Npc10_event = 
	{
			'Sequence',
			{"LoadTemplate",{id = 50012}},
			{"Position",{x = 66.62,y = 50.66}},
			{"Direction",{direction = 1}},
			{"Birth"},
			{"Animation",{name = "f_idle",loop=true}},
			{"Delay",{delay=4.8}},
			{"Animation",{name = "down",loop=false}},
			{"Animation",{name = "situp",loop=false}},
			{"Animation",{name = "f_attack01",loop=false}},
			{"Animation",{name = "f_idle",loop=true}},
			
			
			
	}
	
	
	
	
	
	
	local test_Npc11_event = 
	{
			'Sequence',
			{"LoadTemplate",{id = 50012}},
			{"Position",{x = 60.88,y = 49.81}},
			{"Direction",{direction = 1}},
			{"Birth"},
			{"Animation",{name = "f_idle",loop=true}},
			{"Delay",{delay=7.5}},
			{"Animation",{name = "f_attack01",loop=false}},
			{"Animation",{name = "f_idle",loop=true}},
			
			
	}
	
	
	
	
	
	
	
	
	
	
	local test_Npc12_event = 
	{
			'Sequence',
			{"LoadTemplate",{id = 50012}},
			{"Position",{x = 64.5,y = 47.74}},
			{"Direction",{direction = 1}},
			{"Birth"},
			{"Animation",{name = "f_idle",loop=true}},
			{"Delay",{delay=7.5}},
			{"Animation",{name = "f_attack01",loop=false}},
			{"Animation",{name = "f_idle",loop=true}},
			
			
			
	}
	
	

	
	
	
		local test_Apc1_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099007}},
			{"Delay",{delay=9.8}},
			{"Position",{x = 45.62,y = 46.2}},
			{"Direction",{direction = 0.3}},
			{"Birth"},
			{"Animation",{name = "f_show",loop=false}},
			{"Animation",{name = "f_idle",loop=false}},


			
			
			
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
	Helper.ComplexCamera(48.61,81.39,height -9 ,51.5,77.01,height - 9, 0, 0, height  ,height , 15,15, 0,0, 1.5,0)
	
	Helper.ComplexCamera(53.66,77.54,height -8 ,53.56,73.72,height - 8, -0.2, -0.5, height - 6 ,height - 5 , 6,6, 4,0, 2,3)
	
	Helper.ComplexCamera(53.56,73.72,height -8 ,53.56,73.72,height - 8, -0.5, -0.6, height - 5 ,height - 5 , 6,7.5, 0,0, 2,0)
	
	Helper.ComplexCamera(53.56,73.72,height -8 ,66.18,56.59,height - 4.5, -0.6, 0.7, height - 5 ,height  , 7.5,8, 0,0, 2,3)
	
	Helper.ComplexCamera(66.18,56.59,height -4.5 ,66.09,53.82,height - 4, 0.7, 1.1, height  ,height  +1,8, 8,0,0, 2,3)
	
	
	Helper.ComplexCamera(53.33,48.73,height -4.2 ,48.06,47.02,height - 4.2, 1.2, 1.2, height  -3,height  -3,8, 4,0,0, 0.7,3)
	
	Helper.ComplexCamera(48.06,47.02,height -4.2 ,48.06,47.02,height - 5.6, 1.2, 1.2, height  -3,height  -4.5,4, 4,0,0, 1,3)
	
	Helper.ComplexCamera(48.06,47.02,height -5.6 ,48.06,47.02,height - 5.6, 1.2, 1.25, height  -4.5,height  -4.5,4, 4,0,0, 4,3)	
	
	
	
	
	api.Scene.HideAllUnit(false)
	Cam.SetOffset(0,0,0)
	api.FadeOutBackImg(1)
	
		
	api.SendEndMsg()
	
end
