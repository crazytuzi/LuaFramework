local tbItem = Item:GetClass("IndifferScrollHorse"); 

function tbItem:CanHorseUpgrade(pPlayer, nCostItemId)
	local pCostItem = pPlayer.GetItemInBag(nCostItemId)
	if not pCostItem then
		return
	end
	local tbHorseUpgrade = InDifferBattle.tbDefine.tbHorseUpgrade
	local pCurHorse = pPlayer.GetEquipByPos(Item.EQUIPPOS_HORSE)
	if not pCurHorse then
		return nil, "当前无坐骑";
	end
	local nOldItem, nNewItem = unpack(tbHorseUpgrade)
	if pCurHorse.dwTemplateId ~= nOldItem then
		return nil, "当前无可进阶的坐骑";
	end
	return pCostItem, pCurHorse, nNewItem
end

function tbItem:GetUseSetting(nTemplateId, nItemId)
    local tbUseSetting = { szFirstName = "出售", fnFirst = "SellItem", szSecondName = "使用",};
    tbUseSetting.fnSecond = function ()
	    Ui:CloseWindow("ItemTips")
	    local bRet, szMsg = self:CanHorseUpgrade(me, nItemId)
    	if bRet then
    		RemoteServer.InDifferBattleRequestInst("HorseUpgrade", nItemId)
    	else
    		me.CenterMsg(szMsg)
    	end
    end;

    return tbUseSetting;        
end

function tbItem:CheckUsable(it)
	local bRet, szMsg = self:CanHorseUpgrade(me, it.dwId)
	if not bRet then
		return 0, szMsg
	end
	return 1;
end

function tbItem:IsUsableItem(pPlayer, dwTemplateId)
	if pPlayer.GetItemCountInBags(dwTemplateId) > 0 then
		return false
	end
	local nOldItem, nNewItem = unpack(InDifferBattle.tbDefine.tbHorseUpgrade)
	local tbItems = pPlayer.FindItemInPlayer(nNewItem)
	if #tbItems > 0 then
		return false
	end
	return true
end