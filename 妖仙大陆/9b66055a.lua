

function start(api,...)
	
	local txts = {'我','是','不','花','华','天','一','二','伞','三','四','五'}
	
	local function RandomTxt(length)
		local txt = ''
		for j=1,length do
			local index = math.random(1,#txts)
			txt = txt..txts[index]
		end	
		return txt
	end
	
	local World = api.World
	local Camera = api.Camera
	local Helper = api.Helper
	
  local user = api.GetUserInfo()
  local x,y = user.x, user.y
  
	World.Init()
	api.UI.HideAllHud(true)
	local example = {
		'Sequence',
		{'LoadTemplate',{id=3}},
		{'Position',{x=x,y=y+2}},
		{'BubbleMessage',{message='播放单位出生动画'}},
		{'Birth'},
		{'BubbleMessage',{message='延迟2秒干别的'}},
		{'Delay',{delay=2}},
		{'BubbleMessage',{message='无限的死去活来'}},
		{'Animation',{name='f_dead',loop=true}},
		{'Delay',{delay=4}},
		{'Animation',{name='f_idle',loop=true}},
		{'BubbleMessage',{message='我要名字'}},
		{'Delay',{delay=0.3}},
		{'BubbleMessage',{message='名字出来啦,阵营为1'}},
		{'AddInfoBar',{force=1}},
		{'ChangeName',{name='齐天大圣孙悟空'}},
		{'Delay',{delay=1}},
		{'BubbleMessage',{message='方向设置到3.14'}},
		{'Direction',{direction=3.14}},
		{'Delay',{delay=2}},
		{'BubbleMessage',{message='转向到1.28'}},
		{'TurnDirection',{direction=1.28,speed=1.0}},
		{'Delay',{delay=2}},
		{'BubbleMessage',{message='转向到面向x,y坐标'}},
		{'TurnDirection',{x=x,y=y,speed=2.0}},
		
		{'RemoveInfoBar'},
		{'Delay',{delay=2}},
		{'BubbleMessage',{message='快跑----------'}},
		{'MoveTo',{x=x-2,y=y-3,speed=4}},
		{'Delay',{delay=2}},
		{'BubbleMessage',{message='杀杀杀!!!!'}},
		
		{'Animation',{name='f_idle',loop=true}},
		{'BubbleMessage',{message='一边释放技能一边移动'}},
		
		
		
		
		
	}
	
	local uid = World.CreateUnit()
	
	
	World.RunAction(uid, example) 
	
	
	api.Wait() 
	
	World.RunAction(uid, {'BubbleMessage',{message='隐藏所有danwei'}}) 
	api.Scene.HideAllUnit(true)

	
	local caption = {
		name = '齐天大圣孙悟空',
		iconPath = 'dynamic_n/npc_bust/22001.png',
		wait = 100,
		texts = {
			{text='剧情对话展示',wait=0},
			
			{text='<b>粗体哦</b>',sec=0, wait=0.5},	
			{text='这是一个神奇的故事, 从前的从前',clean=true},
		}
	}
	
	local sc = api.ShowCaption(caption)
	api.Sleep(1)
	api.AddCaptionText(sc, {text='设置剧情摄像头',clean=true})
	api.Sleep(5)
	local ux,uy = World.GetUnitPos(uid)
	
	Camera.SetDramaCamera(true)
	Camera.SetPosition(ux,uy)

	api.AddCaptionText(sc, {text='震屏---------',clean=true})
	api.Wait(Camera.ShakePosition(2,0.5))

	api.AddCaptionText(sc, {text='望远镜效果',clean=true})
	Camera.SetTelescope(true)
	api.Sleep(2)

	api.AddCaptionText(sc, {text='观光镜头-----',clean=true})
	api.Wait(Camera.MoveTo(ux,uy+3,4))
	api.Sleep(1)

	api.AddCaptionText(sc, {text='镜头拉高!',clean=true})
	local h = Camera.GetHeight()
	api.Wait(Camera.MoveToHeight(h+5,4))
	api.Sleep(2)

	api.AddCaptionText(sc, {text='镜头跟随单位实现, ApiHelper中有对应接口',clean=true})
	api.Sleep(2)

	api.AddPeriodicTimer(0,function ()
		api.Camera.SetPosition(World.GetUnitPos(uid))
	end)
	api.Wait(World.RunAction(uid, {'MoveTo',{x=x,y=y,speed=3}}))

	api.AddCaptionText(sc, {text='关闭望远镜效果',clean=true})
	Camera.SetTelescope(false)
	api.Sleep(2)

	api.AddCaptionText(sc, {text='淡出0.0 ',clean=true})
	api.Wait(api.FadeOutBackImg(4))

	api.AddCaptionText(sc, {text='播放摄像机动画',sec=1,clean=true})
	api.Wait(Camera.PlayAnimation('CameraMove_01'))
	api.Sleep(1)
	
	api.AddCaptionText(sc, {text='播放场景特效',clean=true})
	user = api.GetUserInfo()
	local effect_name = '/res/effect/10000_avatar/11300_berserker/vfx_11303_skill.assetBundles'
	local eid = api.Scene.PlayEffect(effect_name,{x=user.x,y=user.y})
	api.Sleep(3)
	api.AddCaptionText(sc, {text='如果特效是循环的,则需要手动关闭特效',clean=true})
	api.Sleep(2)
	api.Scene.StopEffect(eid)

	api.AddCaptionText(sc, {text='慢动作----------',clean=true})
	api.Sleep(2)
	api.SetTimeScale(0.3)

	api.AddCaptionText(sc, {text='互相殴打!!!',clean=true})
	
	api.CloseCaption()

	local att_u1 = World.CreateUnit()
	local att_u2 = World.CreateUnit()

	local att_act1 = {
		'Sequence',
		{"LoadTemplate",{id = 1}},
		{"Position",{x = user.x+3,y = user.y+1}},
		{'Sequence',{time=10},
			{'Skill',{id=100010,target=att_u2}},
			{'Delay',{min=0.8,max=2}},
		}
	}
	local att_act2 = {
		'Sequence',
		{"LoadTemplate",{id = 1}},
		{"Position",{x = user.x+3,y = user.y+2}},
		{'Sequence',{time=10},
			{'Skill',{id=100010,target=att_u1}},
			{'Delay',{min=0.8,max=2}},
		}
	}

	World.RunAction(att_u1,att_act1)
	World.RunAction(att_u2,att_act2)
	api.Sleep(5)
	api.SetTimeScale(1)
  api.Wait()	
end
