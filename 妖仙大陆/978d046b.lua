





function Quest_CanFinish(api, id)
	btn_close = api.UI.FindComponent('xmds_ui/pet/pet_frame.gui.xml','btn_close')
	if btn_close then
		api.Wait(Helper.TouchGuide(btn_close))
	end
	
end

function Quest_InProgress(api, id)
	api.Wait(Helper.WaitScriptEnd('quest_1058'))
	api.Wait(Helper.WaitScriptEnd('guide_useall'))

	api.Wait(Helper.HeroIconTouchGuide({force=true}))
	btn_pet = api.UI.FindHudComponent('newplatform.gui.xml','btn_pet')
	api.Wait(Helper.TouchGuide(btn_pet,{textX=20,force=true}))
	api.SetBlockTouch(false)
	api.Wait(api.UI.WaitMenuEnter('xmds_ui/pet/pet_3D.gui.xml'))
	btn_addexp = api.UI.FindComponent('xmds_ui/pet/pet_3D.gui.xml','tbt_peiyang')
	api.PlaySoundByKey('guide60')
	api.Wait(Helper.TouchGuide(btn_addexp,{text=api.GetText('guide60'),textX=-290,textY=-126,sx=60}))

	api.Wait(api.UI.WaitMenuEnter('xmds_ui/pet/pet_culture.gui.xml'))
	btn_ten = api.UI.FindComponent('xmds_ui/pet/pet_culture.gui.xml','btn_ten')
	api.Wait(Helper.TouchGuide(btn_ten))

end

function start(api, id)
	s = api.Quest.GetState(id)
	if s == api.Quest.Status.CAN_FINISH then
		Quest_CanFinish(api,id)
	elseif s == api.Quest.Status.IN_PROGRESS then
		Quest_InProgress(api,id)
	end
end
