
Player.tbHonorLevel = Player.tbHonorLevel or {}
local tbHonorLevel = Player.tbHonorLevel;
tbHonorLevel.nSaveGroupID = 27;
tbHonorLevel.nSaveFightPower = 1;
tbHonorLevel.nSaveFightPowerStar = 2;
tbHonorLevel.nMinOpenLevel = 17; --最少等级开启
tbHonorLevel.szAchievementKey = "HonorLevel_1";
tbHonorLevel.XD_EX_HONOR_ATTRIB_GROUP = 3; --额外的属性

function tbHonorLevel:GetHonorLevelInfo(nHonorLevel)
    return Player.tbHonorLevelSetting[nHonorLevel];
end

function tbHonorLevel:GetHonorName(nHonorLevel)
    local tbInfo = self:GetHonorLevelInfo(nHonorLevel)
    return tbInfo and tbInfo.Name or ""
end

function tbHonorLevel:GetMainLevel(nHonorLevel)
    local tbInfo = self:GetHonorLevelInfo(nHonorLevel)
    return tbInfo and tbInfo.MainLevel or 0
end

function tbHonorLevel:GetSaveHonorLevel(pPlayer)
    if not self.tbLevelTranslate then
        self.tbLevelTranslate = {}
        for nLevel, tbInfo in pairs(Player.tbHonorLevelSetting) do
            self.tbLevelTranslate[tbInfo.MainLevel * 10000 + tbInfo.StarLevel] = nLevel
        end
    end

    local nMainLevel = pPlayer.GetUserValue(self.nSaveGroupID, self.nSaveFightPower)
    local nStarLevel = pPlayer.GetUserValue(self.nSaveGroupID, self.nSaveFightPowerStar)
    return self.tbLevelTranslate[nMainLevel * 10000 + nStarLevel] or 0
end

function tbHonorLevel:SaveHonorLevel(pPlayer, tbHonorInfo)
    pPlayer.SetUserValue(self.nSaveGroupID, self.nSaveFightPower, tbHonorInfo.MainLevel)
    pPlayer.SetUserValue(self.nSaveGroupID, self.nSaveFightPowerStar, tbHonorInfo.StarLevel)
end

function tbHonorLevel:CheckFinishHonorLevel(pPlayer)
    if not pPlayer then
        return false, "玩家不存在";
    end

    if self.nMinOpenLevel > pPlayer.nLevel then
        return false, string.format("等级不足%s", self.nMinOpenLevel);
    end

    local nAddHonorLevel = pPlayer.nHonorLevel + 1;
    local tbHonorInfo = self:GetHonorLevelInfo(nAddHonorLevel);
    if not tbHonorInfo then
        return false, "尚未开启头衔";
    end

    if GetTimeFrameState(tbHonorInfo.TimeFrame) ~= 1 then
        return false, "尚未开启头衔！";
    end

    local pNpc = pPlayer.GetNpc();
    local nFightPower  = pNpc.GetFightPower();
    if tbHonorInfo.NeedPower > nFightPower then
        return false, string.format("当前战力不足[FFFE0D]%d[-]，还需努力提升哦！", tbHonorInfo.NeedPower);
    end

    local nTotalStart = PersonalFuben:GetAllSectionStarAllLevel(pPlayer);
    if tbHonorInfo.NeedFubenStar > nTotalStart then
        return false, string.format("关卡总星级不足%d", tbHonorInfo.NeedFubenStar);
    end

    -- if GetTimeFrameState(tbHonorInfo.RepairTimeFrame) == 1 then
    --    return true, "", tbHonorInfo;
    -- end

    local nFightPowerLV = self:GetSaveHonorLevel(pPlayer)
    if nFightPowerLV ~= pPlayer.nHonorLevel then
        return false, "需要补交之前的英雄令";
    end

    local bRet, szMsg = self:CheckNeedItem(pPlayer, tbHonorInfo);
    if not bRet then
        return false, szMsg;
    end

    return true, "", tbHonorInfo;
end

