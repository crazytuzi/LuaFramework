

function start(api,need_start)
	local btn_choice2 = api.UI.FindComponent('xmds_ui/rework/rework_main.gui.xml','btn_choice2')
	if btn_choice2 then
		api.Wait(Helper.TouchGuide(btn_choice2,{textY=-15,force=true,text=api.GetText('guide_chuancheng_1')}))
	end
end
