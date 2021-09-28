

function start(api,...)
	local ui = api.UI.OpenUIByXml('xmds_ui/solo/solo_timeover.gui.xml',false)
	local ef_timestart = api.UI.FindComponent(ui,'ef_timestart')
	local ef_timeover = api.UI.FindComponent(ui,'ef_timeover')
	api.UI.SetVisible(ef_timestart,false)
	api.UI.SetVisible(ef_timeover,true)
    api.Wait(api.UI.ShowUIEffect(ef_timeover,51,12))
end
