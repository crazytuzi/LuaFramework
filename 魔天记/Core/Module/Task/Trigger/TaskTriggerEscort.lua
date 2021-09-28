TaskTriggerEscort = class("TaskTriggerEscort", TaskTrigger);

--[[
    护送触发器:在触发npcid附近, 且周围没有monsterid的护送目标时, 向服务器请求刷新护送目标.
]]

function TaskTriggerEscort:_SetParam(data)
    self.updateCount = 0;
    self._needUpdate = true;
    --npcid,monsterid,mapid,x,z,time,roadid,r
    local p = data.target;
    self.npcId = tonumber(p[2]);
    self.escortId = tonumber(p[3]);
    local myinfo = PlayerManager.GetPlayerInfo();
    self.myId = myinfo.id;
end

function TaskTriggerEscort:Update()
    if TaskUtils.SceneReady() == false then
        return;
    end
    local b = TaskUtils.CheckMonster(self.escortId, self.myId);
    if b then
        self.updateCount = math.max(self.updateCount - 1, -1);
        if not TaskUtils.InMonsterCircle(self.escortId, self.myId, 13) then
            
            if self.updateCount < 0 then
                self.updateCount = 11;          --3秒内不再提示.
                MsgUtils.ShowTips("task/escort/warnning");
            end
            --[[
            local target = TaskUtils.GetMonster(self.escortId, self.myId);
            if target then
                log(target);
                PrintTable(target);
            end
            ]]
        end
    elseif TaskUtils.CheckPosToNpc(self.npcId) then
        self:Result(true);
    end
end

function TaskTriggerEscort:Result(bool)
    --TaskProxy.ReqTaskEscort(self.taskId);
    if SequenceManager.IsPlaying("TaskSeqStartEscort") == false then
        local task = TaskManager.GetTaskById(self.taskId);
        SequenceManager.Play("TaskSeqStartEscort", task, TaskSequence);
    end
end
