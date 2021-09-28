	
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
	
	
	
	local test_Npc1_create =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099017}},
			{"Position",{x = 54.03,y = 37.583}},
			{"Direction",{direction = 2.5}},
	}
	
	local test_Npc1_cure =
	{
		'Sequence',
			
			{"Animation",{name = "d_cure_in",loop=true}},
			{"Animation",{name = "d_cure",loop=true}},
	}
	
	local test_Npc1_fall =
	{
		'Sequence',
			{"Animation",{name = "d_cure_out",loop=false}},
			{"Position",{x = 52.3,y = 36.9}},
			{"Animation",{name = "d_fall",loop=false}},
			{"Animation",{name = "d_lay",loop=true}},
	}
		
	
	
	local test_Npc2_create =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099012}},
			
			{"Position",{x = 45.5,y = 34}},
	}
	
	local test_Npc2_move =
	{
		'Sequence',
			{"Direction",{direction = 1}},
			{"Animation",{name = "d_walk",loop=true}},   
			{"MoveTo",{x = 52.3,y = 36.9,speed=2.2,noAnimation = true}},
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=1}},
			{"Direction",{direction = 2.5}},
			{"Position",{x = 52.3,y = 36.9}},
			{"Animation",{name = "d_avoid_in",loop=false}},
			{"Animation",{name = "d_avoid",loop=true}},
			
	}

	
	local test_Npc2_fall =
	{
		'Sequence',
			{"Delay",{delay=1.064}},
			{"Animation",{name = "d_fall",loop=false}},
			{"Animation",{name = "d_lay",loop=true}},
	}



	
	
	
	local test_Npc3_create = 
	{
			'Sequence',
			{"LoadTemplate",{id = 100990004}},
			{"Position",{x = 54.03,y = 37.583}},
			{"Direction",{direction = 2.5}},
	}
	
	
	local test_Npc3_delete = 
	{
			'Sequence',
			{"LoadTemplate",{id = 100990004}},
			{"Position",{x = 0,y = 0}},
	}	
	
	
	
	
	api.World.RunAction(test_Npc1,test_Npc1_create)
	api.World.RunAction(test_Npc2,test_Npc2_create)
	api.World.RunAction(test_Npc3,test_Npc3_create)
	
	local height = 25
	
	
	
	Helper.ComplexCamera(42.4,32.9,height - 6.5 , 45.5,34,height -7.1, 1,1, height -5,height - 6.5 , 15,12, 0,0,4,2)
	

	

	
	api.World.RunAction(test_Npc1,test_Npc1_cure)
	api.World.RunAction(test_Npc2,test_Npc2_move)	
		local Npc2_said_zhangling1 = 
	{
		name = '叶晨',
		wait = 0,
		texts = {
			{text='你没事吧~?',sec=0.5, clean=true ,wait=1},
			}
	}
	local sc = api.ShowCaption(Npc2_said_zhangling1)
	
	
	
	
	
	api.playTalkVoice("/res/sound/dynamic/guide/yy005_1.assetbundles")
	Helper.ComplexCamera(45.5,34,height - 7.1 , 53.2,37.3,height - 10, 1,0.5, height -6.5,height - 8 , 12,6, 0,0,2.94,2)
	
	
	
		local Npc1_said_feifei = 
	{
		name = '南宫菲菲',
		wait = 0,
		texts = {
			{text='别打扰我疗伤',sec=0.5, clean=true ,wait=1},
			}
	}
	api.playTalkVoice("/res/sound/dynamic/guide/yy005_2.assetbundles")
	local sc = api.ShowCaption(Npc1_said_feifei)
	
	
	Helper.ComplexCamera(53.2,37.3,height - 10 , 53.2,37.3,height - 10 , 0.5,0.5, height -8,height - 8 , 6,6, 0,0, 1.5,0)  
	
	
		local Npc1_said_zhangling2= 
	{
		name = '叶晨',
		wait = 0,
		texts = {
			{text='切~~',sec=0.1, clean=true ,wait=5},
			}
	}
	local sc = api.ShowCaption(Npc1_said_zhangling2)
	
	api.playTalkVoice("/res/sound/dynamic/guide/yy005_3.assetbundles")
	Helper.ComplexCamera(54.03,37.583,height - 10.8 , 54.03,37.583,height - 10.8 , -1.5,-1.45, height -9.5,height - 9.5 , 8,8, 0,0, 3,0)


	
	
	local Npc2_said_feifei = 
	{
		name = '南宫菲菲',
		wait = 2,
		texts = {
			{text='好……好了',sec=0.1, clean=true ,wait=2},
			}
	}
	local sc = api.ShowCaption(Npc2_said_feifei)
	
	
	
	
	
	api.World.RunAction(test_Npc3,test_Npc3_delete)
	api.World.RunAction(test_Npc2,test_Npc2_fall)
	api.World.RunAction(test_Npc1,test_Npc1_fall)
	
	
	
	api.playTalkVoice("/res/sound/dynamic/guide/yy005_4.assetbundles")
	Helper.ComplexCamera(54.03,37.583,height - 10 , 54.03,37.783,height - 10 , -0.5,-0.9, height -9.5,height - 9.5 , 4,5, 0,2, 0.5,3)	
	Helper.ComplexCamera(54.03,37.783,height - 10 , 54.03,37.783,height - 10 , -0.9,-0.8, height -9.5,height - 9.5 , 5,4.5, 2,1, 0.5,3)
	Helper.ComplexCamera(54.03,37.783,height - 10 , 54.03,37.783,height - 10 , -0.8,-1.2, height -9.5,height - 9.5 , 4.5,5, 1,2, 0.8,3)
	Helper.ComplexCamera(54.03,37.783,height - 10 , 54.03,37.783,height - 10 , -1.2,-1.1, height -9.5,height - 9.5 , 5,5, 2,1, 0.25,3)
	Helper.ComplexCamera(54.03,37.783,height - 10 , 54.03,37.783,height - 10 , -1.1,-1.2, height -9.5,height - 9.5 , 5,5, 1,2.5, 0.25,3)
	
	api.SetTimeScale(0.13)	
	Helper.ComplexCamera(54.03,37.783,height - 10 , 54.03,37.783,height - 10 , -1.2,-1.2, height -9.5,height - 9.5 , 5,5, 2.5,2.5, 0.23,3)
	Helper.ComplexCamera(54.03,37.783,height - 10 , 51.8,36.6,height - 10.7 , -1.2,-1.1, height -9.5,height - 9.7 , 5,3, 2.5,1, 0.38,3)

	
	api.SetTimeScale(0.75)	
	
	Helper.ComplexCamera(51.8,36.6,height - 10.7 , 51.8,36.6,height - 10.7 , -1.1,-0.9, height -9.7,height - 9.7 , 3,4, 1,1, 0.4,3)
	api.SetTimeScale(1)
	Helper.ComplexCamera(51.8,36.6,height - 10.7 , 51.8,36.6,height - 10.7 , -0.9,-0.85, height -9.7,height - 9.7 , 4,4, 1,1, 1.5,3)


	
	api.Scene.HideAllUnit(false)
	api.SendEndMsg()
	
end
