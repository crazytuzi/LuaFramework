	
function start(api,...)

	
	api.World.Init()

	
	api.UI.HideMFUI(true)

	
	api.UI.HideAllHud(true)

	
	api.UI.CloseAllMenu(true)

	
	api.Scene.HideAllUnit(true)


	
	api.SetBlockTouch(true)

	
	local user = api.GetUserInfo()

	
 	local x,y = user.x, user.y

 	
	local Cam = api.Camera

	
	api.ShowSideTool(true)

	
	Cam.SetDramaCamera(true)

	
	Cam.SetPosition(x,y)

	
	Cam.SetTelescope(true)

	
	api.Wait()

	
local caption = 
	{
		name = '中士  提诺',
		iconPath = 'dynamic_n/npc_bust/22001.png',
		wait = 1,
		texts = {
			{text='兽人洞穴就在艾文郡的西北处',sec=1, wait=1},
			}
	}
	local sc = api.ShowCaption(caption)
	api.Sleep(0.2)



	
	api.Wait(Cam.MoveTo(36.38,48.83,80))

	
	api.AddCaptionText(sc, {text='那些可恶的兽人大军正从那个洞穴中不断的涌出',sec=1, clean=true,wait=12})

	
	api.Sleep(1)
	
	
	local ch1 = api.World:CreateUnit()
	local ch2 = api.World:CreateUnit()
	local ch3 = api.World:CreateUnit()
	
	
	local ch1_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10041}},
			{"Position",{x = 36.38,y = 48.83}},
			{"Direction",{direction = 1}},
			{"Birth"},
			{"MoveTo",{x=46.96,y=53.9,speed=7}},
	}

	
		local ch2_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10041}},
			{"Position",{x = 33.68,y = 47.32}},
			{"Direction",{direction = 1}},
			{"Birth"},
			{"MoveTo",{x=43.29,y=57,speed=7}},
	}

	
		local ch3_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10041}},
			{"Position",{x = 37.39,y = 45.99}},
			{"Direction",{direction = 1}},
			{"Birth"},
			{"MoveTo",{x=49.67,y=48.81,speed=7}},
	}	

	
	api.World.RunAction(ch1,ch1_b)

	
	api.Sleep(0.5)

	
	api.World.RunAction(ch2,ch2_b)

	
	api.Sleep(0.5)

	
	api.World.RunAction(ch3,ch3_b)

	
	api.Sleep(0.5)


	
	local ch4 = api.World:CreateUnit()
	local ch5 = api.World:CreateUnit()
	local ch6 = api.World:CreateUnit()

	
	local ch4_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10041}},
			{"Position",{x = 36.38,y = 48.83}},
			{"Direction",{direction = 1}},
			{"Birth"},
			{"MoveTo",{x=39.44,y=67.4,speed=7}},
	}

	
		local ch5_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10041}},
			{"Position",{x = 33.68,y = 47.32}},
			{"Direction",{direction = 1}},
			{"Birth"},
			{"MoveTo",{x=35.61,y=65.69,speed=7}},
	}

	
		local ch6_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10041}},
			{"Position",{x = 37.39,y = 45.99}},
			{"Direction",{direction = 1}},
			{"Birth"},
			{"MoveTo",{x=40.61,y=63.55,speed=7}},
	}	

	
	api.World.RunAction(ch4,ch4_b)

	
	api.Sleep(0.5)

	
	api.World.RunAction(ch5,ch5_b)

	
	api.Sleep(0.5)

	
	api.World.RunAction(ch6,ch6_b)

	
	api.Sleep(1)

	
	local dz1 = api.World:CreateUnit()
	local dz2 = api.World:CreateUnit()
	local dz3 = api.World:CreateUnit()
	
	
	local dz1_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10050}},
			{"Position",{x = 36.38,y = 48.83}},
			{"Direction",{direction = 1}},
			{"Birth"},
	}

	
		local dz2_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10041}},
			{"Position",{x = 33.68,y = 47.32}},
			{"Direction",{direction = 1}},
			{"Birth"},
			{"Animation",{name ="f_idle" ,loop=true}},
			{"Delay",{delay=2}},
			{'BubbleMessage',{message="Dabu!"}},
			{"Animation",{name ="f_attack01" ,loop=false}},
			{"MoveTo",{x=34.52,y=68.74,speed=8}},
			{"MoveTo",{x=46.23,y=81.34,speed=8}},
			{"MoveTo",{x=57.05,y=80.16,speed=8}},

	}

	
		local dz3_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10041}},
			{"Position",{x = 37.39,y = 45.99}},
			{"Direction",{direction = 1}},
			{"Birth"},
			{"Animation",{name = "f_idle",loop=true}},
			{"Delay",{delay=2}},
			{'BubbleMessage',{message="Dabu!"}},
			{"Animation",{name ="f_attack01" ,loop=false}},
			{"MoveTo",{x=40.38,y=65.63,speed=8}},
			{"MoveTo",{x=46.84,y=74.59,speed=8}},
			{"MoveTo",{x=56.62,y=74.07,speed=10}},
	}	

	
	api.World.RunAction(dz2,dz2_b)

	
	api.World.RunAction(dz3,dz3_b)

	
	api.Wait(api.World.RunAction(dz1,dz1_b))

	
	api.World.Remove(ch1)
	api.World.Remove(ch2)
	api.World.Remove(ch3)
	api.World.Remove(ch4)
	api.World.Remove(ch5)
	api.World.Remove(ch6)
	
	
	local dz1_bb = {
		'Sequence',
		{"Animation",{name = "f_idle",loop=true}},
		{'BubbleMessage',{message="Lok-tar Ogar!"}},
		{"Animation",{name ="f_skill01" ,loop=false}},
		{"Delay",{delay=1}},
		{"MoveTo",{x=39.11,y=69.97,speed=8}},
		{"MoveTo",{x=49.18,y=78.74,speed=8}},
		{"MoveTo",{x=58.88,y=77.03,speed=8}},
	}

	
	local follow = api.AddPeriodicTimer(0,function ()
		Cam.SetPosition(api.World.GetUnitPos(dz1))
	end)

	
	api.World.RunAction(dz1,dz1_bb)

	
	local wb1 = api.World:CreateUnit()
	local wb2 = api.World:CreateUnit()
	local wb3 = api.World:CreateUnit()
	
	
		local wb1_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10001103}},
			{"Position",{x=61.61,y=77.02}},
			{"Direction",{direction = 3.14}},
			{"Animation",{name ="f_idle" ,loop=true}},
			{'Delay',{delay=10.5}},
			{"Animation",{name ="f_dead01" ,loop=false}},
	}

	
		local wb2_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10001103}},
			{"Position",{x=59.91,y=80.15}},
			{"Direction",{direction = 3.14}},
			{"Animation",{name ="f_idle" ,loop=true}},
			{'Delay',{delay=11}},
			{"Animation",{name ="f_dead01" ,loop=false}},
	}

	
		local wb3_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 10001103}},
			{"Position",{x=59.21,y=74.07}},
			{"Direction",{direction = 3.14}},
			{"Animation",{name ="f_idle" ,loop=true}},
			{'Delay',{delay=11}},
			{"Animation",{name ="f_dead01" ,loop=false}},
	}

	
	api.World.RunAction(wb1,wb1_b)
	api.World.RunAction(wb2,wb2_b)
	api.World.RunAction(wb3,wb3_b)

	
	api.Sleep(10)

	
	local dz1_bbc = {
		'Sequence',
		{'BubbleMessage',{message="去死吧！你们这些渣渣！"}},
		{'Skill',{id=10060301}},
		{"Delay",{delay=0.2}},
		{"Delay",{delay=1}},
		{'BubbleMessage',{message="Lok-tar Ogar!!为了部落！"}},
		{"Animation",{name ="f_skill01" ,loop=false}},
		
	}

	
	local dz2_bbc = {
		'Sequence',
		{"Delay",{delay=0.5}},
		{"Animation",{name ="f_attack01" ,loop=false}},
		{"Delay",{delay=1.5}},
		{'BubbleMessage',{message="Lok-tar！"}},
		{"Animation",{name ="f_attack01" ,loop=false}},
	}

	
	local dz3_bbc = {
		'Sequence',
		{"Delay",{delay=0.5}},
		{"Animation",{name ="f_attack01" ,loop=false}},
		{"Delay",{delay=1.5}},
		{'BubbleMessage',{message="Lok-tar!"}},
		{"Animation",{name ="f_attack01" ,loop=false}},
	}

	
	api.World.RunAction(dz1,dz1_bbc)
	api.World.RunAction(dz2,dz2_bbc)
	api.World.RunAction(dz3,dz3_bbc)

	
	api.AddCaptionText(sc, {text='我们虽然派出士兵们去阻止他们的侵袭，可是他们实在太强大，很多人因此丧生了......',sec=1, clean=true,wait=5})

	
	api.Sleep(5)

	
	api.RemoveTimer(follow)

	
	Cam.SetPosition(x,y)

	
	Cam.SetTelescope(false)


	
	api.Scene.HideAllUnit(false)

	
	api.CloseCaption()

	
	api.FadeOutBackImg(4)

	
	api.Sleep(2)

	
	local caption = 
	{
		name = '中士  提诺',
		iconPath = 'dynamic_n/npc_bust/22001.png',
		wait = 1,
		texts = {
			{text='现在我们把希望都寄托在你的身上！请一定要想办法阻止他们！',sec=1, wait=1},
			}
	}
	local sc = api.ShowCaption(caption)

	
	api.Sleep(3)


end
