





function Quest_Done(api, id)
	
	api.Wait(api.UI.WaitMenuEnter('xmds_ui/common/common_item.gui.xml'))
	btn_all = api.UI.FindComponent('xmds_ui/common/common_item.gui.xml','btn_all')
	api.Wait(Helper.TouchGuide(btn_all))

	api.Wait(api.UI.WaitMenuEnter('xmds_ui/common/common_item.gui.xml'))
	btn_all = api.UI.FindComponent('xmds_ui/common/common_item.gui.xml','btn_all')
	Helper.TouchGuide(btn_all,{textX=-10,textY=-24,text = api.GetText('guide30')})
	api.PlaySoundByKey('guide30')
	api.Wait()
end


function start(api, id)
	s = api.Quest.GetState(id)
	if not s or s == api.Quest.Status.DONE then
		Quest_Done(api,id)
	end
end
