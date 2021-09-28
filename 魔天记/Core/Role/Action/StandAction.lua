require "Core.Role.Action.RoleAction";

StandAction = class("StandAction", RoleAction)
StandAction.WAITTIME = 5;
StandAction.WAITRATE = 0.5;
function StandAction:New(position, angle)
    self = { };
    setmetatable(self, { __index = StandAction });
    self:Init();
    self.actionType = ActionType.SIMILARBLOCK;
    self._position = position;
    self._angle = angle;
    self._playing = false;
    self._actionName = "stand";
    self._roleIsFight = false;
    self._roleIsOnRide = false;
    return self;
end

function StandAction:_OnStartHandler()
    local controller = self._controller
    if (controller) then
        local transform = controller.transform;
        controller:OnEnterStandAction()
        if (self._angle) then
            --transform.rotation = Quaternion.Euler(0, self._angle, 0);
            Util.SetRotation(controller.gameObject, 0, self._angle , 0)
        end
        if (self._position) then
            MapTerrain.SampleTerrainPositionAndSetPos(controller.gameObject, self._position)

--            transform.position = MapTerrain.SampleTerrainPosition(self._position);
        end
        if (self.actionType ~= ActionType.COOPERATION) then
            controller.state = RoleState.STAND;
            self._actionName = self:_GetStandActionName(controller);
            self._roleIsFight = controller:IsFightStatus();
            controller:Play(self._actionName);
        end
        self:_OnStartCompleteHandler();
        -- if (controller.info and controller.info.kind == 104000 and (controller.roleType == ControllerType.HERO or controller.roleType == ControllerType.PLAYER)) then
        if (controller.info and(controller.roleType == ControllerType.HERO or controller.roleType == ControllerType.PLAYER) and (not controller:IsOnLMount())) then
            -- math.randomseed(os.time());
            self._waitTime = math.Random(0.1, 1) * StandAction.WAITTIME;
            self:_InitTimer(0, -1);
        end
    end
end
function StandAction:_OnStopHandler()
    if self._controller then self._controller:OnExitStandAction() end
end

function StandAction:_GetRandomTime()
    -- math.randomseed(os.time());
    return math.Random(15, 30)
end

function StandAction:_OnTimerHandler()
    if (self._running) then
        local controller = self._controller;
        if (controller) then
            local isFight = controller:IsFightStatus();
            local isOnRide = controller:IsOnRide();
            if (not isOnRide) then
                local info = controller:GetAnimatorStateInfo();
                if (self._roleIsFight ~= isFight) then
                    if (isFight) then
                        controller:Play("turnatstand");
                    else
                        controller:Play("turnstand");
                    end
                    self._roleIsFight = isFight
                    self._delayTime = StandAction.WAITTIME;
                end
                if (info) then
                    if (not isFight) then
                        if (not info:IsName(RoleActionName.wait)) then
                            self._waitTime = self._waitTime - Time.fixedDeltaTime;
                            if (self._waitTime <= 0) then
                                -- Darren				
                                if (math.Random(0, 1) <= StandAction.WAITRATE) then
                                    controller:Play(RoleActionName.wait);
                                   -- Warning(">>>>>>>>");
                                end
                                self._waitTime = StandAction.WAITTIME;
                            end
                        end
                    else
                        if (info:IsName("turnatstand")) then                                                   
                            if (info.normalizedTime >= 0.9) then
                                self._actionName = self:_GetStandActionName(controller);
                                controller:Play(self._actionName);                                 
                            end
                        end
                    end
                end
            end
        end
    end
end