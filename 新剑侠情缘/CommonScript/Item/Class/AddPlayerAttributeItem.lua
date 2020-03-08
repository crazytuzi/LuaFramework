local tbItem = Item:GetClass("AddPlayerAttributeItem")
tbItem.nSaveGroup    = 63
tbItem.nSaveMaxCount = 60

tbItem.tbItemInfo =
{
    --- 道具的ID  最大使用次数  添加的属性({属性ID，添加数量})  存储的ID
    [2877] = {nMaxCount = 50, tbAddPoint = {{1, 2}, {2, 2}, {3, 2}, {4, 2}}, nSaveID = 1},  --彩云追月
    [3238] = {nMaxCount = 50, tbAddPoint = {{1, 2}, {2, 2}, {3, 2}, {4, 2}}, nSaveID = 2},  --江翻海沸诀要
    [3714] = {nMaxCount = 50, tbAddPoint = {{1, 2}, {2, 2}, {3, 2}, {4, 2}}, nSaveID = 3},  --洗髓经（上卷）
    [3715] = {nMaxCount = 50, tbAddPoint = {{1, 2}, {2, 2}, {3, 2}, {4, 2}}, nSaveID = 4},  --洗髓经（中卷）
    [3716] = {nMaxCount = 50, tbAddPoint = {{1, 2}, {2, 2}, {3, 2}, {4, 2}}, nSaveID = 5},  --洗髓经（下卷）
    [6444] = {nMaxCount = 50, tbAddPoint = {{1, 2}, {2, 2}, {3, 2}, {4, 2}}, nSaveID = 6},  --千里月明
    [7912] = {nMaxCount = 50, tbAddPoint = {{1, 1}, {2, 1}, {3, 1}, {4, 1}}, nSaveID = 41},  --易骨经·卷一
    [7913] = {nMaxCount = 50, tbAddPoint = {{1, 1}, {2, 1}, {3, 1}, {4, 1}}, nSaveID = 42},  --易骨经·卷二
    [7914] = {nMaxCount = 50, tbAddPoint = {{1, 1}, {2, 1}, {3, 1}, {4, 1}}, nSaveID = 43},  --易骨经·卷三
    [7915] = {nMaxCount = 50, tbAddPoint = {{1, 1}, {2, 1}, {3, 1}, {4, 1}}, nSaveID = 44},  --易骨经·卷四
    [7916] = {nMaxCount = 50, tbAddPoint = {{1, 1}, {2, 1}, {3, 1}, {4, 1}}, nSaveID = 45},  --易骨经·卷五
    [11658] = {nMaxCount = 5, tbAddPoint = {{1, 5}, {2, 5}, {3, 5}, {4, 5}}, nSaveID = 46},
    [998006] = {nMaxCount = 50, tbAddPoint = {{1, 5}, {2, 5}, {3, 5}, {4, 5}}, nSaveID = 7},    --粽子
    [994201] = {nMaxCount = 50, tbAddPoint = {{1, 3}}, nSaveID = 8},    --力量
    [994202] = {nMaxCount = 50, tbAddPoint = {{2, 2}}, nSaveID = 9},    --敏捷
    [994203] = {nMaxCount = 50, tbAddPoint = {{3, 2}}, nSaveID = 10},   --体质
    [994204] = {nMaxCount = 50, tbAddPoint = {{4, 2}}, nSaveID = 11},   --灵巧
    [996028] = {nMaxCount = 50, tbAddPoint = {{1, 2}, {2, 2}, {3, 2}, {4, 2}}, nSaveID = 12},      --彩云追月A
    [996029] = {nMaxCount = 50, tbAddPoint = {{1, 2}, {2, 2}, {3, 2}, {4, 2}}, nSaveID = 13},      --彩云追月B
    [996030] = {nMaxCount = 50, tbAddPoint = {{1, 2}, {2, 2}, {3, 2}, {4, 2}}, nSaveID = 14},      --彩云追月C
    [994273] = {nMaxCount = 50, tbAddPoint = {{1, 3}}, nSaveID = 15},    --洗髓经残卷（力量5点）
    [994274] = {nMaxCount = 50, tbAddPoint = {{2, 2}}, nSaveID = 16},    --洗髓经残卷（敏捷5点）
    [994275] = {nMaxCount = 50, tbAddPoint = {{3, 2}}, nSaveID = 17},    --洗髓经残卷（体质5点）
    [994276] = {nMaxCount = 50, tbAddPoint = {{4, 2}}, nSaveID = 18},    --洗髓经残卷（灵巧5点）
    [994295] = {nMaxCount = 50, tbAddPoint = {{1, 3}, {3, 3}}, nSaveID = 19},    --九阳神功
    [994296] = {nMaxCount = 50, tbAddPoint = {{2, 3}, {4, 3}}, nSaveID = 20},    --九阴真经
    [996031] = {nMaxCount = 50, tbAddPoint = {{4, 2}}, nSaveID = 21},    --十绝剑气指
    [996032] = {nMaxCount = 70, tbAddPoint = {{1, 3}}, nSaveID = 22},    --九天狂龙掌
}

