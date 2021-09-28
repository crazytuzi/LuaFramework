	
function start(api,...)

	
	api.World.Init()

	
	api.UI.HideMFUI(true)

	api.UI.HideUGUITextLabel(true)

	api.UI.HideUGUIHpBar(true)

	
	api.UI.HideAllHud(true)

	
	api.UI.CloseAllMenu(true)


	
	api.Scene.HideAllUnit(true)

	
	api.SetBlockTouch(true)

	
	local user = api.GetUserInfo()

	
 	local x,y = user.x, user.y

 	
	local Cam = api.Camera

	
	api.ShowSideTool(true)
	
	
    api.PlayBGM("/res/sound/dynamic/bgm/music_shuijinghu2.assetbundles")
	
	
	
	
	
	Cam.SetDramaCamera(true) 
	
	local test_NpcA = api.World:CreateUnit()
	local test_NpcB = api.World:CreateUnit()
	local test_NpcC = api.World:CreateUnit()
	
	
	local test_NpcA_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10050}},
			{"Position",{x = 90,y = 86}},
			{"Direction",{direction = 0}},
			{"Birth"},
			{"Animation",{name = "f_idle",loop=true}},
			{"Delay",{delay=1}},
			{"MoveTo",{x=90,y=78,speed=4}},
			{"Delay",{delay=4}},
			{"TurnDirection",{x=92,y=77,speed=8}},
			{"Delay",{delay=3.1}},
			{"TurnDirection",{x=90,y=76,speed=8}},
			{"Delay",{delay=1.1}},
			{"MoveTo",{x=90,y=86,speed=4}},
	}
	
	local test_NpcB_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10041}},
			{"Position",{x = 90,y = 76}},
			{"Direction",{direction = 3.14}},
			{"Birth"},
			{"Animation",{name = "f_idle",loop=true}},
	}

	local test_NpcC_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 12010}},
			{"Position",{x = 99,y = 73}},
			{"Direction",{direction = 0}},
			{"Birth"},
			{"Animation",{name = "f_idle",loop=true}},
			{"MoveTo",{x=92,y=77,speed=4}},
			{"Delay",{delay=1}},
			{"Animation",{name = "f_idle",loop=true}},
	}

	
	api.FadeOutBackImg(1.5)
	api.World.RunAction(test_NpcA,test_NpcA_event)
	api.World.RunAction(test_NpcB,test_NpcB_event)
	
	api.Camera.SetOffset(0,0,0)
	
	local follow = api.AddPeriodicTimer(0,function ()
		Cam.SetPosition(api.World.GetUnitPos(test_NpcA))
	end)	
	
	api.Sleep(5)
	api.World.RunAction(test_NpcC,test_NpcC_event)
	api.Sleep(1)
	api.RemoveTimer(follow)
	api.Camera.MoveToHeight(7,3)
	api.Camera.MoveToEulerAngles(15,0,0,12.5)
	api.Sleep(4)
	Helper.AroundCamera(90,78,2, -0.5,-1.5, 6,8, 12, 4,0)
	api.FadeOutBackImg(1)
	api.StopBGM()
		
	api.SendEndMsg()
	
end
