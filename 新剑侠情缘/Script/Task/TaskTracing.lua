Task.emTASKTYPE_DAILY = 1;
Task.emTASKTYPE_SUB   = 2;
Task.emTASKTYPE_WLDS  = 3

function Task:OnTaskUpdate(nTaskId)
    if not nTaskId then
        return
    end

    local tbTask = self.tbDailyTaskSettings[self.emDAILY_COMMERCE]
    local tbKDPTask = self.tbDailyTaskSettings[self.emDAILY_KIN_DP]
    local bNormal = false
    if nTaskId == tbTask.nTaskId then
        if not tbTask.IsInCurTaskList() then
            return
        end
    elseif nTaskId == ActivityQuestion.TASK_ID then
        if not ActivityQuestion:IsTaskDoing() then
            return
        end
    elseif nTaskId == tbKDPTask.nTaskId then
        if not tbKDPTask.IsInCurTaskList() then
            return
        end
    else
        bNormal = true
    end

    self:PushUpdatingTask(nTaskId, bNormal)
    self:SetLatelyTask({ self.emTASKTYPE_SUB, nTaskId })
end

local szRecentTaskList = "UpdatingTaskList_TaskId";
function Task:PushUpdatingTask(nTaskId, bNormal) --bNormal 是否普通任务，商会跟答题都属于普通任务，有独立逻辑
    if bNormal then
        local tbTask = Task:GetTask(nTaskId)
        if tbTask.nTaskType == self.TASK_TYPE_MAIN or tbTask.nTaskType == self.TASK_TYPE_DAILY  or tbTask.nTaskType == self.TASK_TYPE_WLDS or tbTask.nTaskType == self.TASK_TYPE_WLDS_CYCLE or tbTask.nTaskType == self.TASK_TYPE_JYFL then
            return
        end
    end

    local tbTask = Client:GetUserInfo(szRecentTaskList)
    for i, nId in ipairs(tbTask) do
        if nId == nTaskId then
            table.remove(tbTask, i)
            break
        end
    end

    table.insert(tbTask, 1, nTaskId)
    Client:SaveUserInfo()
end

function Task:GetUpdatingTask()
    local tbTask = Client:GetUserInfo(szRecentTaskList)
    local tbUpdating = {}
    for i = #tbTask, 1, -1 do
        local bHasTask = true;
        if ZhenFaTask.tbAllTask[tbTask[i]] then
            local tb = Task:GetPlayerTaskInfo(me, tbTask[i]);
            if not tb then
                bHasTask = false;
            end
        end

        local szTitle, szDesc = self:GetTaskDesc(tbTask[i])
        if bHasTask and szTitle and szDesc then
            table.insert(tbUpdating, 1, {tbTask[i], szTitle, szDesc})
        else
            table.remove(tbTask, i)
        end
    end
    Client:SaveUserInfo()
    return tbUpdating, tbTask
end

function Task:UpdateTracingList()
    local _, tbTask = self:GetUpdatingTask()
    local tbTaskId  = {}
    for _, nTaskId in ipairs(tbTask) do
        tbTaskId[nTaskId] = true
    end
    for _, tbInfo in pairs(self.tbDailyTaskSettings) do
        if not tbTaskId[tbInfo.nTaskId] and tbInfo.IsInCurTaskList() then
            table.insert(tbTask, tbInfo.nTaskId)
        end
    end

    local tbMyTask = self:GetPlayerTaskInfo(me)
    local tbMyTaskId = {}
    for _, tbCurTask in pairs(tbMyTask.tbCurTaskInfo) do
        local tbTaskInfo = Task:GetTask(tbCurTask.nTaskId)
        if not tbTaskId[tbCurTask.nTaskId] and tbTaskInfo.nTaskType ~= self.TASK_TYPE_MAIN and
            tbTaskInfo.nTaskType ~= self.TASK_TYPE_WLDS and
            tbTaskInfo.nTaskType ~= self.TASK_TYPE_WLDS_CYCLE and
            tbTaskInfo.nTaskType ~= self.TASK_TYPE_JYFL then
            table.insert(tbMyTaskId, tbCurTask.nTaskId)
        end
    end
    table.sort(tbMyTaskId, function (a, b)
        return a > b
    end)
    Lib:MergeTable(tbTask, tbMyTaskId)
    Client:SaveUserInfo()
    UiNotify.OnNotify(UiNotify.emNOTIFY_UPDATE_TASK)
