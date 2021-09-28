
function start(api,ActivityName,ActivityId)
	api.Wait(api.UI.WaitMenuEnter('xmds_ui/activity/background.gui.xml'))
	local sp_list = api.UI.FindComponent('xmds_ui/activity/background.gui.xml','sp_list')
	if sp_list then
		local cell = api.UI.FindChild(sp_list,{Name=ActivityName})
		if cell then
			local btn_go = api.UI.FindChild(cell,"btn_go")
			if btn_go then
				api.Wait(api.UI.ShowUIEffect(btn_go,56,-1))
			end
		end
		api.UI.SetActivityEffectId(ActivityId)
	end
end
