require "Core.Role.Action.AbsAction";

RoleAction = class("RoleAction", AbsAction)

function RoleAction:New()
    self = { };
    setmetatable(self, { __index = RoleAction });
    self:Init();
    return self;
end

function RoleAction:_GetStandActionName(role)
    if (role and role:IsFightStatus() and(not role:IsOnRide()) and(role.roleType == ControllerType.HERO or role.roleType == ControllerType.PLAYER) and(not role:IsOnLMount())) then
        -- if (role.info and role.info.kind == 104000) then
        return "atstand"
        -- end
    end
    return "stand";
end

function RoleAction:_GetRunActionName(role)

    if (role and role:IsFightStatus() and(not role:IsOnRide()) and(role.roleType == ControllerType.HERO or role.roleType == ControllerType.PLAYER) and(not role:IsOnLMount())) then
        -- if (role.info and role.info.kind == 104000) then
        return "runc"
        -- end
    end
    return "run";
end

function RoleAction:_GetRideRunActionName(role)
    local rideInfo = role._roleCreater:GetRideInfo();
    if (rideInfo) then
        return rideInfo.action_id;
    end
    return "run";
end

-- 动作完成，子类可重写
function RoleAction:_OnFinishHandler()
    if (self._controller and self._callback ~= nil) then
        local cAct = self._controller:GetCooperationAction();
        if (cAct == nil or(cAct and cAct.__cname ~= "SkillMoveAction" and cAct.__cname ~= "SendSkillMoveAction")) then
            self._controller.state = RoleState.STAND;
            self._controller:Stand(false);
        end
    end
end

function RoleAction:Stop()    
    if (not self._isStop) then
        if (self._owner and self._stopFunc) then
            self._stopFunc(self._owner);            
        end
        self._stopFunc = nil;
        self._owner = nil;
        self._isStop = true
        self._running = false;
        self:_OnStartRemoveListenerHandler();
        self:_OnStopHandler();
        self._controller = nil;
        if (self._timer) then
            self._timer:Stop();
            self._timer = nil;
        end
        if (self._callback) then
            self._callback(self);
        end;
    end
end