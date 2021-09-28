	
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


	Cam.SetFOV(30)
	
	local test_Npc1 = api.World:CreateUnit()
	local test_Npc2 = api.World:CreateUnit()
	local test_Npc3 = api.World:CreateUnit()
	local test_Npc4 = api.World:CreateUnit()
	local test_Npc5 = api.World:CreateUnit()
	local test_Npc6 = api.World:CreateUnit()
	local test_Npc7	= api.World:CreateUnit()
	local test_Npc8 = api.World:CreateUnit()
	
	local test_Apc1 = api.World:CreateUnit()
	
	local test_Apc2 = api.World:CreateUnit()
	local test_Apc3 = api.World:CreateUnit()
	local test_Apc4 = api.World:CreateUnit()
	
	
	local test_Npc1_create =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099001}},
			{"Position",{x = 98.8,y = 124}},
			{"Direction",{direction = 5.49}},
	}
	
	
		local test_Npc1_move =
	{
		'Sequence',
			{"Animation",{name = "n_talk",loop=true}},
			{"Delay",{delay=2.5}},
			{"Animation",{name = "d_walk",loop=true}},
			{"MoveTo",{x=94.8,y=122.5,speed=1,noAnimation = true}},
			{"Animation",{name = "n_idle",loop=true}},
			
	}


		local test_Npc1_run =
	{
		'Sequence',
			{"Delay",{delay=0.5}},
			{"Animation",{name = "d_run",loop=true}},
			{"MoveTo",{x=94.7,y=126.9,speed=1.9,noAnimation = true}},
			{"Animation",{name = "d_sleep",loop=false}},				
			
	}

	
	
	local test_Npc2_create =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099002}},
			{"Position",{x = 99,y = 122.5}},
			{"Direction",{direction = 2.35}},
	}

		local test_Npc2_move =
	{
		'Sequence',
			{"Animation",{name = "n_talk",loop=true}},
			{"Delay",{delay=2.6}},
			{"Animation",{name = "d_walk",loop=true}},
			{"MoveTo",{x=95.3,y=121.1,speed=1,noAnimation = true}},
			{"Animation",{name = "n_idle",loop=true}},

	}
	
		local test_Npc2_run =
	{
		'Sequence',
			{"Delay",{delay=0.5}},
			{"Animation",{name = "d_run",loop=true}},
			{"MoveTo",{x=99,y=119,speed=2,noAnimation = true}},
			{"Animation",{name = "d_sleep",loop=false}},

	}	
	
	
	local test_Npc3_create =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099004}},
			{"Position",{x = 91,y = 111}},
			{"Direction",{direction = 5.9}},
	}

	local test_Npc3_move =
	{
		'Sequence',
			{"Animation",{name = "n_talk",loop=true}},
			{"Delay",{delay=2.7}},
			{"Animation",{name = "d_walk",loop=true}},
			{"MoveTo",{x=91.4,y=115.6,speed=1,noAnimation = true}},
			{"Animation",{name = "n_idle",loop=true}},

	}	
	
	local test_Npc3_run =
	{
		'Sequence',
			{"Delay",{delay=0.5}},	
			{"Animation",{name = "d_run",loop=true}},
			{"MoveTo",{x=87.3,y=114.9,speed=1.8,noAnimation = true}},
			{"Animation",{name = "d_sleep",loop=false}},

	}		
	
	local test_Npc4_create =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099006}},
			{"Position",{x = 93,y = 110}},
			{"Direction",{direction = 2.85}},
	}

	local test_Npc4_move =
	{
		'Sequence',

			{"Animation",{name = "n_talk",loop=true}},
			{"Delay",{delay=2.8}},
			{"Animation",{name = "d_walk",loop=true}},
			{"MoveTo",{x=92.7,y=115.5,speed=1,noAnimation = true}},
			{"Animation",{name = "n_idle",loop=true}},
	}	
	
	local test_Npc4_run =
	{
		'Sequence',
			{"Delay",{delay=0.5}},
			{"Animation",{name = "d_run",loop=true}},
			{"MoveTo",{x=93.5,y=111.3,speed=2.1,noAnimation = true}},
			{"Animation",{name = "d_sleep",loop=false}},
	}	
	
	
	local test_Npc5_create =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099035}},
			{"Position",{x = 97,y = 114}},
			{"Direction",{direction = 1.2}},
	}
	
	local test_Npc5_move =
	{
		'Sequence',
			
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=2.55}},
			{"Animation",{name = "d_walk",loop=true}},
			{"MoveTo",{x=94.1,y=117.8,speed=0.8,noAnimation = true}},
			{"Animation",{name = "n_idle",loop=true}},
	}

		local test_Npc5_run =
	{
		'Sequence',
			{"Delay",{delay=0.5}},
			{"Animation",{name = "d_run",loop=true}},			
			{"MoveTo",{x=97.8,y=116.6,speed=1.9,noAnimation = true}},
			{"Animation",{name = "d_sleep",loop=false}},
	}
	 
	
	local test_Npc6_create =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099036}},
			{"Position",{x = 97.5,y = 126}},
			{"Direction",{direction = 0.5}},
	}
	
	local test_Npc6_move =
	{
		'Sequence',
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=2.65}},
			{"Animation",{name = "d_walk",loop=true}},
			{"MoveTo",{x=95.1,y=123.7,speed=1,noAnimation = true}},
			{"Animation",{name = "n_idle",loop=true}},
	}

	local test_Npc6_run =
	{
		'Sequence',
			{"Delay",{delay=0.5}},
			{"Animation",{name = "d_run",loop=true}},
			{"MoveTo",{x=95,y=128,speed=2,noAnimation = true}},
			{"Animation",{name = "d_sleep",loop=false}},
	}
	
	
	local test_Npc7_create =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099037}},
			{"Position",{x = 100,y = 116.1}},
			{"Direction",{direction = 2.7}},
	}

	local test_Npc7_move =
	{
		'Sequence',

			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=2.75}},
			{"Animation",{name = "d_walk",loop=true}},
			{"MoveTo",{x=95.6,y=118.9,speed=1,noAnimation = true}},
			{"Animation",{name = "n_idle",loop=true}},
	}


	local test_Npc7_run	=
	{
		'Sequence',
			{"Delay",{delay=0.5}},
			{"Animation",{name = "d_run",loop=true}},
			{"MoveTo",{x=99,y=117.3,speed=1.8,noAnimation = true}},
			{"Animation",{name = "d_sleep",loop=false}},
	}

	
	
	local test_Npc8_create =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099038}},
			{"Position",{x = 97.6,y = 115.7}},
			{"Direction",{direction = 2.35}},
	}
	
	local test_Npc8_move =
	{
		'Sequence',

			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=2.85}},
			{"Animation",{name = "d_walk",loop=true}},
			{"MoveTo",{x=93.4,y=118.9,speed=1,noAnimation = true}},
			{"Animation",{name = "n_idle",loop=true}},
	}

	local test_Npc8_run =
	{
		'Sequence',
			{"Delay",{delay=0.5}},
			{"Animation",{name = "d_run",loop=true}},
			{"MoveTo",{x=96.8,y=117.5,speed=2.1,noAnimation = true}},
			{"Animation",{name = "d_sleep",loop=false}},
	}
	
	
		local test_Apc1_create =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099033}},
			{"Position",{x =0,y = 0}},
			{"Direction",{direction = -0.3}},
			
	}
	

		local test_Apc1_talk =
	{
		'Sequence',
			{"Position",{x = 91.9,y = 120.4}},
			{"Animation",{name = "d_show",loop=false}},
			{"Animation",{name = "d_talk",loop=false}},
			{"Animation",{name = "n_talk",loop=false}},
			{"Animation",{name = "n_talk",loop=false}},
	}	
	
		local test_Apc1_kill =
	{
		'Sequence',
			{"Animation",{name = "f_skill01",loop=false}},
			{"Animation",{name = "n_idle",loop=true}},	
	}	
	
	
			local test_Apc2_create =
	{
		'Sequence',
			{"LoadTemplate",{id = 210990001}},
			{"Position",{x = 89.8,y = 121.2}},
			{"Direction",{direction = -0.3}},	
			
	}
	
	
		
		local test_Apc3_create = 
	{
			'Sequence',
			{"LoadTemplate",{id = 100990001}},
			{"Position",{x = 89.8,y = 121.2}},
			{"Direction",{direction = -3}},
	}
	
		
		local test_Apc4_create = 
	{
			'Sequence',
			{"LoadTemplate",{id = 100990005}},
			{"Position",{x = 0,y = 0}},
	}	
	
		local test_Apc4_play = 
	{
			'Sequence',
			{"LoadTemplate",{id = 100990005}},
			{"Position",{x = 91.9,y = 120.4}},
			{"Direction",{direction = -3}},
	}	
	
	
	api.World.RunAction(test_Apc2,test_Apc2_create)
	
	
	api.World.RunAction(test_Apc3,test_Apc3_create)
	
	
	api.World.RunAction(test_Npc1,test_Npc1_create)
	api.World.RunAction(test_Npc2,test_Npc2_create)
	api.World.RunAction(test_Npc3,test_Npc3_create)
	api.World.RunAction(test_Npc4,test_Npc4_create)
	api.World.RunAction(test_Npc5,test_Npc5_create)
	api.World.RunAction(test_Npc6,test_Npc6_create)
	api.World.RunAction(test_Npc7,test_Npc7_create)
	api.World.RunAction(test_Npc8,test_Npc8_create)
	
	
	api.World.RunAction(test_Apc1,test_Apc1_create)
	
	
	api.World.RunAction(test_Apc4,test_Apc4_create)
	
	local height = 25
	
	
	
	
	Helper.ComplexCamera(91.24,121.7,height - 6, 91.24,121.7,height - 6, 1.4,1, height - 3,height - 2, 11,10, 0,0, 4,0)
	
	
	
	api.World.RunAction(test_Npc1,test_Npc1_move)
	api.World.RunAction(test_Npc2,test_Npc2_move)
	api.World.RunAction(test_Npc3,test_Npc3_move)
	api.World.RunAction(test_Npc4,test_Npc4_move)
	api.World.RunAction(test_Npc5,test_Npc5_move)
	api.World.RunAction(test_Npc6,test_Npc6_move)
	api.World.RunAction(test_Npc7,test_Npc7_move)
	api.World.RunAction(test_Npc8,test_Npc8_move)
	
	Helper.ComplexCamera(91.24,121.7,height - 6, 91.24,121.7,height - 6, 1,0.7, height - 2,height - 2, 10,10, 0,0, 3,0)
	
	Helper.ComplexCamera(88,115,height - 7, 88,115,height - 7, -1.8,-2, height - 2,height - 2, 11,10, 0,0, 2,0) 
	Helper.ComplexCamera(92,119.5,height - 8, 92,119.5,height - 8, -1.2,-1.2, height - 3,height - 2, 6,7, 0,0, 1.5,0) 
	
	
	api.World.RunAction(test_Apc4,test_Apc4_play)
	api.World.RunAction(test_Apc1,test_Apc1_talk)
	Helper.ComplexCamera(91.9,120.4,height - 6, 91.9,120.4,height - 6, 1.5,1.5, height - 1 ,height - 1 , 8,8, 0,0, 0.8,0) 
	
	Helper.ComplexCamera(91.9,120.4,height - 6, 91.9,120.4,height - 9.5, 1.5,1.5, height - 1 ,height - 1 , 8,9, 0,0, 1.5,3) 
	
	api.playTalkVoice("/res/sound/dynamic/guide/yy002_1.assetbundles")
	Helper.ComplexCamera(91.9,120.4,height - 9.5, 91.9,120.4,height - 9.5, 1.5,1.5, height - 1 ,height - 1 , 9,9, 0,0, 1,0) 
	
	
	
	local Apc1_said_youran = 
	{
		name = '无天分身',
		wait = 2,
		texts = {
			{text='你们逼得秋忆说了谎…全都该受到惩罚，从今天开始，我会让你们活在恶梦中，直至你们把秋忆送到梦缘仙境跟我成亲为止…',sec=2, clean=true ,wait=1},
			}
	}
	local sc = api.ShowCaption(Apc1_said_youran)

	
	Helper.ComplexCamera(90.7,125.7,height - 7.5, 91.3,125.7,height - 7.5, -0.2,-0.25, height - 3,height - 3, 10,10, 0,0, 5,0) 
	
	Helper.ComplexCamera(91.9,120.4,height - 9.5, 91.9,120.4,height - 9.5, 1.9,2.25, height - 7,height - 7, 5,5, 0,0, 6.5,0)

	api.World.RunAction(test_Apc1,test_Apc1_kill)
	
	api.World.RunAction(test_Npc1,test_Npc1_run)
	api.World.RunAction(test_Npc2,test_Npc2_run)
	api.World.RunAction(test_Npc3,test_Npc3_run)
	api.World.RunAction(test_Npc4,test_Npc4_run)
	api.World.RunAction(test_Npc5,test_Npc5_run)
	api.World.RunAction(test_Npc6,test_Npc6_run)
	api.World.RunAction(test_Npc7,test_Npc7_run)
	api.World.RunAction(test_Npc8,test_Npc8_run)
	
	Helper.ComplexCamera(95,117.4,height - 9,96.6,116.2,height - 9, 2.1,2.15, height ,height , 17,17, 0,0, 6,0)

	
		local Apc1_said_youran = 
	{
		name = '无天分身',
		wait = 3,
		texts = {
			{text='……秋忆，我在梦缘仙境等你！',sec=2, clean=true ,wait=1},
			}
	}
	local sc = api.ShowCaption(Apc1_said_youran)
	
	api.playTalkVoice("/res/sound/dynamic/guide/yy002_2.assetbundles")
	
	Helper.ComplexCamera(91.9,120.4,height - 9.5, 91.9,120.4,height - 9.5, 2.15,2.25, height - 7,height - 7, 5,5, 0,0, 4.5,0)

	
	

	

	
	
	
	api.Scene.HideAllUnit(false)	
	
	api.SendEndMsg()
	
end
