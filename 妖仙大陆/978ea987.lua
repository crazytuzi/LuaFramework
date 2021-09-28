
function start(api, id, s)
	if s == api.Quest.Status.IN_PROGRESS then
		api.Wait(Helper.WaitScriptEndByType(1))
		api.Wait(api.UI.WaitMenuEnter('xmds_ui/smelting/smelting.gui.xml'))
		cvs_choose1 = api.UI.FindComponent('xmds_ui/smelting/smelting.gui.xml','cvs_choose1')
		tbt_gou = api.UI.FindChild(cvs_choose1,'tbt_gou')
		api.Wait(Helper.TouchGuide(tbt_gou))

		btn_yes = api.UI.FindComponent('xmds_ui/smelting/smelting.gui.xml','btn_yes')
		api.PlaySoundByKey('guide27')
		api.Wait(Helper.TouchGuide(btn_yes,{textX=20,textY=-20,text=api.GetText('guide27')}))

		
		
		
	
	
	
	
	
	
	end
end
