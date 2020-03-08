

local tbXinDe = Item:GetClass("XinDeBook");
tbXinDe.nSaveGroupID = 113;
tbXinDe.nSaveValueExp = 1;


tbXinDe.nEmptyXinDeBook = 3011; --空的心得书
tbXinDe.nBaseExpValue = 1; -- 基础经验的参数
tbXinDe.nLoseExpRateValue = 100; --修炼的经验的参数

function tbXinDe:OnLoadSetting()
    self.tbAllItemSetting = {};
    self.tbPlayerLevelSetting = {};

    local tbFileData = Lib:LoadTabFile("Setting/Item/XinDeBook.tab", {PlayerLevel = 1, MinPlayerLevel = 1,  MaxBaseExp = 1, GetItemID = 1, GetBaseExp = 1, LoseExpRate = 1, SendItemID = 1});
    for nRow, tbInfo in pairs(tbFileData) do
        self.tbAllItemSetting[tbInfo.GetItemID] = tbInfo;

        if tbInfo.SendItemID > 0 then
            self.tbAllItemSetting[tbInfo.SendItemID] = tbInfo;
        end

        self.tbPlayerLevelSetting[tbInfo.PlayerLevel] = tbInfo;
    end
end

tbXinDe:OnLoadSetting();

function tbXinDe:GetItemInfoById(nTemplateId)
    return self.tbAllItemSetting[nTemplateId];
end

function tbXinDe:GetPlayerLevelInfo(nLevel)
    return self.tbPlayerLevelSetting[nLevel];
end

function tbXinDe:CheckOnPlayerAddExp(pPlayer, nExp, nTrueExp)
    local nLoseExp = nExp - nTrueExp;
    if nExp <= 0 or nLoseExp <= 0 or nTrueExp <= 0 then
        return false;
    end

    local nMaxLevel = GetMaxLevel();
    if pPlayer.nLevel < nMaxLevel then
        return false;
    end

    local nPlayerNextExp = pPlayer.GetNextLevelExp();
    local nPlayerExp = pPlayer.GetExp();
    if nPlayerExp <= nPlayerNextExp then
        return false;
    end

    local tbLevelInfo = self:GetPlayerLevelInfo(pPlayer.nLevel);
    if not tbLevelInfo then
        return false;
    end

    return true, tbLevelInfo, nLoseExp;
end

function tbXinDe:OnPlayerAddExp(pPlayer, nExp, nTrueExp)
    local bRet, tbLevelInfo, nLoseExp = self:CheckOnPlayerAddExp(pPlayer, nExp, nTrueExp);
    if not bRet then
        return;
    end

    local fBaseExpRate = tbLevelInfo.MaxBaseExp / self.nBaseExpValue;
    local fExpRate = tbLevelInfo.LoseExpRate / self.nLoseExpRateValue;
    local nMaxBaseExp = KPlayer.GetPlayerBaseExp(tbLevelInfo.PlayerLevel);
    local nMaxXiuLianExp = math.floor(fBaseExpRate * nMaxBaseExp);
    local nSaveExp = pPlayer.GetUserValue(self.nSaveGroupID, self.nSaveValueExp);
    local nSetItemExp = math.floor(nSaveExp + nLoseExp * fExpRate);
    local nItemCount = math.floor(nSetItemExp / nMaxXiuLianExp);
    local nResidueExp = math.floor(nSetItemExp % nMaxXiuLianExp);
    pPlayer.SetUserValue(self.nSaveGroupID, self.nSaveValueExp, nResidueExp);

    if nItemCount > 0 then
        local tbItemAward = {{"item", tbLevelInfo.GetItemID, nItemCount}};
        pPlayer.SendAward(tbItemAward, nil, true, Env.LogWay_XiuLianXinDeBook);
        Log("XinDe OnPlayerAddExp", pPlayer.dwID, pPlayer.nLevel, nResidueExp, tbLevelInfo.GetItemID, nItemCount);
    end

    if not pPlayer.bCheckEmptyXinDeBook then
        pPlayer.bCheckEmptyXinDeBook = true;
        local nCount = pPlayer.GetItemCountInAllPos(tbXinDe.nEmptyXinDeBook);
        if nCount <= 0 then
            local tbEmptyItemAward = {{"item", tbXinDe.nEmptyXinDeBook, 1}};
            pPlayer.SendAward(tbEmptyItemAward, nil, true, Env.LogWay_XiuLianXinDeBook);
        end
    end
end

