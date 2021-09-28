





function Quest_InProgress(api, id)
	api.Wait(api.UI.WaitMenuEnter('xmds_ui/character/ui_character.gui.xml'))
	btn_adv = api.UI.FindComponent('xmds_ui/character/ui_character.gui.xml','btn_adv')
	api.Wait(Helper.TouchGuide(btn_adv,{text=api.GetText('guide67')}))
	api.Wait(api.UI.WaitMenuEnter('xmds_ui/up/up_main.gui.xml'))
	btn_confirm = api.UI.FindComponent('xmds_ui/up/up_main.gui.xml','btn_confirm')
	api.Wait(Helper.TouchGuide(btn_confirm))
end

function start(api, id, s)
	if s == api.Quest.Status.IN_PROGRESS then
		Quest_InProgress(api,id)
	end
end
