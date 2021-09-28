require "Core.Role.Action.RoleAction";

MoveToAngleAction = class("MoveToAngleAction", RoleAction)
 
function MoveToAngleAction:New(angle)
    self = { };
    setmetatable(self, { __index = MoveToAngleAction });
    self:Init();
    self.actionType = ActionType.NORMAL;
    self._roleIsFight = false;
    self:_SetAngle(angle);
    return self;
end

function MoveToAngleAction:_OnStartHandler()
    local controller = self._controller;
    if (controller) then
        controller.state = RoleState.MOVE;
        --controller.transform.rotation = Quaternion.Euler(0,(self._r * 180.0 / math.pi), 0);
        Util.SetRotation(controller.transform, 0, (self._r * 180.0 / math.pi), 0)
        self._actionName = self:_GetRunActionName(controller);
        self._roleIsFight = controller:IsFightStatus();
        controller:Play(self._actionName);
        -- self:_OnTimerHandler();
        self:_InitTimer(0, -1);
        self:_OnStartCompleteHandler();
    end
end

function MoveToAngleAction:SetAngle(angle, pt)
    local controller = self._controller;
    if (controller) then
        self:_SetAngle(angle);
        if (pt ~= nil) then
            MapTerrain.SampleTerrainPositionAndSetPos(controller.gameObject, pt)

            -- 		controller.transform.position = MapTerrain.SampleTerrainPosition(pt);
        end
        if (self.actionType ~= ActionType.COOPERATION) then
            self:_CheckIsRunAction();
        end
    end
end

function MoveToAngleAction:_SetAngle(angle)
    self._angle = angle;
    self._r = angle * math.pi / 180;
    local controller = self._controller;
    if (controller) then
        Util.SetRotation(controller.transform, 0, (self._r * 180.0 / math.pi), 0)
        --controller.transform.rotation = Quaternion.Euler(0,(self._r * 180.0 / math.pi), 0);
    end
end

function MoveToAngleAction:_OnTimerHandler()
    self:_OnMoveToAngleHandler();
end
function MoveToAngleAction:_CheckIsRunAction()
    local controller = self._controller;
    if (controller) then
        --local aInfo = controller:GetAnimatorStateInfo();
        local rideAct = self:_GetRideRunActionName(controller);
        self._actionName = self:_GetRunActionName(controller);
        --if (aInfo == nil or(aInfo and(not(aInfo:IsName(self._actionName) or aInfo:IsName(rideAct))))) then
            controller:Play(self._actionName);
        --end
    end
end

function MoveToAngleAction:_OnMoveToAngleHandler()
    local controller = self._controller;
    local transform = controller.transform;
    local pt = transform.position;
    local speed = controller:GetMoveSpeed() / 100 * FPSScale;
    local r = self._r;
    local isFight = controller:IsFightStatus();
    local isOnRide = controller:IsOnRide();

    if (self._roleIsFight ~= isFight) then
        self:_CheckIsRunAction();
        self._roleIsFight = isFight
    end

    pt.x = pt.x + math.sin(r) * speed;
    pt.z = pt.z + math.cos(r) * speed;
    if (GameSceneManager.mpaTerrain:IsWalkable(pt)) then
        --        transform.position = MapTerrain.SampleTerrainPosition(pt);
        MapTerrain.SampleTerrainPositionAndSetPos(transform, pt)

    end
end