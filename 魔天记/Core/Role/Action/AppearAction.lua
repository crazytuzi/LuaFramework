require "Core.Role.Action.RoleAction";

AppearAction = class("AppearAction", AbsAction)

function AppearAction:New(actionName)
    self = { };
    setmetatable(self, { __index = AppearAction });
    self:Init();
    self.actionType = ActionType.SIMILARBLOCK;
    self._createEffect = false
    self._actionName = actionName
    --    self._position = position;
    --    self._angle = angle;
    --    self._delayTime = self:_RandomTime();
    return self;
end

function AppearAction:_OnStartHandler()
    local controller = self._controller
    if (controller) then
        self._effectDelay = controller.info.effectDelay / 1000
        local transform = controller.transform;
        if (self._angle) then
            transform.rotation = Quaternion.Euler(0, self._angle, 0);
        end
        if (self._position) then
            MapTerrain.SampleTerrainPositionAndSetPos(transform, self._position)
            --            transform.position = MapTerrain.SampleTerrainPosition(self._position);
        end
        controller:Play(self._actionName);
        self:_InitTimer(0, -1);
        self:_OnStartCompleteHandler();
    end
end
 
function AppearAction:_OnTimerHandler()
    local controller = self._controller;
    if (controller) then
        local info = controller:GetAnimatorStateInfo();
        if (info) then
            if (not info:IsName(self._actionName)) then
                controller:Play(self._actionName);
            else
                local curTime = info.normalizedTime;
                self._effectDelay = self._effectDelay - Time.fixedDeltaTime

                if (self._effectDelay <= 0 and not self._createEffect) then
                    self._createEffect = true
                end

                if (self._createEffect and self._effect == nil and controller.info.appearEffect ~= 0
                    and controller.info.appearEffect ~= "") then
                    -- log(controller)
                    -- log(controller.transform)

                    if (controller.transform ~= nil) then
                        self._effect = Resourcer.Get("Prefabs/Others", controller.info.appearEffect)
                        if (self._effect) then
                            Util.SetPos(self._effect, controller.transform.position)
                            --                        self._effect.transform.position = controller.transform.position
                        end
                    end
                end
                if curTime > 0.99 then
                    self:Stop()
                end
            end
        end
    end
end

function AppearAction:_OnStopHandler()
    if (self._effect) then
        Resourcer.Recycle(self._effect)
    end

    local controller = self._controller
    if (controller) then
        controller.state = RoleState.STAND;
        controller:Play("stand");
        --        controller:Dispose()
    end
end