require "Core.Role.Action.AbsAction";

ShakeAction = class("ShakeAction", AbsAction)
-- 次数
ShakeAction._times = { 1, 2, 3 };
-- 幅度
ShakeAction._strengths = { 0.2, 0.3, 0.4 };
-- 间隔
ShakeAction._intervals = { 0.03, 0.02, 0.02 };

function ShakeAction:New(type, onComplete, actionType, notTraceHero)
    local shakeType = type or 1;
    self = { };
    setmetatable(self, { __index = ShakeAction });
    self:Init();
    self.actionType = actionType or ActionType.COOPERATION;
    --logTrace("ShakeAction:New," .. tostring(actionType) .. ".." .. self.actionType)
    self.isPauseMainAction = true;
    self._time = ShakeAction._times[shakeType];
    self._strength = ShakeAction._strengths[shakeType];
    self._interval = ShakeAction._intervals[shakeType];
    self._onComplete = onComplete
    self._traceTarget = self.actionType == ActionType.COOPERATION and (not notTraceHero)
    return self;
end

function ShakeAction:_OnStartHandler()
    if (self._controller) then
        self.transform = self._controller.transform
        self._target = HeroController.GetInstance();
        self._currStrength = self._strength;
        self:_InitTimer(self._interval, self._time);
    end
end

function ShakeAction:_OnTimerHandler()
    --[[if self._traceTarget and self._target then 
        local target = self._target.transform.position
        self._controller:LookTarget(target)
    end--]]

    local shake = Vector3.up * self._currStrength;
    self._currStrength = self._currStrength * -0.8;        
    self.transform:Translate(shake, Space.World);
end

function ShakeAction:_OnStopHandler()
    self.transform = nil
    if self._onComplete  then
        self._onComplete()
        self._onComplete = nil
    end 
end