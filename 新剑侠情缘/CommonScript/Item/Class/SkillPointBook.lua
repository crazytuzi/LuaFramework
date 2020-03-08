local tbItem = Item:GetClass("SkillPointBook");
tbItem.nSavePointGroup = 54;
tbItem.nSaveMaxCount   = 10;




--------策划填写------------
tbItem.tbBookInfo =
{
--- 道具的ID  最大使用次数  添加的技能点  存储的ID改变通知程序
    [1430] = {nMaxCount = 50, nAddPoint = 1, nSaveID = 1};  --武林秘籍（上卷）
	[1431] = {nMaxCount = 50, nAddPoint = 1, nSaveID = 2};  --武林秘籍（中卷）
	[1432] = {nMaxCount = 50, nAddPoint = 1, nSaveID = 3};  --武林秘籍（下卷）
	[1454] = {nMaxCount = 50, nAddPoint = 3, nSaveID = 4};  --武道德经
    [2591] = {nMaxCount = 50, nAddPoint = 1, nSaveID = 5};  --幽灵糖 
    [2876] = {nMaxCount = 50, nAddPoint = 1, nSaveID = 6};  --月满西楼
    [8251] = {nMaxCount = 1, nAddPoint = 1, nSaveID = 7};
    [9570] = {nMaxCount = 1, nAddPoint = 1, nSaveID = 8};
    [998005] = {nMaxCount = 50, nAddPoint = 1, nSaveID = 7};  --粽子
}


---------------End ---------------------

function tbItem:CheckUseSkillPoint(pPlayer, pItem)
    local nItemTID = pItem.dwTemplateId;
    local tbInfo = self.tbBookInfo[nItemTID];
    if not tbInfo then
        return false, "不能使用当前的道具";
    end

    if tbInfo.nSaveID <= 0 or tbInfo.nSaveID > self.nSaveMaxCount then
        return false, "不能使用当前的道具!";
    end

    local nCount = pPlayer.GetUserValue(self.nSavePointGroup, tbInfo.nSaveID);
    if nCount >= tbInfo.nMaxCount then
        return false, string.format("该道具最多使用%s个。", tbInfo.nMaxCount);
    end

    return true, "", tbInfo;    
end

function tbItem:OnUse(it)
    local bRet, szMsg, tbInfo = self:CheckUseSkillPoint(me, it);
    if not bRet then
        me.CenterMsg(szMsg);
        return;
    end    

    local nCount = me.GetUserValue(self.nSavePointGroup, tbInfo.nSaveID);
    nCount = nCount + 1;
    me.SetUserValue(self.nSavePointGroup, tbInfo.nSaveID, nCount);
    --me.AddMoney("SkillPoint", tbInfo.nAddPoint, Env.LogWay_SkillPointBook);
    me.CenterMsg(string.format("你获得了%s点技能点", tbInfo.nAddPoint));
    me.CallClientScript("Player:ServerSyncData", "ChangeSkillPoint");
    return 1;
end

function tbItem:GetIntrol(dwTemplateId)
    local tbInfo = KItem.GetItemBaseProp(dwTemplateId)
    if not tbInfo then
        return
    end

    local tbLimitInfo = self.tbBookInfo[dwTemplateId]
    if not tbLimitInfo or tbLimitInfo.nSaveID <= 0 then
        return
    end

    local nCount = me.GetUserValue(self.nSavePointGroup, tbLimitInfo.nSaveID)
    return string.format("%s\n使用数量：%d/%d", tbInfo.szIntro, nCount, tbLimitInfo.nMaxCount)
end  