--跟随服务器等级变化的道具
tbItem.tbItemInfoExtLevel =
{
    [3238] = 1,      --江翻海沸诀要
    [6444] = 1,      --千里月明
    [2877] = 1,      --彩云追月
    [994201] = 1,      --力量
    [994202] = 1,      --敏捷
    [994203] = 1,      --体质
    [994204] = 1,      --灵巧
    [994295] = 1,      --九阳神功
    [994296] = 1,      --九阴真经
    [996031] = 1,
    [996032] = 1,
    [7912] = 1,
    [7913] = 1,
    [7914] = 1,
    [7915] = 1,
    [7916] = 1,

}

--跟随VIP等级变化的道具
tbItem.tbItemInfoExtVip =
{
    [3238] = 1,      --江翻海沸诀要
    [6444] = 1,      --千里月明
    [2877] = 1,      --彩云追月
    [3714] = 1,      --洗髓经（上卷）
    [3715] = 1,      --洗髓经（中卷）
    [3716] = 1,      --洗髓经（下卷）
    [994201] = 1,      --力量
    [994202] = 1,      --敏捷
    [994203] = 1,      --体质
    [994204] = 1,      --灵巧
    [994295] = 1,      --九阳神功
    [994296] = 1,      --九阴真经
    [996031] = 1,
    [996032] = 1,
    [7912] = 1,
    [7913] = 1,
    [7914] = 1,
    [7915] = 1,
    [7916] = 1,

}

tbItem.tbFunc4Type = {
    [1] = "AddStrength",
    [2] = "AddDexterity",
    [3] = "AddVitality",
    [4] = "AddEnergy",
}

function tbItem:CheckUse(pPlayer, pItem)
    local nItemTID = pItem.dwTemplateId
    local tbInfo = self.tbItemInfo[nItemTID]
    if not tbInfo then
        return false, "不能使用当前的道具。"
    end

    if tbInfo.nSaveID <= 0 or tbInfo.nSaveID > self.nSaveMaxCount then
        return false, "不能使用当前的道具!"
    end

    local nUsed,nMax = self:GetUsedAndMaxCount(nItemTID)
    if nUsed >= nMax then
        return false, string.format("该道具最多使用%s个。每次转生可增加50次", nMax)
    end

    return true, "", tbInfo
end

function tbItem:OnUse(it)
    local bRet, szMsg, tbInfo = self:CheckUse(me, it)
    if not bRet then
        me.CenterMsg(szMsg)
        return
    end

    local nCount = me.GetUserValue(self.nSaveGroup, tbInfo.nSaveID)
    nCount = nCount + 1
    me.SetUserValue(self.nSaveGroup, tbInfo.nSaveID, nCount)
    for _, tbAttr in ipairs(tbInfo.tbAddPoint) do
        local szFunc = self.tbFunc4Type[tbAttr[1]]
        PlayerAttribute[szFunc](PlayerAttribute, me, tbAttr[2])
    end
    --me.CenterMsg(string.format("你成功使用了%s", it.szName))
    return 1;
end

function tbItem:GetIntrol(dwTemplateId)
    local tbInfo = KItem.GetItemBaseProp(dwTemplateId)
    if not tbInfo then
        return
    end

    local tbLimitInfo = self.tbItemInfo[dwTemplateId]
    if not tbLimitInfo or tbLimitInfo.nSaveID <= 0 then
        return
    end

    local nUsed,nMax = self:GetUsedAndMaxCount(dwTemplateId)
    return string.format("%s\n使用数量：%d/%d", tbInfo.szIntro, nUsed, nMax)
end

function tbItem:GetExtCountByServerLevel()
    local nMaxLevel = 0
	if MODULE_GAMESERVER then
	 	nMaxLevel = GetMaxLevel();
	else
	 	nMaxLevel = Player:GetPlayerMaxLeve();
	end

	local nBeginLevel = 89
    if (not nMaxLevel or nMaxLevel <= nBeginLevel or nMaxLevel > 999) then
	    return 0
	end

	local nCount = math.modf((nMaxLevel - nBeginLevel) / 10) * 10;
	return nCount
end

function tbItem:GetExtCountByVipLevel()
    local myVipLevel = me.GetVipLevel()
	local nBeginLevel = 11

	if (not myVipLevel or myVipLevel <= nBeginLevel) then
	    return 0
	end

	local nCount = (myVipLevel - nBeginLevel) * 10;
	return nCount
end

function tbItem:GetExtCountByReincarnation()
	return 0
end

function tbItem:GetUsedAndMaxCount(dwTemplateId)
	local nUsed = 0;
	local nMax = 0;
    local tbInfo = KItem.GetItemBaseProp(dwTemplateId)
    if not tbInfo then
        return nUsed,nMax
    end

    local tbLimitInfo = self.tbItemInfo[dwTemplateId]
    if tbLimitInfo and tbLimitInfo.nSaveID > 0 then
        nMax = tbLimitInfo.nMaxCount
		nUsed = me.GetUserValue(self.nSaveGroup, tbLimitInfo.nSaveID)
    end

	if (self.tbItemInfoExtVip[dwTemplateId]) then
	    nMax = nMax + self:GetExtCountByVipLevel()
	end

	if (self.tbItemInfoExtLevel[dwTemplateId]) then
	    nMax = nMax + self:GetExtCountByServerLevel()
	end

	nMax = nMax + self:GetExtCountByReincarnation()
	return nUsed,nMax
end














