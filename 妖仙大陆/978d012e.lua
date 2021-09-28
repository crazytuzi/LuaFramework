	
function start(api, id, s)
	
	local preState = api.Quest.GetPreState(id)
	
	
	step = api.Net.GetStep()
	if s ~= api.Quest.Status.CAN_FINISH or step then
		return
	end
	api.Sleep(1)
	api.SetNeedSendEndMsg()

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

	local pro = api.GetUserInfo().pro

 	local x,y = user.x, user.y

	local Cam = api.Camera
	
	

	local zj1 = api.World.CopyBattleUnit(pro,{nearX=x,nearY=y,filter='-Ride_Equipment'})

	api.Wait(api.World.WaitUnitLoadOk(zj1))

	api.ShowSideTool(true)


	
		local ts1 = api.World:CreateUnit()
		local ts1_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10004310}},
			{"Position",{x = 103.92,y = 56.44}},
			{"Direction",{direction = 1.5}},
	}
	api.World.RunAction(ts1,ts1_b)

		local tswb1 = api.World:CreateUnit()
		local tswb1_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10004301}},
			{"Position",{x = 100.97,y = 60.06}},
			{"Direction",{direction = 1.5}},
	}
	api.World.RunAction(tswb1,tswb1_b)

		local tswb2 = api.World:CreateUnit()
		local tswb2_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10004301}},
			{"Position",{x = 106.44,y = 60.48}},
			{"Direction",{direction = 1.5}},
	}
	api.World.RunAction(tswb2,tswb2_b)

		local tn1 = api.World:CreateUnit()
		local tn1_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 21001101}},
			{"Position",{x = 103.92,y = 60.21}},
			{"Direction",{direction = -1.75}},
	}
	api.World.RunAction(tn1,tn1_b)

	
		local zhs1 = api.World:CreateUnit()
		local zhs1_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10004323}},
			{"Position",{x = 45.77,y = 147.34}},
			{"Direction",{direction = -0.36}},
	}
	api.World.RunAction(zhs1,zhs1_b)

		local cws1 = api.World:CreateUnit()
		local cws1_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10004314}},
			{"Position",{x = 44.49,y = 158.05}},
			{"Direction",{direction = 0.1}},
	}
	api.World.RunAction(cws1,cws1_b)

		local ghs1 = api.World:CreateUnit()
		local ghs1_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10004320}},
			{"Position",{x = 48.23,y = 157.37}},
			{"Direction",{direction = 2.54}},
	}
	api.World.RunAction(ghs1,ghs1_b)


		local tj1 = api.World:CreateUnit()
		local tj1_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10004312}},
			{"Position",{x = 45.08,y = 172.67}},
			{"Direction",{direction = -0.45}},
	}
	api.World.RunAction(tj1,tj1_b)

		local lt1 = api.World:CreateUnit()
		local lt1_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10004319}},
			{"Position",{x = 65.73,y = 170.45}},
			{"Direction",{direction = 2.99}},
	}
	api.World.RunAction(lt1,lt1_b)

		local cw1 = api.World:CreateUnit()
		local cw1_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 104}},
			{"Position",{x = 0,y = 0}},
			{"Direction",{direction = 2.54}},
	}
	api.World.RunAction(cw1,cw1_b)

		local qz1 = api.World:CreateUnit()
		local qz1_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10002104}},
			{"Position",{x = 49.46,y = 146.24}},
			{"Direction",{direction = 2.48}},
	}
	api.World.RunAction(qz1,qz1_b)

		local qz2 = api.World:CreateUnit()
		local qz2_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10002103}},
			{"Position",{x = 48.53,y = 171.8}},
			{"Direction",{direction = 2.48}},
	}
	api.World.RunAction(qz2,qz2_b)

		local qz3 = api.World:CreateUnit()
		local qz3_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10002107}},
			{"Position",{x = 61.87,y = 170}},
			{"Direction",{direction = 0.2}},
	}
	api.World.RunAction(qz3,qz3_b)


	

		local sb1 = api.World:CreateUnit()
		local sb1_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10004325}},
			{"Position",{x = 92.09,y = 150.32}},
			{"Direction",{direction = 2.28}},
	}
	api.World.RunAction(sb1,sb1_b)

		local sb2 = api.World:CreateUnit()
		local sb2_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10004327}},
			{"Position",{x = 93.31,y = 158.12}},
			{"Direction",{direction = 2.19}},
	}
	api.World.RunAction(sb2,sb2_b)

			local sb3 = api.World:CreateUnit()
			local sb3_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10004302}},
			{"Position",{x = 102.14,y = 161.72}},
			{"Direction",{direction = 1.64}},
	}
	api.World.RunAction(sb3,sb3_b)


			local sb4 = api.World:CreateUnit()
			local sb4_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10004326}},
			{"Position",{x = 114.06,y = 158.78}},
			{"Direction",{direction = 1.02}},
	}
	api.World.RunAction(sb4,sb4_b)

			
			local sb5 = api.World:CreateUnit()
			local sb5_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10004303}},
			{"Position",{x = 117.05,y = 152.07}},
			{"Direction",{direction = -0.69}},
	}
	api.World.RunAction(sb5,sb5_b)


			local sb6 = api.World:CreateUnit()
			local sb6_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10004309}},
			{"Position",{x = 90.6,y = 129.41}},
			{"Direction",{direction = 1.15}},
	}
	api.World.RunAction(sb6,sb6_b)


			local sb7 = api.World:CreateUnit()
			local sb7_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10004321}},
			{"Position",{x = 96.84,y = 128.86}},
			{"Direction",{direction = 1.53}},
	}
	api.World.RunAction(sb7,sb7_b)


			local sb8 = api.World:CreateUnit()
			local sb8_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10004313}},
			{"Position",{x = 112.48,y = 128.76}},
			{"Direction",{direction = 1.31}},
	}
	api.World.RunAction(sb8,sb8_b)


			local sb9 = api.World:CreateUnit()
			local sb9_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10004328}},
			{"Position",{x = 116.66,y = 129.25}},
			{"Direction",{direction = 1.78}},
	}
	api.World.RunAction(sb9,sb9_b)


	api.Wait()





	Cam.PlayAnimation('zhucheng1')
	api.FadeOutBackImg(1.5)


		local caption = 
	{
		name = '',
		iconPath = 'dynamic_n/npc_bust/22001.png',
		wait = 1,
		texts = {
			{text='欢迎来到这个宏伟的城市——————王者之城！',sec=1, wait=1},
			}
	}
		local sc = api.ShowCaption(caption)

