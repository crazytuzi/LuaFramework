	
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
	local test_NpcC = api.World:CreateUnit()
	local test_ApcA = api.World:CreateUnit()	





	local test_NpcA_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099012}},
			{"Position",{x = 99.8,y = 114.27}},
			{"Direction",{direction = 1.84}},
			{"Birth"},
			{"Animation",{name = "n_talk",loop=false}},
			{"Animation",{name = "f_attack03",loop=false}},
			{"Animation",{name = "n_idle",loop=true}},


	}
	
	
	
	
	local test_NpcB_event =
	{
		'Sequence',
			{"Delay",{delay=4.8}}, 
			{"LoadTemplate",{id = 10099021}},
			{"Position",{x = 99.05,y = 116.51}},
			{"Direction",{direction = -1}},
			{"Birth"},
			{"Animation",{name = "n_idle",loop=true}},
  


	}

	
	
	
	local test_NpcC_event =
	{
		'Sequence',
			{"Delay",{delay=4}},
			{"LoadTemplate",{id = 100990003}},
			{"Position",{x = 99.05,y = 116.51}},
			{"Direction",{direction = 5}},
			{"Birth"},
			{"Delay",{delay=0.5}},
			{"LoadTemplate",{id = 100990003}},
			{"Position",{x = 99.05,y = 116.51}},
			{"Direction",{direction = 5}},
			{"Birth"},
			
			
	}
	
	

	
		local test_ApcA_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10099041}},
			{"Position",{x = 99.05,y = 116.51}},
			{"Direction",{direction = -1}},
			{"Birth"},
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=4.2}}, 
			{"Position",{x = 123,y = 109}},

	}
	
	
	

	
	
	
	api.World.RunAction(test_NpcA,test_NpcA_event)
	api.World.RunAction(test_NpcB,test_NpcB_event)
	api.World.RunAction(test_NpcC,test_NpcC_event)
	api.World.RunAction(test_ApcA,test_ApcA_event)
	
	
		local Npc_A_zhangling = 
	{
		name = '叶晨',
		wait = 1,
		texts = {
			{text='突然想想，把你变成送亲小哥的样子应该挺有趣，嘿嘿！  来了~  ',sec=0.5, clean=true ,wait=1},
			}
	}
	local sc = api.ShowCaption(Npc_A_zhangling)
	
	
	
	
	
	
	local height = 25
	
	api.playTalkVoice("/res/sound/dynamic/guide/yybs_1.assetbundles")

	
	Helper.ComplexCamera(99.9,114.3,height -8.8, 99.9,114.3,height -8.8 , -0.2,0, height -8.3,height -8.3 , 3,4.5, 0,0, 3.5,0)
	
	api.SetTimeScale(0.7)
	Helper.ComplexCamera(99.9,114.3,height -8.8, 99.9,114.3,height -8.8 , 0,0, height -8.3,height -8.3 , 3,3, 0,0, 1.3,0)
	api.SetTimeScale(1)
	
			local Npc_A_zhangling = 
	{
		name = '送亲小哥',
		wait = 1,
		texts = {
			{text='……  ',sec=0.5, clean=true ,wait=1},
			}
	}
	local sc = api.ShowCaption(Npc_A_zhangling)
	
	
	Helper.ComplexCamera(99.39,115.5,height -8.8, 99.39,115.5,height -8.8 , 1.4,1.2, height -8.3,height -8.3 , 3,3, 0,0, 3.5,0)
	
	
	

	
	


	
 
	api.Scene.HideAllUnit(false)

	
	
	
	
	
	
	Cam.SetOffset(0,0,0)
	api.FadeOutBackImg(1)
	
		
	api.SendEndMsg()
	
end
