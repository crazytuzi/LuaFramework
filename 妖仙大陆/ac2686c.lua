

function start(api,...)
	local ui = api.UI.OpenUIByXml('xmds_ui/solo/solo_timeover.gui.xml',false)
	local ef_timestart = api.UI.FindComponent(ui,'ef_timestart')
	local ef_timeover = api.UI.FindComponent(ui,'ef_timeover')
	api.UI.SetVisible(ef_timestart,true)
	api.UI.SetVisible(ef_timeover,false)
    api.Wait(api.UI.ShowUIEffect(ef_timestart,50,5))
end
