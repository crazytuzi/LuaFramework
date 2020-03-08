local tbItem = Item:GetClass("IndifferScrollEnhance"); 

function tbItem:CanUseItem(pPlayer, nCostItemId)
	local pCostItem = pPlayer.GetItemInBag(nCostItemId)
	if not pCostItem then
		return
	end
	--有一个可强的就是可用
	local tbDefine = InDifferBattle.tbDefine
	local tbStrengthen = pPlayer.GetStrengthen();
	for i,v in ipairs(tbDefine.tbEnhanceScroll) do
		local nEquipPos = v.tbEquipPos[1]
		local nStrengthLevel = tbStrengthen[nEquipPos + 1] + tbDefine.nStrengthStep
		local nCostItemNum = v.tbEnhanceCost[nStrengthLevel] 
		if nCostItemNum and pCostItem.nCount >= nCostItemNum then
			return 1;
		end
	end
	return 0
end

function tbItem:GetUseSetting(nTemplateId, nItemId)
    local tbUseSetting = { szFirstName = "出售",  fnFirst = "SellItem", szSecondName = "使用"};
    tbUseSetting.fnSecond = function ()
    	Ui:CloseWindow("ItemTips")
    	Ui:OpenWindow("DreamlandStrengthenPanel")
    end;

    return tbUseSetting;        
end

function tbItem:CheckUsable(it)
	local bRet, szMsg = self:CanUseItem(me, it.dwId)
	if not bRet then
		return 0, szMsg
	end
	return 1;
end

function tbItem:IsUsableItem(pPlayer, dwTemplateId)
	local tbDefine = InDifferBattle.tbDefine
	local tbStrengthen = pPlayer.GetStrengthen();
    for i,v in ipairs(tbDefine.tbEnhanceScroll) do
        local nEquipPos = v.tbEquipPos[1]
        if v.tbEnhanceCost[tbStrengthen[nEquipPos + 1] + tbDefine.nStrengthStep] then
            return true
        end
    end
    return false
end