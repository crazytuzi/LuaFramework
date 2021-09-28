




function split(str,sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

function repeat_ok(api,force)	
	lb_costnum = api.UI.FindComponent('xmds_ui/Strengthen/Strengthen.gui.xml','lb_costnum')
	if not lb_costnum then
		return 
	end
	numtext_pre = api.UI.GetText(lb_costnum)
	api.Wait(Helper.WaitCheckFunction(function ()
		local check_txt = api.UI.GetText(lb_costnum)
		return force or check_txt ~= numtext_pre
	end))

	numText = api.UI.GetText(lb_costnum)
	tnums = split(numText,'/')
	num1,num2 = tonumber(tnums[1]), tonumber(tnums[2])
	if num1 and num2 and num1  >= num2 then
		btn_ok = api.UI.FindComponent('xmds_ui/Strengthen/Strengthen.gui.xml','btn_ok')
		api.Wait(Helper.TouchGuide(btn_ok,{force=force}))
		if not force then
			repeat_ok(api,false)
		else
			api.SetBlockTouch(false)
		end
	else
		api.SetBlockTouch(false)
	end
end

function Quest_CanFinish(api,id)
	repeat_ok(api)
end


function Quest_InProgress(api, id)
	local function Logic1()
		api.Sleep(0.3)
		api.Wait(api.UI.WaitMenuEnter('xmds_ui/character/ui_idol.gui.xml'))
		btn_ok = api.UI.FindComponent('xmds_ui/Strengthen/Strengthen.gui.xml','btn_ok')
		if btn_ok then 
			return 
		end
		cvs_weapon = api.UI.FindComponent('xmds_ui/character/ui_idol.gui.xml','cvs_weapon')
		itshow = api.UI.FindChild(cvs_weapon)
		if not itshow or not api.UI.IsItemShowFilled(itshow) then
			return 
		end

		Helper.TouchGuide(api.UI.GetTranform(itshow),{textX=30,text=api.GetText('guide26'),force=true})
		api.PlaySoundByKey('guide26')
		api.Wait()
		api.Wait(api.UI.WaitMenuEnter('xmds_ui/bag/item_information02.gui.xml'))
		btn_2 = api.UI.FindComponent('xmds_ui/bag/item_information02.gui.xml','btn_2')
		
		local eid = Helper.TouchGuide(btn_2,{force=true})
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
		repeat_ok(api,true)
		repeat_ok(api,false)
	end

end

function start(api, id, s)
	if s == api.Quest.Status.IN_PROGRESS then
		Quest_InProgress(api,id)
	elseif s == api.Quest.Status.CAN_FINISH then
		Quest_CanFinish(api,id)
	end
end