end

function Task:GetTaskDesc(nTaskId)
    if not nTaskId then
        return
    end

    if LoverTask:IsLoverTask(nTaskId) then
        return
    end

    local szTitle, szDesc = self:GetCommerceTaskInfo(nTaskId)
    if szTitle and szDesc then
        return "[00caff]" .. szTitle, szDesc
    end

    szTitle, szDesc = self:GetKinDPTaskInfo(nTaskId)
    if szTitle and szDesc then
        return "[00caff]" .. szTitle, szDesc
    end

    szTitle, szDesc = self:GetActivityQuestionInfo(nTaskId)
    if szTitle and szDesc then
        return "[00caff]" .. szTitle, szDesc
    end

    szTitle, szDesc = ZhenFaTask:GetZhenFaTaskInfo(nTaskId);
    if szTitle then
        return szTitle, szDesc;
    end

    local _, _, nIdx = self:GetPlayerTaskInfo(me, nTaskId)
    if nIdx then
        local szTitle, szDesc = self:GetNormalTaskInfo(nTaskId)
        return szTitle, szDesc
    end
end

function Task:GetNormalTaskInfo(nTaskId)
    local tbTmpTask  = self:GetTask(nTaskId);
    if not tbTmpTask then
        return
    end

    local szEndInfo = Task:GetTaskExtInfo(nTaskId);
    local nTaskState = self:GetTaskState(me, nTaskId, -1);
    local szDesc = nTaskState == Task.STATE_CAN_FINISH and tbTmpTask.szFinishDesc or tbTmpTask.szTaskDesc;
    if nTaskId ~= 6002 then
        szDesc = szDesc .. szEndInfo;
    end

    local szTitle = tbTmpTask.nTaskType == Task.TASK_TYPE_MAIN and "[ffcd00]" or "[00caff]"
    return szTitle .. tbTmpTask.szTaskTitle, szDesc
end

function Task:GetCommerceTaskInfo(nTaskId)
    local tbTaskInfo = self.tbDailyTaskSettings[self.emDAILY_COMMERCE]
    if nTaskId ~= tbTaskInfo.nTaskId then
        return
    end

    if tbTaskInfo.IsInCurTaskList() then
        return tbTaskInfo.szTitle, tbTaskInfo.szTarget
    end
end

function Task:GetKinDPTaskInfo(nTaskId)
    local tbTaskInfo = self.tbDailyTaskSettings[self.emDAILY_KIN_DP]
    if nTaskId ~= tbTaskInfo.nTaskId then
        return
    end

    if tbTaskInfo.IsInCurTaskList() then
        return tbTaskInfo.szTitle, tbTaskInfo.szTarget
    end
end

function Task:GetActivityQuestionInfo(nTaskId)
    if nTaskId ~= ActivityQuestion.TASK_ID then
        return
    end

    if ActivityQuestion:IsTaskDoing() then
        local szTitle, szDesc = ActivityQuestion:GetCurQuestionDesc()
        return szTitle, szDesc
    end
end

function Task:TrackUpdatingTask(nTaskId)
    if not nTaskId then
        return
    end

    if LoverTask:IsLoverTask(nTaskId) then
        LoverTask:TrackTask()
    elseif CommerceTask:IsCommerceTask(nTaskId) then
        local tbDailyTask = Task.tbDailyTaskSettings[Task.szDailyDefaultKey]
        tbDailyTask.OnTrack()
    elseif KinDinnerParty:IsKinDPTask(nTaskId) then
        local tbDailyTask = Task.tbDailyTaskSettings[Task.emDAILY_KIN_DP]
        tbDailyTask.OnTrack()
    elseif ActivityQuestion:IsActQuesTask(nTaskId) then
        ActivityQuestion:OnTrack()
    else
        Task:OnTrack(nTaskId)
    end
end

function Task:IsCanSubmit(nTaskId)
    if not nTaskId then
        return
    end

    if CommerceTask:IsCommerceTask(nTaskId) or ActivityQuestion:IsActQuesTask(nTaskId) then
        return
    else
        local nTaskState = self:GetTaskState(me, nTaskId)
        return nTaskState == Task.STATE_CAN_FINISH
    end
end

