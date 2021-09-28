TaskTriggerMonster = class("TaskTriggerMonster", TaskTriggerAutoFight);

function TaskTriggerMonster:_SetParam(data)
    self.updateCount = 0;
    self._needUpdate = true;
    --0/1（0表示野外刷怪，1表示触发镜像）,monsterid,mapid,x,z,r,time（单位毫秒）
    local p = data.target;
    self.monId = tonumber(p[2]);
    self.mapId = tonumber(p[3]);
    self.x = tonumber(p[4]);
    self.z = tonumber(p[5]);
    self.r = tonumber(p[6]);
    self.targetPos = TaskUtils.ConvertPoint(self.x, self.z);
end

function TaskTriggerMonster:Update()
    self.updateCount = self.updateCount + 1;
    if self.updateCount > 7 then
        self.updateCount = 0;
        local b = TaskUtils.InArea(self.mapId, self.targetPos, self.r)
        if b and not TaskUtils.CheckMonster(self.monId) then
            self:Result(true);
        end
    end
end

function TaskTriggerMonster:Result(bool)
    if (bool) then
        TaskProxy.ReqMonster(self.taskId);
    end
end

