require "Core.Module.Task.TaskConst";
require "Core.Module.Task.TaskUtils";
require "Core.Info.TaskInfo";
require "Core.Module.Task.TaskNotes";
require "Core.Module.Task.Auto.TaskAuto";


TaskManager = { };
TaskManager._dict = { };
TaskManager._auto = nil;

TaskManager._sort = { };
TaskManager._sort[TaskConst.Type.MAIN] = 1;
TaskManager._sort[TaskConst.Type.DAILY] = 3;
TaskManager._sort[TaskConst.Type.REWARD] = 2;
TaskManager._sort[TaskConst.Type.GUILD] = 4;
TaskManager._sort[TaskConst.Type.BRANCH] = 5;
local _sortfunc = table.sort
local insert = table.insert

TaskManager.data = {
    dailyNum = 0;-- 日常循环任务数量
    rewardNum = 0;-- 悬赏任务数量
    rewardBuy = 0;-- 悬赏任务购买次数
    rewardTime = 0;-- 悬赏刷新时间

    guildNum = 0;-- 仙盟已任务数量
    guildMax = 0;-- 仙盟任务上限
    guildHelp = 0;-- 仙盟求助次数
}

TaskManager._auto = TaskAuto.New();

function TaskManager.Init()
    TaskManager.Clear();
    TaskProxy.ReqTaskList();
    TaskManager._auto:Init();
end

function TaskManager.Dispose()
    TaskManager.Clear();
    TaskManager._auto:Close();
end

function TaskManager.Clear()

    TaskManager._auto:Stop();

    for k, v in pairs(TaskManager._dict) do
        TaskManager.RemoveTaskAndTrigger(v.id);
        v = nil;
    end
    TaskManager._dict = { };
    TaskManager.data = {
        dailyNum = 0;
        rewardNum = 0;
        rewardBuy = 0;
        rewardTime = 0;
        guildNum = 0;
        guildMax = 0;
        guildHelp = 0;
    }
end

function TaskManager.GetConfigById(id)
    return ConfigManager.GetConfig(ConfigManager.CONFIGNAME_TASK)[id];
end

function TaskManager.GetQuestionCfgById(id)
    return ConfigManager.GetConfig(ConfigManager.CONFIGNAME_QUESTION)[id];
end

function TaskManager.GetAllTask()
    return TaskManager._dict;
end

function TaskManager.SortFunc(a, b)
    if a.status == b.status then
        if a.type == b.type and a.type == TaskConst.Type.BRANCH then
            return a:GetConfig().sort < b:GetConfig().sort;
        end
        return TaskManager._sort[a.type] < TaskManager._sort[b.type];
    else
        return a.status > b.status;
    end
end

function TaskManager.GetAllTaskList()
    local tmp = { };
    for k, v in pairs(TaskManager._dict) do
        if v.status == TaskConst.Status.UNACCEPTABLE and (v.type == TaskConst.Type.REWARD  or v.type == TaskConst.Type.GUILD) then
        else
            insert(tmp, v);
        end
    end
    _sortfunc(tmp, TaskManager.SortFunc);
    return tmp;
end

function TaskManager.GetTaskList()
    local tmp = { };
    for k, v in pairs(TaskManager._dict) do
        if (v.type == TaskConst.Type.MAIN or v.type == TaskConst.Type.DAILY) then
            insert(tmp, v);
        end
    end
    _sortfunc(tmp, TaskManager.SortFunc);
    return tmp;
end

function TaskManager.GetRewardList()
    local tmp = { };
    local i = 1;
    for k, v in pairs(TaskManager._dict) do
        if v.type == TaskConst.Type.REWARD then
            tmp[i] = v;
            i = i + 1;
        end
    end
    return tmp;
end

function TaskManager.GetGuildList()
    local tmp = { };
    local i = 1;
    for k, v in pairs(TaskManager._dict) do
        if v.type == TaskConst.Type.GUILD then
            tmp[i] = v;
            i = i + 1;
        end
    end
    return tmp;
