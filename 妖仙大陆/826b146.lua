	
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


	local pro = api.GetUserInfo().pro

	
 	local x,y = user.x, user.y

 	
	local Cam = api.Camera

	local zj1 = api.World.CopyBattleUnit(pro,{nearX=x,nearY=y,filter='-Ride_Equipment'})

	api.Wait(api.World.WaitUnitLoadOk(zj1))

	
	local dz1 = api.World:CreateUnit()

		local dz1_r =
	{
		'Sequence',
			{"LoadTemplate",{id = 10004309}},
			{"Position",{x = 102.63,y = 56.57}},
			{"Direction",{direction = 1}},
	}
	

			local zj1_r =
	{
		'Sequence',
			{"Position",{x = 105.43,y = 59.98}},
				{"Direction",{direction = 3.91}},
		

	}

	api.World.RunAction(zj1,zj1_r)
	api.World.RunAction(dz1,dz1_r)


	
	api.ShowSideTool(true)

	api.Wait()

	api.FadeOutBackImg(1)

	Cam.PlayAnimation('zhucheng5')

	
	local dz1_b =
	{
		'Sequence',
				{
				'Parallel', 
				{"Position",{x = 102.63,y = 56.57}},
				{"Animation",{name ="n_show01" ,loop=false}},
				{"Effect",{name = "/res/effect/20000_monster/vfx_22946_show.assetBundles",bindBody=true,part = "Foot_Buff"}},
				
				{"Effect",{name = "/res/effect/20000_monster/vfx_22946_guazai.assetBundles",bindBody=true,part = "R_Hand_Buff"}},

				{"Effect",{name = "/res/effect/20000_monster/vfx_22946_guazai.assetBundles",bindBody=true,part = "L_Hand_Buff"}},
				},
			{"Animation",{name ="n_wait1" ,loop=false}},
			{"Animation",{name ="n_idle" ,loop=false}},

	}
local zj1_b =
	{
		'Sequence',
		{"Animation",{name = "n_idle"}},
		{'Delay',{delay=3.5}},
		{'Parallel', 
	{"Effect",{name = "/res/effect/50000_state/vfx_50201_level.assetBundles",bindBody=true,part= "Foot_Buff"}},

	},
	{"Animation",{name = "n_idle",loop=false}},
	}





	api.World.RunAction(zj1,zj1_b)
	api.World.RunAction(dz1,dz1_b)
	local caption = 
	{
		name = '大天使拉斐尔',
		iconPath = 'dynamic_n/npc_bust/22001.png',
		wait = 1,
		texts = {
			{text='我将引导魔杖的力量赐予你，年轻的勇者！！',sec=1, wait=1.5},
			}
	}
	local sc = api.ShowCaption(caption)
	api.Sleep(2)

	api.AddCaptionText(sc, {text='勃~洛~波~罗~米',sec=1.8, clean=true,wait=2.5})
	
	api.AddCaptionText(sc, {text='现在你已经拥有了魔杖的力量，获得了魔法的双翼！',sec=1, clean=true,wait=1})

	api.AddCaptionText(sc, {text='请和我一起帮助人类，远离黑暗吧！！',sec=1, clean=true,wait=2})


	api.Sleep(11)

	
	
	api.FadeOutBackImg(2)
	


end
