--自动执行任务行为

TaskAutoAction = class("TaskAutoAction", SequenceContent)

function TaskAutoAction.GetSteps()
    return {
        --TaskAutoAction.Trans
        TaskAutoAction.A
        --,TaskAutoAction.B
    };
end

function TaskAutoAction.A(seq)
    local cfg = seq:GetCfg();
    local pos = nil;
    local map = nil;
    local radius = nil;
    local p = cfg.target;
    if cfg.target_type == TaskConst.Target.USE_ITEM then
        map = tonumber(p[2]);
        pos = Convert.PointFromServer(tonumber(p[3]),0,tonumber(p[4]));
        radius = tonumber(p[5]);
    elseif cfg.target_type == TaskConst.Target.EXPLORE then
        map = tonumber(p[1]);
        pos = Convert.PointFromServer(tonumber(p[2]),0,tonumber(p[3]));
        radius = tonumber(p[4]);
    end
    
    if pos and map then
        if seq:IsPay() then
            return SequenceCommand.Task.TaskTransmit(map, pos);
        end

        return SequenceCommand.Common.GoToPos(map, pos, radius);
    end
    return nil;
end


function TaskAutoAction.B(seq)
    --执行动作
    return nil;
end