local tbPreview = Lib:LoadTabFile("Setting/Task/TaskAwardPreview.tab", {TaskIdBegin = 1, TaskIdEnd = 1, ItemTemplateId = 1})
function Task:GetAwardPreview(nTaskId)
    if not nTaskId then
        return
    end

    for _, tbInfo in ipairs(tbPreview) do
        if nTaskId >= tbInfo.TaskIdBegin and nTaskId <= tbInfo.TaskIdEnd then
            return tbInfo.TaskIdEnd - nTaskId, tbInfo.ItemTemplateId
        end
    end
end

function Task:OnTaskTimeout(tbNeedUpdate)
    for _, nTaskId in ipairs(tbNeedUpdate or {}) do
        self:UpdateTaskInfo(nTaskId)
    end
end

function Task:GetOfferTask()
    local tbRet = {}
    local tbPlayerTask = Task:GetPlayerTaskInfo(me)
    for _, tbInfo in pairs((tbPlayerTask or {}).tbCurTaskInfo or {}) do
        local tbTask = Task:GetTask(tbInfo.nTaskId)
        if tbTask and tbTask.nTaskType == Task.TASK_TYPE_OFFER then
            table.insert(tbRet, {tbInfo.nTaskId, tbTask.szTaskTitle})
        end
    end
    return tbRet
end

function Task:GetWLDSTask()
    if not self.tbWLDSUi then
        self.tbWLDSUi = {}
        local tbFile = Lib:LoadTabFile("Setting/Task/WLDS_UIList.tab", {})
        for nGroupIdx, tbInfo in ipairs(tbFile) do
            local tbTaskList = {}
            for i = 1, 99 do
                local nTaskId = tonumber(tbInfo["TaskId" .. i])
                if not nTaskId then
                    break
                end
                table.insert(tbTaskList, nTaskId)
            end
            self.tbWLDSUi[nGroupIdx] = {szTitle = tbInfo.Title, tbTaskList = tbTaskList}
        end
    end

    local tbPlayerTask = Task:GetPlayerTaskInfo(me)
    local tbCurWLDSTask = {}
    for _, tbInfo in pairs(tbPlayerTask.tbCurTaskInfo) do
        local tbTask = Task:GetTask(tbInfo.nTaskId)
        if tbTask and tbTask.nTaskType == Task.TASK_TYPE_WLDS then
            tbCurWLDSTask[tbInfo.nTaskId] = true
        end
    end
    local tbTask = {}
    for nGroupIdx, tbInfo in ipairs(self.tbWLDSUi) do
        local tbShowTask = {}
        local nCurTaskId
        local bAllFinish = true
        for _, nTaskId in ipairs(tbInfo.tbTaskList) do
            if not nCurTaskId then
                nCurTaskId = tbCurWLDSTask[nTaskId] and nTaskId
            end
            --if Task:IsFinish(me, nTaskId) or tbCurWLDSTask[nTaskId] then
                table.insert(tbShowTask, nTaskId)
            --end
            if not Task:IsFinish(me, nTaskId) then
                bAllFinish = false
            end
        end
        -- 有进行中的任务或者任务已经
        if nCurTaskId or bAllFinish then
            table.insert(tbTask, {szTitle = tbInfo.szTitle, nGroupIdx = nGroupIdx, tbTaskList = tbShowTask, nCurTaskId = nCurTaskId, bAllFinish = bAllFinish})
        end
    end
     -- 按表里填的倒序
    local fnSort = function (a, b)
        return a.nGroupIdx > b.nGroupIdx
    end
    if #tbTask > 1 then
        table.sort(tbTask, fnSort)
    end
    return tbTask
end

--------------------------------task panel--------------------------------
--TODO
function Task:OnCommerceTaskUpdate()
    self:SetLatelyTask({ self.emTASKTYPE_DAILY, self.emDAILY_COMMERCE });
end

function Task:OnKinDinnerPartyTaskUpdate()
    self:SetLatelyTask({ self.emTASKTYPE_DAILY, self.emDAILY_KIN_DP });
end

local szRecentTask = "LatelyTask";
function Task:SetLatelyTask(tbTaskInfo)
    local tbTask = Client:GetUserInfo(szRecentTask);
    tbTask[1] = tbTaskInfo[1];
    tbTask[2] = tbTaskInfo[2];
    Client:SaveUserInfo();
end

function Task:GetLatelyTask()
    local tbTask = Client:GetUserInfo(szRecentTask);
    if tbTask and next(tbTask) then
        return { tbTask[1], tbTask[2] };
    end
end