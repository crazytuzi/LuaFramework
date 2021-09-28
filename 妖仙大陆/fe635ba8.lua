	
function start(api,...)

	api.SetNeedSendEndMsg()

	
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

	local zj1 = api.World.CopyBattleUnit(pro,{nearX=x,nearY=y,filter='-Ride_Equipment'})

	api.Wait(api.World.WaitUnitLoadOk(zj1))

	local dz1 = api.World:CreateUnit()

		local dz1_r =
	{
		'Sequence',
			{"LoadTemplate",{id = 60008}},
			{"Position",{x = 0,y = 0}},
	}
	
	api.World.RunAction(dz1,dz1_r)


	
	api.ShowSideTool(true)

	api.Wait()

	api.FadeOutBackImg(1)

	Cam.PlayAnimation('shouren3')

	local zj1_b =
	{
		'Sequence',
			{"Position",{x = 100.11,y = 44.31}},
			{"MoveTo",{x = 108,y = 34 ,speed=11.5}},
			{'Delay',{delay=0.5}},
			{"Direction",{direction = -1.75}},
			{"Animation",{name ="f_idle" ,loop=true}},
	}

	local dz1_b =
	{
		'Sequence',
			{"Position",{x = 95.81,y = 2.1}},
			{"Direction",{direction = 1.5}},
			{'Delay',{delay=1.2}},
				{
				'Parallel', 
				{"Position",{x=106.99,y=28.06}},
				{"Animation",{name ="n_show1" ,loop=false}},
				},
			{"Animation",{name ="f_idle" ,loop=true}},	
	}


	api.World.RunAction(zj1,zj1_b)
	api.World.RunAction(dz1,dz1_b)

	api.Sleep(1.8)

	local caption = 
	{
		name = '加尔范',
		iconPath = 'dynamic_n/npc_bust/22001.png',
		wait = 1,
		texts = {
			{text='死吧！入侵者~！！',sec=1, wait=1.5},
			}
	}
	local sc = api.ShowCaption(caption)
	api.PlaySound( "/res/sound/dynamic/monster/monster_101404_word03.assetbundles")
	api.SetTimeScale(0.3)
	api.Sleep(0.5)
	api.SetTimeScale(1)
		
	api.Sleep(2)

	local dz1_bb =
	{
		'Sequence',
				{
				'Parallel', 
				{"Effect",{name = "/res/effect/20000_monster/vfx_29301_skill03.assetBundles",bindBody=true,part= Foot_Buff}},
				{"Animation",{name ="f_skill03" ,loop=false}},
				},	
	}
	api.World.RunAction(dz1,dz1_bb)	

	api.PlaySound( "/res/sound/dynamic/monster/monster_101404_word02.assetbundles")
	api.AddCaptionText(sc, {text='你的生命正走向终结！！！！',sec=2,wait=1})

	api.Sleep(4)

	local zj1_bbc =
	{
		'Sequence',
			{"Position",{x = x,y = y}},
	}

	api.World.RunAction(zj1,zj1_bbc)

	api.FadeOutBackImg(2)
	


end
