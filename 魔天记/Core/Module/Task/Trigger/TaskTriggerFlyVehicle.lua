TaskTriggerFlyVehicle = class("TaskTriggerFlyVehicle", TaskTrigger);

function TaskTriggerFlyVehicle:_SetParam(data)
    self._needUpdate = true;
    local p = data.target;
    self.vehicleId = tonumber(p[1]);
    self.pathId = tonumber(p[2]);
    local cfg = ConfigManager.GetMovePath(self.pathId);
    self.mapId = cfg.map_id;
    self.targetPos = TaskUtils.ConvertPoint(cfg.start_x, cfg.start_z);
    self.r = cfg.ef_radius / 100;

    self.isTrigger = false;
end

function TaskTriggerFlyVehicle:Update()
	local b = TaskUtils.InArea(self.mapId, self.targetPos, self.r)
    if b then
        if self.isTrigger == false and HeroController:GetInstance():IsOnFMount() == false then
    		self:OnTrigger();
        	self.isTrigger = true;
    	end
    else 
        self.isTrigger = false;
    end
end

function TaskTriggerFlyVehicle:OnTrigger()
	HeroController:GetInstance():OnMountByRid(self.vehicleId, self.pathId, true, 0);
end

function TaskTriggerFlyVehicle:OnEvent(sequenceEventType, param)
    if(sequenceEventType == SequenceEventType.Base.VEHICLE_FLY_COMPLETE and param == self.pathId) then
        self:Result(true);
    end
end

function TaskTriggerFlyVehicle:Result(bool)
    if (bool) then
    	--上报后端完成.
    	TaskProxy.ReqTaskTrigger(self.taskId);
    end
end

