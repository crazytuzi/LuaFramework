TaskAutoFlyVehicle = class("TaskAutoFlyVehicle", SequenceContent);

function TaskAutoFlyVehicle.GetSteps()
    return {
        TaskAutoFlyVehicle.A
    };
end

function TaskAutoFlyVehicle.A(seq)
	local cfg = seq:GetCfg();
    local pathId = tonumber(cfg.target[2]);
    local pathCfg = ConfigManager.GetMovePath(pathId);
	local mapId = pathCfg.map_id;
	local targetPos = TaskUtils.ConvertPoint(pathCfg.start_x, pathCfg.start_z);
	local r = pathCfg.ef_radius / 100;
	if seq:IsPay() then
        return SequenceCommand.Task.TaskTransmit(mapId, targetPos);
    end
	return SequenceCommand.Common.GoToPos(mapId, targetPos, r);
end

--[[
function TaskAutoFlyVehicle.B(seq)

end
]]

