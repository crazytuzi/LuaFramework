--自动执行护送
TaskAutoEscort = class("TaskAutoEscort", SequenceContent)

function TaskAutoEscort.GetSteps()
    return {
        TaskAutoEscort.A
    };
end

function TaskAutoEscort.A(seq)
	--如果不在配置地图,或周围没有任务的NPC则认为任务失败, 重新导航到接取NPC出发护送任务.
    local myInfo = PlayerManager.GetPlayerInfo();
    local cfg = seq:GetCfg();
    local p = cfg.target;
    local targetId = tonumber(p[3]);
    local isFail = TaskUtils.InArea(tonumber(p[4])) == false or TaskUtils.CheckMonster(targetId, myInfo.id) == false;
    if isFail then
        local npcId = tonumber(p[2]);
        if seq:IsPay() then
            return SequenceCommand.Task.TransmitToNpc(npcId);
        end
        return SequenceCommand.Common.GoToNpc(npcId);
    else
        HeroController.GetInstance():StartAutoEscort(targetId);
    end
    return nil;
end  