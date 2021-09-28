	
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
	
	
	
	local yy9_yr   = api.World:CreateUnit()
	local yy9_ff   = api.World:CreateUnit()
	local yy9_ys1  = api.World:CreateUnit()
	local yy9_ys2  = api.World:CreateUnit()	
	local yy9_ys3  = api.World:CreateUnit()		
	
	local yy9_yr_evt =
	{
		'Sequence',
			{"LoadTemplate",{id = 10050}},
			{"Position",{x = 0,y = 0}},
	}
	
	local yy9_ff_evt =
	{
		'Sequence',
			{"LoadTemplate",{id = 10041}},
			{"Position",{x = 0,y = 0}},
	}

	local yy9_ys1_evt =
	{
		'Sequence',
			{"LoadTemplate",{id = 12010}},
			{"Position",{x = 0,y = 0}},
	}
	
	local yy9_ys2_evt =
	{
		'Sequence',
			{"LoadTemplate",{id = 12010}},
			{"Position",{x = 0,y = 0}},
	}
	
	local yy9_ys3_evt =
	{
		'Sequence',
			{"LoadTemplate",{id = 12010}},
			{"Position",{x = 0,y = 0}},
	}
	
	
	
	
	api.World.RunAction(yy9_yr,yy9_yr_evt)
	api.World.RunAction(yy9_ff,yy9_ff_evt)
	api.World.RunAction(yy9_ys1,yy9_ys1_evt)
	api.World.RunAction(yy9_ys2,yy9_ys2_evt)
	api.World.RunAction(yy9_ys3,yy9_ys3_evt)
	
	
	api.Wait()
	
	
	
	

	
	
	
	local yy9_ff_pon =
	{
		'Sequence',
			{"Position",{x = 36.38,y = 48.83}},
			{"Direction",{direction = 1}},
			{"Birth"},
			{"Animation",{name = "f_idle",loop=true}},
			
	}
	
	local yy9_ys1_pon =
	{
		'Sequence',
			{"Position",{x = 33.68,y = 47.32}},
			{"Direction",{direction = 1}},
			{"Birth"},
			{"Animation",{name ="f_idle" ,loop=true}},
			{"Delay",{delay=0.5}},
			{'BubbleMessage',{message="..."}},
			{"Animation",{name ="f_attack01" ,loop=false}},
	}
	
	local yy9_ys2_pon =
	{
		'Sequence',
			{"Position",{x = 37.39,y = 45.99}},
			{"Direction",{direction = 1}},
			{"Birth"},
			{"Animation",{name ="f_idle" ,loop=true}},
			{"Delay",{delay=0.5}},
			{'BubbleMessage',{message="哪来的声音??"}},
	}
	
	local yy9_ys3_pon =
	{
		'Sequence',
			{"Position",{x = 35.68,y = 46.62}},
			{"Direction",{direction = 1}},
			{"Birth"},
			{"Animation",{name ="f_idle" ,loop=true}},
			{"Delay",{delay=0.5}},
			{'BubbleMessage',{message="好可怕！！"}},
	}
	
	
	Cam.SetPosition(36.38,48.83)
	api.Wait(3)
	
	
	
	api.World.RunAction(yy9_ff,yy9_ff_pon)
	api.World.RunAction(yy9_ys1,yy9_ys1_pon)
	api.World.RunAction(yy9_ys2,yy9_ys2_pon)
	api.World.RunAction(yy9_ys3,yy9_ys3_pon)
	
	
	api.Sleep(1.5)
	api.Wait()
	
	api.FadeOutBackImg(1)
	
	
	
	
	
	
	
	local yy9_yr_pon =
	{
		'Sequence',
			{"Position",{x = 40.68,y = 51.62}},
			{"Direction",{direction = 6.28}},
			{"Birth"},
			{"Animation",{name ="f_idle" ,loop=true}},
			{"Delay",{delay=2}},
			{"MoveTo",{x=39.11,y=45.97,speed=2}},
			{'BubbleMessage',{message="秋意，我俩以天地为证，今天就在这桃树下结为夫妻吧。"}},
			{"Animation",{name ="f_idle" ,loop=false}},
	}
	
	
	api.World.RunAction(yy9_yr,yy9_yr_pon)
	
	
	api.Sleep(1.5)
	
	
	local follow = api.AddPeriodicTimer(0,function ()
		Cam.SetPosition(api.World.GetUnitPos(yy9_yr))
	end)
	api.Wait()
	
		
	api.RemoveTimer(follow)
	
	
	
	
	Cam.SetPosition(36.38,48.83)
	api.Wait(3)
	
	local yy9_ff_pon1 =
	{
		'Sequence',
			{"Animation",{name = "f_idle",loop=true}},
			{"Delay",{delay=3}},
			{'BubbleMessage',{message="痴心妄想，人妖相恋，天地不容！"}},
			{"Animation",{name ="f_attack01" ,loop=true}},
	}
	
	
	api.World.RunAction(yy9_ff,yy9_ff_pon1)	
	
	
	api.Sleep(3)
	api.Wait()
	
	
	
	
	

	
	local yy9_yr_pon1 =
	{
		'Sequence',
			{"Animation",{name ="f_idle" ,loop=true}},
			{"Delay",{delay=3}},
			{'BubbleMessage',{message="五岳仙盟？！是秋意要你们来杀我吗？！"}},
			{"Animation",{name ="f_attack01" ,loop=true}},
	}	
	
	
	api.World.RunAction(yy9_yr,yy9_yr_pon1)	
	
	
	api.Sleep(3)
	api.Wait()	
	
		local follow = api.AddPeriodicTimer(0,function ()
		Cam.SetPosition(api.World.GetUnitPos(yy9_yr))
	end)
	api.Wait()
	
		
	api.RemoveTimer(follow)
	
	
	
	
	
	
	local yy9_ff_pon2 =
	{
		'Sequence',
			{"Animation",{name = "f_attack01",loop=true}},
			{"Delay",{delay=3}},
			{'BubbleMessage',{message="降妖卫道，是五岳术士的天职，如果你甘心伏诛，我给你一个痛快！"}},
	}	

	
	api.World.RunAction(yy9_ff,yy9_ff_pon2)

	
	api.Sleep(3)
	Cam.SetPosition(36.38,48.83)
	api.Wait()	

	
	
	
	
	
	local yy9_yr_pon2 =
	{
		'Sequence',
			{"Animation",{name ="f_attack01" ,loop=true}},
			{"Delay",{delay=3}},
			{'BubbleMessage',{message="好大的口气，千年之前，五岳仙盟要不是向仙界乞怜，早给妖界灭了！"}},
	}
	
	
	api.World.RunAction(yy9_yr,yy9_yr_pon2)
	
	api.Sleep(3)
	api.Wait()
	
	
			local follow = api.AddPeriodicTimer(0,function ()
		Cam.SetPosition(api.World.GetUnitPos(yy9_yr))
	end)
	api.Wait()
	
		
	api.RemoveTimer(follow)
	
	
	
	
	
	local yy9_ff_pon3 =
	{
		'Sequence',
			{"Animation",{name = "f_attack01",loop=true}},
			{"Delay",{delay=3}},
			{'BubbleMessage',{message="看剑！"}},
	}
	
	
	api.World.RunAction(yy9_ff,yy9_ff_pon3)

	
	api.Sleep(3)
	Cam.SetPosition(36.38,48.83)
	api.Wait()	
	
	
	
	

	api.Sleep(4)

	
	api.RemoveTimer(follow)

	
	Cam.SetPosition(x,y)

	
	api.Scene.HideAllUnit(false)

	
	api.CloseCaption()

	
	api.FadeOutBackImg(4)

	
	api.Sleep(2)
	
	api.StopBGM()
	
	api.SendEndMsg()


end
