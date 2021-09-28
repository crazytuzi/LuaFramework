TaskTriggerAction = class("TaskTriggerAction", TaskTrigger);

function TaskTriggerAction:_SetParam(data)
    self._needUpdate = true;
    local p = data.target;
    --self.itemId = tonumber(p[1]);
    self.mapId = tonumber(p[2]);
    self.x = tonumber(p[3]);
    self.z = tonumber(p[4]);
    self.r = tonumber(p[5]);
    self.targetPos = TaskUtils.ConvertPoint(self.x, self.z);
    self._isOpen = false;
end

function TaskTriggerAction:Update()

    if self._manualUpdate then
        self._manualUpdate = false;
        return;
    end

    if TaskUtils.InArea(self.mapId, self.targetPos, self.r) then
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

function TaskTriggerAction:OnEvent(sequenceEventType, param)
    if(sequenceEventType == SequenceEventType.Base.TASK_ACTION) then
        if (param == self.taskId) then
            self:Result(true);
        end
    elseif sequenceEventType == SequenceEventType.Base.TASK_ACTION_UPDATE then
        --暂时关闭一下
        if (self._isOpen == true) then
            ModuleManager.SendNotification(TaskNotes.CLOSE_TASKACTIONPANEL);
            self._isOpen = false;
        end
        self._manualUpdate = true;
    end
end

function TaskTriggerAction:Result(bool)
    if (bool) then
        TaskProxy.ReqTaskTrigger(self.taskId);
    end
end

function TaskTriggerAction:Dispose()
    self.super.Dispose(self);
    ModuleManager.SendNotification(TaskNotes.CLOSE_TASKACTIONPANEL);
end
