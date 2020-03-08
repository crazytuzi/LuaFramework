WuLinDaShi.tbCycleTask =
{
    {
        --Player
        nPlayerSaveGroup = 75,
        nVersionBegin    = 1,
        nVersionEnd      = 2,
        nDataDay         = 3,
        nAcceptCount     = 4,
        nDayTaskBeginKey = 5,
        --nDayTaskEndKey = nDayTaskBeginKey + nDayTaskCount

        --Task
        nDayTaskCount      = 5,
        nStartTaskId       = 2500,
        nAllCompleteTaskId = 2504,
        nDayTask4Show      = 2503,
        tbSectionTask      = {
            {nDayCompleteTaskId = 2501, tbRandomTask = {2600, 2601, 2602, 2603, 2604, 2620, 2623, 2625}},
            {nDayCompleteTaskId = 2502, tbRandomTask = {2600, 2601, 2602, 2603, 2604, 2605, 2622, 2623, 2624, 2625, 2626, 2627}},
        },
    }
}
WuLinDaShi.tbDayTask = {}
WuLinDaShi.tbStartTaskId = {}
WuLinDaShi.tbDayCompleteTaskId = {}
for nTranche, tbInfo in ipairs(WuLinDaShi.tbCycleTask) do
    for _, tbSInfo in ipairs(tbInfo.tbSectionTask) do
        for _, nRTaskId in ipairs(tbSInfo.tbRandomTask) do
            WuLinDaShi.tbDayTask[nRTaskId] = nTranche
        end
        WuLinDaShi.tbDayCompleteTaskId[tbSInfo.nDayCompleteTaskId] = nTranche
    end
    WuLinDaShi.tbStartTaskId[tbInfo.nStartTaskId] = nTranche
end

function WuLinDaShi:GetCycleTask(pPlayer)
    local tbPlayerTask = Task:GetPlayerTaskInfo(pPlayer)
    local tbCurInfo = tbPlayerTask.tbCurTaskInfo

    for _, tbInfo in pairs(tbCurInfo) do
        local tbTask = Task:GetTask(tbInfo.nTaskId)
        if tbTask and tbTask.nTaskType == Task.TASK_TYPE_WLDS_CYCLE then
            return tbTask
        end
    end

    return
end

WuLinDaShi.FUBEN_TASK_ID    = 2031
WuLinDaShi.FUBEN_TASK_MAP   = 153
WuLinDaShi.FUBEN_MIN_LEVEL  = 20
WuLinDaShi.MIN_PLAYER_COUNT = 2
WuLinDaShi.MAX_PLAYER_COUNT = 4
function WuLinDaShi:CheckFubenTask(pPlayer)
    local tbTask = Task:GetPlayerTaskInfo(pPlayer, self.FUBEN_TASK_ID)
    return tbTask and true
end