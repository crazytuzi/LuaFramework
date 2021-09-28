--[[
自动杀怪. 
杀怪.掉落: 走到任务配置的位置,开启自动战斗.
刷怪:通过任务读取要击杀的怪物配置. 寻路到怪物的出生范围,开启自动战斗.
]]
TaskAutoKill = class("TaskAutoKill", SequenceContent)

function TaskAutoKill.GetSteps()
    return {
        TaskAutoKill.A
        ,TaskAutoKill.B
        --,TaskAutoKill.C
    };
end

function TaskAutoKill.A(seq)
    local cfg = seq:GetCfg();
    local mapId = 0;
    local pos = nil;
    if cfg.target_type == TaskConst.Target.MONSTER then
        --刷怪.
        local p = cfg.target;
        mapId = tonumber(p[3]);
        pos = Convert.PointFromServer(tonumber(p[4]),0,tonumber(p[5]));
    elseif cfg.target_type == TaskConst.Target.KILL or cfg.target_type == TaskConst.Target.DROP then
        --杀怪.
        local monId = tonumber(cfg.target[1]);
        local monCfg = ConfigManager.GetMonById(monId);
        mapId = monCfg.map_id;
        pos = Convert.PointFromServer(monCfg.x,monCfg.y,monCfg.z);
    end
       
    if mapId > 0 and  pos then
        if seq:IsPay() then
            return SequenceCommand.Task.TaskTransmit(mapId, pos);
        end
        return SequenceCommand.Common.GoToPos(mapId, pos);    
    else
        Error("taskAutoKill map or pos");
    end
    return nil;
end

function TaskAutoKill.B(seq)
    --local task = seq:GetTask();
    local cfg = seq:GetCfg();
    local monId = nil;

    if cfg.target_type == TaskConst.Target.KILL or cfg.target_type == TaskConst.Target.DROP then
        monId = tonumber(cfg.target[1]);
    elseif cfg.target_type == TaskConst.Target.MONSTER then
        monId = tonumber(cfg.target[2]);
    end

    PlayerManager.hero:StartAutoKill(monId);
    return nil;
    --return SequenceCommand.Task.TaskFinish(task.id);
end

--[[
function TaskAutoKill.C(seq)
    --PlayerManager.hero:StopAction(3);
    PlayerManager.hero:StopAutoFight();
    return nil;
end
]]