function tbHonorLevel:CheckNeedItem(pPlayer, tbHonorInfo)
    if tbHonorInfo.ItemCount <= 0 then
        return true;
    end

    local nTotalCount = pPlayer.GetItemCountInAllPos(tbHonorInfo.ItemID);
    if tbHonorInfo.ItemCount > nTotalCount then
        local tbItemInfo = KItem.GetItemBaseProp(tbHonorInfo.ItemID);
        return false, string.format("本次晋升需[FFFE0D] %s [-]个[FFFE0D] %s [-]，快去收集吧！", tbHonorInfo.ItemCount, tbItemInfo.szName);
    end

    return true;
end

function tbHonorLevel:FinishHonorLevel(pPlayer)
    local bRet, szMsg, tbHonorInfo = self:CheckFinishHonorLevel(pPlayer);
    if not bRet then
        pPlayer.CenterMsg(szMsg);
        return;
    end

    local nFightPowerLV = self:GetSaveHonorLevel(pPlayer)
    local bRet = self:CheckNeedItem(pPlayer, tbHonorInfo);
    local nOldHonorLevel = pPlayer.nHonorLevel
    if bRet and nOldHonorLevel == nFightPowerLV then
        if tbHonorInfo.ItemCount > 0 then
            local nConsumeCount = pPlayer.ConsumeItemInAllPos(tbHonorInfo.ItemID, tbHonorInfo.ItemCount, Env.LogWay_FinishHonorLevel);
            assert(tbHonorInfo.ItemCount == nConsumeCount);
        end

        self:SaveHonorLevel(pPlayer, tbHonorInfo)
        Log("HonorLevel FinishHonorLevel Add FightPower", pPlayer.dwID, pPlayer.szName, nOldHonorLevel);
    end

    pPlayer.SetHonorLevel(tbHonorInfo.Level);
    pPlayer.TLog("HonorLevelFlow", pPlayer.nLevel, nOldHonorLevel, tbHonorInfo.Level)
    Achievement:AddCount(pPlayer, tbHonorLevel.szAchievementKey, 1);

    if pPlayer.dwKinId ~= 0 then
        local szShowMsg = string.format("恭喜「%s」晋升为「%s」头衔", pPlayer.szName, tbHonorInfo.Name);
        ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szShowMsg, pPlayer.dwKinId);
    end

    pPlayer.CallClientScript("Ui:OpenWindow", "SharePanelNew", "HonorLevelUp");
    FightPower:ChangeFightPower("Honor", pPlayer);

    pPlayer.CallClientScript("Player.tbHonorLevel:UpdateInfo");

    if tbHonorInfo.IsNotice == 1 then
        local tbHonorLevelRank = ScriptData:GetValue("HonorLevelRank");
        local nCurRank = tbHonorLevelRank[tbHonorInfo.MainLevel] or 0;
        nCurRank = nCurRank + 1;
        tbHonorLevelRank[tbHonorInfo.MainLevel] = nCurRank;
        local szWorldMsg = nil;
        if nCurRank == 1 then
            szWorldMsg = string.format("恭喜「%s」成为全服第一个晋升「%s」头衔的少侠", pPlayer.szName, tbHonorInfo.Name);
        elseif nCurRank >= 2 and nCurRank <= 10 then
            szWorldMsg = string.format("恭喜「%s」成为全服前十个晋升「%s」头衔的少侠", pPlayer.szName, tbHonorInfo.Name);
        end

        if not Lib:IsEmptyStr(szWorldMsg) then
            KPlayer.SendWorldNotify(1, 999, szWorldMsg, 1, 1);
        end

        ScriptData:AddModifyFlag("HonorLevelRank");
    end

    if pPlayer.dwKinId>0 then
        local kinData = Kin:GetKinById(pPlayer.dwKinId)
        kinData:SetCacheFlag("UpdateMemberInfoList", true)
    end

    Kin:RedBagOnEvent(pPlayer, Kin.tbRedBagEvents.title, tbHonorInfo.Level)
    TeacherStudent:OnAddHonorTitle(pPlayer, tbHonorInfo.Level)

    pPlayer.OnEvent("OnHonorLevelUp", pPlayer.nHonorLevel, nOldHonorLevel);
    pPlayer.CallClientScript("GameSetting.Comment:OnEvent", GameSetting.Comment.Type_HonorLevelChange, tbHonorInfo.Level);
    Activity:OnPlayerEvent(pPlayer, "Act_HonorLevel", tbHonorInfo.Level);
    Achievement:SetCount(pPlayer, "Label", tbHonorInfo.Level);
    Log("HonorLevel FinishHonorLevel", pPlayer.dwID, pPlayer.szName, pPlayer.nHonorLevel, tbHonorInfo.Level);
