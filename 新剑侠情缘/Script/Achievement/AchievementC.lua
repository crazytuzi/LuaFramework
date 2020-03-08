function Achievement:IsShowHideList()
    for _, szKind in pairs(Achievement.tbHideList) do
        local nCompletedLv = Achievement:GetCompletedLevel(me, szKind)
        if nCompletedLv > 0 then
            return true
        end
    end
end

function Achievement:GetKindPoint(szKind)
    local nTotal        = 0
    local nCompleted    = 0
    local _1, _2, nFlag = Achievement:CheckCanGainAward(me, szKind, 1)
    for nLv, tbInfo in ipairs(Achievement.tbSetting[szKind].tbLevel) do
        if nFlag and KLib.GetBit(nFlag, nLv) == 1 then
            nCompleted = nCompleted + tbInfo.nPoint
        end
        nTotal = nTotal + tbInfo.nPoint
    end
    return nCompleted, nTotal
end

function Achievement:CheckKindRedpoint(szKind)
    local nCompletedLv = self:GetCompletedLevel(me, szKind)
    local nGainLv      = self:GetGainLevel(me, szKind)
    return nGainLv < nCompletedLv
end

function Achievement:GetTitleAndDesc(szKind, nLevel)
    local tbLevelInfo = self:GetLevelInfo(szKind, nLevel);
    if not tbLevelInfo then
        return "", "";
    end

    return tbLevelInfo.szName, tbLevelInfo.szDesc;
end

function Achievement:GetAchievementNum()
    local nNum = 0;
    for szKind, _ in pairs(self.tbSetting) do
        nNum = nNum + self:GetMaxLevel(szKind);
    end
    return nNum;
end

function Achievement:GetCompleteNum()
    local nCompleteNum = 0;
    for szKind, _ in pairs(self.tbSetting) do
        local nCompletedLevel = self:GetCompletedLevel(me, szKind)
        nCompleteNum = nCompleteNum + nCompletedLevel
    end
    return nCompleteNum;
end

function Achievement:GetCompleteList(nGroupIdx)
    local tbList = {}
    local fnInsert = function (szKind)
        local nLevel = self:GetGainLevel(me, szKind)
        if nLevel > 0 then
            for i = 1, nLevel do
                table.insert(tbList, {szKind = szKind, nLevel = i})
            end
        end
    end
    if Achievement.tbUiSetting[nGroupIdx] then
        for _, tbSubList in pairs(Achievement.tbUiSetting[nGroupIdx]) do
            for _, szKind in pairs(tbSubList.tbList) do
                fnInsert(szKind)
            end
        end
    else
        for _, szKind in pairs(Achievement.tbHideList) do
            fnInsert(szKind)
        end
    end
    return tbList
end

function Achievement:AddCount(szKind, nCount)
    if self.tbLegal[szKind] then
        local bAllFinish = self:IsAllFinish(me, szKind);
        if not bAllFinish then
            RemoteServer.UpdateAchievementKindData(szKind, nCount or 1);
        end
    end
end

function Achievement:GetTmpLikeList()
    if not self.tbTmpLikeList then
        self.nLikeCount = 0
        self.tbTmpLikeList = {}
        local tbList = Achievement:GetLikeList(me)
        for nValue, bLike in pairs(tbList) do
            if bLike then
                self.tbTmpLikeList[nValue] = true
                self.nLikeCount = self.nLikeCount + 1
            end
        end
    end
    return self.tbTmpLikeList
end

function Achievement:OnClickLikeBtn(szKind, nLevel)
    local tbList = self:GetTmpLikeList()
    local nId    = self:GetIdByKind(szKind)
    local nValue = self:GetKindLevelValue(nId, nLevel)
    if not tbList[nValue] then
        if self.nLikeCount >= self.LIKE_MAXCOUNT then
            me.CenterMsg("收藏数量已超上限")
            return
        else
            local _, nFlag = self:CheckCanGainAward(me, szKind, nLevel)
            if nFlag ~= 1 then
                me.CenterMsg("要领取奖励才能收藏")
                return
            end
            self.nLikeCount = self.nLikeCount + 1
        end
    else
        self.nLikeCount = self.nLikeCount - 1
    end

    local szMsg = tbList[nValue] and "取消收藏" or "收藏成功"
    tbList[nValue] = not tbList[nValue]
    me.CenterMsg(szMsg)
    self:BeginSyncTimer()
    return tbList[nValue]
end

function Achievement:BeginSyncTimer()
    if self.nSyncLikeTimer then
        return
    end
    self.nSyncLikeTimer = Timer:Register(Env.GAME_FPS * 5, function ()
        self:DoSyncLikeList()
    end)
end

