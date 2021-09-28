	
function start(api, id, s)
	
	
	
	step = api.Net.GetStep()
	if s ~= api.Quest.Status.IN_PROGRESS or step then
		return
	end
	api.Net.SendStep('entry')
	api.Scene.SetTempAutoFight(false)
	
	

	
	api.World.Init()

	
	api.UI.HideMFUI(true)

	api.UI.HideUGUITextLabel(true)

	api.UI.HideUGUIHpBar(true)

	
	api.UI.HideAllHud(true)

	
	api.UI.CloseAllMenu(true)

	
	api.Scene.HideAllUnit(true)

	
	api.SetBlockTouch(true)

	
	local user = api.GetUserInfo()


	local pro = api.GetUserInfo().pro

	
 	local x,y = user.x, user.y

 	
	local Cam = api.Camera

	
	local dz1 = api.World:CreateUnit()

		local dz1_r =
	{
		'Sequence',
			{"LoadTemplate",{id = 60108}},
			{"Position",{x = 0,y = 0}},
	}
	
	api.World.RunAction(dz1,dz1_r)


	
	api.ShowSideTool(true)

	api.Wait()

	api.FadeOutBackImg(1)

	Cam.PlayAnimation('sjkd1')

	
	local dz1_b =
	{
		'Sequence',
			{"Position",{x = 0,y = 0}},
			{"Direction",{direction = 2.6}},
				{
				'Parallel', 
				{"Position",{x = 134.49,y = 75.76}},
				{"Animation",{name ="n_show01" ,loop=false}},
				{"Effect",{name = "/res/effect/20000_monster/vfx_29102_show.assetBundles",bindBody=true,part = "Foot_Buff"}},
				
				{"Effect",{name = "/res/effect/20000_monster/vfx_29102_show_02.assetBundles",bindBody=true,part = "R Hand_Buff"}},

				{"Effect",{name = "/res/effect/20000_monster/vfx_29102_show_02.assetBundles",bindBody=true,part = "L Hand_Buff"}},
				},

			{"Animation",{name ="f_idle" ,loop=true}},	
	}


	api.World.RunAction(dz1,dz1_b)
	api.PlaySound( "/res/sound/dynamic/monster/monster_106404_word03.assetbundles")
	api.Sleep(3.4)
	api.PlaySound( "/res/sound/dynamic/monster/monster_106404_word01.assetbundles")
	api.Sleep(2)
	
	
	api.FadeOutBackImg(2)
	


end
