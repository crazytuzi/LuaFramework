	
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
	api.FadeOutBackImg(1)
	api.PauseUser()

	
	
	local test_Npc1 = api.World:CreateUnit()
	local test_Npc2 = api.World:CreateUnit()
	local test_Npc3 = api.World:CreateUnit()
	local test_Npc4 = api.World:CreateUnit()
	local test_Npc5 = api.World:CreateUnit()
	local test_Npc6 = api.World:CreateUnit()
	local test_Npc7	= api.World:CreateUnit()
	local test_Npc8 = api.World:CreateUnit()
	local test_Apc1 = api.World:CreateUnit()
	local test_Npc9 = api.World:CreateUnit()
	
	
	
	
	
		local test_Npc9_event = 
	{
			'Sequence',
			{"LoadTemplate",{id = 100990001}},
			{"Position",{x = 91.9,y = 120.4}},
			{"Direction",{direction = -3}},
			{"Birth"},
			
			
	}
	
	
	
	local test_Npc1_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099001}},
			{"Position",{x = 98.8,y = 124}},
			{"Direction",{direction = 5.49}},
			{"Birth"},
			{"Animation",{name = "n_talk",loop=true}},
			{"Delay",{delay=2.5}},
			{"Animation",{name = "d_walk",loop=true}},
			{"MoveTo",{x=94.8,y=122.5,speed=0.8}},
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=12}},
			{"Animation",{name = "d_run",loop=true}},
			{"MoveTo",{x=94.7,y=126.9,speed=1.9}},
			{"Animation",{name = "d_sleep",loop=false}},
			
			
			
	}
	
	local test_Npc2_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099002}},
			{"Position",{x = 99,y = 122.5}},
			{"Direction",{direction = 2.35}},
			{"Birth"},
			{"Animation",{name = "n_talk",loop=true}},
			{"Delay",{delay=2.6}},
			{"Animation",{name = "d_walk",loop=true}},
			{"MoveTo",{x=95.3,y=121.1,speed=0.9}},
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=12}},
			{"Animation",{name = "d_run",loop=true}},
			{"MoveTo",{x=99,y=119,speed=2}},
			{"Animation",{name = "d_sleep",loop=false}},

	}

	local test_Npc3_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099004}},
			{"Position",{x = 91,y = 111}},
			{"Direction",{direction = 5.9}},
			{"Birth"},
			{"Animation",{name = "n_talk",loop=true}},
			{"Delay",{delay=2.7}},
			{"Animation",{name = "d_walk",loop=true}},
			{"MoveTo",{x=91.4,y=115.6,speed=0.7}},
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=11}},
			{"Animation",{name = "d_run",loop=true}},
			{"MoveTo",{x=87.3,y=114.9,speed=1.8}},
			{"Animation",{name = "d_sleep",loop=false}},

	}

	local test_Npc4_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099006}},
			{"Position",{x = 93,y = 110}},
			{"Direction",{direction = 2.85}},
			{"Birth"},
			{"Animation",{name = "n_talk",loop=true}},
			{"Delay",{delay=2.8}},
			{"Animation",{name = "d_walk",loop=true}},
			{"MoveTo",{x=92.7,y=115.5,speed=1}},
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=12}},
			{"Animation",{name = "d_run",loop=true}},
			{"MoveTo",{x=93.5,y=111.3,speed=2.1}},
			{"Animation",{name = "d_sleep",loop=false}},
			
			
	}

	local test_Npc5_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099001}},
			{"Position",{x = 97,y = 114}},
			{"Direction",{direction = 1.2}},
			{"Birth"},
			{"Animation",{name = "d_cry",loop=true}},
			{"Delay",{delay=2.55}},
			{"Animation",{name = "d_walk",loop=true}},
			{"MoveTo",{x=94.1,y=117.8,speed=0.8}},
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=12}},
			{"Animation",{name = "d_run",loop=true}},			
			{"MoveTo",{x=97.8,y=116.6,speed=1.9}},
			{"Animation",{name = "d_sleep",loop=false}},
			
			
	}
	
	local test_Npc6_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099002}},
			{"Position",{x = 97.5,y = 126}},
			{"Direction",{direction = 0.5}},
			{"Birth"},
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=2.65}},
			{"Animation",{name = "d_walk",loop=true}},
			{"MoveTo",{x=95.1,y=123.7,speed=0.9}},
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=12}},
			{"Animation",{name = "d_run",loop=true}},
			{"MoveTo",{x=95,y=128,speed=2}},
			{"Animation",{name = "d_sleep",loop=false}},
			
			
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
			{"Animation",{name = "d_walk",loop=true}},
			{"MoveTo",{x=95.6,y=118.9,speed=0.7}},
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=9.5}},
			{"Animation",{name = "d_run",loop=true}},
			{"MoveTo",{x=99,y=117.3,speed=1.8}},
			{"Animation",{name = "d_sleep",loop=false}},
			
			
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
			{"Animation",{name = "d_walk",loop=true}},
			{"MoveTo",{x=93.4,y=118.9,speed=1}},
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=12}},
			{"Animation",{name = "d_run",loop=true}},
			{"MoveTo",{x=96.8,y=117.5,speed=2.1}},
			{"Animation",{name = "d_sleep",loop=false}},
			
			
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
	
	Cam.SetPosition(90,123)
	
	api.World.RunAction(test_Npc1,test_Npc1_event)
	api.World.RunAction(test_Npc2,test_Npc2_event)
	api.World.RunAction(test_Npc3,test_Npc3_event)
	api.World.RunAction(test_Npc4,test_Npc4_event)
	api.World.RunAction(test_Npc5,test_Npc5_event)
	api.World.RunAction(test_Npc6,test_Npc6_event)
	api.World.RunAction(test_Npc7,test_Npc7_event)
	api.World.RunAction(test_Npc8,test_Npc8_event)
	api.World.RunAction(test_Apc1,test_Apc1_event)
	api.World.RunAction(test_Npc9,test_Npc9_event)
	
	local height = 25
	
	
	Helper.ComplexCamera(91.24,121.7,height - 6, 94.1,123.8,height - 6, 0.9,0.7, height - 2,height - 2, 13,15, 0,0, 3,0)
	
	Helper.ComplexCamera(88,115,height - 7, 88,115,height - 7, -1.8,-2, height - 2,height - 2, 11,10, 0,0, 2,0) 
	Helper.ComplexCamera(92,119.5,height - 8, 92,119.5,height - 8, -1.2,-1.2, height - 3,height - 2, 6,7, 0,0, 1.5,0) 
	
	
	Helper.ComplexCamera(91.9,120.4,height - 6, 91.9,120.4,height - 6, 1.5,1.5, height - 1 ,height - 1 , 8,8, 0,0, 1,0) 
	Helper.ComplexCamera(91.9,120.4,height - 6, 91.9,120.4,height - 9.5, 1.5,1.5, height - 1 ,height - 1 , 8,9, 0,0, 1.5,3) 
	Helper.ComplexCamera(91.9,120.4,height - 9.5, 91.9,120.4,height - 9.5, 1.5,1.5, height - 1 ,height - 1 , 9,9, 0,0, 1,0) 
	
	
	
	local Apc1_said_youran = 
	{
		name = '悠然',
		wait = 2,
		texts = {
			{text='是你们逼秋意说谎的…你们全都要接受徵罚，从今天开始，你们将会活在恶梦之中，直至把秋意送嫁到梦缘圣境跟我成亲为止…',sec=2, clean=true ,wait=1},
			}
	}
	local sc = api.ShowCaption(Apc1_said_youran)

	
	Helper.ComplexCamera(90.7,125.7,height - 7.5, 91.3,125.7,height - 7.5, -0.2,-0.25, height - 3,height - 3, 10,10, 0,0, 5,0) 
	Helper.ComplexCamera(91.9,120.4,height - 9.5, 91.9,120.4,height - 9.5, 1.9,2.25, height - 7,height - 7, 5,5, 0,0, 4.5,0)
	
	local Apc1_said_youran = 
	{
		name = '悠然',
		wait = 3,
		texts = {
			{text='哼哼哼哼哼……秋意，我等你！',sec=2, clean=true ,wait=1},
			}
	}
	local sc = api.ShowCaption(Apc1_said_youran)
	
	
	Helper.ComplexCamera(95,117.4,height - 9,96.6,116.2,height - 9, 2.1,2.15, height ,height , 17,17, 0,0, 6,0)
 	

	
	

	

	
	
	
	
	
	
	Cam.SetOffset(0,0,0)
	api.FadeOutBackImg(1)
	
		
	api.SendEndMsg()
	
end
