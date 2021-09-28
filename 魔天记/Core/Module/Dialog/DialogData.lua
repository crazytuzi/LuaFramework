DialogDataType = {
    NONE = 0;
    NPC = 1;                --NPC的对话内容
    TASK = 2;               --任务当前的对话内容
    DIALOG = 3;             --文本解析的对话(任务接取对话内容, FIND类任务的对话内容)
    QUESTION = 4;           --答题.
    DRAMA = 5;
}

DialogData = class("DialogData");

--[[
DialogData.npcId = 0;           --触发的npcId
DialogData.roleId = 0;          --NPC形象
DialogData.dialog = "";         --对话内容
DialogData.showfunc = false;    --是否有功能 (npc对话)
DialogData.funcLabel = "";      --功能标签 (npc对话)
DialogData.func = "";           --功能事件 (npc对话)
DialogData.taskId = false;      --任务对话id
DialogData.awards = {};          --奖励物品 (npc对话)
DialogData.showAward = false;   --显示奖励
DialogData.speakSpeed = 0;      --speakSpeed说话速度(每单位时间一字,0立即显示)
DialogData.closeDelay = 0;   --closeDelay说完延迟关闭
DialogData.speakSkip = 0;   --speakSkip 说话可否跳过
]]

function DialogData:ctor()
   self.type = DialogDataType.NONE;
   self.npcId = 0;
   self.roleId = 0;
   self.dialog = "";
   self.showfunc = false;
   self.funcLabel = "";
   self.func = "";
   self.taskId = 0;
   self.awards = {};
   self.showAward = false;
   self.speakSpeed = 0
   self.closeDelay = 0
   self.speakSkip = true
   self.param = nil;
end

--提取NPC的对话
function DialogData:InitWithNpcCfg(npcCfg)
    self.type = DialogDataType.NPC;
    self.npcId = npcCfg.id;
    self.roleId = npcCfg.id;
    self.dialog = npcCfg.dialog;
    self.showfunc = npcCfg.func ~= "";
    if(self.showfunc) then
        local temp = string.split(npcCfg.func, "#");
        self.funcLabel = temp[1];
        self.func = temp[2];
    end
end

--根据任务状态提取对话(任务完成对话)
function DialogData:InitWithTask(task)
    local taskCfg = TaskManager.GetConfigById(task.id);
    self.type = DialogDataType.TASK;
    self.npcId = taskCfg.com_npcid;
    self.roleId = taskCfg.com_npcid;
    self.dialog = taskCfg.com_des;
    self.showfunc = false;
    self.taskId = task.id;
    self.awards = TaskUtils.GetTaskAward(task);
    self.showAward = true;
    self.param = taskCfg.exp_double;
end

--任务配置的对话字符串
function DialogData:InitWithTaskCfg(cfg, str, npcId)
    local tmp = string.split(str, ':')
    self.type = DialogDataType.DIALOG;
    self.npcId = npcId;
    self.roleId = tonumber(tmp[1]);
    self.taskId = cfg.task_id;
    self.dialog = tmp[2];
    self.showfunc = false;
end

--roleId对话角色id,msg对话内容,speakSpeed说话速度(每单位时间一字,0立即显示),closeDelay说完延迟关闭,speakSkip说辞可跳过
function DialogData:InitWithStr(roleId, msg, speakSpeed, closeDelay, speakSkip)
    self.type = DialogDataType.DRAMA;
    self.npcId = 0;
    self.roleId = tonumber(roleId);
    self.taskId = 0;
    self.dialog = msg;
    self.showfunc = false;
    self.speakSpeed = speakSpeed
    self.closeDelay = closeDelay
    self.speakSkip = speakSkip
end

--答题对话.
function DialogData:InitWithQuestion(id, qId, idx, num)
    self.type = DialogDataType.QUESTION;
    self.taskId = id;
    self.qId = qId;
    self.idx = idx;
    self.num = num;
end