	
function start(api,...)

	
	api.World.Init()

	
	api.UI.HideMFUI(true)

	api.UI.HideUGUITextLabel(true)

	api.UI.HideUGUIHpBar(true)
	
	api.SetNeedSendEndMsg()  

	
	api.UI.HideAllHud(true)

	
	api.UI.CloseAllMenu(true)


	
	

	
	api.SetBlockTouch(true)

	
	local user = api.GetUserInfo()

	
 	local x,y = user.x, user.y

 	
	local Cam = api.Camera

	
	api.ShowSideTool(true)
	
	
    
	
	
	
	
	
	api.FadeOutBackImg(1)
	Cam.SetOffset(0,0,0)
	Cam.SetDramaCamera(true) 
	api.Scene.HideAllUnit(true)
	api.PauseUser()

	Cam.SetFOV(30)
	
	local test_Npc1 = api.World:CreateUnit()
	local test_Npc2 = api.World:CreateUnit()
	local test_Npc3 = api.World:CreateUnit()
	local test_Npc4 = api.World:CreateUnit()
	local test_Npc5 = api.World:CreateUnit()
	local test_Npc6 = api.World:CreateUnit()
	
	
	
	local test_Apc1 = api.World:CreateUnit()
	local test_Apc2 = api.World:CreateUnit()
	local test_Apc3 = api.World:CreateUnit()
	local test_Apc4 = api.World:CreateUnit()
	local test_Apc5 = api.World:CreateUnit()
	local test_Apc6 = api.World:CreateUnit()

	

	local test_Bpc1 = api.World:CreateUnit()
	local test_Bpc2 = api.World:CreateUnit()
	local test_Bpc3 = api.World:CreateUnit()
	local test_Bpc4 = api.World:CreateUnit()
	local test_Bpc5 = api.World:CreateUnit()
	local test_Bpc6 = api.World:CreateUnit()

	
	
	local test_Cpc1 = api.World:CreateUnit()
	local test_Cpc2 = api.World:CreateUnit()
	local test_Cpc3 = api.World:CreateUnit()
	
	
	local test_Dpc1 = api.World:CreateUnit()
	local test_Dpc2 = api.World:CreateUnit()
	local test_Dpc3 = api.World:CreateUnit()	
	local test_Dpc4 = api.World:CreateUnit()
	local test_Dpc5 = api.World:CreateUnit()


	local test_Epc1 = api.World:CreateUnit()
	local test_Epc2 = api.World:CreateUnit()
	local test_Epc3 = api.World:CreateUnit()
	local test_Epc4 = api.World:CreateUnit()
	
	
	
	
	
	local test_Npc1_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098004}},
			{"Position",{x = 217.99,y = 111.9}},
			{"Direction",{direction = -0.75}},
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=6.5}},
			{"Animation",{name = "d_summon_in",loop=false}},
			{"Animation",{name = "d_summon",loop=true}},
			{"Delay",{delay=4}},
			{"Animation",{name = "n_idle",loop=true}},
	}
	
	
	local test_Npc2_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098044}},
			{"Position",{x = 223.47,y = 113.55}},
			{"Direction",{direction = -1.3}},
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=6.5}},
			{"Animation",{name = "d_summon_in",loop=false}},
			{"Animation",{name = "d_summon",loop=true}},
			{"Delay",{delay=4}},
			{"Animation",{name = "n_idle",loop=true}},
	}
	
	
	
	local test_Npc3_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098020}},
			{"Position",{x = 216.12,y = 106.62}},
			{"Direction",{direction = -0.2}},
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=6.5}},
			{"Animation",{name = "d_summon_in",loop=false}},
			{"Animation",{name = "d_summon",loop=true}},
			{"Delay",{delay=4}},
			{"Animation",{name = "n_idle",loop=true}},
	}
	
	
	
		local test_Npc4_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098032}},
			{"Position",{x = 216.49,y = 109.3}},
			{"Direction",{direction = -0.425}},
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=6.5}},
			{"Animation",{name = "d_summon_in",loop=false}},
			{"Animation",{name = "d_summon",loop=true}},
			{"Delay",{delay=4}},
			{"Animation",{name = "n_idle",loop=true}},
	}
	
	
	
		local test_Npc5_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 10098010}},
			{"Position",{x = 220.72,y = 113.35}},
			{"Direction",{direction = -0.975}},
			{"Animation",{name = "n_idle",loop=true}},
			{"Delay",{delay=6.5}},
			{"Animation",{name = "d_summon_in",loop=false}},
			{"Animation",{name = "d_summon",loop=true}},
			{"Delay",{delay=4}},
			{"Animation",{name = "n_idle",loop=true}},
	}
	
	
		local test_Npc6_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 100980001}},
			{"Position",{x = 224.71,y = 105.24}},
			{"Direction",{direction = 2.3}},
	}
	
	
	
		local test_Apc1_event =
	{
		'Sequence',
			{"Delay",{delay=6.8}},
			{"LoadTemplate",{id = 1009800002}},
			{"Position",{x = 217.99,y = 111.9}},
			{"Direction",{direction = -0.75}},
	}
	


	
		local test_Apc2_event =
	{
		'Sequence',
			{"Delay",{delay=6.8}},
			{"LoadTemplate",{id = 1009800003}},
			{"Position",{x = 223.47,y = 113.55}},
			{"Direction",{direction = -1.3}},
	}		

	
	
	
		local test_Apc3_event =
	{
		'Sequence',
			{"Delay",{delay=6.8}},
			{"LoadTemplate",{id = 1009800005}},
			{"Position",{x = 216.12,y = 106.62}},
			{"Direction",{direction = -0.2}},
	}

	
	
		local test_Apc4_event =
	{
		'Sequence',
			{"Delay",{delay=6.8}},
			{"LoadTemplate",{id = 1009800004}},
			{"Position",{x = 216.49,y = 109.3}},
			{"Direction",{direction = -0.425}},
	}

	
	
	
		local test_Apc5_event =
	{
		'Sequence',
			{"Delay",{delay=6.8}},
			{"LoadTemplate",{id = 1009800001}},
			{"Position",{x = 220.72,y = 113.35}},
			{"Direction",{direction = -0.975}},
	}

	
	
	
		local test_Apc6_event =
	{
		'Sequence',
			{"LoadTemplate",{id = 1009800006}},
			{"Position",{x = 224.71,y = 105.24}},
			{"Direction",{direction = 2.3}},
	}

	
		local test_Bpc1_event =
	{
		'Sequence',
			{"Delay",{delay=6.8}},
			{"LoadTemplate",{id = 1009800008}},
			{"Position",{x = 217.99,y = 111.9}},
			{"Direction",{direction = -0.75}},
	}
	


	
		local test_Bpc2_event =
	{
		'Sequence',
			{"Delay",{delay=6.8}},
			{"LoadTemplate",{id = 1009800009}},
			{"Position",{x = 223.47,y = 113.55}},
			{"Direction",{direction = -1.3}},
	}		

	
	
	
		local test_Bpc3_event =
	{
		'Sequence',
			{"Delay",{delay=6.8}},
			{"LoadTemplate",{id = 1009800011}},
			{"Position",{x = 216.12,y = 106.62}},
			{"Direction",{direction = -0.2}},
	}

	
	
	
		local test_Bpc4_event =
	{
		'Sequence',
			{"Delay",{delay=6.8}},
			{"LoadTemplate",{id = 1009800010}},
			{"Position",{x = 216.49,y = 109.3}},
			{"Direction",{direction = -0.425}},
	}

	
	
	
		local test_Bpc5_event =
	{
		'Sequence',
			{"Delay",{delay=6.8}},
			{"LoadTemplate",{id = 1009800007}},
			{"Position",{x = 220.72,y = 113.35}},
			{"Direction",{direction = -0.975}},
	}
	
	
	
		local test_Cpc1_event =
	{
		'Sequence',
			{"Delay",{delay=13}},
			{"LoadTemplate",{id = 1009800012}},
			{"Position",{x = 224,y = 106}},
			{"Direction",{direction = -0.975}},
	}


	
		local test_Cpc2_event =
	{
		'Sequence',
			{"Delay",{delay=15}},
			{"LoadTemplate",{id = 1009800013}},
			{"Position",{x = 223.2,y = 106.8}},
			{"Direction",{direction = 2.3}},
	}

	
		local test_Dpc1_event =
	{
		'Sequence',
			{"Delay",{delay=8.7}},
			{"LoadTemplate",{id = 1009800018}},
			{"Position",{x = 217.99,y = 111.9}},
			{"Direction",{direction = -0.75}},
	}
	


	
		local test_Dpc2_event =
	{
		'Sequence',
			{"Delay",{delay=8.3}},
			{"LoadTemplate",{id = 1009800019}},
			{"Position",{x = 223.47,y = 113.55}},
			{"Direction",{direction = -1.3}},
	}		

	
	
	
		local test_Dpc3_event =
	{
		'Sequence',
			{"Delay",{delay=8.6}},
			{"LoadTemplate",{id = 1009800021}},
			{"Position",{x = 216.12,y = 106.62}},
			{"Direction",{direction = -0.2}},
	}

	
	
	
		local test_Dpc4_event =
	{
		'Sequence',
			{"Delay",{delay=8.9}},
			{"LoadTemplate",{id = 1009800020}},
			{"Position",{x = 216.49,y = 109.3}},
			{"Direction",{direction = -0.425}},
	}

	
	
	
		local test_Dpc5_event =
	{
		'Sequence',
			{"Delay",{delay=8.3}},
			{"LoadTemplate",{id = 1009800017}},
			{"Position",{x = 220.72,y = 113.35}},
			{"Direction",{direction = -0.975}},
	}




	
		local test_Epc1_event =
	{
		'Sequence',
			{"Delay",{delay=8.3}},
			{"LoadTemplate",{id = 1009800023}},
			{"Position",{x = 225.4,y = 106}},
			{"Direction",{direction = -0.75}},
	}
	

	
		local test_Epc3_event =
	{
		'Sequence',
			{"Delay",{delay=12.5}},
			{"LoadTemplate",{id = 1009800025}},
			{"Position",{x = 224,y = 106}},
			{"Direction",{direction = -0.75}},
	}
	
	



	
	
	
	api.World.RunAction(test_Npc1,test_Npc1_event)
	api.World.RunAction(test_Npc2,test_Npc2_event)
	api.World.RunAction(test_Npc3,test_Npc3_event)
	api.World.RunAction(test_Npc4,test_Npc4_event)
	api.World.RunAction(test_Npc5,test_Npc5_event)
	api.World.RunAction(test_Npc6,test_Npc6_event)
	
	api.World.RunAction(test_Apc1,test_Apc1_event)
	api.World.RunAction(test_Apc2,test_Apc2_event)
	api.World.RunAction(test_Apc3,test_Apc3_event)
	api.World.RunAction(test_Apc4,test_Apc4_event)
	api.World.RunAction(test_Apc5,test_Apc5_event)
	api.World.RunAction(test_Apc6,test_Apc6_event)
	
	api.World.RunAction(test_Bpc1,test_Bpc1_event)
	api.World.RunAction(test_Bpc2,test_Bpc2_event)
	api.World.RunAction(test_Bpc3,test_Bpc3_event)
	api.World.RunAction(test_Bpc4,test_Bpc4_event)
	api.World.RunAction(test_Bpc5,test_Bpc5_event)

	api.World.RunAction(test_Cpc1,test_Cpc1_event)
	api.World.RunAction(test_Cpc2,test_Cpc2_event)	

	
	api.World.RunAction(test_Dpc1,test_Dpc1_event)
	api.World.RunAction(test_Dpc2,test_Dpc2_event)
	api.World.RunAction(test_Dpc3,test_Dpc3_event)
	api.World.RunAction(test_Dpc4,test_Dpc4_event)
	api.World.RunAction(test_Dpc5,test_Dpc5_event)
	
	api.World.RunAction(test_Epc1,test_Epc1_event)

	api.World.RunAction(test_Epc3,test_Epc3_event)	
	
	
	
	
	
	local height = 40
	
	
	Helper.ComplexCamera(224.71,105.24, height-5,220.1,109.8, height-7.5, -0.8,-0.8, height -3,height -3, 10,15, 0,0, 5,3) 
	
	api.FadeOutBackImg(1)
	

	
	Helper.ComplexCamera(222.9,111.48, height-7.5,218.91,106.99, height-7.5, 2.353,2.353, height -7,height -7, 4,4, 0,0, 3.5,3) 
		local Npc1_said_donghuangtaiyi = 
	{
		name = '众盟主',
		wait = 2,
		texts = {
			{text='五岳借法！',sec=1, clean=true ,wait=1},
			}
	}
	local sc = api.ShowCaption(Npc1_said_donghuangtaiyi)
	api.playTalkVoice("/res/sound/dynamic/guide/yy011_1.assetbundles")		
	Helper.ComplexCamera(220.1,109.8, height-6.5,220.1,109.8, height-5, -0.8,-0.8, height -3,height -2, 12,14, 0,0, 1,3) 
	
	Helper.ComplexCamera(220.1,109.8, height-5,220.1,109.8, height-5, -0.8,-0.8, height -2,height -2, 14,14, 0,0, 0.5,3) 
	
	Helper.ComplexCamera(220.1,109.8, height-5,220.1,109.8, height-5, -0.8,-0.8, height -2,height -2.8, 14,8, 0,0, 3,3) 

	
	
	api.World.Remove(test_Dpc1)
	api.World.Remove(test_Dpc2)
	api.World.Remove(test_Dpc3)
	api.World.Remove(test_Dpc4)
	api.World.Remove(test_Dpc5)
	
	
	
	
	Helper.ComplexCamera(220.1,109.8, height-5,220.1,109.8, height-5, -0.8,-0.8, height -2.8,height , 8,15, 0,0, 0.5,3) 
	
	Helper.ComplexCamera(220.1,109.8, height-5,220.1,109.8, height-5, -0.8,-0.8, height ,height , 15,15, 0,0, 1.5,3) 
	
	api.World.Remove(test_Epc1)
	
	Helper.ComplexCamera(220.1,109.8, height+3,220.1,109.8, height-6.18, -0.8,-0.8, height ,height -6.1, 2,0.3, 0,0, 7,3) 
	
	Helper.ComplexCamera(220.1,109.8, height-6.18,220.1,109.8, height-6.18, -0.8,-0.83, height -6.1,height -6.1, 0.3,0.3, 0,0, 3,3)
	
	
	
	
	
	
	
	
	
	

	
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	api.Scene.HideAllUnit(false)	
	
	Cam.SetOffset(0,0,0)
	api.FadeOutBackImg(1)
	
		
	api.SendEndMsg()
	
end
