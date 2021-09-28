TaskTriggerVehicleAction = class("TaskTriggerVehicleAction", TaskTriggerVehicle);

function TaskTriggerVehicleAction:_SetParam(data)
    self._needUpdate = true;
    local p = data.target;
    self.vehicleId = tonumber(p[1]);
    self.itemId = tonumber(p[2]);
    self.mapId = tonumber(p[3]);
    self.x = tonumber(p[4]);
    self.z = tonumber(p[5]);
    self.r = tonumber(p[6]);
    self.targetPos = TaskUtils.ConvertPoint(self.x, self.z);
    self._isOpen = false;
end

function TaskTriggerVehicleAction:Update()
    
    if self._manualUpdate then
        self._manualUpdate = false;
        return;
    end

    local vehicleId = HeroController:GetInstance():GetMountId();
    if vehicleId and vehicleId == self.vehicleId and TaskUtils.InArea(self.mapId, self.targetPos, self.r) then
        if (self._isOpen == false) then
            ModuleManager.SendNotification(TaskNotes.OPEN_TASKACTIONPANEL, {self.taskId});
            self._isOpen = true;
        end
    else 
        if (self._isOpen == true) then
            ModuleManager.SendNotification(TaskNotes.CLOSE_TASKACTIONPANEL);
            self._isOpen = false;
        end
    end
end

function TaskTriggerVehicleAction:Result(bool)
    if (bool) then
        TaskProxy.ReqTaskTrigger(self.taskId);
    end
end

function TaskTriggerVehicleAction:OnEvent(sequenceEventType, param)
    self.super.OnEvent(self, sequenceEventType, param);

    if(sequenceEventType == SequenceEventType.Base.TASK_ACTION and param == self.taskId) then
        self:Result(true);
    elseif sequenceEventType == SequenceEventType.Base.TASK_ACTION_UPDATE then
        --暂时关闭一下
        if (self._isOpen == true) then
            ModuleManager.SendNotification(TaskNotes.CLOSE_TASKACTIONPANEL);
            self._isOpen = false;
        end
        self._manualUpdate = true;
    end
end

function TaskTriggerVehicleAction:Dispose()
    self.super.Dispose(self);
    ModuleManager.SendNotification(TaskNotes.CLOSE_TASKACTIONPANEL);
end

