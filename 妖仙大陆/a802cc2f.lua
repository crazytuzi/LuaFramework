	
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
	local test_Apc1 = api.World:CreateUnit()
	local test_Apc2 = api.World:CreateUnit()
	local test_Apc3 = api.World:CreateUnit()
	local test_Apc4	= api.World:CreateUnit()
	local test_Apc5 = api.World:CreateUnit()
	local test_Apc6 = api.World:CreateUnit()
	local test_Apc7 = api.World:CreateUnit()
	local test_Apc8 = api.World:CreateUnit()
	local test_Apc9 = api.World:CreateUnit()
	local test_Apc10 = api.World:CreateUnit()
	
	local test_Bpc1 = api.World:CreateUnit()
	local test_Bpc2 = api.World:CreateUnit()
	local test_Bpc3 = api.World:CreateUnit()

	
	
	local test_Npc1_create =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098004}},
			{"Position",{x = 179.7,y = 189.1}},
			{"Direction",{direction = 0.9}},	
	}
	
	local test_Npc1_talk1 =
	{
		'Sequence',
			{"Animation",{name = "n_talk",loop=false}},
			{"Animation",{name = "n_idle",loop=true}},	
	}	
	
	local test_Npc1_talk2 =
	{
		'Sequence',
			{"Animation",{name = "n_talk",loop=false}},
			{"Animation",{name = "n_idle",loop=true}},	
	}	
	
	
	
	
	local test_Npc2_create =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098044}},
			{"Position",{x = 177.4,y = 190}},
			{"Direction",{direction = 0.9}},
			{"Animation",{name = "n_idle",loop=true}},
	}
	
	
	local test_Npc2_jump1 =
	{
		'Sequence',
			{"Animation",{name = "d_blast",loop=false}},
			{"Animation",{name = "d_jump",loop=false}},	
	}
	
	local test_Npc2_jump2 =
	{
		'Sequence',
			{"Position",{x = 183.6,y = 192.8}},
			{"Animation",{name = "d_fall",loop=false}},
			
	}
	
	
	local test_Npc3_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098014}},
			{"Position",{x = 180.6,y = 186.9}},
			{"Direction",{direction = 0.9}},
			{"Animation",{name = "n_idle",loop=true}},		
	}
	
	
	
		local test_Apc1_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098009}},
			{"Position",{x = 186.21,y = 202.62}},
			{"Direction",{direction = -2.27}},
			{"Animation",{name = "n_idle",loop=true}},		
			
	}
	
	
	
		local test_Apc2_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098013}},
			{"Position",{x = 188.13,y = 204.39}},
			{"Direction",{direction = -2.28}},
			{"Animation",{name = "n_idle",loop=true}},		
			
	}
	
	
	
		local test_Apc3_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098019}},
			{"Position",{x = 190.87,y = 202.58}},
			{"Direction",{direction = -2.29}},
			{"Animation",{name = "n_idle",loop=true}},		
	}
	
	
	
		local test_Apc4_create =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098045}},
			{"Position",{x = 186.9,y = 199}},
			{"Direction",{direction = -2.3}},
			{"Animation",{name = "f_idle",loop=true}},		
	}
	
	
	
		local test_Apc4_talk =
	{
		'Sequence',
			{"Position",{x = 186.05,y = 198.23}},
			{"Animation",{name = "d_step",loop=false}},
			{"Animation",{name = "d_threat",loop=false}},
			{"Animation",{name = "f_idle",loop=true}},	
	}


	
		local test_Apc4_knockout =
	{
		'Sequence',
			{"Animation",{name = "d_knockout3",loop=false}},
			
		
			
	}	
	
		local test_Apc5_create =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098046}},
			{"Position",{x = 187.9,y = 197}},
			{"Direction",{direction = -2.32}},
			{"Animation",{name = "f_idle",loop=true}},		
			
	}

	
		local test_Apc5_talk =
	{
		'Sequence',
			
			{"MoveTo",{x=187.16,y=196.13,speed=1}},
			{"Animation",{name = "d_step",loop=false}},
			{"Animation",{name = "d_threat",loop=false}},
			{"Animation",{name = "f_idle",loop=true}},
	}

	
		local test_Apc5_knockout =
	{
		'Sequence',
			{"Animation",{name = "d_knockout2",loop=false}},
			
			
	}	
	
	
	
		local test_Apc6_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098036}},
			{"Position",{x = 193.16,y = 195.85}},
			{"Direction",{direction = -2.34}},
			{"Animation",{name = "n_idle",loop=true}},	
	}
	
	
	
	
		local test_Apc7_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098037}},
			{"Position",{x = 192.98,y = 199.33}},
			{"Direction",{direction = -2.33}},
			{"Animation",{name = "n_idle",loop=true}},					
	}
	
	
	
	
	local test_Apc8_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098018}},
			{"Position",{x = 195.01,y = 197.78}},
			{"Direction",{direction = -2.35}},
			{"Animation",{name = "n_idle",loop=true}},	
	}
	
	
	
	
	local test_Apc9_create =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098046}},
			{"Position",{x = 185.8,y = 199.9}},
			{"Direction",{direction = -2.35}},
			{"Animation",{name = "f_idle",loop=true}},
	}

		local test_Apc9_talk =
	{
		'Sequence',
			{"Position",{x=184.8,y=199.2}},
			{"Animation",{name = "d_step",loop=false}},
			{"Animation",{name = "f_idle",loop=true}},
		
			
	}

	local test_Apc9_knockout =
	{
		'Sequence',
			{"Animation",{name = "d_knockout",loop=false}},
			
	}
	
	
	
	
	local test_Apc10_create =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098045}},
			{"Position",{x = 188.98,y = 195.59}},
			{"Direction",{direction = -2.35}},
			{"Animation",{name = "f_idle",loop=true}},
	}
	
	local test_Apc10_knockout =
	{
		'Sequence',
			{"Animation",{name = "d_knockout",loop=false}},
			
	}
	
	
	
	
		local test_Bpc1_event =
	{
		'Sequence',
			
			{"LoadTemplate",{id = 1009800014}},
			{"Position",{x = 0,y = 0}},
			{"Direction",{direction = 0.9}},
			
	}
	
		local test_Bpc1_event1 =
	{
		'Sequence',
			{"LoadTemplate",{id = 1009800014}},
			{"Position",{x = 177.4,y = 190}},
			{"Direction",{direction = 0.9}},		
	}
	
	
	
	
		local test_Bpc2_event =
	{
		'Sequence',
			
			{"LoadTemplate",{id = 1009800015}},
			{"Position",{x = 0,y = 0}},
			{"Direction",{direction = 0.9}},
			
	}


		local test_Bpc2_event1 =
	{
		'Sequence',
			{"LoadTemplate",{id = 1009800015}},
			{"Position",{x = 177.4,y = 190}},
			{"Direction",{direction = 0.9}},			
	}	
	
	
	
	
		local test_Bpc3_event =
	{
		'Sequence',
			
			{"LoadTemplate",{id = 1009800016}},
			{"Position",{x = 0,y = 0}},
			{"Direction",{direction = 0.9}},		
	}	
	
	
		local test_Bpc3_event1 =
	{
		'Sequence',
			{"LoadTemplate",{id = 1009800016}},
			{"Position",{x = 183.6,y = 192.8}},
			{"Direction",{direction = 0.9}},				
			
	}	

	
		local test_Bpc3_event2 =
	{
		'Sequence',
			{"LoadTemplate",{id = 1009800016}},
			{"Position",{x = 183.6,y = 192.8}},
			{"Direction",{direction = 0.9}},				
			
	}		
		
	

	
	api.World.RunAction(test_Npc1,test_Npc1_create)
	api.World.RunAction(test_Npc2,test_Npc2_create)
	api.World.RunAction(test_Npc3,test_Npc3_event)
	api.World.RunAction(test_Apc1,test_Apc1_event)
	api.World.RunAction(test_Apc2,test_Apc2_event)
	api.World.RunAction(test_Apc3,test_Apc3_event)
	api.World.RunAction(test_Apc4,test_Apc4_create)
	api.World.RunAction(test_Apc5,test_Apc5_create)
	api.World.RunAction(test_Apc6,test_Apc6_event)
	api.World.RunAction(test_Apc7,test_Apc7_event)
	api.World.RunAction(test_Apc8,test_Apc8_event)
	api.World.RunAction(test_Apc9,test_Apc9_create)
	api.World.RunAction(test_Apc10,test_Apc10_create)
	api.World.RunAction(test_Bpc1,test_Bpc1_event)
	api.World.RunAction(test_Bpc2,test_Bpc2_event)
	api.World.RunAction(test_Bpc3,test_Bpc3_event)
	


	
	
	
	
	
	local height = 25
	Helper.ComplexCamera(181.65,197.24,height - 8.5,186.4,191.1,height - 8.5, -0.2,-0.5, height+1 ,height  +4, 23,25, 0,0, 5,0)
	
	
	
	
	
	
	
		local Npc1_said_donghuangtaiyi = 
	{
		name = '南宫无我',
		wait = 2,
		texts = {
			{text='第一场试炼结束，持有红珠的参加者，你们已经被淘汰了！',sec=1, clean=true ,wait=1},
			}
	}
	local sc = api.ShowCaption(Npc1_said_donghuangtaiyi)
	
	api.playTalkVoice("/res/sound/dynamic/guide/yy010_1.assetbundles")
	api.World.RunAction(test_Npc1,test_Npc1_talk1)
	Helper.ComplexCamera(179,189.4, height -1.5 , 179.7,189.1, height -1.5 , 0.45,0.8, height-0.5 ,height-0.5 , 5,6, 0,0, 5.5,0) 
	Helper.ComplexCamera(186.7,197.5, height -1.5 , 186.7,197.5, height -1.5 , -2.2,-2.2, height+1 ,height+1 , 12,12, 0,0, 1,0) 

	
		local Apc4_said_chuangzhenzhe4 = 
	{
		name = '搅场者甲',
		wait = 2,
		texts = {
			{text='这是什么试炼？剑都没动一下，就说我们被淘汰了？！！',sec=1, clean=true ,wait=1},
			}
	}
	local sc = api.ShowCaption(Apc4_said_chuangzhenzhe4)
	api.World.RunAction(test_Apc4,test_Apc4_talk)
	api.playTalkVoice("/res/sound/dynamic/guide/yy010_2.assetbundles")
	Helper.ComplexCamera(186.7,197.5, height -1.5 , 186.9,199, height -1.5 , -2.2,-2.2, height+1 ,height , 12,7, 0,0, 0.5,3) 
	Helper.ComplexCamera(186.9,199, height -1.5  , 186.9,199, height -1.5 , -2.2,-2.2, height ,height , 7,7, 0,0, 4,0) 

	
	
	
			local Npc1_said_donghuangtaiyi = 
	{
		name = '南宫无我',
		wait = 2,
		texts = {
			{text='第一场试炼是仙缘的试炼，仙缘不足，强求无用！',sec=1, clean=true ,wait=1},
			}
	}
	local sc = api.ShowCaption(Npc1_said_donghuangtaiyi)
	api.World.RunAction(test_Npc1,test_Npc1_talk2)
	api.playTalkVoice("/res/sound/dynamic/guide/yy010_3.assetbundles")
	Helper.ComplexCamera(182.8,193.6, height -2.5 , 182.8,193.6, height -2.5 , 1.3,1.25, height+3 ,height+3 , 20,20, 0,0, 5,0) 

	
			local Apc5_said_chuangzhenzhe5 = 
	{
		name = '搅场者乙',
		wait = 2,
		texts = {
			{text='这么儿戏算什么！？！直接不战而败？简直荒谬！我不服！',sec=1, clean=true ,wait=0},
			}
	}
	local sc = api.ShowCaption(Apc5_said_chuangzhenzhe5)
	api.World.RunAction(test_Apc5,test_Apc5_talk)
	
	api.playTalkVoice("/res/sound/dynamic/guide/yy010_4.assetbundles")
	Helper.ComplexCamera(187.9,197, height -1.5 , 187.9,197, height -1.5 , -2.7,-2.7, height+1 ,height+1 , 10,10, 0,0, 5,0) 

	
				local Apc4_said_chuangzhenzhe4 = 
	{
		name = '搅场者甲',
		wait = 0,
		texts = {
			{text='我也不服',sec=0.1, clean=true ,wait=0},
			}
	}
	local sc = api.ShowCaption(Apc4_said_chuangzhenzhe4)
	api.World.RunAction(test_Apc9,test_Apc9_talk)
	api.playTalkVoice("/res/sound/dynamic/guide/yy010_5.assetbundles")
	Helper.ComplexCamera(187.9,197, height -1.5 , 187.9,197, height -1.5 , -2.7,-2.7, height+1 ,height+1 , 10,10, 0,0, 2,0) 

	
	
	
		local Npc2_said_shenhuolaozu = 
	{
		name = '神火真人',
		wait = 2,
		texts = {
			{text='嗯……不服？！',sec=0.1, clean=true ,wait=0},
			}
	}
	local sc = api.ShowCaption(Npc2_said_shenhuolaozu)
	api.World.RunAction(test_Npc2,test_Npc2_jump1)
	api.playTalkVoice("/res/sound/dynamic/guide/yy010_6.assetbundles")
	api.World.RunAction(test_Bpc1,test_Bpc1_event1)
	Helper.ComplexCamera(177.4,190, height -1.5 , 177.4,190, height -1.2 , 0.72,0.72, height-0.5 ,height-0.5 , 5,3, 0,0, 0.3,3) 
	api.World.RunAction(test_Bpc2,test_Bpc2_event1)
	Helper.ComplexCamera(177.4,190, height -1.2 , 177.4,190, height -1.5 , 0.72,0.72, height-0.4 ,height-0.5 , 3,5, 0,0, 0.5,3) 
	
	Helper.ComplexCamera(177.4,190, height -1.5 , 177.4,190, height -1.5 , 0.72,0.72, height-0.5 ,height-0.5 , 5,5, 0,0, 0.25,0) 
	Helper.ComplexCamera(177.4,190, height -1.5 , 177.4,190, height -1.8 , 0.72,0.72, height-0.4 ,height-0.5 , 5,5, 0,0, 0.25,3) 
	api.World.RunAction(test_Bpc3,test_Bpc3_event1)
	api.SetTimeScale(0.3)
	Helper.ComplexCamera(177.4,190, height -1.8 , 177.4,190, height +3 , 0.72,0.72, height-0.5 ,height-0.5 , 5,5, 0,0,0.28,1) 
	api.SetTimeScale(1)


	
	
	
	local Npc2_said_shenhuolaozu = 
	{
		name = '神火真人',
		wait = 0,
		texts = {
			{text='弱者……没有资格谈不服！！！',sec=0.1, clean=true ,wait=0},
			}
	}
	local sc = api.ShowCaption(Npc2_said_shenhuolaozu)
	

	
	api.World.RunAction(test_Npc2,test_Npc2_jump2)
	api.World.RunAction(test_Bpc3,test_Bpc3_event2)
	api.playTalkVoice("/res/sound/dynamic/guide/yy010_7.assetbundles")
	Helper.ComplexCamera(183.6,192.8, height -2.5 , 183.6,192.8, height -2.5 , -1.5,-1.52, height+4 ,height+4 , 17,17, 0,0,0.2,0)
	api.SetTimeScale(0.1)
	api.World.RunAction(test_Apc4,test_Apc4_knockout)
	api.World.RunAction(test_Apc5,test_Apc5_knockout)
	api.World.RunAction(test_Apc9,test_Apc9_knockout)
	api.World.RunAction(test_Apc10,test_Apc10_knockout)
	Helper.ComplexCamera(183.6,192.8, height -2.5 , 183.6,192.8, height -2.5 , -1.52,-1.54, height+4 ,height+4 , 17,17, 0,0,0.4,0)	
	api.SetTimeScale(1)
	Helper.ComplexCamera(183.6,192.8, height -2.5 , 183.6,192.8, height -2.5 , -1.54,-1.7, height+4 ,height+4 , 17,17, 0,0,1.3,0)

	
	
	
	
	
	
	
	api.Scene.HideAllUnit(false)
	
	Cam.SetOffset(0,0,0)

	api.SendEndMsg()
	
end
