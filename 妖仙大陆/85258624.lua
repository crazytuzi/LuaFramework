




function start(api,need_start)
	step = api.Net.GetStep()
	if not need_start or step == "end" then
		return
	end
	
	api.Scene.StopSeek()

	btn_makefriends = api.UI.FindComponent('xmds_ui/social/friend.gui.xml','btn_makefriends')
	if btn_makefriends then
		api.SetGuideBiStep(1)
		api.PlayGuideSoundByKey('yindao_16')
		api.Wait(Helper.TouchGuide(btn_makefriends,{textY=-15,force=false,text=api.GetText('guide_4001_2')}))
	end
	api.Wait(api.UI.WaitMenuEnter('xmds_ui/social/friend_add.gui.xml'))
	btn_apply1 = api.UI.FindComponent('xmds_ui/social/friend_add.gui.xml','btn_apply1')
	if btn_apply1 then
		api.Net.SendStep('end')
		api.SetGuideBiStep(2)
		api.PlayGuideSoundByKey('yindao_17')
		api.Wait(Helper.TouchGuide(btn_apply1,{textY=-15,force=false,text=api.GetText('guide_4001_3')}))
	end

	local btn_close = api.UI.FindComponent('xmds_ui/social/friend_add.gui.xml','btn_close')
	if btn_close then
		api.SetGuideBiStep(3)
		api.Wait(Helper.TouchGuide(btn_close,{force=false}))
	end

	local btn_close = api.UI.FindComponent('xmds_ui/social/main.gui.xml','btn_close')
	if btn_close then
		api.SetGuideBiStep(4)
		api.Wait(Helper.TouchGuide(btn_close,{force=false}))
	end
end