end


function tbHonorLevel:CheckRepairItem(pPlayer)
    if self.nMinOpenLevel > pPlayer.nLevel then
        return false, string.format("等级不足%s", self.nMinOpenLevel);
    end

    local nFightPowerLV = self:GetSaveHonorLevel(pPlayer)
    nFightPowerLV = nFightPowerLV + 1;

    if nFightPowerLV > pPlayer.nHonorLevel then
        return false, "当前头衔未达到补交等级";
    end

    local tbHonorInfo = self:GetHonorLevelInfo(nFightPowerLV);
    if not tbHonorInfo then
        return false, "尚未开启头衔";
    end

    if GetTimeFrameState(tbHonorInfo.RepairTimeFrame) ~= 1 then
       return false, "尚未开启补交";
    end

    local bRet, szMsg = self:CheckNeedItem(pPlayer, tbHonorInfo);
    if not bRet then
        return false, szMsg;
    end

    return true, "", tbHonorInfo;
end

-- function tbHonorLevel:RepairItem(pPlayer)
--     local bRet, szMsg, tbHonorInfo = self:CheckRepairItem(pPlayer);
--     if not bRet then
--         pPlayer.CenterMsg(szMsg);
--         return;
--     end

--     if tbHonorInfo.ItemCount > 0 then
--         local nConsumeCount = pPlayer.ConsumeItemInAllPos(tbHonorInfo.ItemID, tbHonorInfo.ItemCount, "HonorRepairItem");
--         assert(tbHonorInfo.ItemCount == nConsumeCount);
--     end

--     pPlayer.SetUserValue(self.nSaveGroupID,  self.nSaveFightPower, tbHonorInfo.Level);
--     FightPower:ChangeFightPower("Honor", pPlayer);
--     Log("HonorLevel RepairItem", pPlayer.dwID, pPlayer.szName, pPlayer.nHonorLevel, tbHonorInfo.Level);
-- end

function tbHonorLevel:CheckTimeFrameRedPoint(pPlayer)
    local nHonorLevel    = pPlayer.nHonorLevel;
    local nAddHonorLevel = nHonorLevel + 1;
    local tbHonorInfo = self:GetHonorLevelInfo(nHonorLevel);
    if not tbHonorInfo then
        return false;
    end

    local tbAddHonorInfo = self:GetHonorLevelInfo(nAddHonorLevel);
    if not tbAddHonorInfo then
        return false;
    end

    if GetTimeFrameState(tbAddHonorInfo.TimeFrame) ~= 1 then
        return false;
    end 

    if tbAddHonorInfo.TimeFrame == tbHonorInfo.TimeFrame then
        return false;
    end    

    local tbUserSet = Client:GetUserInfo("HonorLevelData");
    if tbUserSet.szRedPoint and tbAddHonorInfo.TimeFrame == tbUserSet.szRedPoint then
        return false;
    end    
    
    return true, tbAddHonorInfo;    
end

function tbHonorLevel:UpdateRedPoint()
    local bRet = self:CheckFinishHonorLevel(me);
    local bRet1 = self:CheckTimeFrameRedPoint(me);
    if bRet or bRet1 then
        Ui:SetRedPointNotify("TitleUpgrade")
    else
        Ui:ClearRedPointNotify("TitleUpgrade") 
    end
end

function tbHonorLevel:UpdateInfo()
    if Ui:WindowVisible("HonorLevelPanel") == 1 then
        Ui("HonorLevelPanel"):UpdateInfo();
    end
end

function tbHonorLevel:GetFightLevel(nHonorLevel)
    local tbInfo = self:GetHonorLevelInfo(nHonorLevel)
    if not tbInfo then
        return 0
    end
    return tbInfo.FightLevel
end