api.PlaySound( "/res/sound/dynamic/guide/mv_city01.assetbundles")

	api.Sleep(4)






	api.FadeOutBackImg(1.5)
	Cam.PlayAnimation('zhucheng2')

	local caption = 
	{
		name = '',
		iconPath = 'dynamic_n/npc_bust/22001.png',
		wait = 1,
		texts = {
			{text='每个来到这里的新兵都将受到圣光的赐福!',sec=1, wait=1},
			}
	}
	local sc = api.ShowCaption(caption)


		local ts1_d =
	{
		'Sequence',
	{'Delay',{delay=0.5}},
	{'BubbleMessage',{message="愿圣光与你同在!"}},
	{"Animation",{name ="n_wait2" }},
	}
	api.World.RunAction(ts1,ts1_d)

		local tn1_d =
	{
		'Sequence',
	{"Animation",{name = "n_idle"}},
	{'Delay',{delay=0.2}},
	{'Parallel', 
	{"Effect",{name = "/res/effect/50000_state/vfx_50201_level.assetBundles",bindBody=true,part= "Foot_Buff"}},
	{"Animation",{name ="f_hurt" }},
	},
	}
	api.World.RunAction(tn1,tn1_d)

api.PlaySound( "/res/sound/dynamic/guide/mv_city02.assetbundles")

	api.Sleep(5)

	api.FadeOutBackImg(1.5)
	Cam.PlayAnimation('zhucheng3')

	local caption = 
	{
		name = '',
		iconPath = 'dynamic_n/npc_bust/22001.png',
		wait = 1,
		texts = {
			{text='除此之外，这里也是一个热闹的商业圈，形形色色的人都会聚集在这里。',sec=1, wait=1},
			}
	}
	local sc = api.ShowCaption(caption)

