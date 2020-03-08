local tbUi = Ui:CreateClass("PlayerLevelUpGuide")

tbUi.tbHideGuideMap = 
{
    [ArenaBattle.nArenaMapId] = "擂场",
}
--结构待优化
function tbUi:IsTodayOpen(tbGuide)
    local szType = tbGuide.szType
    local tbParam = tbGuide.tbParam
    if szType == "Level" then
        if me.nLevel < tbParam[1] then
            if tbParam[2] and tbParam[3] then
                local nAchComLevel = Achievement:GetCompletedLevel(tbParam[2])
                if nAchComLevel < tbParam[3] then
                    return true
                end
            else
                return true
            end
        end
    elseif szType == "OpenServer" then
        local nOpenServerDay = Lib:GetLocalDay(GetServerCreateTime())
        local nToday = Lib:GetLocalDay()
        if nOpenServerDay == nToday then
            return true
        end
    elseif szType == "PreView" then
        local nCalendarId     = tbParam[1]
        local tbTodayOpenTime = Calendar:GetTodayOpenTime(nCalendarId)
        local szCalendarKey   = Calendar:GetActivityStringKey(nCalendarId)
        if not Calendar:IsAdditionalShowActivity(szCalendarKey) then
            return false
        end
        --如果活动今天开放的时间中有跟显示时间重叠的就算这个预告今天生效
        for _, tbInfo in ipairs(tbTodayOpenTime) do
            if tbInfo[1] >= tbParam[2] and tbInfo[1] <= tbParam[3] then
                return true
            end
        end
    elseif szType == "ByServer" or szType == "ActShow" then
        return true
    elseif szType == "PreView_Ticket" then
        return self:GetActTicketType(tbGuide)
    end
end

function tbUi:OnOpen()
    self:UpdateTodayActivity()
    self:Update()
end

function tbUi:UpdateTodayActivity()
    self.tbTodayGuide = {}
    for nIdx, tbGuide in ipairs(self.tbGuide) do
        local bOpenToday = self:IsTodayOpen(tbGuide)
        if bOpenToday then
            table.insert(self.tbTodayGuide, nIdx)
        end
    end
    self.nOpenDay = Lib:GetLocalDay()
end


function tbUi:GetGuideName(tbCurGuide)
    local szName = tbCurGuide.szName
    if tbCurGuide.nCalendarId ~= 0 and szName == "" then
        local szNewName = Calendar:GetActivityName(tbCurGuide.nCalendarId)
        if szNewName then
            szName = szNewName 
        end
    end
    return szName
end

function tbUi:GetActTicketType(tbCurGuide)
    if not tbCurGuide.bShowTicket then
        return
    end
    if not tbCurGuide.nCalendarId then
        return
    end
    local szAct = Calendar:GetActivityStringKey(tbCurGuide.nCalendarId)
    if not Calendar:IsAdditionalShowActivity(szAct) then
        return
    end
    return Calendar:GetMarkTypeOfPlayer(szAct, true)
end

tbUi.tbMarkText = {"月度赛", "季度赛", "年度赛"}
function tbUi:Update()
    if self.tbHideGuideMap[me.nMapTemplateId] then
        self.pPanel:SetActive("Main",false)
        return
    end

    self.tbCurGuide = self:GetGuide()
    self.pPanel:SetActive("Main", self.tbCurGuide and true or false)
    if not self.tbCurGuide then
        return
    end

    self.pPanel:Sprite_SetSprite("Icon", self.tbCurGuide.szIconSprite, self.tbCurGuide.szIconAltas)
    self.pPanel:Label_SetText("Limite", self.tbCurGuide.szDesc)
    self.pPanel:Label_SetText("Name", self:GetGuideName(self.tbCurGuide))
    self.pPanel:SetActive("texiao", self.tbCurGuide.nLight > 0)
    local nTickType = self:GetActTicketType(self.tbCurGuide)
    self.pPanel:SetActive("Mark", nTickType or false)
    if nTickType then
        self.pPanel:Label_SetText("MarkTxt", self.tbMarkText[nTickType])
    end

    if not self.pPanel.OnTouchEvent then
        self.pPanel.OnTouchEvent = self.pPanel.OnTouchEvent or self.OnClick
    end
end

