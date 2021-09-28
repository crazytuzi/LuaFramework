





function Quest_InProgress(api, id)
	api.Wait(Helper.HeroIconTouchGuide({force=true}))
	btn_magic = api.UI.FindHudComponent('newplatform.gui.xml','btn_magic')
	api.Wait(Helper.TouchGuide(api.UI.GetTranform(btn_magic),{textX=20,force=true}))


	api.UI.WaitMenuEnter('xmds_ui/magicring/magicring_main.gui.xml')
	api.Wait()
	cvs_shuxing1 = api.UI.FindComponent('xmds_ui/magicring/magicring_main.gui.xml','cvs_shuxing1')
	btn_ok = api.UI.FindChild(cvs_shuxing1,'btn_ok')
	Helper.TouchGuide(btn_ok,{textX=10,textY=-14,text=api.GetText('guide32')})
	api.PlaySoundByKey('guide32')
	api.Wait()
	api.Sleep(1.7)
	api.PlaySoundByKey('guide33')
	btn_yes = api.UI.FindComponent('xmds_ui/magicring/magicring_main.gui.xml','btn_yes')
	if btn_yes then
		Helper.TouchGuide(btn_yes,{textX=10,textY=-16,text=api.GetText('guide33')})
		api.Wait()
	else
		Helper.TouchGuide(nil,{noDestory=true,text=api.GetText('guide33')})
		api.Sleep(4)
	end
	
end

function start(api, id)
	s = api.Quest.GetState(id)
	if s == api.Quest.Status.IN_PROGRESS then
		Quest_InProgress(api,id)
	end
end
