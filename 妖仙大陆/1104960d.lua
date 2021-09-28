












function start(api,need_start)
	step = api.Net.GetStep()
	if (not need_start and not step) or step == "guide_socialFriend_end" then
		return
	end
	
	api.Scene.StopSeek()
	
	btn_makefriends = api.UI.FindComponent('xmds_ui/social/friend.gui.xml','btn_makefriends')
	if btn_makefriends then
		api.Wait(Helper.TouchGuide(btn_makefriends,{force=true,text=api.GetText('guide_friend_1')}))
	end

	api.Net.SendStep('guide_socialFriend_end')
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
end
