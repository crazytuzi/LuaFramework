local tbItem = Item:GetClass("KinDinnerPartyToken")

function tbItem:OnUse(it)
	local bOk, szErr = KinDinnerParty:CanUsePartyToken(me)
	if not bOk then
		if szErr and szErr ~= "" then
			me.CenterMsg(szErr, true)
		end
		return 0
	end

	if not KinDinnerParty:IsPlayerJoinCountValid(me) then
		me.CenterMsg(string.format("您本周已经参与过%d次家族聚餐，无法使用", KinDinnerParty.Def.nMaxPlayerJoinCount), true)
		return 0
	end

	if KinDinnerParty:IsRunning(me.dwID) then
		me.CenterMsg("已有聚餐正在进行中", true)
		return 0
	end

	me.CallClientScript("Ui:CloseWindow", "ItemBox")
	me.CallClientScript("Ui:CloseWindow", "ItemTips")

	if not House:IsInOwnHouse(me) or not House:IsIndoor(me) then
		House:GotoKinDinnerParty(me, me.dwID)
		return 0
	end

	local nMyId = me.dwID
	me.MsgBox("是否在当前位置召唤餐桌？", {
        {"确定", function()
        	local pPlayer = KPlayer.GetPlayerObjById(nMyId)
        	if not pPlayer then
        		return
        	end
            pPlayer.CallClientScript("Ui:CloseWindow", "QuickUseItem")
            local bOk, szErr = KinDinnerParty:TryCallTable(pPlayer, it)
            if not bOk then
            	if szErr and szErr ~= "" then
            		pPlayer.CenterMsg(szErr, true)
            	end
            end
        end}, {"取消"}
    })

	return 0
end
