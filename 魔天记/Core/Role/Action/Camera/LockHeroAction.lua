require "Core.Role.Action.AbsAction";
require "Core.Role.Controller.HeroController"

LockHeroAction = class("LockHeroAction", AbsAction)

function LockHeroAction:New()
    self = { };
    setmetatable(self, { __index = LockHeroAction });
    self:Init();
    self.actionType = ActionType.NORMAL;
    return self;
end

function LockHeroAction:_OnStartHandler()
    Scene.EnableCameraOpreate(true)
    if (self._controller) then
        self._target = HeroController.GetInstance();
        self:_InitTimer(0, -1);
        self:_OnTimerHandler()
    end
end

function LockHeroAction:_OnTimerHandler()
    if (self._target and self._target.transform) then
        -- local transform = self._controller.transform;

        local target = self._target.transform.position
        self._controller:LookTarget(target)
    else
        self:Stop()
    end
end

function LockHeroAction:_OnStopHandler()
    Scene.EnableCameraOpreate(false)
end