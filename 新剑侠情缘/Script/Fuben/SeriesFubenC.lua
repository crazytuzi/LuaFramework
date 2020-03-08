function SeriesFuben:InitMapList()
    self.tbMapList = {}
    for _, tbInfo in pairs(self.tbSetting) do
        self.tbMapList[tbInfo.MapTemplateId] = 1
    end

    UiNotify:RegistNotify(UiNotify.emNOTIFY_UPDATE_TASK, self.ResetTaskDesc, self)
end

function SeriesFuben:OnMapLoaded(nMapTemplate)
    if self.tbMapList[nMapTemplate] then
        Ui:CloseWindow("HomeScreenTask")
        Ui:OpenWindow("HomeScreenFuben", "SeriesFuben")
        Ui:OpenWindow("AsyncPartner")
        self.nStartTime = self.nStartTime or GetTime()
        
        Timer:Register(Env.GAME_FPS/2, function ()
            self:SetTargetInfo()
        end)
    elseif self.bOpenWnd then
        Ui:OpenWindow("TrialPanel")
        self.bOpenWnd = false
    end
end

function SeriesFuben:SetTargetInfo()
    if not self.nStartTime then
        return
    end

    local nCurIdx = self:GetCurIdx(me)
    local tbFubenInfo = self.tbSetting[nCurIdx]
    if not tbFubenInfo then
        return
    end

    local nConsumeTime = GetTime() - self.nStartTime
    local nEndTime = self.nStartTime + 3
    local szTarget = "等待开启"
    if nConsumeTime < 3 then
        local nX, nY = unpack(Lib:SplitStr(tbFubenInfo.GuidePos, "|"))
        if not nX or not nY then
            return
        end

        UiNotify.OnNotify(UiNotify.emNOTIFY_GUIDE_RANGE_CHANGE, 300)
        Fuben:SetTargetPos(tonumber(nX), tonumber(nY))
    else
        nEndTime = self.nStartTime + tbFubenInfo.Time
        szTarget = "击败" .. KNpc.GetNameByTemplateId(tbFubenInfo.BossTemplateId)
    end

    Fuben:SetEndTime(nEndTime)
    Fuben:SetTargetInfo(szTarget)
end

function SeriesFuben:OnTrainBegin(nTime)
    Fuben:SetEndTime(GetTime() + nTime)

    local nCurIdx = self:GetCurIdx(me)
    local tbFubenInfo = self.tbSetting[nCurIdx]
    Fuben:SetTargetInfo("击败" .. KNpc.GetNameByTemplateId(tbFubenInfo.BossTemplateId))
end

function SeriesFuben:OnFubenClose()
    self.nStartTime = nil
    self.bOpenWnd = true
    Ui:CloseWindow("HomeScreenFuben")
end

function SeriesFuben:ResetTaskDesc(nTaskId)
    if nTaskId and nTaskId ~= self.nTaskId then
        return
    end

    local _1, tbTask, nIdx = Task:GetPlayerTaskInfo(me, self.nTaskId)
    if not nIdx then
        return
    end

    local tbTmpTask = Task:GetTask(self.nTaskId)
    local tbFubenInfo = SeriesFuben:GetFubenInfo(self:GetCurIdx(me)) or {}
    tbTmpTask.szTaskDesc = string.format("完成[FFFE0D]%d级[-]江湖试炼", tbFubenInfo.ReqLevel or 100)
    Task:OnTaskUpdate(self.nTaskId)
    UiNotify.OnNotify(UiNotify.emNOTIFY_TASK_HAS_CHANGE, self.nTaskId)
end

function SeriesFuben:OnLogin()
    self:ResetTaskDesc()

    if not self.tbMapList[me.nMapTemplateId] then
        return
    end

    if not self.nStartTime then
        return
    end

    Ui:CloseWindow("HomeScreenTask")
    Ui:OpenWindow("HomeScreenFuben", "SeriesFuben")
    Ui:OpenWindow("AsyncPartner")
    
    Timer:Register(Env.GAME_FPS/2, function ()
            self:SetTargetInfo()
        end)
end

SeriesFuben:InitMapList()