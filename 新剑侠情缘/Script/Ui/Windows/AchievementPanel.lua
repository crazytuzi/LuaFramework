local TYPE_TOTAL  = 1
local TYPE_NORMAL = 2
local TYPE_HIDE   = 3
local TYPE_SUB    = 4
local TYPE_LIKE   = 5
function Achievement:OnLogout()
    self.tbCatalog     = nil
    self.tbTmpLikeList = nil
    self.tbNormalRpNum = nil
    self.nLikeCount    = 0
end

function Achievement:GetUiCatalog()
    if not self.tbCatalog then
        self.tbCatalog = {}
        table.insert(self.tbCatalog, {szTitle = "总览", nType = TYPE_TOTAL})
        table.insert(self.tbCatalog, {szTitle = "收藏", nType = TYPE_LIKE})
        for nGroupIdx, tbInfo in ipairs(self.tbUiSetting) do
            local tbTitle = {nType     = TYPE_NORMAL,
                             bShowSub  = false,
                             szTitle   = Achievement.tbFirstTitle[nGroupIdx],
                             nGroupIdx = nGroupIdx}
            table.insert(self.tbCatalog, tbTitle)
        end
    end

    if self.tbCatalog[#self.tbCatalog].nType ~= TYPE_HIDE and self:IsShowHideList() then
        local tbTitle = {szTitle = "神秘", nType = TYPE_HIDE}
        table.insert(self.tbCatalog, tbTitle)
    end
    return self.tbCatalog
end

function Achievement:GetCatalogInfo(nIndex)
    local tbCatalog = self:GetUiCatalog()
    return tbCatalog[nIndex]
end

function Achievement:ShowSubList(nGroupIdx, nBeginIdx)
    local nInsertPos = nBeginIdx
    for nSubIdx, tbInfo in ipairs(Achievement.tbUiSetting[nGroupIdx]) do
        nInsertPos = nInsertPos + 1
        table.insert(self.tbCatalog, nInsertPos, 
            {nType = TYPE_SUB, nGroupIdx = nGroupIdx, nSubIdx = nSubIdx, szTitle = tbInfo.szTitle})
    end
end

function Achievement:CloseSubList(nGroupIdx, nBeginIdx)
    for i = 1, #Achievement.tbUiSetting[nGroupIdx] do
        table.remove(self.tbCatalog, nBeginIdx + 1)
    end
end

function Achievement:IsCatalogHaveRedpoint(nIndex)
    local tbInfo = Achievement:GetCatalogInfo(nIndex)
    if tbInfo.nType == TYPE_SUB or tbInfo.nType == TYPE_NORMAL then
        for nSubIdx, tbSubInfo in pairs(Achievement.tbUiSetting[tbInfo.nGroupIdx]) do
            for _, szKind in pairs(tbSubInfo.tbList) do
                if tbInfo.nType == TYPE_SUB and tbInfo.nSubIdx ~= nSubIdx then
                    break
                end
                if Achievement:CheckKindRedpoint(szKind) then
                    return true
                end
            end
        end
    elseif tbInfo.nType == TYPE_HIDE then
        if not self.nHideListRpCount then
            self.nHideListRpCount = 0
        end
        for _, szKind in pairs(Achievement.tbHideList) do
            if Achievement:CheckKindRedpoint(szKind) then
                self.nHideListRpCount = 1
                break
            end
        end 
        return self.nHideListRpCount > 0
    end
    return false
end


local tbUi = Ui:CreateClass("AchievementPanel")
tbUi.tbOnClick = 
{
    BtnClose = function (self)
        Ui:CloseWindow(self.UI_NAME)
    end
}
function tbUi:RegisterEvent()
    return
    {
        { UiNotify.emNOTIFY_ACHIEVEMENT_DATA_SYNC, self.Update, self },
    }
end

function tbUi:OnOpenEnd()
    self:Update()
    Achievement:CheckSpecilAchievement();
end

function tbUi:Update()
    self.nSelectedIdx = self.nSelectedIdx or 1
    self:UpdateCatalog();
    self:UpdateContent();
end

function tbUi:UpdateCatalog()
    local fnOnClick = function (buttonObj)
        self.nSelectedIdx = buttonObj.nIndex
        local tbInfo = Achievement:GetCatalogInfo(buttonObj.nIndex)
        if tbInfo.nType == TYPE_NORMAL then
            if not tbInfo.bShowSub then
                Achievement:ShowSubList(tbInfo.nGroupIdx, buttonObj.nIndex)
            else
                Achievement:CloseSubList(tbInfo.nGroupIdx, self.nSelectedIdx)
            end
            tbInfo.bShowSub = not tbInfo.bShowSub
            self:UpdateCatalog()
        elseif tbInfo.nType == TYPE_TOTAL or
            tbInfo.nType == TYPE_SUB or
            tbInfo.nType == TYPE_HIDE or
            tbInfo.nType == TYPE_LIKE then
            self:UpdateContent()
        end
    end
    local fnSetItem = function (itemObj, nIndex)
        local tbInfo   = Achievement:GetCatalogInfo(nIndex)
        local bChecked = self.nSelectedIdx == nIndex
        local bShowRP  = Achievement:IsCatalogHaveRedpoint(nIndex)
        itemObj.pPanel:SetActive("BaseClass", tbInfo.nType ~= TYPE_SUB and tbInfo.nType ~= TYPE_LIKE)
        itemObj.pPanel:SetActive("SubClass", tbInfo.nType == TYPE_SUB)
        itemObj.pPanel:SetActive("BtnCollection", tbInfo.nType == TYPE_LIKE)

        local tbNode
        if tbInfo.nType == TYPE_SUB then
            tbNode = itemObj.SubClass
        elseif tbInfo.nType == TYPE_LIKE then
            tbNode = itemObj.BtnCollection
        else
            tbNode = itemObj.BaseClass
        end
        tbNode.nIndex = nIndex
        tbNode.pPanel.OnTouchEvent = fnOnClick;
        if tbInfo.nType == TYPE_SUB then
            tbNode.pPanel:Label_SetText("Label", tbInfo.szTitle)
        else
            tbNode.pPanel:Label_SetText("LabelDark", tbInfo.szTitle)
            tbNode.pPanel:Label_SetText("LabelLight", tbInfo.szTitle)
            tbNode.pPanel:SetActive("BtnDownS", tbInfo.nType == TYPE_NORMAL and not tbInfo.bShowSub)
            tbNode.pPanel:SetActive("Checked", tbInfo.bShowSub)
        end
        tbNode.pPanel:Toggle_SetChecked("Main", bChecked)
        itemObj.pPanel:SetActive("RedPoint", bShowRP)
    end

    local tbCatalog = Achievement:GetUiCatalog()
    local tbHeight = {}
    for _, tbInfo in ipairs(tbCatalog) do
        table.insert(tbHeight, tbInfo.nType == TYPE_SUB and 65 or 76)
    end
    self.ScrollViewCatalog:UpdateItemHeight(tbHeight);
    if self.nSelectedIdx > #tbCatalog then
        self.nSelectedIdx = 1
    end
    self.ScrollViewCatalog:Update(#tbCatalog, fnSetItem);
end

local fnSetItem = function (itemObj, tbKindInfo)
    local nShowLv     = tbKindInfo.nShowLv
    local szKind      = tbKindInfo.szKind
    local tbLevelInfo = Achievement:GetLevelInfo(szKind, nShowLv)
    local nMaxCount   = tbLevelInfo.nCount
    local bOperation  = not tbKindInfo.bNoOperation
    itemObj.pPanel:Label_SetText("Achievement", tbLevelInfo.szName)
    itemObj.pPanel:Label_SetText("Condition", tbLevelInfo.szDesc)
    itemObj.pPanel:Label_SetText("PointTxt", tbLevelInfo.nPoint .. "点")

    local bShowProgress = bOperation and not tbKindInfo.bComplete and not tbKindInfo.bCanGain
    itemObj.pPanel:SetActive("ProgressBar", bShowProgress)
    if bShowProgress then
        local nThisCount = math.min(tbKindInfo.nCount, nMaxCount)
        itemObj.pPanel:Sprite_SetFillPercent("ProgressFore", nThisCount/nMaxCount)
        itemObj.pPanel:Label_SetText("Percentage", string.format("%d/%d", nThisCount, nMaxCount))
    end

    itemObj.pPanel:SetActive("Completed", tbKindInfo.bComplete)
    itemObj.pPanel:SetActive("BtnGain", bOperation and tbKindInfo.bCanGain)
    if bOperation and tbKindInfo.bCanGain then
        itemObj.BtnGain.pPanel.OnTouchEvent = function ()
            RemoteServer.TryGainAchievementAward(szKind)
        end
    end
    itemObj.pPanel:SetActive("Collection", tbKindInfo.bComplete)
    if tbKindInfo.bComplete and bOperation then
        local tbTmp  = Achievement:GetTmpLikeList()
        local nId    = Achievement:GetIdByKind(szKind)
        local nValue = Achievement:GetKindLevelValue(nId, nShowLv)
        itemObj.BtnCollection.pPanel:Toggle_SetChecked("Main", tbTmp[nValue] or false)
        itemObj.BtnCollection.pPanel.OnTouchEvent = function (btnObj)
            local bRet = Achievement:OnClickLikeBtn(szKind, nShowLv)
            btnObj.pPanel:Toggle_SetChecked("Main", bRet or false)
        end
    end

    local tbAward = Achievement:GetAwardInfo(szKind, nShowLv)
    tbAward = tbAward or {}
    local bShowAward = bOperation and (tbKindInfo.bCanGain or not tbKindInfo.bComplete)
    for i = 1, 3 do
        itemObj.pPanel:SetActive("Itemframe" .. i, (bShowAward and tbAward[i]) or false)
        if bShowAward and tbAward[i] then
            itemObj["Itemframe" .. i]:SetGenericItem(tbAward[i])
            itemObj["Itemframe" .. i].fnClick = itemObj["Itemframe" .. i].DefaultClick
        end
    end
end

local function GetKindAndLevel(nValue)
    local nKindId, nLevel = Achievement:GetKindAndLevel(nValue)
    return Achievement:GetKindById(nKindId), nLevel
end
function tbUi:UpdateContent()
    local tbInfo = Achievement:GetCatalogInfo(self.nSelectedIdx)
    self.pPanel:SetActive("AchievementOverview", tbInfo.nType == TYPE_TOTAL)
    self.pPanel:SetActive("ScrollViewContent", tbInfo.nType ~= TYPE_TOTAL)
    local bHideType = tbInfo.nType == TYPE_HIDE
    if tbInfo.nType == TYPE_TOTAL then
        self:UpdateTotalPoint()
    elseif bHideType or tbInfo.nType == TYPE_SUB or tbInfo.nType == TYPE_LIKE then
        local tbKindList = {}
        if tbInfo.nType == TYPE_SUB or bHideType then
            local tbBaseList = bHideType and
                                Achievement.tbHideList or 
                                Achievement.tbUiSetting[tbInfo.nGroupIdx][tbInfo.nSubIdx].tbList
            for _, szKind in pairs(tbBaseList) do
                if (not bHideType) or (Achievement:GetCompletedLevel(me, szKind) > 0) then
                    local nGainLevel = Achievement:GetGainLevel(me, szKind)
                    for nLevel = 1, math.min(Achievement:GetMaxLevel(szKind), nGainLevel + 1) do
                        local tbKindInfo = {szKind = szKind, nShowLv = nLevel}
                        if nLevel <= nGainLevel then
                            tbKindInfo.bComplete = true
                            tbKindInfo.bCanGain  = false
                        else
                            local nCompleteLv    = Achievement:GetCompletedLevel(me, szKind)
                            tbKindInfo.bCanGain  = nCompleteLv >= nLevel
                            tbKindInfo.nCount    = Achievement:GetSubKindCount(me, szKind)
                            tbKindInfo.bComplete = false
                        end
                        table.insert(tbKindList, tbKindInfo)
                    end
                end 
            end
        elseif tbInfo.nType == TYPE_LIKE then
            local tbTmp = Achievement:GetTmpLikeList()
            for nValue, bLike in pairs(tbTmp) do
                if bLike then
                    local szKind, nLevel = GetKindAndLevel(nValue)
                    if Achievement:GetLevelInfo(szKind, nLevel) then
                        local tbKindInfo     = {szKind = szKind}
                        tbKindInfo.nShowLv   = nLevel
                        tbKindInfo.bCanGain  = false
                        tbKindInfo.bComplete = true
                        table.insert(tbKindList, tbKindInfo)
                    end
                end
            end
        end
        if tbInfo.nType ~= TYPE_LIKE then
            for nIndex = 1, #tbKindList do
                local tbKindInfo = tbKindList[nIndex]
                tbKindInfo.nSort = nIndex
                if tbKindInfo.bComplete then
                    tbKindInfo.nSort = tbKindInfo.nSort + 10000
                elseif not tbKindInfo.bCanGain then
                    tbKindInfo.nSort = tbKindInfo.nSort + 1000
                end
            end
            table.sort(tbKindList, function (a, b)
                return a.nSort < b.nSort
            end)
        end
        local fnInitItem = function (itemObj, nIndex)
            fnSetItem(itemObj, tbKindList[nIndex])
        end
        self.ScrollViewContent:Update(#tbKindList, fnInitItem)
    end
end

tbUi.tbPointSetting = {
    "Comprehensive",
    "GrowUp",
    "Ability",
    "Sports",
    "Explore",
    "SocialContact",
    "Power",
    "Noise",
    "Mysterious",
}
function tbUi:UpdateTotalPoint()
    local nTotalPoint    = 0
    local nTotalComplete = 0
    for nGroupIdx, szNode in pairs(self.tbPointSetting) do
        local nTotal     = 0
        local nCompleted = 0
        local tbKindList = {}
        if Achievement.tbUiSetting[nGroupIdx] then
            for _, tbSubInfo in pairs(Achievement.tbUiSetting[nGroupIdx]) do
                Lib:MergeTable(tbKindList, tbSubInfo.tbList)
            end
        else
            tbKindList = Achievement.tbHideList
        end
        for _, szKind in pairs(tbKindList) do
            local nKindCompleted, nKindTotal = Achievement:GetKindPoint(szKind)
            nTotalPoint    = nTotalPoint + nKindTotal
            nTotal         = nTotal + nKindTotal
            nTotalComplete = nTotalComplete + nKindCompleted
            nCompleted     = nCompleted + nKindCompleted
        end
        self.pPanel:Sprite_SetFillPercent(szNode .. "ProgressFore", nTotal == 0 and 0 or nCompleted/nTotal)
        self.pPanel:Label_SetText(szNode .. "Percentage", string.format("%d/%d", nCompleted, nTotal))
    end
    self.pPanel:Sprite_SetFillPercent("StatisticsProgressFore", nTotalPoint == 0 and 0 or nTotalComplete/nTotalPoint)
    self.pPanel:Label_SetText("StatisticsPercentage", string.format("%d/%d", nTotalComplete, nTotalPoint))
    local tbRecentComplete = Achievement:GetRecentCompleteList()
    local fnInitItem = function (itemObj, nIndex)
        fnSetItem(itemObj, tbRecentComplete[nIndex])
    end
    self.ScrollViewContent_Total:Update(#tbRecentComplete, fnInitItem)
end

function tbUi:OnClose()
    Achievement:BeginSyncTimer()
end

----------------------------------------------------------------------------------
local ChatAchievementPopup = Ui:CreateClass("ChatAchievementPopup");
function ChatAchievementPopup:OnOpen(nKindId, nLevel, szPlayerName, tbExtraData)
    self.pPanel:SetActive("PointTxt", true)
    self.pPanel:SetActive("Complete", true)
    self.pPanel:SetActive("Name", true)
    if tbExtraData then
        self.pPanel:SetActive("PointTxt", not tbExtraData.bHidePoint)
        self.pPanel:Label_SetText("Achievement", tbExtraData.szName or "")
        print(string.format(tbExtraData.szCondition or ""))
        self.pPanel:Label_SetText("Condition", tbExtraData.szCondition or "")
        self.pPanel:SetActive("Complete", not tbExtraData.bHidePlayer)
        self.pPanel:SetActive("Name", not tbExtraData.bHidePlayer)
    else
        local szKind = Achievement:GetKindById(nKindId)
        local tbInfo = Achievement:GetLevelInfo(szKind, nLevel)
        local nPoint = tbInfo.nPoint
        self.pPanel:Label_SetText("PointTxt", string.format("成就点：%d", nPoint))
        self.pPanel:Label_SetText("Name", szPlayerName)
        local szName, szDesc = Achievement:GetTitleAndDesc(szKind, nLevel)
        self.pPanel:Label_SetText("Achievement", szName)
        self.pPanel:Label_SetText("Condition", szDesc)
    end
end

function ChatAchievementPopup:OnScreenClick(szClickUi)
    if szClickUi ~= self.UI_NAME then
        Ui:CloseWindow(self.UI_NAME);
    end
end

----------------------------------------------------------------------------------
local ChatAchievement = Ui:CreateClass("ChatAchievement");
function ChatAchievement:SetContent(szKind, nLevel)
    local szTitle = Achievement:GetTitleAndDesc(szKind, nLevel);
    local tbInfo  = Achievement:GetLevelInfo(szKind, nLevel)
    local nPoint  = tbInfo.nPoint
    self.pPanel:Label_SetText("AchievementPointTxt", string.format("成就点：%d", nPoint));
    self.pPanel:Label_SetText("AchievementName", szTitle);
end

----------------------------------------------------------------------------------
local CompleteDisplay = Ui:CreateClass("AchievementDisplay");
function CompleteDisplay:OnOpenEnd(szKind, nLevel)
    local tbLevelInfo = Achievement:GetLevelInfo(szKind, nLevel)
    self.pPanel:Label_SetText("AchievementTxt", tbLevelInfo.szName)
    local bHide = Achievement.tbSetting[szKind].bHide
    self.pPanel:SetActive("Effect1", not bHide)
    self.pPanel:SetActive("Effect2", bHide)
    self:CloseTimer()
    self.nCloseTimer = Timer:Register(Env.GAME_FPS * 5, function ()
        self.nCloseTimer = nil
        Ui:CloseWindow(self.UI_NAME)
    end)
end

function CompleteDisplay:OnClose()
    self:CloseTimer()
end

function CompleteDisplay:CloseTimer()
    if self.nCloseTimer then
        Timer:Close(self.nCloseTimer)
        self.nCloseTimer = nil
    end
end

----------------------------------------------------------------------------------
local ChatAchievementGroup = Ui:CreateClass("ChatAchievementGroup")
function ChatAchievementGroup:OnOpenByParent(tbParent)
    self.tbParent = tbParent
    self:Update()
end

function ChatAchievementGroup:Update()
    self.nCurAchievement = self.nCurAchievement or 1
    local tbItems = Achievement:GetCompleteList(self.nCurAchievement);
    local fnSelectAchievement = function (ButtonObj)
        self.tbParent:AddAchievement(unpack(ButtonObj.tbParams));
    end

    local fnSetItem = function (itemObj, nIndex)
        for i = 1,4 do
            local tbItem = tbItems[(nIndex - 1) * 4 + i];
            itemObj.pPanel:SetActive("Item"..i, tbItem ~= nil);
            if tbItem then
                itemObj["Item"..i]:SetContent(tbItem.szKind, tbItem.nLevel);
                itemObj["Item"..i].tbParams = {tbItem.szKind, tbItem.nLevel};
                itemObj["Item"..i].pPanel.OnTouchEvent = fnSelectAchievement;
            end
        end
    end

    self.AchievementScrollView:Update(math.ceil(#tbItems / 4), fnSetItem);
end

function ChatAchievementGroup:UpdateList(nGroupIdx)
    self.nCurAchievement = nGroupIdx
    self:Update()
end

ChatAchievementGroup.tbOnClick = {}
for i = 1, 9 do
    ChatAchievementGroup.tbOnClick["Btn" .. i] = function (self)
        self:UpdateList(i)
    end
end

----------------------------------------------------------------------------------
local LikePanel = Ui:CreateClass("AchievementLikePanel")
function LikePanel:OnOpenEnd(tbEquip, tbNpcRes, tbPartnerInfo, pAsyncRole)
    local tbData = {}
    for i = 1, Achievement.LIKE_MAXCOUNT do
        local nData = pAsyncRole.GetAsyncValue(Achievement.LIKE_ASYNC_BEGIN + i - 1)
        if nData == 0 then
            break
        end
        local tbKindInfo        = {}
        local nKindId, nLevel   = Achievement:GetKindAndLevel(nData)
        tbKindInfo.szKind       = Achievement:GetKindById(nKindId)
        tbKindInfo.nShowLv      = nLevel
        tbKindInfo.bCanGain     = false
        tbKindInfo.bComplete    = true
        tbKindInfo.bNoOperation = true
        table.insert(tbData, tbKindInfo)
    end
    local fnInitItem = function (itemObj, nIndex)
        fnSetItem(itemObj, tbData[nIndex])
    end
    self.ScrollView:Update(#tbData, fnInitItem)
    self.pPanel:Label_SetText("Title", string.format("%s的收藏成就", pAsyncRole.szName))
end

LikePanel.tbOnClick = {
    BtnClose = function (self)
        Ui:CloseWindow(self.UI_NAME)
    end
}