end

function TaskManager.GetMainTaskId()
    for k, v in pairs(TaskManager._dict) do
        if (v.type == TaskConst.Type.MAIN) then
            return v.id;
        end
    end
    return 0;
end

function TaskManager.HasDailyTask()
    return TaskManager.data.dailyNum > 0;
end

-- 判断某个任务是否接取(只限于主线任务)
function TaskManager.TaskIsAccess(taskId)
    local curId = TaskManager.GetMainTaskId();
    return curId >= taskId;
end

function TaskManager.GetTaskById(id)
    return TaskManager._dict[id];
end


-- 更新任务的其他数据
function TaskManager.OnUpdateTaskData(data)
    if data.n then
        TaskManager.data.dailyNum = data.n;
    end

    local rewardNumChg = false;
    if data.rn then
        TaskManager.data.rewardNum = data.rn;
        rewardNumChg = true;
    end

    if data.rbn then
        TaskManager.data.rewardBuy = data.rbn;
        rewardNumChg = true;
    end

    if data.rt then
        TaskManager.data.rewardTime = GetGameTime() + data.rt / 1000;
    end

    if rewardNumChg then
        TaskManager.DiapatchEvent(TaskNotes.TASK_REWARD_CHANCE);
    end

    local guildNumChg = false;
    if data.tn then
        TaskManager.data.guildNum = data.tn;
        guildNumChg = true;
    end

    if data.ttn then
        TaskManager.data.guildMax = data.ttn;
        guildNumChg = true;
    end

    if data.thn then
        TaskManager.data.guildHelp = data.thn;
        guildNumChg = true;
    end

    if guildNumChg then
        MessageManager.Dispatch(GuildNotes, GuildNotes.ENV_TASK_DATA_CHG);
    end
end

function TaskManager.OnInitTaskList(ts, data, isLogin)
    TaskManager.Clear();
    for i, v in ipairs(ts) do
        TaskManager.AddTask(v);
    end

    TaskManager.OnUpdateTaskData(data);
    TaskManager.DiapatchEvent(TaskNotes.TASK_UPDATE);

    if isLogin then
        -- 完成后检查引导.
        GuideManager.CheckAll();
    end
end

function TaskManager.AddTask(task)
    TaskManager._dict[task.id] = task;
    if (task:NeedTrigger()) then
        TriggerManager.AddTaskTrigger(task);
    end
end

function TaskManager.RemoveTaskAndTrigger(taskId)
    local task = TaskManager._dict[taskId];
    if (task ~= nil) then
        TriggerManager.RemoveTaskTrigger(taskId);
        TaskManager._dict[taskId] = nil;
        task = nil;
    end
end