function tbXinDe:CheckUseXinDe(pPlayer, pItemOrId)
	pItemOrId = type(pItemOrId) == "number" and pItemOrId or pItemOrId.dwTemplateId
    local tbItemInfo = tbXinDe:GetItemInfoById(pItemOrId);
    if not tbItemInfo then
        return false, "";
    end

    if pPlayer.nLevel < tbItemInfo.MinPlayerLevel then
        return false, string.format("少侠等级不足%s级，不可使用心得书", tbItemInfo.MinPlayerLevel);
    end

    if pPlayer.nLevel > tbItemInfo.PlayerLevel then
        return false, string.format("少侠等级大于%s级，不可使用该本心得书", tbItemInfo.PlayerLevel);
    end

    local nPlayerNextExp = pPlayer.GetNextLevelExp();
    local nPlayerExp = pPlayer.GetExp();
    if nPlayerExp >= nPlayerNextExp then
        return false, string.format("少侠当前经验已满，不可使用心得书");
    end

    local nCount = DegreeCtrl:GetDegree(pPlayer, "XinDeBook");
    if nCount <= 0 then
        return false, "今日可使用次数不足";
    end

    return true, "", tbItemInfo;
end

function tbXinDe:OnUse(it)
    local bRet, szMsg, tbItemInfo = self:CheckUseXinDe(me, it);
    if not bRet then
        me.CenterMsg(szMsg, true);
        return;
    end

    DegreeCtrl:ReduceDegree(me, "XinDeBook", 1);
    local nCosetCount = me.ConsumeItem(it, 1, Env.LogWay_XiuLianXinDeBook);
    if nCosetCount ~= 1 then
        Log("Error UseXinDeBook ConsumeItem Count", me.dwID, it.dwTemplateId);
        return;
    end

    local fBaseExp = tbItemInfo.GetBaseExp / tbXinDe.nBaseExpValue;
    local tbAllAward = {{"BasicExp", fBaseExp}};
    me.SendAward(tbAllAward, true, nil, Env.LogWay_XiuLianXinDeBook);
end

function tbXinDe:GetTip(pItem)
    local tbItemInfo = tbXinDe:GetItemInfoById(pItem.dwTemplateId);
    local fBaseExp = tbItemInfo.GetBaseExp / tbXinDe.nBaseExpValue;
    local nPlayerLevel = me.nLevel;
    if nPlayerLevel > tbItemInfo.PlayerLevel then
        nPlayerLevel = tbItemInfo.PlayerLevel;
    end
    local tbPlayerSet = KPlayer.GetPlayerLevelSet(nPlayerLevel);
    local nPlayerBaseExp = tbPlayerSet.nBaseAwardExp;
    local nGetExp = me.TrueChangeExp(nPlayerBaseExp * fBaseExp);
    local nCount = DegreeCtrl:GetDegree(me, "XinDeBook");
    local szMsg = string.format("心得书等级：%s\n今日还可使用：%s次\n使用获得经验：%s", tbItemInfo.PlayerLevel, nCount, nGetExp);
    return szMsg;
end

function tbXinDe:GetUseSetting(nItemTemplateId, nItemId)
    local fnSong = function()
        Ui:OpenWindow("GiftSystem");
        Ui:CloseWindow("ItemTips");
	end

	local bRet = self:CheckUseXinDe(me, nItemTemplateId)
	if bRet then
    	return {szFirstName = "赠送", fnFirst = fnSong, szSecondName = "使用", fnSecond = "UseItem"};
	else
		return {szFirstName = "赠送", fnFirst = fnSong, szSecondName = "出售", fnSecond = "SellItem"};
	end
end



local tbEmpty = Item:GetClass("EmptyXinDeBook");
function tbEmpty:GetCurPlayerLevel()
    local nMaxPlayerLevel = Player:GetPlayerMaxLeve();
    for nI = 0, 1000 do
        local nLevel = nMaxPlayerLevel + nI * 10;
        local tbInfo = tbXinDe:GetPlayerLevelInfo(nLevel);
        if tbInfo then
            return tbInfo;
        end
    end
end

function tbEmpty:GetTip(pItem)
    local tbLevelInfo = self:GetCurPlayerLevel();
    local nSaveExp = me.GetUserValue(tbXinDe.nSaveGroupID, tbXinDe.nSaveValueExp);
    local fBaseExpRate = tbLevelInfo.MaxBaseExp / tbXinDe.nBaseExpValue;
    local tbPlayerSet = KPlayer.GetPlayerLevelSet(tbLevelInfo.PlayerLevel);
    local nPlayerBaseExp = tbPlayerSet.nBaseAwardExp;
    local nMaxXiuLianExp = math.floor(fBaseExpRate * nPlayerBaseExp);
    local szMsg = string.format("等级：%s\n修炼进度：%s%%", tbLevelInfo.PlayerLevel, math.floor(nSaveExp / nMaxXiuLianExp * 100));
    return szMsg;
end

function tbEmpty:GetUseSetting(nItemTemplateId, nItemId)
    return {};
end
