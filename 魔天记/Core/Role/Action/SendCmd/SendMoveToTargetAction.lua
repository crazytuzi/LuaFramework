require "Core.Role.Action.SendCmd.SendMoveToAction";

SendMoveToTargetAction = class("SendMoveToTargetAction", SendMoveToAction)

function SendMoveToTargetAction:New(target, blRandom, distance)
    self = { };
    setmetatable(self, { __index = SendMoveToTargetAction });
    self:Init();
    self.actionType = ActionType.NORMAL;
    self._toMap = GameSceneManager.map.info.id;
    self._rDistance = distance;
    self._blRandom = blRandom
    self.isAcrossMap = false;
    self._disRoleEvent = true;
    if (target) then
        if (self._angle ~= nil) then
            self._toPosition = self:_GetRandomPosition(target.transform.position);
        else
            self._toPosition = target.transform.position;
        end
    end
    if (self._finished ~= true) then
        return self;
    end
    return nil;
end

function SendMoveToTargetAction:SetTarget(target)
    if (self._target ~= target) then
        local controller = self._controller;
        self._target = target;
        if (target) then
            if (self._blRandom) then
                self._toPosition = self:_GetRandomPosition(target.transform.position);
            else
                self._toPosition = target.transform.position;
            end
            if (controller and self._toPosition) then
                self:_SearchPath();
                if (self._running and self._path) then
                    self:_NextPosition();
                end
            else
                self:Finish();
            end
        end
    end
end

function SendMoveToTargetAction:_Randomseed()
    local controller = self._controller;
    if (controller and controller.transform) then
        local position = controller.transform.position;
        -- math.randomseed(position.x * position.y * position.z * 100);
    end
end

function SendMoveToTargetAction:_GetRandomPosition(origin)
    self:_Randomseed();
    local distance = self._rDistance;
    local index = 0;
    local angle = math.random(0, 360);    
    while (index < 9) do
        for i=1,3,2 do            
            local r = (angle + (i-2) * index * 20) * math.pi / 180;
            local pt = Vector3.New(origin.x,origin.y,origin.z);
            pt.x = pt.x + math.sin(r) * distance;
            pt.z = pt.z + math.cos(r) * distance;            
            if (GameSceneManager.mpaTerrain:IsWalkable(pt)) then
                --Warning(">>>>>>>>>>>01 distance:"..distance.."  index:"..index)
                return MapTerrain.SampleTerrainPosition(pt);
            end
        end
        index = index + 1
    end
    --Warning(">>>>>>>>>>>02 distance:"..distance.."  index:"..index)
    return nil;
end

function SendMoveToTargetAction:_OnCompleteHandler()
    local controller = self._controller;
    local target = self._target;
    if (target and target.transform) then
        local position = controller.transform.position;
        if (Vector3.Distance2(target.transform.position, controller.transform.position) > self._rDistance * 1.1) then
            if (self._blRandom) then
                self._toPosition = self:_GetRandomPosition(target.transform.position);
            else
                self._toPosition = target.transform.position;
            end
            if (controller and self._toPosition) then
                self:_SearchPath();
                if (self._path) then
                    self:_NextPosition();
                end
            else
                self:Finish();
            end
        else
            self:Finish();
        end
    end
end

function SendMoveToTargetAction:GetTarget()
    return self._target;
end