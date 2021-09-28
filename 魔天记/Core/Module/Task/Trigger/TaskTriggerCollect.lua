TaskTriggerCollect = class("TaskTriggerCollect", TaskTrigger);

function TaskTriggerCollect:_SetParam(data)
    self._needUpdate = true;
    local p = data.target;
    local task = TaskManager.GetTaskById(self.taskId);
    self.cache = task.cache;
    self.mapId = task.mapId;
    self.r = tonumber(p[3]);
    self._isOpen = false;
end

function TaskTriggerCollect:Update()

    if TaskUtils.InMap(self.mapId) == false then
        return;
    end

    local nearId = 0;
    local offset = 999999;
    local role = HeroController.GetInstance();
    local myPos = role.transform.position;
    myPos.y = 0;
    --找到最近的物件
    for k, v in pairs(self.cache) do 
        local obj = GameSceneManager.map:GetSceneObjById(k);
        --Warning(k .. " -> " .. tostring(obj) .. tostring(obj:IsEnable()));
        if obj and obj:IsEnable() == true then
            local tmp = (myPos - v.pos):Magnitude();
            if tmp < offset then
                offset = tmp;
                nearId = k;
            end
        end
    end

    --判断最近的距离
    if nearId > 0 and offset > self.r then
        nearId = 0
    end

    if nearId > 0 then
        if (self._isOpen == false) then
            ModuleManager.SendNotification(TaskNotes.OPEN_TASKACTIONPANEL, {self.taskId, nearId});
            self._isOpen = true;
        end
    elseif (self._isOpen == true) then
        ModuleManager.SendNotification(TaskNotes.CLOSE_TASKACTIONPANEL);
        self._isOpen = false;
    end
end

function TaskTriggerCollect:OnEvent(sequenceEventType, param)
    if(sequenceEventType == SequenceEventType.Base.TASK_ACTION) then
        if (param == self.taskId) then
	        self:Result(true);
	    end
    elseif sequenceEventType == SequenceEventType.Base.TASK_ACTION_UPDATE then
        self:Update();
    end
end

function TaskTriggerCollect:Result(bool)
    if (bool) then
        TaskProxy.ReqTaskTrigger(self.taskId);
    end
end

function TaskTriggerCollect:Dispose()
    self.super.Dispose(self);
    ModuleManager.SendNotification(TaskNotes.CLOSE_TASKACTIONPANEL);
end