	
function start(api,...)

	
	api.World.Init()

	
	api.UI.HideMFUI(true)

	api.UI.HideUGUITextLabel(true)

	api.UI.HideUGUIHpBar(true)

	
	api.UI.HideAllHud(true)

	
	api.UI.CloseAllMenu(true)
	
	api.SetNeedSendEndMsg()  

	
	

	
	api.SetBlockTouch(true)

	
	local user = api.GetUserInfo()

	
 	local x,y = user.x, user.y

 	
	local Cam = api.Camera

	
	api.ShowSideTool(true)
	
	
    
	
	
	
	
	
	Cam.SetOffset(0,0,0)
	Cam.SetDramaCamera(true) 
	Cam.SetPosition(75.99,163.4)
	api.Scene.HideAllUnit(true)
	
	api.FadeOutBackImg(1)
	
	
	Cam.SetFOV(30)
	
	local test_NpcA = api.World:CreateUnit()
	local test_NpcB = api.World:CreateUnit()
	
	local test_ApcA = api.World:CreateUnit()
	local test_ApcB = api.World:CreateUnit()
	local test_ApcC = api.World:CreateUnit()
	local test_ApcD = api.World:CreateUnit()
	local test_ApcE = api.World:CreateUnit()
	
	local test_BpcA = api.World:CreateUnit()  
	local test_BpcB = api.World:CreateUnit()  
	local test_BpcC = api.World:CreateUnit()  
	local test_BpcD = api.World:CreateUnit()  
	local test_BpcE = api.World:CreateUnit()  
	local test_BpcF = api.World:CreateUnit()  
	local test_BpcG = api.World:CreateUnit()  
	local test_BpcH = api.World:CreateUnit()  
	local test_BpcI = api.World:CreateUnit()  
	local test_BpcJ = api.World:CreateUnit()  
	local test_BpcK = api.World:CreateUnit()  
	
	local test_CpcA = api.World:CreateUnit()  
	
	
	

	
	

	
	local test_NpcA_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099001}},
			{"Position",{x = 83.44,y = 162.43}},
			{"Direction",{direction = 2}},
			{"Birth"},
			
			{"Animation",{name = "d_fear",loop=true}},
			{"Delay",{delay=4}},
			{"Animation",{name = "d_cry_in",loop=false}},
			{"Animation",{name = "d_cry",loop=true}},	          
			{"Delay",{delay=4}},
			{"Animation",{name = "d_cry",loop=true}},
			{"Delay",{delay=5}},


	}
	
	
	local test_NpcB_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 4}},
			{"Position",{x = 74,y = 153.7}},
			{"Direction",{direction = -0.3}},
			{"Birth"},
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=4}},
			{"Direction",{direction = 1.1}},
			
			
	}	
	

	
	local test_ApcA_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10011}},
			{"Position",{x = 77.2,y = 167.4}},
			{"Direction",{direction = 5.3}},
			{"Birth"},
			
			{"Animation",{name = "f_idle",loop=true}},
			{"Delay",{delay=2}},   
			{"Animation",{name = "f_move",loop=true}},
			{"MoveTo",{x=81.4,y=164.4,speed=2.5}},
			{"Animation",{name = "f_idle",loop=true}},
			{"Delay",{delay=5.5}},   
			{"Animation",{name = "d_threat",loop=true}},
			

	}

	local test_ApcB_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10011}},
			{"Position",{x = 82.5,y = 169.2}},
			{"Direction",{direction = 5}},
			{"Birth"},
			
			{"Animation",{name = "f_idle",loop=true}},
			{"Delay",{delay=1}},
			{"Animation",{name = "f_move",loop=true}},
			{"MoveTo",{x = 83.2,y = 163.8,speed=2.5}},
			{"Animation",{name = "f_idle",loop=true}},
			{"Delay",{delay=0.5}},
			{"Animation",{name = "d_threat",loop=true}},
			
	}

	local test_ApcC_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10011}},
			{"Position",{x = 88,y = 169.1}},
			{"Direction",{direction = 4.21}},
			{"Birth"},
			
			{"Animation",{name = "f_idle",loop=true}},
			{"Delay",{delay=1.5}},
			{"Animation",{name = "f_move",loop=true}},
			{"MoveTo",{x=85.1,y=164.8,speed=2.5}},
			{"Animation",{name = "f_idle",loop=true}},
			{"Delay",{delay=7}},
			{"Animation",{name = "d_threat",loop=true}},
			
			
	}

	local test_ApcD_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10011}},
			{"Position",{x = 81.5,y = 161.7}},
			{"Direction",{direction = 6.5}},
			{"Birth"},
			
			{"Animation",{name = "f_idle",loop=true}},
			{"Delay",{delay=8}},
			{"Animation",{name = "d_threat",loop=true}},
			
			
	}
	
		local test_ApcE_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10011}},
			{"Position",{x = 85.7,y = 162.7}},
			{"Direction",{direction = 3.3}},
			{"Birth"},
			
			{"Animation",{name = "f_idle",loop=true}},
			{"Delay",{delay=7}},
			{"Animation",{name = "d_threat",loop=true}},
			
			
	}
	

	
	
		local test_BpcA_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099027}},
			{"Position",{x = 93.24,y = 141.85}},
			{"Direction",{direction = 2.83}},
			{"Birth"},
	}
	
	
		local test_BpcB_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099026}},
			{"Position",{x = 92.06,y = 140.25}},
			{"Direction",{direction = 0.46}},
			{"Birth"},
	}
	
	
	
		local test_BpcC_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099027}},
			{"Position",{x = 96.25,y = 133.99}},
			{"Direction",{direction = -2.4}},
			{"Birth"},
	}
	
	
		local test_BpcD_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099026}},
			{"Position",{x = 98.32,y = 133.76}},
			{"Direction",{direction = -2.77}},
			{"Birth"},
	}
	
		local test_BpcE_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099029}},
			{"Position",{x = 102.83,y = 138.48}},
			{"Direction",{direction = 2.71}},
			{"Birth"},
	}
	
		local test_BpcF_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099030}},
			{"Position",{x = 100.06,y = 139.39}},
			{"Direction",{direction = 2.84}},
			{"Birth"},
	}
	
		local test_BpcG_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099002}},
			{"Position",{x = 93.86,y = 112.57}},
			{"Direction",{direction = 1.36}},
			{"Birth"},
	}
	
		local test_BpcH_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099004}},
			{"Position",{x = 96.8,y = 113.4}},
			{"Direction",{direction = 1.8}},
			{"Birth"},
	}
	
		local test_BpcI_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099024}},
			{"Position",{x = 96.3,y = 128.9}},
			{"Direction",{direction = 0.28}},
			{"Birth"},
	}
	
		local test_BpcJ_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099023}},
			{"Position",{x = 75.64,y = 119.5}},
			{"Direction",{direction = 0.22}},
			{"Birth"},
	}
	
	
		local test_BpcK_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099025}},
			{"Position",{x = 75.5,y = 121.26}},
			{"Direction",{direction = 0.05}},
			{"Birth"},
	}
	
	
		local test_CpcA_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099016}},
			{"Position",{x = 107.67,y = 110.63}},
			{"Direction",{direction = 2.42}},
			{"Birth"},
	}
	
	api.World.RunAction(test_NpcA,test_NpcA_event)
	api.World.RunAction(test_NpcB,test_NpcB_event)
	
	api.World.RunAction(test_ApcA,test_ApcA_event)
	api.World.RunAction(test_ApcB,test_ApcB_event)
	api.World.RunAction(test_ApcC,test_ApcC_event)
	api.World.RunAction(test_ApcD,test_ApcD_event)
	api.World.RunAction(test_ApcE,test_ApcE_event)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	local height = 25
	
	
	
	
	
	
	
	
	
	
	
			local Npc_A_littleboy = 
	{
		name = '小宝',
		wait = 1,
		texts = {
			{text='救……救命~',sec=0.5, clean=true ,wait=1},
			}
	}
	local sc = api.ShowCaption(Npc_A_littleboy)
	api.playTalkVoice("/res/sound/dynamic/guide/yy001_1.assetbundles")
	Helper.ComplexCamera(74.7,158.3,height -8 , 83.44,162.43,height -10, 0,0, height  ,height -5, 12,7, 0,0, 2,3)  
	
	
	local Npc_A_littleboy = 
	{
		name = '小宝',
		wait = 6,
		texts = {
			{text='快走开，你们这些可恶的妖怪，呜呜呜呜',sec=1,clean=true, wait=5},
			}
	}
	local sc = api.ShowCaption(Npc_A_littleboy)
	

	

	
	
	
	
	
	
	
	
	api.playTalkVoice("/res/sound/dynamic/guide/yy001_2.assetbundles")
	Helper.ComplexCamera(83.2,163.8,height -10, 83.2,163.8,height -10 , -0.5,-0.4, height -8.5,height -8.5 , 7.5,7, 7,7, 3.5,0)
	
	Helper.ComplexCamera(83.44,162.43,height -9.5, 83.44,162.43,height -9.5 , 0.2,0.3, height -7,height -7.5 , 7,5.5, 0,0, 3,0)
	
	Helper.ComplexCamera(83.4,163.1,height - 9.5, 83.4,163.1,height - 9.5, 1.5,1.3, height - 7,height - 7, 6,5, 0,0, 3,0) 

	Helper.ComplexCamera(83.44,162.43,height - 10,74.7,158.3,height - 8, -1.3,0, height - 5,height , 7,15, 0,0, 1.5,2) 
	
	
	api.Scene.HideAllUnit(false)
	
	Cam.SetOffset(0,0,0)
	api.FadeOutBackImg(1)
	
		
	api.SendEndMsg()
	
end
