
function Quest_InProgress(api, id)

	local function Logic1()
		
		api.Wait(api.UI.WaitMenuEnter('xmds_ui/character/ui_idol.gui.xml'))
		
		tbt_set = api.UI.FindComponent('xmds_ui/bag/bagtab.gui.xml','tbt_set')
		if tbt_set then 
			return 
		end
		cvs_weapon = api.UI.FindComponent('xmds_ui/character/ui_idol.gui.xml','cvs_weapon')
		itshow = api.UI.FindChild(cvs_weapon)
		if not itshow or not api.UI.IsItemShowFilled(itshow) then
			return 
		end

		api.Wait(Helper.TouchGuide(itshow))
		api.Wait(api.UI.WaitMenuEnter('xmds_ui/bag/item_information02.gui.xml'))
		btn_2 = api.UI.FindComponent('xmds_ui/bag/item_information02.gui.xml','btn_2')
		local eid = Helper.TouchGuide(btn_2,{noDestory=true})
		api.Wait(api.UI.WaitMenuEnter('xmds_ui/Strengthen/Strengthen.gui.xml'))
		api.StopEvent(eid)
		
	end

	local function Logic2()
		api.Wait(api.UI.WaitMenuEnter('xmds_ui/Strengthen/Strengthen.gui.xml'))
		
	end

	e_id = api.AddEvent(Logic1)
	e_id2 = api.AddEvent(Logic2)
	api.WaitSelects({e_id,e_id2})

	cvs_weapon = api.UI.FindComponent('xmds_ui/character/ui_idol.gui.xml','cvs_weapon')
	itshow = api.UI.FindChild(cvs_weapon)
	if itshow and api.UI.IsItemShowFilled(itshow) and api.UI.IsItemShowSelected(itshow) then
		api.Wait(api.UI.WaitMenuEnter('xmds_ui/bag/bagtab.gui.xml'))
		tbt_set = api.UI.FindComponent('xmds_ui/bag/bagtab.gui.xml','tbt_set')
		api.Wait(Helper.TouchGuide(tbt_set))
		api.Wait(api.UI.WaitMenuEnter('xmds_ui/set/set_new.gui.xml'))

		btn_ok = api.UI.FindComponent('xmds_ui/set/set_new.gui.xml','btn_ok')
		api.Wait(Helper.TouchGuide(btn_ok,{textY=-16,text=api.GetText('guide70')}))
	end

end

function start(api, id, s)
	if s == api.Quest.Status.IN_PROGRESS then
		api.Wait(Helper.WaitScriptEndByType(1))
		api.Sleep(0.5)
		api.Wait(Helper.WaitScriptEnd('quest_4209'))
		Quest_InProgress(api,id)
	end
end
