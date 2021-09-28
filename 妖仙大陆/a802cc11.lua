	
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
	
	
    
	
	
	
	
	

	Cam.SetDramaCamera(true) 
	api.Scene.HideAllUnit(true)
	api.FadeOutBackImg(1)

	Cam.SetFOV(30)
	
	local test_Npc1 = api.World:CreateUnit()
	local test_Npc2 = api.World:CreateUnit()
	local test_Npc3 = api.World:CreateUnit()
	local test_Npc4 = api.World:CreateUnit()
	local test_Npc5 = api.World:CreateUnit()
	local test_Npc6 = api.World:CreateUnit()
	local test_Npc7 = api.World:CreateUnit()
	local test_Npc8 = api.World:CreateUnit()	
	local test_Npc9 = api.World:CreateUnit()

    local npc1_create = {
        'Sequence',
			{"LoadTemplate",{id = 10099017}},
			{"Position",{x = 98.4,y = 115.6}},
			{"Direction",{direction = 2.9}},
			{"Birth"},
			{"Animation",{name = "d_sedanidle",loop=true}},
    }

    local npc1_move = {
        'Sequence',
            {"Delay",{delay=2}},
			{"Animation",{name = "d_sedanidle",loop=true}},
			
			{"MoveTo",{x=79.22,y=111.67,speed=1.5,noAnimation =true}},
            {"MoveTo",{x=66.33,y=88.52,speed=1.5,noAnimation =true}},
    }
	
	local npc2_create = {
        'Sequence',
			{"LoadTemplate",{id = 10099018}},
			{"Position",{x = 98.4,y = 115.6}},
			{"Direction",{direction = 2.9}},
			{"Birth"},
    }

    local npc2_move = {
        'Sequence',
            {"Delay",{delay=2}},
			{"Animation",{name = "n_move",loop=true}},
			
			{"MoveTo",{x=79.22,y=111.67,speed=1.5,noAnimation =true}},
            {"MoveTo",{x=66.33,y=88.52,speed=1.5,noAnimation =true}},
    }
	
	local npc3_create = {
        'Sequence',
			{"LoadTemplate",{id = 10099019}},
			{"Position",{x = 95.44,y = 114.35}},
			{"Direction",{direction = 2.9}},
			{"Birth"},
    }

    local npc3_move = {
        'Sequence',
            {"Delay",{delay=2}},
			{"Animation",{name = "d_walk",loop=true}},
			{"MoveTo",{x=79.73,y=111,speed=1.5,noAnimation =true}},
			{"Animation",{name = "d_walk",loop=true}},
			{"MoveTo",{x=66.08,y=87.39,speed=1.5,noAnimation =true}},
    }

	local npc4_create = {
		'Sequence',
			{"LoadTemplate",{id = 10099019}},
			{"Position",{x = 95.17,y = 115.59}},
			{"Direction",{direction = 2.9}},
			{"Birth"},
    }
	
    local npc4_move = {
        'Sequence',
			{"Delay",{delay=2}},
			{"Animation",{name = "d_walk",loop=true}},
			{"MoveTo",{x=79.09,y=112.53,speed=1.5,noAnimation =true}},
			{"Position",{x = 78.37,y = 112.02}},
			{"Animation",{name = "d_walk",loop=true}},
			{"MoveTo",{x=64.9,y=88.56,speed=1.5,noAnimation =true}},
    }
	
	local npc5_create = {
		'Sequence',
			{"LoadTemplate",{id = 10099021}},
			{"Position",{x = 92.17,y = 113.73}},
			{"Direction",{direction = 2.9}},
			{"Birth"},
    }
	
    local npc5_move = {
        'Sequence',
			{"Delay",{delay=2}},
			{"Animation",{name = "n_move",loop=true}},
			{"MoveTo",{x=79.73,y=111,speed=1.5,noAnimation =true}},
			{"Animation",{name = "n_move",loop=true}},
			{"MoveTo",{x=66.08,y=87.39,speed=1.5,noAnimation =true}},
    }
	
	local npc6_create = {
		'Sequence',
			{"LoadTemplate",{id = 10099021}},
			{"Position",{x = 91.9,y = 114.7}},
			{"Direction",{direction = 2.9}},
			{"Birth"},
    }	
	
    local npc6_move = {
        'Sequence',
			{"Delay",{delay=2}},
			{"Animation",{name = "n_move",loop=true}},
			{"MoveTo",{x=79.09,y=112.53,speed=1.5,noAnimation =true}},
			{"Position",{x = 78.37,y = 112.02}},
			{"Animation",{name = "n_move",loop=true}},
			{"MoveTo",{x=64.9,y=88.56,speed=1.5,noAnimation =true}},
    }

	local npc7_create = {
		'Sequence',
			{"LoadTemplate",{id = 10099020}},
			{"Position",{x = 101.75,y = 116.02}},
			{"Direction",{direction = 2.9}},
			{"Birth"},
    }	
	
    local npc7_move = {
        'Sequence',
			{"Delay",{delay=2}},
			{"Animation",{name = "n_move",loop=true}},
			{"MoveTo",{x=79.73,y=111,speed=1.5,noAnimation =true}},
			{"Animation",{name = "n_move",loop=true}},
			{"MoveTo",{x=66.08,y=87.39,speed=1.5,noAnimation =true}},
    }
	
	local npc8_create = {
		'Sequence',
			{"LoadTemplate",{id = 10099020}},
			{"Position",{x = 101.54,y = 116.94}},
			{"Direction",{direction = 2.9}},
			{"Birth"},
    }	
	
    local npc8_move = {
        'Sequence',
			{"Delay",{delay=2}},
			{"Animation",{name = "n_move",loop=true}},
			{"MoveTo",{x=79.09,y=112.53,speed=1.5,noAnimation =true}},
			{"Position",{x = 78.37,y = 112.02}},
			{"Animation",{name = "n_move",loop=true}},
			{"MoveTo",{x=64.9,y=88.56,speed=1.5,noAnimation =true}},
    }
	
	local npc9_create = {
		'Sequence',
			{"LoadTemplate",{id = 10099012}},
			{"Position",{x = 99.8,y = 114.27}},
			{"Direction",{direction = 1.8}},
			{"Birth"},
    }	
	
    local npc9_move = {
        'Sequence',
			{"Delay",{delay=2}},
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=2.5}},
			{"Animation",{name = "d_avoid_in",loop=false}},
			{"Animation",{name = "d_avoid",loop=true}},
    }
	
	
	
	
	
	api.World.RunAction(test_Npc1,npc1_create)
	api.World.RunAction(test_Npc2,npc2_create)
	api.World.RunAction(test_Npc3,npc3_create)
	api.World.RunAction(test_Npc4,npc4_create)	
	api.World.RunAction(test_Npc5,npc5_create)		
    api.World.RunAction(test_Npc6,npc6_create)
    api.World.RunAction(test_Npc7,npc7_create)	
	api.World.RunAction(test_Npc8,npc8_create)
	api.World.RunAction(test_Npc9,npc9_create)
	api.World.RunAction(test_Npc1,npc1_move)
	api.World.RunAction(test_Npc2,npc2_move)
	api.World.RunAction(test_Npc3,npc3_move)
	api.World.RunAction(test_Npc4,npc4_move)	
	api.World.RunAction(test_Npc5,npc5_move)
	api.World.RunAction(test_Npc6,npc6_move)
	api.World.RunAction(test_Npc7,npc7_move)
	api.World.RunAction(test_Npc8,npc8_move)
	api.World.RunAction(test_Npc9,npc9_move)
	
	
	local height = 25
	
	Helper.ComplexCamera(98.4,115.6,height - 9.5, 98.4,115.6,height - 9.5, -0.9,-0.7, height ,height  -7, 12,5, 0,0, 2.6,0)
	Helper.ComplexCamera(98.4,115.6,height - 9.5, 93.1,114.4,height - 9, -0.7,-1, height - 7,height  -7, 5,9, 0,0, 5,0)
	Helper.ComplexCamera(83.5,113.5,height - 7, 83.5,113.5,height - 7, -1.4,-1.4, height -1.5,height -1.5, 12,12, 0,0, 2.5,0)	

	api.Scene.HideAllUnit(false)
	
	
	Cam.SetOffset(0,0,0)
	api.FadeOutBackImg(1)
	
		
	api.SendEndMsg()
	
end
