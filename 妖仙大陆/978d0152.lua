





Good_name = '100金票'

function Quest_CAN_FINISH(api,id)
	if api.Net.GetStep() then return end
	api.UI.WaitMenuEnter('xmds_ui/jimaihang/jimaihang_main.gui.xml')
	api.Wait()
	sp_see2 = api.UI.FindComponent('xmds_ui/jimaihang/jimaihang_main.gui.xml','sp_see2')
	if not sp_see2 then return end
	api.Net.SendStep('finish')
	con = api.UI.FindChild(sp_see2)
	con = api.UI.FindChild(con)

	lb_goodsname = api.UI.FindChild(con,function (child)
		local text = api.UI.GetText(child)
		return text == Good_name
	end)
	
	if lb_goodsname then
		cvs_single1 = api.UI.GetParent(lb_goodsname)
		btn_buy = api.UI.FindChild(cvs_single1,'btn_buy')
		api.PlaySoundByKey('guide37')

		api.Wait(Helper.TouchGuide(btn_buy,{text=api.GetText('guide37'),textX=-20,textY=-18,checkfn=function ()
			return api.UI.GetText(lb_goodsname) == Good_name
		end}))
		api.Wait(api.UI.WaitMenuEnter('xmds_ui/jimaihang/jimaihang_information.gui.xml'))
		btn_2 = api.UI.FindComponent('xmds_ui/jimaihang/jimaihang_information.gui.xml','btn_2')
		api.Wait(Helper.TouchGuide(btn_2))
	else
		Helper.TouchGuide(nil,{text=api.GetText('guide37')})
		api.Sleep(4)
	end
end

function Quest_InProgress(api, id)
	local function Logic1()
		tb_shouhui = api.UI.FindHudComponent('xmds_ui/hud/mainhud.gui.xml','tb_shouhui')
		if api.UI.IsChecked(tb_shouhui) then
			api.Wait(Helper.TouchGuide(tb_shouhui,{force=true}))
			api.Sleep(0.2)
		end
		btn_daily = api.UI.FindHudComponent('xmds_ui/hud/mainhud.gui.xml','btn_daily')
		api.Wait(Helper.TouchGuide(btn_daily))
		btn_auction = api.UI.FindHudComponent('xmds_ui/hud/dailyplay.gui.xml','btn_auction')
		eid = Helper.TouchGuide(api.UI.GetTranform(btn_auction),{noDestory=true})
		api.UI.WaitMenuEnter('xmds_ui/jimaihang/jimaihang_main.gui.xml')
		api.Wait()
	end

	local function Logic2()
		api.UI.WaitMenuEnter('xmds_ui/jimaihang/jimaihang_main.gui.xml')
		api.Wait()
	end
	api.Net.SendStep()
	e_id = api.AddEvent(Logic1)
	e_id2 = api.AddEvent(Logic2)
	api.WaitSelects({e_id,e_id2})
	api.Sleep(0.5)
	Quest_CAN_FINISH(api,id)
end

function start(api, id, s)
	if s == api.Quest.Status.IN_PROGRESS then
		
		Quest_InProgress(api,id)
	elseif s == api.Quest.Status.CAN_FINISH then
		
		Quest_CAN_FINISH(api,id)
	end
end
