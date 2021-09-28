require "Core.Module.Dialog.DialogData";
--对话集合. 包含1个或多个对话内容.
DialogSet = class("DialogSet");

DialogSet.Type = {
    Normal = 0;     --普通对话
    Plot = 1;       --剧情对话
    Question = 2;   --问答对话
}


function DialogSet:ctor()
    self.npcId = 0;
end

function DialogSet:Init(data, func)
    if type(data) == "table" and #data > 0 then
        self.data = data;
    else
        self.data = {data};
    end
    self.onEnd = func;
end

function DialogSet:SetEnd(func)
    self.onEnd = func;
end

function DialogSet.InitPlot(data, func, isPlot)
    local d = DialogSet.New();
    d:Init(data, func);
    d.type = DialogSet.Type.Plot;
    d.isPlot = isPlot or false;--是剧情
    return d;
end

--提取NPC对话集
function DialogSet.InitWithNpc(npcId)
    local ds = DialogSet.New();
    ds.npcId = npcId;
    local data = nil;
    local allTask = TaskManager.GetAllTaskList();
    for i,v in ipairs(allTask) do
        local cfg = v:GetConfig();
        if (v.status == TaskConst.Status.FINISH) then
            --任务完成的NPC对话
            if (cfg and cfg.com_npcid == npcId) then
                data = DialogData.New();
                data:InitWithTask(v);
                break;
            end
        elseif (v.status == TaskConst.Status.IMPLEMENTATION and v.tType == TaskConst.Target.FIND) then
            --对话任务的对话列表
            if (cfg and tonumber(cfg.target[1]) == npcId) then
                data = v:GetNpcTalkDialog(npcId);
                break;
            end
        end
    end
    
    if (data == nil) then
        local npcCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_NPC)[npcId];
        data = DialogData.New();
        data:InitWithNpcCfg(npcCfg);
    end

    ds:Init(data);
    ds.type = DialogSet.Type.Normal;
    return ds;
end

--提取任务答题对话集
function DialogSet.InitWithTaskQA(taskId)
    local ds = DialogSet.New();
    
    local cfg = TaskManager.GetConfigById(taskId);
    local qs = {};
    local count = #cfg.target;
    for i, v in ipairs(cfg.target) do
        local qId = tonumber(v);
        qs[i] = DialogData.New();
        qs[i]:InitWithQuestion(taskId, qId, i, count);
    end
    ds:Init(qs);
    ds.type = DialogSet.Type.Question;
    ds.isPlot = false;
    return ds;
end
local insert = table.insert

--提取任务接取对话集
function DialogSet.InitWithNewTaskDialog(task)
    local dialogs = {};
    local bool = false;
    local cfg = task:GetConfig();
    
    if cfg.task_dialogue ~= "" then
        local list = string.split(cfg.task_dialogue, "|");
        for i,v in ipairs(list) do
            if(v ~= "") then
                bool = true;
                local d = DialogData.New();
                d:InitWithTaskCfg(cfg, v, 0);
                insert(dialogs, d);
            end
        end
    end

    if bool then
        local ds = DialogSet.InitPlot(dialogs);
        ds.isNewTask = true;
        ds.taskId = task.id;
        return ds;
    end
    return nil;
end