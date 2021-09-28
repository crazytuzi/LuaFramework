TaskAutoVehicleAction = class("TaskAutoVehicleAction", SequenceContent);

function TaskAutoVehicleAction.GetSteps()
    return {
    	TaskAutoVehicleAction.GotoMap
    	,TaskAutoVehicleAction.OnVehicle
        ,TaskAutoVehicleAction.A
    };
end

function TaskAutoVehicleAction.GotoMap(seq)
    local cfg = seq:GetCfg();
    local mapId = tonumber(cfg.target[3]);
    return SequenceCommand.Common.GoToScene(mapId);
end

function TaskAutoVehicleAction.OnVehicle(seq)
	local cfg = seq:GetCfg();
	local vehicleId = tonumber(cfg.target[1]);

    local isOnIngMount = false;
    if HeroController:GetInstance():GetMountId() == vehicleId then 
        return nil;
    elseif HeroController:GetInstance():GetMountId() == nil and HeroCtrProxy.IsOnIngMountId() == vehicleId then
        isOnIngMount = true;
    end
    
    if isOnIngMount == false then
        HeroController:GetInstance():OnMountLang(vehicleId, nil, true);
    end
	
	local filter = function(args) return(args == vehicleId) end;
    return SequenceCommand.WaitForEvent(SequenceEventType.Base.VEHICLE_INIT, nil, filter);
end

function TaskAutoVehicleAction.A(seq)
	local cfg = seq:GetCfg();
    local p = cfg.target;
    local map = tonumber(p[3]);
    local pos = Convert.PointFromServer(tonumber(p[4]),0,tonumber(p[5]));
    local radius = tonumber(p[6]);
    return SequenceCommand.Common.GoToPos(map, pos, radius);
end

TaskAutoVipVehicleAction = class("TaskAutoVipVehicleAction", SequenceContent);

function TaskAutoVipVehicleAction.GetSteps()
    return {
        TaskAutoVipVehicleAction.Transmit
        ,TaskAutoVehicleAction.OnVehicle
    };
end

function TaskAutoVipVehicleAction.Transmit(seq)
    Warning("123123123123123");
    local cfg = seq:GetCfg();
    local p = cfg.target;
    local mapId = tonumber(p[3]);
    local pos = Convert.PointFromServer(tonumber(p[4]),0,tonumber(p[5]));
    return SequenceCommand.Task.TaskTransmit(mapId, pos);
end
