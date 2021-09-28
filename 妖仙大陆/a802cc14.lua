	
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
	api.PauseUser()
	
	
	local test_Npc1 = api.World:CreateUnit()
	local test_Npc2 = api.World:CreateUnit()
	local test_Npc3 = api.World:CreateUnit()
	local test_Npc4 = api.World:CreateUnit()
	local test_Npc5 = api.World:CreateUnit()	
	local test_Npc6 = api.World:CreateUnit()
	
	
	Cam.SetFOV(30)
	
	local Npc1_create = {
        'Sequence',
			{"LoadTemplate",{id = 10099017}},
			{"Position",{x = 45.62,y = 46.2}},
			{"Direction",{direction = -2.9}},
			{"Birth"},
			{"Animation",{name = "f_idle",loop=true}},	
    }

    local Npc1_move	= {
        'Sequence',
			{"Delay",{delay=9.3}},
			{"Animation",{name = "d_cover_in",loop=false}},
			{"Animation",{name = "d_cover",loop=true}},   
    }

    
	
	local Npc2_create = {
        'Sequence',
		{"LoadTemplate",{id = 10099012}},
			{"Position",{x = 58.2,y = 53.14}},
			{"Direction",{direction = -2.9}},
			{"Birth"},
			{"Animation",{name = "f_idle",loop=true}},	
    }

    local Npc2_move	= {
        'Sequence',
        {"Delay",{delay=6.6}},
			{"Animation",{name = "d_look",loop=false}},
			{"Delay",{delay=0.2}},
			{"Direction",{direction = -2.4}},
			{"Animation",{name = "f_idle",loop=true}},
			{"Delay",{delay=0.5}},
			{"Animation",{name = "f_skill04_1",loop=false}},
			{"Position",{x = 45.62,y = 46.2}},
			{"Direction",{direction = -2.9}},
			{"Animation",{name = "d_cover_in",loop=false}},
			{"Animation",{name = "d_cover",loop=true}},    
    }
	
	

	
	local Npc3_create = {
        'Sequence',
		{"LoadTemplate",{id = 210990001}},
			{"Position",{x = 43.6,y = 44.8}},
			{"Direction",{direction = 0}},
			{"Birth"},	
    }


	local Npc4_create = {
        'Sequence',
		{"LoadTemplate",{id = 210990002}},
			{"Position",{x = 36.2,y = 38.1}},
			{"Direction",{direction = 0}},
			{"Birth"},	
    }

	local Npc5_create = {
        'Sequence',
		{"Delay",{delay=8.75}},
			{"LoadTemplate",{id = 210990003}},
			{"Position",{x = 58.2,y = 53.14}},
			{"Direction",{direction = -2.9}},
			{"Birth"},	
    }


	local Npc6_create = {
        'Sequence',
		{"Delay",{delay=9.3}},
			{"LoadTemplate",{id = 210990004}},
			{"Position",{x = 45.62,y = 46.2}},
			{"Direction",{direction = -2.9}},
			{"Birth"},	
    }

	
	
	api.World.RunAction(test_Npc1,Npc1_create)
	api.World.RunAction(test_Npc2,Npc2_create)
	api.World.RunAction(test_Npc3,Npc3_create)
	api.World.RunAction(test_Npc4,Npc4_create)	
	api.World.RunAction(test_Npc5,Npc5_create)	
	api.World.RunAction(test_Npc6,Npc6_create)
	
	api.World.RunAction(test_Npc1,Npc1_move)
	api.World.RunAction(test_Npc2,Npc2_move)
	
	
	
	
	
	
	local height = 25
	
	
	

	

	
	Helper.ComplexCamera(46.3,44.5,height -2.8 ,46.3,44,height -1 , 0.94,0.89, height -5.5,height -5.5, 18,18, 0,0, 7,0) 
		
	Helper.ComplexCamera(58.2,53.14,height -6.5 ,58.2,53.14,height -5.5 , -2.2,-2.2, height -3 ,height - 4.5 , 8,2.2, 0,0, 0.4,2)
	
	Helper.ComplexCamera(58.2,53.14,height -5.5 ,58.2,53.14,height -5.5 , -2.2,-2.2, height -4.5 ,height - 4.5 , 2.2,2.2, 0,0, 0.5,0)
	
	
	
	Helper.ComplexCamera(48.5,48,height -5.5 ,48.5,48,height -5.5 , -1.5,-1.5, height +5,height +5, 20,20, 0,0, 1.2,0)
	
	api.SetTimeScale(0.5)	
	
	Helper.ComplexCamera(45.62,45.2,height -5.5 ,45.62,45.2,height -5.5 , -1.2,-0.2, height +5,height -5.5, 13,2.2, 0,0, 5,2)
	api.SetTimeScale(1)

	Helper.ComplexCamera(45.62,45.2,height -5.5 ,45.62,45.2,height -5.5 , -1.6,-1.8, height +2,height +2, 8,8, 0,0, 5,0)

	
	

	
	api.Scene.HideAllUnit(false)
	
	

	
	Cam.SetOffset(0,0,0)
	api.FadeOutBackImg(1)
	
		
	api.SendEndMsg()
	
end
