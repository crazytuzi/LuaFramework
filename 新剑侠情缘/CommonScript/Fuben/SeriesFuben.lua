SeriesFuben.GROUP         = 55
SeriesFuben.CUR_INDEX_KEY = 1
SeriesFuben.CLOSE_LEVEL   = 40
SeriesFuben.TASK_GROUP    = 38
SeriesFuben.TASK_FLAG     = 1
SeriesFuben.nTaskId       = 3020

function SeriesFuben:LoadSetting()
    local tbKey = {FubenIdx = 1, MapTemplateId = 1, ReqLevel = 1, Time = 1, FightPower = 1, BossTemplateId = 1, BossLevel = 1, EnemyTemplate = 1, EnemyLevel = 1, PosIndex = 1}
    local tbMapSetting = Lib:LoadTabFile("Setting/Fuben/SeriesFuben/MapSetting.tab", tbKey)
    assert(tbMapSetting, "[SeriesFuben LoadSetting Fail]")
    
    local tbNpcPos = {}
    local tbNpcSetting = Lib:LoadTabFile("Setting/Fuben/SeriesFuben/NpcPos.tab", {PosIndex = 1, PosX = 1, PosY = 1})
    assert(tbNpcSetting, "[SeriesFuben LoadNpcSetting Fail]")
    for _, tbInfo in ipairs(tbNpcSetting) do
        local nPosIdx = tbInfo.PosIndex
        tbNpcPos[nPosIdx] = tbNpcPos[nPosIdx] or {}
        table.insert(tbNpcPos[nPosIdx], {tbInfo.PosX, tbInfo.PosY})
    end

    self.tbSetting = {}
    self.tbMyMap = {}
    for _, tbInfo in ipairs(tbMapSetting) do
        local nFubenIdx = tbInfo.FubenIdx
        assert(not self.tbSetting[nFubenIdx], "[SeriesFuben Err], FubenIdx Repeat")
        self.tbSetting[nFubenIdx] = tbInfo
        self.tbSetting[nFubenIdx].tbNpcList = tbNpcPos[tbInfo.PosIndex] or {}
        self.tbMyMap[tbInfo.MapTemplateId] = true
    end
end
SeriesFuben:LoadSetting()

--注意溢出问题
function SeriesFuben:GetCurIdx(pPlayer)
    return pPlayer.GetUserValue(self.GROUP, self.CUR_INDEX_KEY) + 1
end

function SeriesFuben:CheckCanEntry(nFubenIdx)
    if not nFubenIdx then
        return false
    end

    local tbFubenInfo = self.tbSetting[nFubenIdx]
    if not tbFubenInfo then
        return false
    end

    local nCurIdx = self:GetCurIdx(me)
    if nFubenIdx ~= nCurIdx then
        return false, nFubenIdx < nCurIdx and "该关卡已通关" or "该关卡还未开启"
    end

    if me.nLevel < tbFubenInfo.ReqLevel then
        return false, "等级不足，无法挑战"
    end

    if not Fuben.tbSafeMap[me.nMapTemplateId] and Map:GetClassDesc(me.nMapTemplateId) ~= "fight" then
        return false, "所在地图不允许进入江湖试炼！"
    end

    if Map:GetClassDesc(me.nMapTemplateId) == "fight" and me.nFightMode ~= 0 then
        return false, "非安全区不允许进入江湖试炼！"
    end

    if self:IsTaskFinish() then
        return false
    end

    return true
end

function SeriesFuben:GetFubenInfo(nFubenIdx)
    local tbFubenInfo = self.tbSetting[nFubenIdx]
    return tbFubenInfo
end

function SeriesFuben:GetAward(nFubenIdx)
    local tbFubenInfo = self.tbSetting[nFubenIdx]
    if not tbFubenInfo then
        return
    end

    local tbAward = Lib:GetAwardFromString(tbFubenInfo.Award)
    return tbAward
end

function SeriesFuben:GetFubenCount()
    return #self.tbSetting
end

function SeriesFuben:IsMyMap(nMapTemplateId)
    return nMapTemplateId and self.tbMyMap[nMapTemplateId]
end

function SeriesFuben:GetPos(nFubenIdx, szKey)
    local tbFubenInfo = self:GetFubenInfo(nFubenIdx)
    local nX, nY = unpack(Lib:SplitStr(tbFubenInfo[szKey], "|"))
    return tonumber(nX), tonumber(nY)
end

function SeriesFuben:IsTaskFinish()
    local nTaskState = Task:GetTaskState(me, self.nTaskId, -1)
    return nTaskState ~= Task.STATE_ON_DING and nTaskState ~= Task.STATE_CAN_ACCEPT
end