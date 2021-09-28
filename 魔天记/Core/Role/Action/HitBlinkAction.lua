require "Core.Role.Action.RoleAction";

HitBlinkAction = class("HitBlinkAction", RoleAction)

local _alpha = 0.3
function HitBlinkAction:New()
    self = { };
    setmetatable(self, { __index = HitBlinkAction });
    self:Init();
    self.actionType = ActionType.COOPERATION;
    self._actName = "hitBlink";
    self._alpha = _alpha
    return self;
end

function HitBlinkAction:_OnStartHandler()
    if (self._controller) then      
        self._controller.state = RoleState.HURT;
        UIUtil.SetShaderFloat(self._controller.gameObject, "_BlinkTime", self._alpha)
        self:_InitTimer(0, -1);
    end
end

function HitBlinkAction:_OnStopHandler()
    if(self._controller and not IsNil(self._controller.gameObject) ) then
        UIUtil.SetShaderFloat(self._controller.gameObject, "_BlinkTime", 0)
    end
end

function HitBlinkAction:_OnTimerHandler() 
    local controller = self._controller;
    if (controller) then
        self._alpha = math.clamp(self._alpha - Time.fixedDeltaTime, 0, _alpha)    
        if (self._alpha <= 0) then
            self:Stop()
        end
    end
end