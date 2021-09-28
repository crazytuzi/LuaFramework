
function Quest_New(api, id)

end

function Quest_CanFinish(api, id)

end

function Quest_InProgress(api, id)
	api.Scene.StopSeek()
	local btn_mall = api.UI.FindHudComponent('xmds_ui/hud/mainhud.gui.xml','btn_mall')
	if btn_mall then
		api.Wait(Helper.TouchGuide(btn_mall,{force=true,text=api.GetText('guide_4036_1')}))
	end
	api.Sleep(0.3)
	local bt_scoreshop = api.UI.FindCurrencyChild('bt_scoreshop')
	if bt_scoreshop then
		api.Wait(Helper.TouchGuide(bt_scoreshop,{force=true,text=api.GetText('guide_4036_2')}))
	end
	api.Sleep(0.3)

	local btn_buy = api.UI.FindComponent('xmds_ui/shop/main.gui.xml','btn_buy')
	if btn_buy then
		api.Wait(Helper.TouchGuide(btn_buy,{force=true,text=api.GetText('guide_4036_4')}))
	end
end

function start(api, id)
	s = api.Quest.GetState(id)
	if s == api.Quest.Status.NEW then
		Quest_New(api,id)
	elseif s == api.Quest.Status.CAN_FINISH then
		Quest_CanFinish(api,id)
	elseif s == api.Quest.Status.IN_PROGRESS then
		Quest_InProgress(api,id)
	end
end
