require "Core.Role.Action.MoveRoleToDistanceAction";

DartAction = class("DartAction", RoleAction)

function DartAction:New(distance, delay, time)
    self = { };
    setmetatable(self, { __index = DartAction });
    self:Init();
    self.actionType = ActionType.COOPERATION;
    self._delay = delay;
    self._distance = distance;
    self._time = time;
    self._speed = distance /((time - delay) * 1000);
    return self;
end

function DartAction:_OnStartHandler()
    local controller = self._controller;
    if (controller) then
        local target = controller.target;
        if (target and target.info) then
            self._distance = self._distance -(target.info.radius + controller.info.radius) / 100
        end
        if (self._distance > 0) then
            controller.state = RoleState.MOVE;
            self._orgPosition = controller.transform.position;
            self._r =(controller.transform.rotation.eulerAngles.y) / 180.0 * math.pi;
            self:_InitTimer(0, -1);
        else
            self:Stop();
        end
    else
        self:Stop();
    end
end

function DartAction:_OnTimerHandler()
    local controller = self._controller;
    if (controller) then
        if (self._delay <= 0) then
            if (self._distance > 0) then
                local pt = controller.transform.position;
                local speed = self._speed * (Time.fixedDeltaTime * 1000) * FPSScale;
                if (self._distance < speed) then
                    speed = self._distance
                end
                pt.x = pt.x + math.sin(self._r) * speed;
                pt.z = pt.z + math.cos(self._r) * speed;
                self._distance = self._distance - speed;
                if (GameSceneManager.mpaTerrain:IsWalkable(pt)) then
                    MapTerrain.SampleTerrainPositionAndSetPos(controller.gameObject, pt)
                    --                    controller.transform.position = MapTerrain.SampleTerrainPosition(pt);
                else
                    self:Stop();
                end
            end
        else
            self._delay = self._delay - Time.fixedDeltaTime;
        end
    else
        self:Stop();
    end
end

--[[
function DartAction:New(distance, speed)
    self = { };
    setmetatable(self, { __index = DartAction });
    self.actionType = ActionType.COOPERATION;
    self._distance = distance;
    self._speed = speed;
    return self;
end

function DartAction:_OnStartHandler()
    local controller = self._controller;
    if (controller) then
        controller.state = RoleState.MOVE;
        self._orgPosition = controller.transform.position;
        self._r =(controller.transform.rotation.eulerAngles.y) / 180.0 * math.pi;
        self:_InitTimer(0, -1);
    else
        self:Stop();
    end
end

function DartAction:_OnTimerHandler()
    local controller = self._controller;
    if (controller) then
        if (self._distance > 0) then
            local pt = controller.transform.position;
            local speed = self._speed *(Time.fixedDeltaTime * 1000);
            if (self._distance < speed) then
                speed = self._distance
            end
            pt.x = pt.x + math.sin(self._r) * speed;
            pt.z = pt.z + math.cos(self._r) * speed;
            self._distance = self._distance - speed;
            if (GameSceneManager.mpaTerrain:IsWalkable(pt)) then
                controller.transform.position = MapTerrain.SampleTerrainPosition(pt);
            else
                self:Stop();
            end
        end
    else
        self:Stop();
    end
end
]]