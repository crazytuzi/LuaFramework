--位置的任务触发
TaskTriggerExplore = class("TaskTriggerExplore", TaskTrigger);

function TaskTriggerExplore:_SetParam(data)
    self._needUpdate = true;
    --8:区域探索 mapid_x_z_r
    self.mapId = tonumber(data[1]);
    self.x = tonumber(data[2]);
    self.z = tonumber(data[3]);
    self.r = tonumber(data[4]);
    self.targetPos = TaskUtils.ConvertPoint(self.x, self.z);
    self.isTrigger = false;
end

function TaskTriggerExplore:Update()
    local b = TaskUtils.InArea(self.mapId, self.targetPos, self.r)
    if b then
        self:Result(true);
    else 
        self:Result(false);
    end
end

function TaskTriggerExplore:Result(bool)
    if (bool) then
        if(self.isTrigger == false)then
            TaskProxy.ReqTaskTrigger(self.taskId);           
            self.isTrigger = true;
        end
    else
        self.isTrigger = false;
    end
end
