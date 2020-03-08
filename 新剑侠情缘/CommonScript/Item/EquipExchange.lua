

Item.tbEquipExchange = Item.tbEquipExchange or {};
local tbEquipExchange = Item.tbEquipExchange;

local tbSetting = LoadTabFile("Setting/Item/Equip2WaiYi.tab", "dddd", nil, {"EquipItem", "WaiYiItem", "Cost", "TimeOut"});
tbEquipExchange.tbItemSetting = {}
for _, tbInfo in ipairs(tbSetting) do
	if tbInfo.EquipItem and tbInfo.EquipItem ~= 0 and tbInfo.WaiYiItem and tbInfo.WaiYiItem ~= 0 then
		tbEquipExchange.tbItemSetting[tbInfo.EquipItem] = tbInfo;
	end
end

function tbEquipExchange:CanExchange(dwTemplateId, pPlayer)
	if not self.tbItemSetting[dwTemplateId] or self.tbItemSetting[dwTemplateId].WaiYiItem == 0 then
		return false, "该装备不可收藏！";
	end
	local tbItemList = pPlayer.FindItemInPlayer(self.tbItemSetting[dwTemplateId].WaiYiItem)
	if #tbItemList > 0 then
		return false, "你已经拥有该装备对应的外装";
	end
	return true;
end

function tbEquipExchange:GetCost(dwTemplateId)
	if not self.tbItemSetting[dwTemplateId] then
		return fasle, 0;
	end
	return true, self.tbItemSetting[dwTemplateId].Cost;
end

function tbEquipExchange:GetTargetItem(dwTemplateId)
	if not self.tbItemSetting[dwTemplateId] then
		return;
	end
	return self.tbItemSetting[dwTemplateId].WaiYiItem, self.tbItemSetting[dwTemplateId].TimeOut;
end

function tbEquipExchange:DoExchange(pPlayer, nItemId)
	local pItem, nPos = pPlayer.GetItemInBag(nItemId);
	if not pItem then
		pPlayer.CenterMsg("装备不存在！")
		return;
	end
	local bRet, szMsg = self:CanExchange(pItem.dwTemplateId, pPlayer)
	if not bRet then
		pPlayer.CenterMsg(szMsg)
		pItem.Delete(Env.LogWay_EquipExchage);
		return
	end
	if nPos ~= Item.EITEMPOS_BAG then
		pPlayer.CenterMsg("不在背包的装备不可收藏！")
		return;
	end
	if self.tbItemSetting[pItem.dwTemplateId].Cost > 0 and not pPlayer.CostMoney("Coin", self.tbItemSetting[pItem.dwTemplateId].Cost, Env.LogWay_EquipExchage) then
		pPlayer.CenterMsg("您的银两不足！");
		return;
	end
	local nTimeOut;
	if self.tbItemSetting[pItem.dwTemplateId].TimeOut and self.tbItemSetting[pItem.dwTemplateId].TimeOut > 0 then
		nTimeOut = GetTime() + self.tbItemSetting[pItem.dwTemplateId].TimeOut;
	end
	pItem.Delete(Env.LogWay_EquipExchage);
	local pNewItem = pPlayer.AddItem(self.tbItemSetting[pItem.dwTemplateId].WaiYiItem, 1, nTimeOut, Env.LogWay_EquipExchage);
	Item:UseEquip(pNewItem.dwId, nil, Item.EQUIPPOS_WAIYI);
	
	Item.tbChangeColor:UpdateRank(pPlayer);
end
