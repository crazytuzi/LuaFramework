TaskInfo = class("TaskInfo");

local _objCfgs = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_OBJECT);

function TaskInfo:ctor(data)
    self:_Init(data);
end

function TaskInfo:SetId(taskId)
    self.id = taskId;
    self._config = TaskManager.GetConfigById(self.id);
    if (self._config == nil) then
        Error("TaskInfo - can't find task config - " .. self.id);
        return;
    end
    self.type = self._config.type;              --任务类型
    self.tType = self._config.target_type;      --目标类型
    self.isNew = self._config.min_lev <= 24;
    self.isPay = 0;
end

function TaskInfo:_Init(data)
    
    self:SetId(data.id);

    self.status = data.st;
    self.status2 = data.st;
    self.guildHelp = data.hst or -1;
    self.param1 = data.num;

    self:_Check();

    self:_InitConfig();
end

function TaskInfo:_InitConfig()
    
    if self.tType == TaskConst.Target.COLLECT and self.status ~= TaskConst.Status.FINISH then
        self.cache = {};
        
        for k, v in pairs(_objCfgs) do
            if v.taskId == self.id then
                local pos = TaskUtils.ConvertPoint(v.x, v.z);
                self.cache[k] = {info = v, map = v.map, pos = pos};
                self.mapId = v.map;
            end
        end
    end
end
 
function TaskInfo:Update(tMsg)
    if tMsg.st then
        self.status = tMsg.st;
    end

    if tMsg.st then
        self.status2 = tMsg.st;
    end

    if tMsg.num then
        self.param1 = tMsg.num;
    end
    
    self:_Check();
end

function TaskInfo:_Check()
    --把正在进行的对话任务置成完成.
    if (self.tType == TaskConst.Target.TALK and self.status == TaskConst.Status.IMPLEMENTATION) then    
        self.status = TaskConst.Status.FINISH;
    end
end

function TaskInfo:GetConfig()
    return self._config;
end

--获取对话任务的对话内容
function TaskInfo:GetNpcTalkDialog(npcId)
    local dialogs = {};

    if self._config.npc_dialogue ~= "" then
        local list = string.split(self._config.npc_dialogue, "|");
        for i,v in ipairs(list) do
            if(v ~= "") then
                local d = DialogData.New();
                d:InitWithTaskCfg(self._config, v, npcId);
                dialogs[i] = d;
            end
        end
    end
    return dialogs;
end

function TaskInfo:NeedTrigger()
    --根据真实的状态判断是否要加入触发器
    if(self.status2 == TaskConst.Status.IMPLEMENTATION) then
        return true;
    end
    return false;
end

function TaskInfo:AutoShowAcceptDialogs()
     return self.type == TaskConst.Type.MAIN and self.tType ~= TaskConst.Target.ESCORT;
end

function TaskInfo:SetPay(v)
    self.isPay = v and self.status or 0;
end

function TaskInfo:IsPay()
    return self.isPay > 0 and self.isPay == self.status;
end

--[[
{id,st:0 未接 1已接 2 已完成,num：完成数量}
self.id --任务ID
self.status = 前端展示的任务状态 0 未接取 1 已接取 2 已完成    
self.status2 = 后端返回的状态(未改动)
self.param1 = 参数1 (进度)
self.awards = 任务配置的奖励
]]