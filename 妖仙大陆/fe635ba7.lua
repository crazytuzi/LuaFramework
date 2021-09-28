	
function start(api,...)
	
	step = api.Net.GetStep()
	if step then
		return
	end
	api.Scene.SetTempAutoFight(false)
	api.Net.SendStep('entry')
	
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

	local dz1 = api.World:CreateUnit()
	local dz2 = api.World:CreateUnit()
	local dz3 = api.World:CreateUnit()

	local dz1_r =
	{
		'Sequence',
			{"LoadTemplate",{id = 60007}},
			{"Position",{x = 0,y = 0}},
	}

		local dz2_r =
	{
		'Sequence',
			{"LoadTemplate",{id = 60001}},
			{"Position",{x = 0,y = 0}},
	}

		local dz3_r =
	{
		'Sequence',
			{"LoadTemplate",{id = 60001}},
			{"Position",{x = 0,y = 0}},
	}			

	api.World.RunAction(dz1,dz1_r)
	api.World.RunAction(dz2,dz2_r)
	api.World.RunAction(dz3,dz3_r)


	
	api.ShowSideTool(true)

	api.Wait()

	Cam.PlayAnimation('shouren2')

	local dz1_b =
	{
		'Sequence',
			{"Position",{x = 82.55,y = 95.44}},
			{"Direction",{direction = 0.75}},
			{"Birth"},
			{"Animation",{name ="n_show1" ,loop=false}},
			{"Animation",{name ="f_idle" ,loop=false}},
	}

		local dz2_b =
	{
		'Sequence',
			
			{"Position",{x = 87.86,y = 96.65}},
			{"Direction",{direction = -2.3}},
			{"Birth"},
			{"Animation",{name ="f_idle" ,loop=true}},
	}

		local dz3_b =
	{
		'Sequence',
			
			{"Position",{x = 86.02,y = 99.15}},
			{"Direction",{direction = -2.3}},
			{"Birth"},
			{"Animation",{name = "f_idle",loop=true}},
	}	

	api.World.RunAction(dz1,dz1_b)
	api.World.RunAction(dz2,dz2_b)
	api.World.RunAction(dz3,dz3_b)

	api.Sleep(1.5)
	api.PlaySound( "/res/sound/dynamic/monster/BossOrcDeath.assetbundles")

	api.Sleep(2)
	api.PlaySound( "/res/sound/dynamic/monster/monster_101704_word01.assetbundles")

	local dz1_bb =
	{
		'Sequence',
			{'BubbleMessage',{message="你们几个，去看看那边是怎么回事？"}},
			{"Animation",{name ="n_show2" ,loop=false}},
			{"Animation",{name ="f_idle" ,loop=false}},
	}

	api.World.RunAction(dz1,dz1_bb)
	
	api.Sleep(2.5)

	local dz2_bb =
	{
		'Sequence',
			{'BubbleMessage',{message="Dadu!"}},
			{'Delay',{delay=0.5}},
			{"MoveTo",{x=97.07,y=106.15,speed=8}},
	}

	local dz3_bb =
	{
		'Sequence',
			{'BubbleMessage',{message="Dadu!"}},
			{'Delay',{delay=0.5}},
			{"MoveTo",{x=93.91,y=107.77,speed=8}},
	}

	api.World.RunAction(dz2,dz2_bb)
	api.World.RunAction(dz3,dz3_bb)

	api.Sleep(2)

	

	
	
	
	api.SendEndMsg()

end