-- 任务状态更新
function TaskManager.OnUpdateTask(tMsg)
    local oldTask = TaskManager.GetTaskById(tMsg.id);
    local addTrigger = false;
    local isFinish = false;

    if oldTask == nil then
        error("找不到旧的任务 .. " .. tMsg.id);
        return;
    end

    if (oldTask.status2 == TaskConst.Status.UNACCEPTABLE and tMsg.st == TaskConst.Status.IMPLEMENTATION) then
        addTrigger = true;
    end

    if (oldTask.status2 == TaskConst.Status.IMPLEMENTATION and tMsg.st == TaskConst.Status.FINISH) then
        isFinish = true;
    end

    --[[
        客户端防错处理.因为后端发送的数据顺序有问题.
        有可能后端发送的是垃圾数据. 因此要判断状态, 进度数量
        不允许从高级状态修改到低级状态 不允许进度数量减少. by Dylan
    ]]
    if tMsg.st > oldTask.status2 or tMsg.num >= oldTask.param1 then
        oldTask:Update(tMsg);

        if (addTrigger) then
            -- 任务从不可接取到已接取 加载任务
            TriggerManager.AddTaskTrigger(oldTask);
        end

        TaskManager.DiapatchEvent(TaskNotes.TASK_UPDATE);

        if (isFinish) then
            -- 先触发完成
            SequenceManager.TriggerEvent(SequenceEventType.Base.TASK_FINISH, tMsg.id);
            -- 再删除触发器.
            TriggerManager.RemoveTaskTrigger(tMsg.id);

            TaskManager.OnTaskComplete(oldTask);

            TaskManager.DiapatchEvent(TaskNotes.TASK_STATUS_FINISH, tMsg.id);

            if oldTask.tType == TaskConst.Target.INSTANCE_CLEAR or oldTask.tType == TaskConst.Target.B_ZONGMEN_LILIAN 
            or oldTask.tType == TaskConst.Target.B_XLT or oldTask.tType == TaskConst.Target.B_GOTO_INSTANCE then
                --特殊任务类型 完成后不做自动处理
            elseif (oldTask.tType == TaskConst.Target.FIND and oldTask.type ~= TaskConst.Type.GUILD) then
                -- 完成找人任务时如果目标跟完成NPC是同一个人,则打开NPC对话界面领取奖励.
                local npcId = oldTask._config.com_npcid;
                local targetId = tonumber(oldTask._config.target[1]);
                if npcId == targetId then
                    ModuleManager.SendNotification(DialogNotes.OPEN_DIALOGPANEL, npcId);
                end
            elseif TaskManager.IsAuto() then
                --如果是悬赏任务或者仙盟任务, 完成任务后继续做同类型任务.
                if oldTask.type == TaskConst.Type.REWARD or oldTask.type == TaskConst.Type.GUILD then
                    TaskManager.GoToNextTask(oldTask.type);
                elseif oldTask.type ~= TaskConst.Type.BRANCH then
                    TaskManager.Auto(tMsg.id);
                end
            end

        else
            -- SequenceManager.TriggerEvent(SequenceEventType.Base.TASK_UPDATE, tMsg.id);
        end
    end
    
end

-- 领取任务完毕
function TaskManager.OnGetTask(task, data)
    -- 更新循环 悬赏数量
    if (data.n) then
        TaskManager.data.dailyNum = data.n;
    end
    if (data.rn) then
        TaskManager.data.rewardNum = data.rn;
    end

    if task.type == TaskConst.Type.BRANCH then
        if task.id == 840080 then
            --GuideManager.ManualGuide(37);
            task.isTips = true;
        end
    end

    TaskManager.AddTask(task);
    TaskManager.DiapatchEvent(TaskNotes.TASK_UPDATE);
    -- SequenceManager.TriggerEvent(SequenceEventType.Base.TASK_ACESS, id = task.id);

    -- 展示接取任务剧情对话.
    if task:AutoShowAcceptDialogs() == true then
        local ds = DialogSet.InitWithNewTaskDialog(task);
        if ds then
            ds:SetEnd( function()
                TaskManager.OnNewTask(task);
            end );
            ModuleManager.SendNotification(DialogNotes.OPEN_DIALOGPANEL, ds);
            return;
        end
    end
    TaskManager.OnNewTask(task);
end

-- 接取到新任务, 并且完成接取对话之后
function TaskManager.OnNewTask(task)
    local cfg = task:GetConfig();
    if cfg and cfg.plotId > 0 then
        -- 如果有剧情, 播放剧情.
        DramaDirector.Trigger(cfg.plotId,
        function()
            TaskManager.OnNewTaskAndDramaEnd(task);
        end );
        return;
    end

    TaskManager.OnNewTaskAndDramaEnd(task);
end

