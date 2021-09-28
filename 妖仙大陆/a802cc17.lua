	
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
	
	
    
	
	
	
	
	
	api.FadeOutBackImg(1)
	Cam.SetOffset(0,0,0)
	Cam.SetDramaCamera(true) 
	api.Scene.HideAllUnit(true)
	api.PauseUser()

	Cam.SetFOV(30)
	
	local test_Npc1 = api.World:CreateUnit()
	local test_Npc2 = api.World:CreateUnit()
	local test_Npc3 = api.World:CreateUnit()
	local test_Npc4 = api.World:CreateUnit()
	local test_Npc5 = api.World:CreateUnit()
	
	
	local test_Apc1 = api.World:CreateUnit()
	local test_Apc2 = api.World:CreateUnit()
	local test_Apc3 = api.World:CreateUnit()
	local test_Apc4 = api.World:CreateUnit()
	
	
	local test_Bpc1 = api.World:CreateUnit()
	
	local test_Cpc1 = api.World:CreateUnit()
	
	
	local test_Npc1_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098004}},
			{"Position",{x = 230.22,y = 173.22}},
			{"Direction",{direction = -0.5}},
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=3}},
			{"Animation",{name = "d_summon_in",loop=false}},
			{"Animation",{name = "d_summon",loop=true}},
			{"Delay",{delay=7}},
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=7}},
			{"Animation",{name = "n_talk",loop=false}},
			{"Animation",{name = "n_idle",loop=true}},
			{"Animation",{name = "n_talk",loop=false}},
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=28}},
			{"Animation",{name = "n_talk",loop=false}},
			{"Animation",{name = "n_idle",loop=true}},
	}
	
	
	local test_Npc2_event =
	{
		'Sequence',
			{"Delay",{delay=8.5}},
			{"LoadTemplate",{id = 10098044}},
			{"Position",{x = 239.52,y = 162.2}},
			{"Direction",{direction = 2.3}},
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=32}},
			{"Animation",{name = "n_talk",loop=false}},
			{"Animation",{name = "n_idle",loop=true}},
	}
	
	
	
	local test_Npc3_event =
	{
		'Sequence',
			{"Delay",{delay=9.5}},
			{"LoadTemplate",{id = 10098020}},
			{"Position",{x = 237.82,y = 175.85}},
			{"Direction",{direction = -2.8}},
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=40}},
			{"Animation",{name = "n_talk",loop=false}},
			{"Animation",{name = "n_idle",loop=true}},
	}
	
	
	
		local test_Npc4_event =
	{
		'Sequence',
			{"Delay",{delay=8}},
			{"LoadTemplate",{id = 10098032}},
			{"Position",{x = 230.57,y = 164.4}},
			{"Direction",{direction = 1.5}},
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=5}},
			{"Animation",{name = "n_talk",loop=false}},
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=23}},
			{"Animation",{name = "n_talk",loop=false}},
			{"Animation",{name = "n_idle",loop=true}},
			
			
			
	}
	
	
	
		local test_Npc5_event =
	{
		'Sequence',
			{"Delay",{delay=9}},
			{"LoadTemplate",{id = 10098010}},
			{"Position",{x = 243.54,y = 170.25}},
			{"Direction",{direction = 2.9}},
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=27}},
			{"Animation",{name = "n_talk",loop=false}},
			{"Animation",{name = "n_idle",loop=true}},
			
	}
	
	
	
		local test_Apc1_event =
	{
		'Sequence',
			{"Delay",{delay=8.5}},
			{"LoadTemplate",{id = 1009800028}},
			{"Position",{x = 239.52,y = 162.2}},
			{"Direction",{direction = -2.8}},
	}
	
	
		local test_Apc2_event =
	{
		'Sequence',
			{"Delay",{delay=9.5}},
			{"LoadTemplate",{id = 1009800030}},
			{"Position",{x = 237.82,y = 175.85}},
			{"Direction",{direction = -2.8}},
	}
	
	
	
		local test_Apc3_event =
	{
		'Sequence',
			{"Delay",{delay=8}},
			{"LoadTemplate",{id = 1009800026}},
			{"Position",{x = 230.57,y = 164.4}},
			{"Direction",{direction = -2.8}},
	}	
	

			
		local test_Apc4_event =
	{
		'Sequence',
			{"Delay",{delay=9}},
			{"LoadTemplate",{id = 1009800029}},
			{"Position",{x = 243.54,y = 170.25}},
			{"Direction",{direction = -2.8}},
	}			

	
	
		local test_Bpc1_event =
	{
		'Sequence',
			{"Delay",{delay=3}},
			{"LoadTemplate",{id = 1009800002}},
			{"Position",{x = 230.22,y = 173.22}},
			{"Direction",{direction = -0.5}},
	}	
	
	
		local test_Cpc1_event =
	{
		'Sequence',
			{"Delay",{delay=5}},
			{"LoadTemplate",{id = 1009800032}},
			{"Position",{x = 237.3,y = 168.6}},
			{"Direction",{direction = 4.6}},
	}	
	
	






	
	
	
	
	
	api.World.RunAction(test_Npc1,test_Npc1_event)
	api.World.RunAction(test_Npc2,test_Npc2_event)
	api.World.RunAction(test_Npc3,test_Npc3_event)
	api.World.RunAction(test_Npc4,test_Npc4_event)
	api.World.RunAction(test_Npc5,test_Npc5_event)

	api.World.RunAction(test_Apc1,test_Apc1_event)
	api.World.RunAction(test_Apc2,test_Apc2_event)
	api.World.RunAction(test_Apc3,test_Apc3_event)
	api.World.RunAction(test_Apc4,test_Apc4_event)

	api.World.RunAction(test_Bpc1,test_Bpc1_event)
	
	api.World.RunAction(test_Cpc1,test_Cpc1_event)






	
	local height = 30
	
	
		
	
	
	
	Helper.ComplexCamera(232.6,172, height-5,232.6,172, height-5, 1,2, height ,height , 15,15, 0,0, 2.5,3) 
	
	
	Helper.ComplexCamera(232.6,172, height-5,231.9,172.2, height-5, 2,2.4, height ,height , 15,9, 0,0, 1,3) 
	local Npc1_said_donghuangtaiyi = 
	{
		name = '南宫无我',
		wait = 3,
		texts = {
			{text='五岳借法！',sec=1, clean=true ,wait=1},
			}
	}
	local sc = api.ShowCaption(Npc1_said_donghuangtaiyi)
	
	
	api.playTalkVoice("/res/sound/dynamic/guide/yy009_1.assetbundles")
	Helper.ComplexCamera(231.9,172.2, height-5,231.9,172.2, height-5, 2.4,2.4, height ,height , 9,9, 0,0, 1.3,3)
	
	Helper.ComplexCamera(231.9,172.2, height-5,236.47,169.76, height-5, 2.4,2.6, height -1,height +2, 9,20, 0,0, 0.5,2) 
	
	Helper.ComplexCamera(236.47,169.76, height-5,236.47,169.76, height-6, 2.6,2.9, height +2,height +3, 20,23, 0,0,3,3) 
	Helper.ComplexCamera(236.47,169.76, height-6,236.47,169.76, height-6, 2.9,2.5, height +3,height +5, 23,20, 0,0,4,3) 
	
	api.SetTimeScale(0.6)
	Helper.ComplexCamera(230.57,164.4, height-4.6,230.57,164.4, height-4.6, 0.4,0.4, height -2,height -2, 5,5, 0,0, 0.5,0)
	
	api.World.Remove(test_Bpc1)
	
	Helper.ComplexCamera(239.52,162.2, height-4.7,239.52,162.2, height-4.7, -0.3,-0.3, height -2,height -2, 5,5, 0,0, 0.5,0)
	Helper.ComplexCamera(243.54,170.25, height-4.6,243.54,170.25, height-4.6, -1,-1, height -2,height -2, 5,5, 0,0, 0.5,0)
	Helper.ComplexCamera(237.82,175.85, height-4.7,237.82,175.85, height-4.7, -1.7,-1.7, height -2,height -2, 6,6, 0,0, 0.5,0)
	Helper.ComplexCamera(230.22,173.22, height-4.6,230.22,173.22, height-4.6, 2.5,2.5, height -2,height -2, 6,6, 0,0, 0.5,0)
	api.SetTimeScale(1)
	
	
	
	
		local Npc4_said_lianbixie = 
	{
		name = '炼僻斜',
		wait = 2,
		texts = {
			{text='盟主召唤我等，所为何事？',sec=1, clean=true ,wait=1},
			}
	}
	local sc = api.ShowCaption(Npc4_said_lianbixie)
	

	api.playTalkVoice("/res/sound/dynamic/guide/yy009_2.assetbundles")
	Helper.ComplexCamera(230.3,171.5, height-4.7,233.2,169.4, height-4.7, -1.35,-1.75, height ,height , 13,15, 0,0, 4,0)
	
	
	
		local Npc1_said_donghuangtaiyi = 
	{
		name = '南宫无我',
		wait = 2,
		texts = {
			{text='千年之后，问道者临，元始归一，妖尽玄门！！',sec=1, clean=true ,wait=0},
			}
	}
	local sc = api.ShowCaption(Npc1_said_donghuangtaiyi)
	
	api.playTalkVoice("/res/sound/dynamic/guide/yy009_3.assetbundles")
	Helper.ComplexCamera(230.22,173.22, height-4.6,230.22,173.22, height-4.6, 2.1,2.1, height -2,height-2 , 6,6, 0,0, 5.5,0)

	
	local Npc1_said_donghuangtaiyi = 
	{
		name = '南宫无我',
		wait = 0,
		texts = {
			{text='如今，时机已到！',sec=1, clean=true ,wait=0},
			}
	}
	local sc = api.ShowCaption(Npc1_said_donghuangtaiyi)
	api.playTalkVoice("/res/sound/dynamic/guide/yy009_4.assetbundles")
	
	Helper.ComplexCamera(236.47,169.76, height-4.8,236.47,169.76, height-4.8, -1.3,-1.4, height +3,height+3 , 20,20, 0,0, 2,0)

	
	local Npc1_said_donghuangtaiyi = 
	{
		name = '南宫无我',
		wait = 0,
		texts = {
			{text='本座想启动「魔劫成道大阵」，改变天机，创造寻找「问道者」和元始圣甲的机缘！',sec=0.1, clean=true ,wait=0},
			}
	}
	local sc = api.ShowCaption(Npc1_said_donghuangtaiyi)	
	

	api.playTalkVoice("/res/sound/dynamic/guide/yy009_5.assetbundles")
	Helper.ComplexCamera(236.47,169.76, height-4.8,236.47,169.76, height-4.8, -1.4,-1.5, height +3,height+4 , 20,20, 0,0, 6,0)
	


	
	
	Helper.ComplexCamera(236.47,169.76, height-4.8,236.47,169.76, height-4.8, 1.4,1.3, height +4,height+4 , 20,20, 0,0, 3.5,0)

	
	
		
			local Npc5_said_busifuren = 
	{
		name = '慕容夫人',
		wait = 2,
		texts = {
			{text='我赞成启动大阵！此举可增加净世的胜算！',sec=0.1, clean=true ,wait=0},
			}
	}
	local sc = api.ShowCaption(Npc5_said_busifuren)
	
	api.playTalkVoice("/res/sound/dynamic/guide/yy009_6.assetbundles")
	Helper.ComplexCamera(243.54,170.25, height-4.6,243.54,170.25, height-4.6, -1,-1, height -2,height -2, 5,5, 0,0, 2,0)
	Helper.ComplexCamera(236.47,169.76, height-4.8,236.47,169.76, height-4.8, -1,-0.96, height +4,height+4 , 20,20, 0,0, 3,0)	

	
			local Npc2_said_shenhuolaozu = 
	{
		name = '神火真人',
		wait = 2,
		texts = {
			{text='我也不反对！要成大事，凶险就不可避免！',sec=0.1, clean=true ,wait=0},
			}
	}
	local sc = api.ShowCaption(Npc2_said_shenhuolaozu)
	
	api.playTalkVoice("/res/sound/dynamic/guide/yy009_7.assetbundles")
	Helper.ComplexCamera(236.47,169.76, height-4.8,236.47,169.76, height-4.8, -0.96,-0.9, height +4,height+4 , 20,20, 0,0, 3,0)
	Helper.ComplexCamera(239.52,162.2, height-4.6,239.52,162.2, height-4.6, -0.9,-0.9, height -2,height -2 , 5,5, 0,0, 2,0)

	
			local Npc4_said_lianbixie = 
	{
		name = '炼僻斜',
		wait = 2,
		texts = {
			{text='五岳中已有三岳赞成，我炼僻斜就是反对也无用！',sec=0.1, clean=true ,wait=0},
			}
	}
	local sc = api.ShowCaption(Npc4_said_lianbixie)	
	
	api.playTalkVoice("/res/sound/dynamic/guide/yy009_8.assetbundles")
	Helper.ComplexCamera(230.57,164.4, height-4.7,230.57,164.4, height-4.7, 0.2,0.2, height -2,height -2, 6.5,6.5, 0,0, 5.5,0)

	
			local Npc3_said_qingyijianke = 
	{
		name = '青灵子',
		wait = 2,
		texts = {
			{text='就依从盟主的意思吧！',sec=0.1, clean=true ,wait=0},
			}
	}
	local sc = api.ShowCaption(Npc3_said_qingyijianke)	
	
	api.playTalkVoice("/res/sound/dynamic/guide/yy009_9.assetbundles")
	Helper.ComplexCamera(237.82,175.85, height-4.6,237.82,175.85, height-4.6, -2.3,-2.3, height -2,height-2 , 6.5,6.5, 0,0, 3,0)	

	
			local Npc1_said_donghuangtaiyi = 
	{
		name = '南宫无我',
		wait = 2,
		texts = {
			{text='好，那随后就举办「五岳一战」，挑选若干闯阵者参加「魔劫成道大阵」！',sec=0.1, clean=true ,wait=0},
			}
	}
	local sc = api.ShowCaption(Npc1_said_donghuangtaiyi)

	api.playTalkVoice("/res/sound/dynamic/guide/yy009_10.assetbundles")
	Helper.ComplexCamera(230.22,173.22, height-4.8,230.22,173.22, height-4.8, 2.1,2.1, height -2,height -2, 7,7, 0,0, 2,0)	
	Helper.ComplexCamera(230.22,173.22, height-4.8,230.22,173.22, height-4.8, -0.9,-0.9, height -2,height -2, 7,7, 0,0, 0.5,0)	
	Helper.ComplexCamera(230.22,173.22, height-4.8,236.5,168.9, height-4.8, -0.9,-1.6, height -2,height +3, 7,20, 0,0, 7,0)



	
	
	

	
	
	
	
	
	
	
	api.Scene.HideAllUnit(false)
	
	Cam.SetOffset(0,0,0)
	api.FadeOutBackImg(1)
	
		
	api.SendEndMsg()
	
end
