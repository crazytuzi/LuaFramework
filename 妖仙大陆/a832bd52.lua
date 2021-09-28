


function start(api,params)
	api.Wait(api.UI.WaitMenuEnter('xmds_ui/common/common_item.gui.xml'),{timeout=10})
	btn_all = api.UI.FindComponent('xmds_ui/common/common_item.gui.xml','btn_all')
	if not btn_all then return end
	Helper.TouchGuide(btn_all,params)
	api.Wait()

	if params.titleUse then
		api.Wait(api.UI.WaitMenuEnter('xmds_ui/title/title_get.gui.xml'),{timeout=5})
		btn_use = api.UI.FindComponent('xmds_ui/title/title_get.gui.xml','btn_use')
		api.PlaySoundByKey('guide62')
		Helper.TouchGuide(btn_use,{text=api.GetText('guide62'),textX=140,textY=136,sx=80})
		api.Wait()
	end

end
