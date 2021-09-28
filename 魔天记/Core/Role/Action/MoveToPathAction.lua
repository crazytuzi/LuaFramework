require "Core.Role.Action.RoleAction";

MoveToPathAction = class("MoveToPathAction", RoleAction)

MoveToPathAction._stopDistance = 0;

function MoveToPathAction:New(path)
    self = {};
    setmetatable(self, {__index = MoveToPathAction});
    self:Init();
    self.actionType = ActionType.NORMAL;
    self._stopDistance = 0;
    self:_InitPath(path);
    return self;
end

function MoveToPathAction:_FormatPath(data)
    local path = {};
    local count = #data
    local s = 1;
    for i = 1, count, 3 do
        local pt = Convert.PointFromServer(data[i], data[i + 1], data[i + 2])
        path[s] = pt;
        s = s + 1;
    end
    return path;
end

function MoveToPathAction:_InitPath(path)
    if (path) then
        self._index = 1;
        self._points = path;
        self._path = self:_FormatPath(path);
        -- self._toPoint = nil;
        self._endPoint = self:_GetEndPoint(self._path);
        -- if self._controller and self._controller.MESSAGE_ON_MOUNTLANG then
        -- logTrace("MoveToPathAction:_InitPath:path="..type(self._path)..",end="..tostring(self._endPoint));
        -- end
        if (self._endPoint == nil) then
            self._path = nil;
            self:Finish();
        end
    else
        self._path = nil;
        self:Finish();
    end
end

function MoveToPathAction:_GetEndPoint(path)
    local pt = nil;
    for i, v in pairs(path or {}) do
        pt = v;
    end
    return pt;
end

function MoveToPathAction:_OnStartHandler()
    local controller = self._controller;
    -- if controller.__cname == "PlayerController" then Error(tostring(self._path) .. "____" .. tostring(controller.gameObject.name)) end
    if (controller and self._path) then
        controller.state = RoleState.MOVE;
        self:_NextPosition();
        self:_InitTimer(0, -1);
        self:_OnStartCompleteHandler();
        self._actionName = self:_GetRunActionName(controller);
        --controller:Play(self._actionName);
    else
        self:Stop();
    end
end

function MoveToPathAction:_OnCompleteHandler()
    if (self._running) then
        self:Finish();
    end
end

function MoveToPathAction:_NextPosition()
    local controller = self._controller;
    local path = self._path;
    if (controller) then
        -- if controller.MESSAGE_ON_MOUNTLANG then
        -- logTrace("MoveToPathAction:_NextPosition:"..tostring(path and path[self._index]));
        -- end
        if (path and path[self._index]) then
            local transform = controller.transform
            --local aInfo = controller:GetAnimatorStateInfo();
            self._toPoint = path[self._index];
            self._r = math.atan2(self._toPoint.x - transform.position.x, self._toPoint.z - transform.position.z);
            self._index = self._index + 1;
            -- controller.transform.rotation = Quaternion.Euler(0,(self._r * 180.0 / math.pi), 0);
            Util.SetRotation(controller.transform, 0, (self._r * 180.0 / math.pi), 0)
            self._actionName = self:_GetRunActionName(controller);
            --if (aInfo == nil or (aInfo and not aInfo:IsName(self._actionName))) then
                controller:Play(self._actionName);
            --end
        else
            if (self._endPoint) then
                MapTerrain.SampleTerrainPositionAndSetPos(controller.transform, self._endPoint)
            end
            self:_OnCompleteHandler();
        end
    end
end

function MoveToPathAction:_OnTimerHandler()
    self:_OnMovePath();
end

function MoveToPathAction:_OnMovePath()
    local controller = self._controller;
    if (controller and self._endPoint and controller.transform) then
        --if (self._toPoint) then
        local pt = controller.transform.position;
        local toPoint = self._toPoint;
        local toEnd = Vector3.Distance2(self._endPoint, pt);
        local speed = (controller:GetMoveSpeed() / 100) * FPSScale;
        --local canWalk = GameSceneManager.mpaTerrain:IsWalkable(pt)
        local ed = self._stopDistance;
        if (ed <= 0) then
            ed = speed;
        end
        --if (canWalk) then
        if (toEnd > ed) then
            local isFight = controller:IsFightStatus();
            if (self._roleIsFight ~= isFight) then
                --local aInfo = controller:GetAnimatorStateInfo();
                self._actionName = self:_GetRunActionName(controller);
                --if (aInfo == nil or (aInfo and not aInfo:IsName(self._actionName))) then
                    controller:Play(self._actionName);
                --end
                self._roleIsFight = isFight
            end
            
            toEnd = Vector3.Distance2(toPoint, pt);
            if (toEnd > speed) then
                pt.x = pt.x + math.sin(self._r) * speed;
                pt.z = pt.z + math.cos(self._r) * speed;
                MapTerrain.SampleTerrainPositionAndSetPos(controller.transform, pt)
            else
                MapTerrain.SampleTerrainPositionAndSetPos(controller.transform, toPoint)
                self:_NextPosition();
            end
        else
            if (self._endPoint and self._stopDistance <= 0) then
                MapTerrain.SampleTerrainPositionAndSetPos(controller.transform, self._endPoint)
            end
            self:_OnCompleteHandler();
        end
        end
    --else
        --self:Stop();
    --end
end
