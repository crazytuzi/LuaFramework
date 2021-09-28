TaskTriggerVehicle = class("TaskTriggerVehicle", TaskTrigger);

function TaskTriggerVehicle:_SetParam(data)
    local p = data.target;
    self.mapId = tonumber(p[3]);
    self.vehicleId = tonumber(p[1]);
end

function TaskTriggerVehicle:OnEvent(sequenceEventType, param)
    if(sequenceEventType == SequenceEventType.Base.TASK_ACESS_DIALOG_END and param == self.taskId) then
        self:OnAcessDialogEnd();
    end
end

function TaskTriggerVehicle:OnAcessDialogEnd()
	
	--对话完成时.同时在配置地图时, 加载载具.
	if TaskUtils.InMap(self.mapId) then
		HeroController:GetInstance():OnMountLang(self.vehicleId, nil, true);
	end

end