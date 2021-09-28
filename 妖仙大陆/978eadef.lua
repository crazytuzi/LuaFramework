





function Quest_InProgress(api, id)
	api.Wait(api.UI.WaitMenuEnter('xmds_ui/guild/guild_hall.gui.xml'))
	btn_territory = api.UI.FindComponent('xmds_ui/guild/guild_hall.gui.xml','btn_territory')
	api.Wait(Helper.TouchGuide(btn_territory))

	api.Wait(api.UI.WaitMenuEnter('xmds_ui/guild/guild_fuben.gui.xml'))
	btn_into = api.UI.FindComponent('xmds_ui/guild/guild_fuben.gui.xml','btn_into')
	api.Sleep(0.6)
	local function Logic1()
		api.Wait(Helper.TouchGuide(btn_into,{textX=-8,textY=-20,text=api.GetText('guide52')}))
	end

	local function Logic2()
		Helper.WaitCheckFunction(function ()
			return not api.UI.IsValid(btn_into) or not api.UI.IsEnable(btn_into)
		end)
		api.Wait()
	end

	if api.UI.IsValid(btn_into) and api.UI.IsEnable(btn_into) then
		Helper.TouchGuide(btn_into,{textX=-8,textY=-20,text=api.GetText('guide52')})
		e_id = api.AddEvent(Logic1)
		e_id2 = api.AddEvent(Logic2)
		api.WaitSelects({e_id,e_id2})
	else
		Helper.TouchGuide(nil,{text=api.GetText('guide52')})
		api.Sleep(4)
	end
end

function start(api, id, s)
	if s == api.Quest.Status.IN_PROGRESS then
		api.Wait(Helper.WaitScriptEndByType(1))
		Quest_InProgress(api,id)
	end
end