-- 任务接取时剧情完结或没有剧情.
function TaskManager.OnNewTaskAndDramaEnd(task)
    if TaskManager.IsAuto() and (task.type == TaskConst.Type.MAIN or task.type == TaskConst.Type.DAILY) then
        TaskManager.AutoTask(task);
    end

    if task.type == TaskConst.Type.MAIN then

        -- 触发系统管理器刷新.
        SystemManager.Check(SystemConst.OpenType.TASK, task.id);
        
        -- 任务接取触发 引导管理器的刷新.
        GuideManager.Check(GuideManager.Type.TASK, task.id);
    end
    
end

-- 提交任务完毕(任务结束)
function TaskManager.OnComitTask(tMsg)
    local task = TaskManager.GetTaskById(tMsg.id);
    if task then
        TaskManager.OnTaskEnd(task);
        SequenceManager.TriggerEvent(SequenceEventType.Base.TASK_END, tMsg.id);
        TaskManager.DiapatchEvent(TaskNotes.TASK_END, tMsg.id);
        TaskManager.RemoveTaskAndTrigger(tMsg.id);
        TaskManager.DiapatchEvent(TaskNotes.TASK_UPDATE);
    end
end

function TaskManager.OnTaskEnd(task)
    -- 任务结束的特殊处理
    if task.tType == TaskConst.Target.VKILL or task.tType == TaskConst.Target.VACTION then
        -- 地面载具类任务卸载载具。
        PlayerManager.hero:StopMountLang();
    end
end

function TaskManager.GoToNextTask(taskType)
    for k, v in pairs(TaskManager._dict) do
        if v.type == taskType and v.status == TaskConst.Status.IMPLEMENTATION then
            TaskManager.AutoTask(v);
        end
    end
end

function TaskManager.OnCancelTask(taskId)
    local task = TaskManager.GetTaskById(taskId);
    task:Update( { st = TaskConst.Status.UNACCEPTABLE });
    TriggerManager.RemoveTaskTrigger(taskId);
    TaskManager.DiapatchEvent(TaskNotes.TASK_UPDATE);
end

function TaskManager.OnRewardBuy(data)
    TaskManager.DiapatchEvent(TaskNotes.TASK_REWARD_CHANCE);
end

function TaskManager.DiapatchEvent(env, param)
    MessageManager.Dispatch(TaskManager, env, param);
end

function TaskManager.Auto(taskId)
    local task = TaskManager.GetTaskById(taskId);
    if task then
        TaskManager.AutoTask(task);
    else
        log("找不到任务. " .. taskId);
    end
end

function TaskManager.AutoTask(task)
    TaskManager._auto:Start(task);
end

function TaskManager.IsAuto()
    return TaskManager._auto.enabled;
end

function TaskManager.StopAuto()
    TaskManager._auto:Stop();
end

function TaskManager.TriggerEvent(eventType, param)
    if TaskManager._auto then
        TaskManager._auto:OnEvent(eventType, param);
    end
end

-- 后端有时不发任务更新.需要前端自己删某些类型的任务.
-- type TaskConst.Type.MAIN
function TaskManager.ClearTaskType(taskType)
    for k, v in pairs(TaskManager._dict) do
        if v.type == taskType then
            TaskManager.RemoveTaskAndTrigger(v.id);
            v = nil;
        end
    end

    TaskManager.DiapatchEvent(TaskNotes.TASK_UPDATE);
end
 

function TaskManager.OnTaskComplete(task)
    if task.tType == TaskConst.Target.ESCORT then
        HeroController.GetInstance():StopAutoEscort();
    end
end

function TaskManager.ChangeTaskId(oId, nId)
    local isChg = false;
    local newTask = nil;
    for k, v in pairs(TaskManager._dict) do
        if v.id == oId and v.status == TaskConst.Status.UNACCEPTABLE then
            v:SetId(nId);
            isChg = true;
            newTask = v;
            break;
        end
    end

    if isChg then
        TaskManager._dict[oId] = nil;
        TaskManager._dict[nId] = newTask;
        TaskManager.DiapatchEvent(TaskNotes.TASK_UPDATE);
    end
end