function tbUi:GetGuide()
    if not self.nOpenDay or self.nOpenDay ~= Lib:GetLocalDay() then
        self:UpdateTodayActivity()
    end

    local nCurTime = Lib:GetTodaySec()
    for _, nIdx in ipairs(self.tbTodayGuide or {}) do
        local tbInfo = self.tbGuide[nIdx]
        if me.nLevel >= tbInfo.nLevel then
            local szType = tbInfo.szType
            local tbParam = tbInfo.tbParam
            if szType == "Level" then
                if me.nLevel < tbParam[1] then
                    if tbParam[2] and tbParam[3] then
                        local nAchCompleteLevel = Achievement:GetCompletedLevel(me, tbParam[2])
                        if nAchCompleteLevel < tonumber(tbParam[3]) then
                            return tbInfo
                        end
                    else
                        return tbInfo
                    end
                end
            elseif szType == "OpenServer" or szType == "PreView" or szType == "PreView_Ticket" then
                if nCurTime >= tbParam[2] and nCurTime < tbParam[3] then
                    return tbInfo
                end
            elseif szType == "ByServer" then
                local szStateKey = tbParam[2]
                if Calendar:IsActivityInOpenState(szStateKey) then
                    return tbInfo
                end
            elseif szType == "ActShow" then
                if nCurTime >= tbParam[1] and nCurTime < tbParam[2] and Activity:__IsActInProcessByType(tbParam[3]) and Calendar:IsAdditionalShowActivity(tbParam[3]) then
                    return tbInfo
                end
            end
        end
    end
end

function tbUi:OnClick()
    local bRet = Map:IsForbidTransEnter(me.nMapTemplateId);
    if bRet then
        me.CenterMsg("当前地图无法操作", true);
        return;
    end

    if not self.tbCurGuide or self.tbCurGuide.nCalendarId == 0 then
        return
    end

    Calendar:Dirt2Act(self.tbCurGuide.nCalendarId)
end

function tbUi:AnalysicParam(tbGuide)
    local szType = tbGuide.szType
    local szParam = tbGuide.szParam
    local tbAllParam = {}
    if szType == "Level" then
        local tbParam = Lib:SplitStr(szParam, ";")
        local nEndLevel = tonumber(tbParam[1]) or 9999
        table.insert(tbAllParam, nEndLevel)
        local szAchData = tbParam[2]
        if not Lib:IsEmptyStr(szAchData) then
            local tbAch = Lib:SplitStr(szAchData, ":")
            table.insert(tbAllParam, tbAch[1], tonumber(tbAch[2]))
        end
    elseif szType == "OpenServer" or szType == "PreView" or szType == "PreView_Ticket" then
        local szTimeParam = szParam
        if szType == "PreView" or szType == "PreView_Ticket" then
            table.insert(tbAllParam, tbGuide.nCalendarId)
        else
            local tbParam = Lib:SplitStr(szParam, ";")
            table.insert(tbAllParam, tonumber(tbParam[1]))
            szTimeParam = tbParam[2]
        end

        local tbTime = Lib:SplitStr(szTimeParam, "-")
        local nBegin = Lib:ParseTodayTime(tbTime[1])
        local nEnd   = Lib:ParseTodayTime(tbTime[2])
        table.insert(tbAllParam, nBegin)
        table.insert(tbAllParam, nEnd)
    elseif szType == "ByServer" then
        table.insert(tbAllParam, tbGuide.nCalendarId)
        table.insert(tbAllParam, szParam)
    elseif szType == "ActShow" then
        local tbParam = Lib:SplitStr(szParam, ";")
        local tbTime = Lib:SplitStr(tbParam[2], "-")
        local nBegin = Lib:ParseTodayTime(tbTime[1])
        local nEnd   = Lib:ParseTodayTime(tbTime[2])
        table.insert(tbAllParam, nBegin)
        table.insert(tbAllParam, nEnd)
        table.insert(tbAllParam, tbParam[1]) --ActivityType
    end
    tbGuide.tbParam = tbAllParam
end

function tbUi:LoadFile()
    local tbFile = Lib:LoadTabFile("Setting/Guide/PlayerLevelUpGuide.tab", {nLevel = 1, nPreferential = 1, nCalendarId = 1, nLight = 1, bShowTicket = 1})
    assert(tbFile, "[PlayerLevelUpGuide] LoadFile Error")
    
    self.tbGuide = {}
    for _, tbInfo in ipairs(tbFile) do
        self:AnalysicParam(tbInfo)
        tbInfo.bShowTicket = tbInfo.bShowTicket > 0
        table.insert(self.tbGuide, tbInfo)
    end

    table.sort(self.tbGuide, function (a1, a2) return a1.nPreferential > a2.nPreferential end)
end
tbUi:LoadFile()