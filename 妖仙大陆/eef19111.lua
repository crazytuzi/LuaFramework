


    
    
    
    



	
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

	local dz1 = api.World:CreateUnit()
	local dz2 = api.World:CreateUnit()
	local dz3 = api.World:CreateUnit()

	local dz1_r =
	{
		'Sequence',
			{"LoadTemplate",{id = 10050}},
			{"Position",{x = 0,y = 0}},
	}

	local dz2_r =
	{
		'Sequence',
			{"LoadTemplate",{id = 10041}},
			{"Position",{x = 0,y = 0}},
	}

	local dz3_r =
	{
		'Sequence',
			{"LoadTemplate",{id = 10041}},
			{"Position",{x = 0,y = 0}},
	}

	api.World.RunAction(dz1,dz1_r)
	api.World.RunAction(dz2,dz2_r)
	api.World.RunAction(dz3,dz3_r)
	
	api.Wait()

	Cam.PlayAnimation('shouren1')

	
	
	
	
	
	local dz1_b =
	{
		'Sequence',
			{"Position",{x = 36.38,y = 48.83}},
			{"Direction",{direction = 1}},
			{"Birth"},
			{"Animation",{name = "f_idle",loop=true}},
			{'BubbleMessage',{message="Lok-tar Ogar!"}},
			{"Animation",{name ="f_skill01" ,loop=false}},
			{"Animation",{name ="f_idle" ,loop=false}},
	}

	
		local dz2_b =
	{
		'Sequence',
			{"Position",{x = 33.68,y = 47.32}},
			{"Direction",{direction = 1}},
			{"Birth"},
			{"Animation",{name ="f_idle" ,loop=true}},
			{"Delay",{delay=2}},
			{'BubbleMessage',{message="Dabu!"}},
			{"Animation",{name ="f_attack01" ,loop=false}},
	}

	
		local dz3_b =
	{
		'Sequence',
			{"Position",{x = 37.39,y = 45.99}},
			{"Direction",{direction = 1}},
			{"Birth"},
			{"Animation",{name = "f_idle",loop=true}},
			{"Delay",{delay=2}},
			{'BubbleMessage',{message="Dabu!"}},
			{"Animation",{name ="f_attack01" ,loop=false}},
	}	

	
	api.World.RunAction(dz1,dz1_b)

	
	api.World.RunAction(dz2,dz2_b)

	
	api.World.RunAction(dz3,dz3_b)
api.Sleep(1)
api.PlaySound( "/res/sound/dynamic/guide/mv_orc01.assetbundles")
	api.Wait()
	


	api.FadeOutBackImg(1)

	Cam.SetDramaCamera(true)

	Cam.SetPosition(36.38,48.83)
	
	local follow = api.AddPeriodicTimer(0,function ()
		Cam.SetPosition(api.World.GetUnitPos(dz1))
	end)
	
	
	local dz1_bb = {
		'Sequence',
		{"MoveTo",{x=39.11,y=69.97,speed=8}},
		{"MoveTo",{x=49.18,y=78.74,speed=8}},
		{"MoveTo",{x=58.88,y=77.03,speed=8}},
	}

	local dz2_bb = {
		'Sequence',
		{"MoveTo",{x=34.52,y=68.74,speed=8}},
			{"MoveTo",{x=46.23,y=81.34,speed=8}},
			{"MoveTo",{x=57.05,y=80.16,speed=8}},
	}

	local dz3_bb = {
		'Sequence',
		{"MoveTo",{x=40.38,y=65.63,speed=8}},
			{"MoveTo",{x=46.84,y=74.59,speed=8}},
			{"MoveTo",{x=56.62,y=74.07,speed=10}},
	}

	
	api.World.RunAction(dz1,dz1_bb)
	api.World.RunAction(dz2,dz2_bb)
	api.World.RunAction(dz3,dz3_bb)




local caption = 
	{
		name = '中士  提诺',
		iconPath = 'dynamic_n/npc_bust/22001.png',
		wait = 1,
		texts = {
			{text='兽人洞穴就在艾文郡的西北处。',sec=1, wait=1},
			}
	}
	local sc = api.ShowCaption(caption)
	api.Sleep(0.2)

	
	local wb1 = api.World:CreateUnit()
	local wb2 = api.World:CreateUnit()
	local wb3 = api.World:CreateUnit()
	
	
		local wb1_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 12010}},
			{"Position",{x=61.61,y=77.02}},
			{"Direction",{direction = 3.14}},
			{"Animation",{name ="f_idle" ,loop=true}},
			{'Delay',{delay=7.5}},
			{"Animation",{name ="f_dead01" ,loop=false}},
	}

	
		local wb2_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 12010}},
			{"Position",{x=59.91,y=80.15}},
			{"Direction",{direction = 3.14}},
			{"Animation",{name ="f_idle" ,loop=true}},
			{'Delay',{delay=8}},
			{"Animation",{name ="f_dead01" ,loop=false}},
	}

	
		local wb3_b =
	{
		'Sequence',
			{"LoadTemplate",{id = 12010}},
			{"Position",{x=59.21,y=74.07}},
			{"Direction",{direction = 3.14}},
			{"Animation",{name ="f_idle" ,loop=true}},
			{'Delay',{delay=8}},
			{"Animation",{name ="f_dead01" ,loop=false}},
	}

	
	api.World.RunAction(wb1,wb1_b)
	api.World.RunAction(wb2,wb2_b)
	api.World.RunAction(wb3,wb3_b)

	
	api.AddCaptionText(sc, {text='那些可恶的兽人大军正从那个洞穴中不断的涌出！',sec=1, clean=true,wait=4})

api.PlaySound( "/res/sound/dynamic/guide/mv_npc01.assetbundles")

api.Sleep(3)
api.PlaySound( "/res/sound/dynamic/guide/mv_npc02.assetbundles")


	
	api.Sleep(4)

	
	local dz1_bbc = {
		'Sequence',
		{'BubbleMessage',{message="去死吧！你们这些渣渣！"}},
		{'Skill',{id=10060301}},
		{"Delay",{delay=0.2}},
		{"Delay",{delay=1}},
		{'BubbleMessage',{message="Lok-tar Ogar!!"}},
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

api.PlaySound( "/res/sound/dynamic/guide/mv_npc03.assetbundles")
api.PlaySound( "/res/sound/dynamic/guide/mv_orc02.assetbundles")

api.Sleep(3)

api.PlaySound( "/res/sound/dynamic/guide/mv_orc01.assetbundles")
	
	api.Sleep(4)

	
	api.RemoveTimer(follow)

	
	Cam.SetPosition(x,y)

	
	api.Scene.HideAllUnit(false)

	
	api.CloseCaption()

	
	api.FadeOutBackImg(4)

	
	api.Sleep(2)

	
	local caption2 = 
	{
		name = '中士  提诺',
		iconPath = 'dynamic_n/npc_bust/22001.png',
		wait = 2,
		texts = {
			{text='现在我们把希望都寄托在你的身上！请一定要想办法阻止他们！', wait=2},
			}
	}
	local sc = api.ShowCaption(caption2)

api.PlaySound( "/res/sound/dynamic/guide/mv_npc04.assetbundles")
	api.Sleep(5.5)
	
	api.StopBGM()
	
	api.SendEndMsg()


end










	
	
		
	
	
	
	
	
	
	
	
	
	
	
	




































































