

function start(api,...)
	local ef_timeover = api.UI.FindComponent('xmds_ui/solo/solo_timeover.gui.xml','ef_timeover')
	if ef_timeover then
    	api.UI.SetVisible(ef_timeover,false)
    end
end