function Achievement:DoSyncLikeList()
    local tbList   = self:GetLikeList(me)
    local tbTmp    = self:GetTmpLikeList()
    local tbLike   = {}
    local tbUnLike = {}
    for nValue, bLike in pairs(tbTmp) do
        if bLike ~= tbList[nValue] then
            table.insert(bLike and tbLike or tbUnLike, nValue)
        end
    end
    if #tbLike > 0 or #tbUnLike > 0 then
        RemoteServer.RequestRefreshAchievementLike(tbLike, tbUnLike)
    end
    self.nSyncLikeTimer = nil
end



function Achievement:OnGainAwardRsp(szKind, nLevel)
    self:CheckRedPoint()
    self:OnRecentComplete(szKind, nLevel)
    UiNotify.OnNotify(UiNotify.emNOTIFY_ACHIEVEMENT_DATA_SYNC);
end

Achievement.tbGoogleAchivement = {}
if version_kor then
    Achievement.tbGoogleAchivement = {
        Title_Purple          = {[1] = "CgkIgru8o6ABEAIQAA"},
        Partner_4             = {[1] = "CgkIgru8o6ABEAIQAQ"},
        Friend_2              = {[1] = "CgkIgru8o6ABEAIQAg"},
        Family_1              = {[1] = "CgkIgru8o6ABEAIQAw"},
        MoneyTree_1           = {[4] = "CgkIgru8o6ABEAIQBA"},
        TheBox_1              = {[4] = "CgkIgru8o6ABEAIQBQ"},
        RedBag_1              = {[1] = "CgkIgru8o6ABEAIQBg"},
        TeacherStudentElite_1 = {[1] = "CgkIgru8o6ABEAIQBw"},
        FamilyContribute_1    = {[3] = "CgkIgru8o6ABEAIQCA"},
        PayOff_1              = {[3] = "CgkIgru8o6ABEAIQCQ"},
    }
end
function Achievement:OnCompleteLv(szKind, tbCompleteLv)
    if self.tbGoogleAchivement[szKind] then
        for _, nLevel in ipairs(tbCompleteLv) do
            local szAchiId = self.tbGoogleAchivement[szKind][nLevel]
            if szAchiId then
                Sdk:XGUpdateGoogleAchieve(szAchiId)
            end
        end
    end
    Ui:OpenWindow("AchievementDisplay", szKind, tbCompleteLv[#tbCompleteLv])

    self:CheckRedPoint()
    UiNotify.OnNotify(UiNotify.emNOTIFY_ACHIEVEMENT_DATA_SYNC)
end

function Achievement:OnRecentComplete(szKind, nLevel)
    local tbInfo  = Client:GetUserInfo("RecentCompleteAchievement", me.dwID)
    local nKindId = self:GetIdByKind(szKind)
    local nValue  = self:GetKindLevelValue(nKindId, nLevel)
    if #tbInfo > 10 then
        table.remove(tbInfo, 11)
    end
    table.insert(tbInfo, 1, nValue)
    Client:SaveUserInfo()
end

function Achievement:GetRecentCompleteList()
    local tbList = {}
    local tbData = Client:GetUserInfo("RecentCompleteAchievement", me.dwID)
    for _, nValue in ipairs(tbData) do
        local nId, nLevel = self:GetKindAndLevel(nValue)
        local szKind      = self:GetKindById(nId)
        if szKind and self:GetLevelInfo(szKind, nLevel) then
            local tbKindInfo     = {szKind = szKind}
            tbKindInfo.nShowLv   = nLevel
            tbKindInfo.bCanGain  = false
            tbKindInfo.bComplete = true
            table.insert(tbList, tbKindInfo)
        end
    end
    return tbList
end

function Achievement:CheckRedPoint()
    Ui:ClearRedPointNotify("Achievement_Btn")
    for szKind, tbInfo in pairs(self.tbSetting) do
        if self:CheckKindRedpoint(szKind) then
            Ui:SetRedPointNotify("Achievement_Btn")
            break
        end
    end
    self.tbNormalRpNum    = nil
    self.nHideListRpCount = nil 
end

--一些特殊情况导致的成就没加上就在这检查。如果应该完成就申请服务端检查完成一次
function Achievement:CheckSpecilAchievement()
    if self.bClientChecked then
        return
    end
    self.bClientChecked = true
    --全身强化+20,40 之前红包bug 有可能导致没完成,现在判断如果后面的完成了，前面没完成就申请服务端检查
    local tbCheckAchi = {};
    for i,szKind in ipairs(self.tbSpecialCheck) do
        local bFinish = Achievement:CheckCompleteLevel(me, szKind, 1)
        if not bFinish then
            if self:CheckSpecilAchievementFinish(me, szKind) then
                local nKindId = self:GetIdByKind(szKind)
                table.insert(tbCheckAchi, nKindId)
            end
        end
    end
    if next(tbCheckAchi) then
        RemoteServer.RequestCheckAchievementFinish(me, tbCheckAchi)
    end
end