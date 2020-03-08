
local tbItem = Item:GetClass("AddBuffItem");
tbItem.nExtBuffId    = 1;
tbItem.nExtBuffLevel = 2;
tbItem.nExtBuffTime  = 3;
tbItem.nExtBuffType = 4;
tbItem.nExtBuffReset = 5;

tbItem.nSaveGroup = 64
tbItem.tbUseNumLimit =
{
--- 道具的ID  最大使用次数  存储的ID改变通知程序
    [2878] = {nUseMaxNum = 100, nSaveID = 1},
    [8250] = {nUseMaxNum = 100, nSaveID = 2},
    [998007] = {nUseMaxNum = 100, nSaveID = 1},
};

tbItem.tbSkillMutual = 
{
    {2307, 2319};
    {2326, 2313};
};

function tbItem:InitSkillMutual()
    self.tbSkillMutualBuff = {};
    for _, tbInfo in pairs(self.tbSkillMutual) do
        for _, nSkillId in pairs(tbInfo) do
            if not self.tbSkillMutualBuff[nSkillId] then
                self.tbSkillMutualBuff[nSkillId] = tbInfo;
            else
                Log("Error AddBuffItem InitSkillRegular", nSkillId);
            end    
        end   
    end    
end
tbItem:InitSkillMutual();


function tbItem:GetSkillMutual(nSkillId)
    local tbInfo = self.tbSkillMutualBuff[nSkillId];
    if not tbInfo then
        return {nSkillId};
    end

    return tbInfo;    
end

function tbItem:CheckCanUse(it)
    local tbInfo = self.tbUseNumLimit[it.dwTemplateId]
    if not tbInfo then
        return true
    end

    local nHadUse = me.GetUserValue(self.nSaveGroup, tbInfo.nSaveID)
    return nHadUse < tbInfo.nUseMaxNum, string.format("不能够使用超过%d次", tbInfo.nUseMaxNum)
end

-- nExtBuffType 0.不存盘持续帧数 1.存盘，指定持续帧数 2.存盘,指定持续时间为真实的时间  3.不存盘持续帧数离开地图不删除

function tbItem:IsBuffType(nBuffType)
    for _, nType in pairs(FightSkill.STATE_TIME_TYPE) do
        if nType == nBuffType then
            return true;
        end    
    end

    return false;
end

function tbItem:CheckSkillMutual(pPlayer, nSkillID, nSkillLevel, nBuffReset)
    local pNpc = pPlayer.GetNpc();
    local tbMutualSkill = self:GetSkillMutual(nSkillID);
    local tbSkillState = nil;
    for _, nMutualID in pairs(tbMutualSkill) do
        tbSkillState = pNpc.GetSkillState(nMutualID);
        if tbSkillState and tbSkillState.nSkillLevel >= nSkillLevel and nBuffReset <= 0 then
            return false, "已有相同等级或更高级的效果";
        end

        if tbSkillState then
            return true, "", tbSkillState;
        end    
    end

    return true, "", tbSkillState;
end

function tbItem:OnUse(it)
    local bRet, szMsg = self:CheckCanUse(it)
    if not bRet then
        me.CenterMsg(szMsg)
        return
    end

    local nSkillID    = KItem.GetItemExtParam(it.dwTemplateId, self.nExtBuffId);
    local nSkillLevel = KItem.GetItemExtParam(it.dwTemplateId, self.nExtBuffLevel);
    local nTime       = KItem.GetItemExtParam(it.dwTemplateId, self.nExtBuffTime);
    local nBuffType   = KItem.GetItemExtParam(it.dwTemplateId, self.nExtBuffType);
    local nBuffReset  = KItem.GetItemExtParam(it.dwTemplateId, self.nExtBuffReset) or 0;

    if nSkillID <= 0 or nSkillLevel <= 0 or nTime <= 0 then
        Log("Error AddBuffItem Not SkillID", it.dwTemplateId, nSkillID, nSkillLevel, nTime, nBuffType);
        return;
    end

    local bRet = self:IsBuffType(nBuffType);
    if not bRet then
         Log("Error AddBuffItem Not Type", it.dwTemplateId, nSkillID, nSkillLevel, nTime, nBuffType);
        return;
    end

    local tbSkillInfo = KFightSkill.GetSkillInfo(nSkillID, nSkillLevel);
    if not tbSkillInfo then
        Log("Error AddBuffItem Not Skill", it.dwTemplateId, nSkillID, nSkillLevel, nTime, nBuffType);
        return;
    end

    local pNpc = me.GetNpc();
    local bRet, szMsg, tbSkillState = self:CheckSkillMutual(me, nSkillID, nSkillLevel, nBuffReset);
    if not bRet then
        me.CenterMsg(szMsg)
        return;
    end    

    if nBuffType == FightSkill.STATE_TIME_TYPE.state_time_truetime then
        nTime = nTime * Env.GAME_FPS + GetTime();
    end    

    if tbSkillState and nBuffReset > 0 then
        me.RemoveSkillState(tbSkillState.nSkillId);
    end

    local tbInfo = self.tbUseNumLimit[it.dwTemplateId]
    if tbInfo then
        local nHadUse = me.GetUserValue(self.nSaveGroup, tbInfo.nSaveID)
        me.SetUserValue(self.nSaveGroup, tbInfo.nSaveID, nHadUse + 1)
    end

    pNpc.AddSkillState(nSkillID, nSkillLevel, nBuffType, nTime, 1, 1);
    me.CenterMsg(string.format("使用%s成功", it.szName));
    Log("AddBuffItem", me.dwID, nSkillID, nSkillLevel, nBuffType, nTime);
    return 1;
end

function tbItem:GetIntrol(dwTemplateId)
    local tbInfo = KItem.GetItemBaseProp(dwTemplateId)
    if not tbInfo then
        return
    end

    local tbLimitInfo = self.tbUseNumLimit[dwTemplateId]
    if not tbLimitInfo or tbLimitInfo.nSaveID <= 0 then
        return
    end

    local nCount = me.GetUserValue(self.nSaveGroup, tbLimitInfo.nSaveID)
    return string.format("%s\n使用数量：%d/%d", tbInfo.szIntro, nCount, tbLimitInfo.nUseMaxNum)
end