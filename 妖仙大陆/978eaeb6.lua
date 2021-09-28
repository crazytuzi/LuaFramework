
Qcolor = 2
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
		tbt_enchant = api.UI.FindComponent('xmds_ui/bag/bagtab.gui.xml','tbt_enchant')
		api.Wait(Helper.TouchGuide(tbt_enchant))
		api.Wait(api.UI.WaitMenuEnter('xmds_ui/enchant/enchant.gui.xml'))

		tbt_add = api.UI.FindComponent('xmds_ui/enchant/enchant.gui.xml','tbt_add')
		api.Wait(Helper.TouchGuide(tbt_add))
		api.Wait(api.UI.WaitMenuEnter('xmds_ui/enchant/enchantbag.gui.xml'))
		bag_pan = api.UI.FindComponent('xmds_ui/enchant/enchantbag.gui.xml','bag_pan')
		itshow = api.UI.FindItemShow(bag_pan,{static={Qcolor = Qcolor}})
		if itshow then
			api.Wait(Helper.TouchGuide(itshow,{textX=16,text=api.GetText('guide71')}))
			api.Sleep(0.3)
			btn_ok = api.UI.FindComponent('xmds_ui/enchant/enchant.gui.xml','btn_ok')
			api.Wait(Helper.TouchGuide(btn_ok,{textY=-16,text=api.GetText('guide72')}))
		end
	end

end

function start(api, id, s)
	if s == api.Quest.Status.IN_PROGRESS then
		
		Quest_InProgress(api,id)
	end
end