local zhs1_d =
	{
		'Sequence',
	{'Delay',{delay=0.2}},	
	{'BubbleMessage',{message="走过路过不要错过啊！"}},
	{"Animation",{name ="n_wait2" }},
	{'BubbleMessage',{message="这些药可都是很稀有的哦！"}},
	{"Animation",{name ="n_wait1" }},
	}
	api.World.RunAction(zhs1,zhs1_d)

local cws1_d =
	{
		'Sequence',
	{'Delay',{delay=2.5}},
	{'BubbleMessage',{message="啊呀！这个实在太可爱啦！"}},
	{"Animation",{name ="n_wait1" }},
	}
	api.World.RunAction(cws1,cws1_d)

local ghs1_d =
	{
		'Sequence',
	{'BubbleMessage',{message="你看看，这个宠物怎么样？"}},
	{"Animation",{name ="n_wait1" }},
	}
	api.World.RunAction(ghs1,ghs1_d)

local tj1_d =
	{
		'Sequence',
	{'Delay',{delay=0.5}},
	{'Parallel', 
	{"Animation",{name ="n_wait1" }},
	{'Sequence',
	{'Delay',{delay=2.2}},
	{'BubbleMessage',{message="来看看这里的装备吧！保证物超所值！"}},
	},
	},

	}
	api.World.RunAction(tj1,tj1_d)

local lt1_d =
	{
		'Sequence',
	{'BubbleMessage',{message="咳~咳~~"}},
	{"Animation",{name ="n_wait2" }},
		{'BubbleMessage',{message="我这有新的图纸卖哟~"}},
	}
	api.World.RunAction(lt1,lt1_d)

local cw1_d =
	{
		'Sequence',
	{"Delay",{delay=1}},
	{"Position",{x = 47.12,y = 158.93}},
	{"Birth"},
	{"Animation",{name = "f_attack01"}},
	}
	api.World.RunAction(cw1,cw1_d)

	local qz1_d =
	{
		'Sequence',
	{"Animation",{name = "n_idle",loop=true}},
	}
	api.World.RunAction(qz1,qz1_d)
	api.World.RunAction(qz2,qz1_d)
	api.World.RunAction(qz3,qz1_d)


api.PlaySound( "/res/sound/dynamic/guide/mv_city03.assetbundles")

	api.Sleep(7)




	Cam.PlayAnimation('zhucheng4')
	api.FadeOutBackImg(1.5)

	local caption = 
	{
		name = '',
		iconPath = 'dynamic_n/npc_bust/22001.png',
		wait = 1,
		texts = {
			{text='勇敢的冒险者，你又会在这里经历怎样的冒险呢？',sec=1, wait=1},
			}
	}
	local sc = api.ShowCaption(caption)


	local zj1_b =
	{
		'Sequence',
			{"Position",{x = 103.76,y = 226.85}},
			{"MoveTo",{x = 103.76,y = 175.68 ,speed=13}},
	}
	api.World.RunAction(zj1,zj1_b)

	local sb1_d =
	{
		'Sequence',
	{"Animation",{name = "n_idle",loop=true}},
	}

	api.World.RunAction(sb1,sb1_d)
	api.World.RunAction(sb2,sb1_d)
	api.World.RunAction(sb3,sb1_d)
	api.World.RunAction(sb4,sb1_d)
	api.World.RunAction(sb5,sb1_d)
	api.World.RunAction(sb6,sb1_d)
	api.World.RunAction(sb7,sb1_d)
	api.World.RunAction(sb8,sb1_d)
	api.World.RunAction(sb9,sb1_d)
api.PlaySound( "/res/sound/dynamic/guide/mv_city04.assetbundles")
	api.Sleep(6)


	api.Wait()
	api.SendEndMsg()

end
