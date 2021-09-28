TaskAutoVehicleKill = class("TaskAutoVehicleKill", SequenceContent);

function TaskAutoVehicleKill.GetSteps()
    return {
    	TaskAutoVehicleKill.GotoMap
    	,TaskAutoVehicleKill.OnVehicle
        ,TaskAutoVehicleKill.A
        ,TaskAutoVehicleKill.B
    };
end

function TaskAutoVehicleKill.GotoMap(seq)
    local cfg = seq:GetCfg();
    local mapId = tonumber(cfg.target[3]);
    return SequenceCommand.Common.GoToScene(mapId);
end

function TaskAutoVehicleKill.OnVehicle(seq)
	local cfg = seq:GetCfg();
	local vehicleId = tonumber(cfg.target[1]);

    if HeroController:GetInstance():GetMountId() == vehicleId then 
        return nil;
    elseif HeroController:GetInstance():GetMountId() == nil and HeroCtrProxy.IsOnIngMountId() == vehicleId then
        return nil;
    end
    
	HeroController:GetInstance():OnMountLang(vehicleId, nil, true);
	local filter = function(args) return(args == vehicleId) end;
    return SequenceCommand.WaitForEvent(SequenceEventType.Base.VEHICLE_INIT, nil, filter);
end

function TaskAutoVehicleKill.A(seq)
	local cfg = seq:GetCfg();
    local monId = tonumber(cfg.target[2]);
    local monCfg = ConfigManager.GetMonById(monId);
    mapId = monCfg.map_id;
    pos = Convert.PointFromServer(monCfg.x,monCfg.y,monCfg.z);
	return SequenceCommand.Common.GoToPos(mapId, pos);
end

function TaskAutoVehicleKill.B(seq)
    local cfg = seq:GetCfg();
    local monId = tonumber(cfg.target[2]);

    PlayerManager.hero:StartAutoKill(monId);
    return nil;
end

TaskAutoVipVehicleKill = class("TaskAutoVipVehicleKill", SequenceContent);

function TaskAutoVipVehicleKill.GetSteps()
    return {
        TaskAutoVipVehicleKill.Transmit
        ,TaskAutoVehicleKill.OnVehicle
        ,TaskAutoVehicleKill.B
    };
end

function TaskAutoVipVehicleKill.Transmit(seq)
    local cfg = seq:GetCfg();
    local monId = tonumber(cfg.target[2]);
    local monCfg = ConfigManager.GetMonById(monId);
    local mapId = monCfg.map_id;
    local pos = Convert.PointFromServer(monCfg.x,monCfg.y,monCfg.z);
    return SequenceCommand.Task.TaskTransmit(mapId, pos);
end