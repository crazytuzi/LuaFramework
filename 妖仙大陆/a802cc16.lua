	
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
	local test_Npc2 = api.World:CreateUnit()
	local test_Npc3 = api.World:CreateUnit()
	
	local test_Npc5 = api.World:CreateUnit()
	local test_Npc6 = api.World:CreateUnit()
	local test_Npc7 = api.World:CreateUnit()
	
	local test_Npc9 = api.World:CreateUnit()
	local test_Npc10 = api.World:CreateUnit()
	local test_Npc11 = api.World:CreateUnit()
	local test_Npc12 = api.World:CreateUnit()
	local test_Npc13 = api.World:CreateUnit()
	local test_Npc14 = api.World:CreateUnit()
	local test_Npc15 = api.World:CreateUnit()
	local test_Npc16 = api.World:CreateUnit()
	local test_Npc17 = api.World:CreateUnit()
	local test_Npc18 = api.World:CreateUnit()
	local test_Npc19 = api.World:CreateUnit()
	local test_Npc20 = api.World:CreateUnit()
	local test_Npc21 = api.World:CreateUnit()
	local test_Npc22 = api.World:CreateUnit()
	
	local test_Npc24 = api.World:CreateUnit()
	local test_Npc25 = api.World:CreateUnit()
	local test_Npc26 = api.World:CreateUnit()
	local test_Npc27 = api.World:CreateUnit()
	local test_Npc28 = api.World:CreateUnit()
	
	
	
	local test_Npc1_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098052}},
			{"Position",{x = 118.89,y = 203.8}},
			{"Direction",{direction = 2.39}},

	}
	
	local test_Npc2_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098052}},
			{"Position",{x = 121.84,y = 206.83}},
			{"Direction",{direction = 2.39}},

	}
	
	local test_Npc3_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098052}},
			{"Position",{x = 124.96,y = 209.7}},
			{"Direction",{direction = 2.39}},

	}
	
	
	local test_Npc5_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 33003}},
			{"Position",{x = 204.6,y = 189.1}},
			{"Direction",{direction = -2.39}},
			{"Delay",{delay=3}},
			{"MoveTo",{x=174.1,y=162.3,speed=1.5}},

	}
	
	local test_Npc6_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 33005}},
			{"Position",{x = 203.93,y = 189.84}},
			{"Direction",{direction = -2.39}},
			{"Delay",{delay=3}},
			{"MoveTo",{x=174.1,y=162.3,speed=1.5}},

	}
	
	local test_Npc7_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098054}},
			{"Position",{x = 181.2,y = 183.2}},
			{"Direction",{direction = 1.51}},

	}
	
	
	local test_Npc9_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098025}},
			{"Position",{x = 218.73,y = 111.24}},
			{"Direction",{direction = 2.4}},

	}
	
	local test_Npc10_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098028}},
			{"Position",{x = 216.77,y = 110.68}},
			{"Direction",{direction = 2.4}},

	}
	
	local test_Npc11_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098018}},
			{"Position",{x = 214.58,y = 109.13}},
			{"Direction",{direction = 1.83}},

	}
	
	local test_Npc12_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098019}},
			{"Position",{x = 220.31,y = 114.16}},
			{"Direction",{direction = 2.68}},

	}
	
	local test_Npc13_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 100980001}},
			{"Position",{x = 157.18,y = 69.08}},
			{"Direction",{direction = 0.48}},

	}
	
	local test_Npc14_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098023}},
			{"Position",{x = 161.73,y = 68.64}},
			{"Direction",{direction = 0.97}},

	}
	
	local test_Npc15_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098010}},
			{"Position",{x = 113.77,y = 110.91}},
			{"Direction",{direction = 0.65}},

	}
	
	local test_Npc16_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10083002}},
			{"Position",{x = 122.08,y = 108.17}},
			{"Direction",{direction = 1.6}},

	}
	
	local test_Npc17_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098041}},
			{"Position",{x = 94.06,y = 143.43}},
			{"Direction",{direction = 0.65}},

	}
	
	local test_Npc18_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10085002}},
			{"Position",{x = 108.92,y = 153}},
			{"Direction",{direction = 1.96}},

	}
	
	local test_Npc19_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098006}},
			{"Position",{x = 206.44,y = 243.11}},
			{"Direction",{direction = 2.4}},

	}
	
	local test_Npc20_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10084002}},
			{"Position",{x = 203.57,y = 241.23}},
			{"Direction",{direction = 1.8}},
	}
	
	local test_Npc21_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098005}},
			{"Position",{x = 245.02,y = 223.6}},
			{"Direction",{direction = 2.64}},

	}
	
	local test_Npc22_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10082002}},
			{"Position",{x = 246.61,y = 227.31}},
			{"Direction",{direction = -3.06}},

	}
	
	
	local test_Npc24_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098016}},
			{"Position",{x = 182.38,y = 183.52}},
			{"Direction",{direction = 1.77}},

	}
	
	local test_Npc25_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098012}},
			{"Position",{x = 194.66,y = 176.74}},
			{"Direction",{direction = 3.1}},

	}
	
	local test_Npc26_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098015}},
			{"Position",{x = 201.45,y = 181.08}},
			{"Direction",{direction = 2.44}},

	}
	
	local test_Npc27_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 30007}},
			{"Position",{x = 181.38,y = 190.87}},
			{"Direction",{direction = 0.7}},

	}
	
	local test_Npc28_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10061}},
			{"Position",{x = 188.81,y = 198.02}},
			{"Direction",{direction = -2.45}},

	}
	
	

	api.World.RunAction(test_Npc1,test_Npc1_event)
	api.World.RunAction(test_Npc2,test_Npc2_event)
	api.World.RunAction(test_Npc3,test_Npc3_event)
	api.World.RunAction(test_Npc5,test_Npc5_event)
	api.World.RunAction(test_Npc6,test_Npc6_event)
	api.World.RunAction(test_Npc7,test_Npc7_event)
	api.World.RunAction(test_Npc9,test_Npc9_event)
	api.World.RunAction(test_Npc10,test_Npc10_event)
	api.World.RunAction(test_Npc11,test_Npc11_event)
	api.World.RunAction(test_Npc12,test_Npc12_event)
	api.World.RunAction(test_Npc13,test_Npc13_event)
	api.World.RunAction(test_Npc14,test_Npc14_event)
	api.World.RunAction(test_Npc15,test_Npc15_event)
	api.World.RunAction(test_Npc16,test_Npc16_event)
	api.World.RunAction(test_Npc17,test_Npc17_event)
	api.World.RunAction(test_Npc18,test_Npc18_event)
	api.World.RunAction(test_Npc19,test_Npc19_event)
	api.World.RunAction(test_Npc20,test_Npc20_event)
	api.World.RunAction(test_Npc21,test_Npc21_event)
	api.World.RunAction(test_Npc22,test_Npc22_event)
	api.World.RunAction(test_Npc24,test_Npc24_event)
	api.World.RunAction(test_Npc25,test_Npc25_event)
	api.World.RunAction(test_Npc26,test_Npc26_event)
	api.World.RunAction(test_Npc27,test_Npc27_event)
	api.World.RunAction(test_Npc28,test_Npc28_event)
	
	
	local height = 30
	
	
	
	Helper.ComplexCamera(120.6,207.5,height - 17,131,199.8,height - 15, -0.8,-0.2, height-2 ,height , 25,38, 0,0, 5,0) 
	Helper.ComplexCamera(181.65,197.24,height - 8.5,186.4,191.1,height - 8.5, -0.2,-0.6, height ,height  +6, 22,25, 0,0, 5,0) 
	Helper.ComplexCamera(160.58,70.18,height-2 ,160.58,70.18,height-2 , 0.8,0.5, height+9 ,height  +9, 26,27, 0,0, 3,0) 
	
	Helper.ComplexCamera(96.9,145.66,height - 6,102.76,149.55,height - 6, 0.4,0.5, height+5 ,height+7 , 24,26, 0,0, 3,0) 
	
	Helper.ComplexCamera(116.5,110.81,height - 6,116.5,110.81,height - 6, 0.3,0.3, height+8 ,height+6 , 28,26, 0,0, 3,0) 
	
	Helper.ComplexCamera(243.69,226.14,height - 8.5,243.69,226.14,height - 8.5, -0.6,-0.9, height+4 ,height  +4, 22,25, 0,0, 3,0) 
	
	Helper.ComplexCamera(203.87,245.43,height - 6,203.87,245.43,height - 6, -0.8,-0.8, height+9 ,height+7 , 25,22, 0,0, 3,0) 
	
	Helper.ComplexCamera(213.2,117.2,height+4.5 ,215.8,115,height +8, -0.8,-0.8, height +6,height+15 , 10,22, 0,0, 5,2) 
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	



	
	
	
	api.Scene.HideAllUnit(false)
	
	Cam.SetOffset(0,0,0)
	api.FadeOutBackImg(1)
	
		
	api.SendEndMsg()
	
end
