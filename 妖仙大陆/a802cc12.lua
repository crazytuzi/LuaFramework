	
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
	
	local test_Apc1 = api.World:CreateUnit()
	local test_Apc2 = api.World:CreateUnit()

	
	
	local test_Npc1_create =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099017}},
			{"Position",{x = 52.8,y = 39.2}},
			{"Direction",{direction = 3.6}},
			{"Animation",{name = "d_idle_b",loop=ture}},
	}
	
	local test_Npc1_turnback =
	{
		'Sequence',
			
			
			
			{"Animation",{name = "d_aim_in",loop=false}},
			{"Animation",{name = "d_aim",loop=true}},
	}
	
	
	local test_Npc1_fight =
	{
		'Sequence',
			{"Animation",{name = "d_fight",loop=false}},
	}
	
	
	local test_Npc2_create =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099007}},
			{"Position",{x = 0,y = 0}},	
			{"Direction",{direction = 0.5}},			
	}


	local test_Npc2_move =
	{
		'Sequence',
			{"Position",{x = 45.6,y = 36.9}},
			{"Animation",{name = "d_show",loop=false}},
			{"Animation",{name = "f_move",loop=true}},
			{"MoveTo",{x=47.2,y=37.6,speed=1.2}},
			{"Animation",{name = "n_talk",loop=false}},
	}  


	local test_Npc2_gesture =
	{
		'Sequence',
			{"Animation",{name = "d_gesture_in",loop=false}},
			{"Animation",{name = "d_gesture",loop=true}},
	}	
	
	local test_Npc2_idle =
	{
		'Sequence',
			{"Animation",{name = "f_idle",loop=true}},
	}	

	
	
			local test_Apc1_create = 
	{
			'Sequence',
			{"LoadTemplate",{id = 100990001}},
			{"Position",{x = 45.6,y = 36.9}},
			{"Direction",{direction = -3}},
	}
	
	
			local test_Apc2_create = 
	{
			'Sequence',
			{"LoadTemplate",{id = 100990005}},
			{"Position",{x = 0,y = 0}},
	}	
	

			local test_Apc2_play = 
	{
			'Sequence',
			{"LoadTemplate",{id = 100990005}},
			{"Position",{x = 45.6,y = 36.9}},
			{"Direction",{direction = -3}},
	}	


	
	api.World.RunAction(test_Npc1,test_Npc1_create)
	api.World.RunAction(test_Npc2,test_Npc2_create)
	api.World.RunAction(test_Apc1,test_Apc1_create)
	api.World.RunAction(test_Apc2,test_Apc2_create)
	
	Cam.SetPosition(15.5,49.5)
	
	local height = 25
	
	Helper.ComplexCamera(49.5,38.8,height - 5, 49.5,38.8,height - 8, 0.58,0.58, height -0.5,height -0.5, 10,24, 0,0,5,0) 

	local Apc1_said_youran = 
	{
		name = '悠冉',
		texts = {
			{text='桃之夭夭，灼灼其华。之子于归，宜其室家。',sec=2, clean=true ,wait=1},
			}
	}
	local sc = api.ShowCaption(Apc1_said_youran)
	
	
	
	
	api.playTalkVoice("/res/sound/dynamic/guide/yy004_1.assetbundles")
	
	Helper.ComplexCamera(49.5,38.8,height - 8, 49.5,38.8,height - 8, 0.58,0.68, height -0.5,height -0.5, 24,24, 0,0, 7,0) 
	
	
	
	
	api.World.RunAction(test_Apc1,test_Apc2_play)
	api.World.RunAction(test_Npc2,test_Npc2_move)
	Helper.ComplexCamera(49.5,38.8,height - 8, 45.6,36.9,height - 7.5, 0.68,1.5, height - 0.5,height - 3, 24,8, 0,0, 0.6,3) 
	Helper.ComplexCamera(45.6,36.9,height - 7.5, 45.6,36.9,height - 7.5, 1.5,1.5, height - 3,height - 3, 8,8, 0,0, 0.1,3) 
	Helper.ComplexCamera(45.6,36.9,height - 7.5, 45.6,36.9,height - 11, 1.5,1.5, height - 3,height - 7, 8,8, 0,0, 1,3)
	
	
	
	
	
	
	local Apc1_said_youran = 
	{
		name = '悠冉',
		texts = {
			{text='秋忆，我俩今日就以天地为证，在这桃树下结为夫妻吧！！！',sec=2, clean=true ,wait=1},
			}
	}
	local sc = api.ShowCaption(Apc1_said_youran)
	
	api.playTalkVoice("/res/sound/dynamic/guide/yy004_2.assetbundles")
	Helper.ComplexCamera(45.6,36.9,height - 11,49.3,38.4,height - 11.5, 1.5,1.1, height - 7,height - 9, 8,11.3, 0,0, 3,3) 
	api.World.RunAction(test_Npc2,test_Npc2_gesture)
	
	Helper.ComplexCamera( 49.3,38.4,height - 11.5, 49.3,38.4,height - 11.5, 1.1,1.5, height - 9,height - 9, 11.3,11.3, 0,0, 4.5,3) 
	api.World.RunAction(test_Npc2,test_Npc2_idle)
	
	
	
	local Npc1_said_feifei = 
	{
		name = '南宫菲菲',
		texts = {
			{text='痴心妄想，人妖相恋，天地不容！',sec=1, clean=true ,wait=1},
			}
	}
	local sc = api.ShowCaption(Npc1_said_feifei)
	api.World.RunAction(test_Npc1,test_Npc1_turnback)
	
	Helper.ComplexCamera( 52.8,39.2,height - 11, 52.8,39.2,height - 11, -1.5,-1.5, height - 8,height - 8, 7,7, 0,0, 0.2,2)
	
	Helper.ComplexCamera( 52.8,39.2,height - 11, 52.8,39.2,height - 11, -1.5,-1.55, height - 8,height - 8, 7,8, 0,0, 0.3,2)
	Helper.ComplexCamera( 52.8,39.2,height - 11, 52.8,39.2,height - 11, -1.55,-1.5, height - 8,height - 8, 8,6.5, 0,0, 0.15,2)
	api.playTalkVoice("/res/sound/dynamic/guide/yy004_3.assetbundles")
	Helper.ComplexCamera( 52.8,39.2,height - 11, 52.8,39.2,height - 11, -1.5,-1.5, height - 8,height - 8, 6.5,6.5, 0,0, 2.8,0) 	
	
	
	
	
		local Apc1_said_youran = 
	{
		name = '悠冉',
		texts = {
			{text='五岳仙盟？！是秋忆要你们来杀我的吗？！',sec=2, clean=true ,wait=1},
			}
	}
	local sc = api.ShowCaption(Apc1_said_youran)
	
	api.playTalkVoice("/res/sound/dynamic/guide/yy004_4.assetbundles")
	Helper.ComplexCamera( 47.2,37.6,height - 11, 47.2,37.6,height - 11, 1.6,1.6, height - 8,height - 8, 7,7, 0,0, 3.5,0) 

	
	
		local Npc1_said_feifei = 
	{
		name = '南宫菲菲',
		texts = {
			{text='你若甘愿伏诛，我给你一个痛快！',sec=1, clean=true ,wait=1},
			}
	}
	local sc = api.ShowCaption(Npc1_said_feifei)
	
	api.playTalkVoice("/res/sound/dynamic/guide/yy004_5.assetbundles")
	Helper.ComplexCamera( 52.8,39.2,height - 11, 52.8,39.2,height - 11, -1.6,-1.6, height - 8,height - 8, 7,7, 0,0, 4,0)

	
	
	
		local Apc1_said_youran = 
	{
		name = '悠冉',
		texts = {
			{text='好大的口气，千年之前，五岳仙盟要不是向仙界乞怜，早给妖界灭了！',sec=2, clean=true ,wait=1},
			}
	}
	local sc = api.ShowCaption(Apc1_said_youran)
	
	api.playTalkVoice("/res/sound/dynamic/guide/yy004_6.assetbundles")
	Helper.ComplexCamera( 47.2,37.6,height - 11, 50.3,38.6,height - 11, 2,2.05, height - 5,height - 5, 10,11.5, 0,0, 6.5,3) 
	
	
	
	
	

	
		local Npc1_said_feifei = 
	{
		name = '南宫菲菲',
		texts = {
			{text='看剑！',sec=0.1, clean=true ,wait=1},
			}
	}
	local sc = api.ShowCaption(Npc1_said_feifei)
	api.World.RunAction(test_Npc1,test_Npc1_fight)
	api.playTalkVoice("/res/sound/dynamic/guide/yy004_7.assetbundles")
	Helper.ComplexCamera( 50.3,38.6,height - 11, 50,38.6,height - 11, 2.05,2.8, height - 5,height - 6, 11.5,9, 0,0, 0.5,3) 
	Helper.ComplexCamera( 50,38.6,height - 11, 50,38.6,height - 11, 2.8,2.8, height - 6,height - 6, 9,9, 0,0, 0.8,0) 

	
	api.Scene.HideAllUnit(false)
	api.SendEndMsg()
	
end
