Exchange.MAX_ITEM          = 20; --最多道具种类

--[[
tbExchangeSetting = {
	[szType] = {
		Content = "dasda";
		Title = "dasda";
		CheckFun = "dasda";
		Type = "dad"''
		tbAllExchange = 
		{
			{
				tbAllItem =  { 
								[123] = 1;
							 };
				tbAllAward = { 
								{"item", 123,1};
							 };	
			};
		};
	};
}
]]


function Exchange:Init()
	self.tbExchangeSetting = {};
	local szPath            = "Setting/Exchange/";
	local tbMainFile = Lib:LoadTabFile(szPath .. "Main.tab", {});
	for _, tbSetting in pairs(tbMainFile) do
		local szType = tbSetting.Type;
        local tbFile = Lib:LoadTabFile(szPath..szType..".tab", {});
        assert(tbFile, "Not tab file " .. szType)

        tbSetting.tbAllExchange = {};
        for _, tbInfo in ipairs(tbFile) do
            local tbExchange = {};
            local tbAllItem  = {};

            for nI = 1, self.MAX_ITEM do
            	local szVal = tbInfo["Item"..nI]
                if szVal and szVal ~= "" then
                	local _,_, nItemId, nCount = string.find(szVal, "^(%d+)|(%d+)$")
                	tbAllItem[tonumber(nItemId)] = tonumber(nCount)
                else
                	break;
                end
            end
            tbExchange.tbAllItem = tbAllItem;

            if tbInfo["Award"] and tbInfo["Award"] ~= "" then
                tbExchange.tbAllAward = Lib:GetAwardFromString(tbInfo["Award"]);
            else
            	tbExchange.tbAllAward = {};
            end

            table.insert(tbSetting.tbAllExchange, tbExchange);
        end
		self.tbExchangeSetting[szType] = tbSetting;
	end

end

Exchange:Init();

function Exchange:SortItemTId(tbAllItem)
    local tbAllItemCount = {};
    for _, pItem in ipairs(tbAllItem) do
        local ItemTType = pItem.dwTemplateId;
        tbAllItemCount[ItemTType] = tbAllItemCount[ItemTType] or {nCount = 0, tbAllItem = {}};
        local  tbSortItem = tbAllItemCount[ItemTType];

        tbSortItem.nCount = tbSortItem.nCount + pItem.nCount;
        table.insert(tbSortItem.tbAllItem, pItem);
    end

    return tbAllItemCount;    
end

function Exchange:GetCanExchageItems(pPlayer, szType)
	local tbSetting = self.tbExchangeSetting[szType];
	local tbAllItems = pPlayer.GetItemListInBag()
	local tbAllItemCount = self:SortItemTId(tbAllItems)

	local tbCanChangeItems = {};
	for nAwardIndex, tbExchange in ipairs(tbSetting.tbAllExchange) do
		for nItemId, nCount in pairs(tbExchange.tbAllItem) do
			if  tbAllItemCount[nItemId]  then
				tbCanChangeItems[nItemId] = tbAllItemCount[nItemId].tbAllItem;
			end
		end
	end	

	return tbCanChangeItems
end

function Exchange:DefaultCheck(tbItems, tbSetting)
	local tbCheckItems = Lib:CopyTB(tbItems) --TODO 在 tbAllExchange 较多的时候效率较低
	local tbExchangeIndex = {}
	for nAwardIndex, tbExchange in ipairs(tbSetting.tbAllExchange) do
		local bCan = true;
		for i=1,20 do
			if not bCan then
				break;
			end
			for nItemId, nCount in pairs(tbExchange.tbAllItem) do
				if not tbCheckItems[nItemId] or tbCheckItems[nItemId] < nCount then
					bCan = false;
					break;
				end
			end

			if bCan then
				for nItemId, nCount in pairs(tbExchange.tbAllItem) do
					tbCheckItems[nItemId] = tbCheckItems[nItemId] - nCount
				end
				table.insert(tbExchangeIndex, nAwardIndex)
			end			
		end
	end		
	if next(tbExchangeIndex) then
		return tbExchangeIndex
	end
end

function Exchange:Check_Qixi(tbItems, tbSetting)
    if me.CheckNeedArrangeBag() then
        return nil, "背包已满，请清理背包"
    end
    local tbCheckItems = Lib:CopyTB(tbItems)
    local tbExchangeIndex = {}
    for nAwardIndex, tbExchange in ipairs(tbSetting.tbAllExchange) do
        for i = 1, 999 do
            local bCan = true
            for nItemId, nCount in pairs(tbExchange.tbAllItem) do
                if not tbCheckItems[nItemId] or tbCheckItems[nItemId] < nCount then
                    bCan = false
                    break;
                end
            end

            if not bCan then
                break
            end

            for nItemId, nCount in pairs(tbExchange.tbAllItem) do
                tbCheckItems[nItemId] = tbCheckItems[nItemId] - nCount
            end
            table.insert(tbExchangeIndex, nAwardIndex)
        end
    end     
    if next(tbExchangeIndex) then
        return tbExchangeIndex
    else
        local szErrMsg = self:GetQixiExchangeMsg(tbItems)
        return nil, szErrMsg or ""
    end
end

function Exchange:GetQixiExchangeMsg(tbItems)
    --待优化
    if (tbItems[2688] or tbItems[2689]) and not tbItems[2690] and not tbItems[2691] then
        local tbInfo = KItem.GetItemBaseProp(2690) --只提示非礼物道具
        return string.format("%s不足，无法兑换", tbInfo.szName)
    end

    if (tbItems[2690] or tbItems[2691]) and not tbItems[2688] and not tbItems[2689] then
        local tbInfo = KItem.GetItemBaseProp(2688)
        return string.format("%s不足，无法兑换", tbInfo.szName)
    end

    return "兑换失败"
end