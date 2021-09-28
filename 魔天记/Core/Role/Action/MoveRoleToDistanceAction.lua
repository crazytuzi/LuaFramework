require "Core.Role.Action.RoleAction";

MoveRoleToDistanceAction = class("MoveRoleToDistanceAction", RoleAction)

function MoveRoleToDistanceAction:New()
    self = { };
    setmetatable(self, { __index = MoveRoleToDistanceAction });
    self:Init();
    return self;
end

function MoveRoleToDistanceAction:_OnStartHandler()
    local controller = self._controller;
    if (controller) then
        self._curTime = 0;
        self._r = 0;
        self._totalTime = 0.2;
        self._rate = 1.8;
        self._orgPosition = Vector3(controller.transform.position.x, controller.transform.position.y, controller.transform.position.z);
        self:_InitData()
        self:_InitTimer(0, -1);
    end
end

function MoveRoleToDistanceAction:_InitData()

end

function MoveRoleToDistanceAction:_OnTimerHandler()
    local controller = self._controller;
    local pt = Vector3(self._orgPosition.x, self._orgPosition.y, self._orgPosition.z);
    if (controller and self._curTime < self._totalTime) then
        local d = self._distance * math.pow(self._curTime / self._totalTime, 1.0 / self._rate);
        self._curTime = self._curTime + Time.fixedDeltaTime;
        pt.x = pt.x + math.sin(self._r) * d;
        pt.z = pt.z + math.cos(self._r) * d;
        if (GameSceneManager.mpaTerrain:IsWalkable(pt)) then
            MapTerrain.SampleTerrainPositionAndSetPos(controller.gameObject, pt)

            --            controller.transform.position = MapTerrain.SampleTerrainPosition(pt);
        else
            self:Stop()
        end
    else
        local d = self._distance
        pt.x = pt.x + math.sin(self._r) * d;
        pt.z = pt.z + math.cos(self._r) * d;
        if (GameSceneManager.mpaTerrain:IsWalkable(pt)) then
            MapTerrain.SampleTerrainPositionAndSetPos(controller.gameObject, pt)

            --            controller.transform.position = MapTerrain.SampleTerrainPosition(pt);
        end
        self:Stop();
    end
end