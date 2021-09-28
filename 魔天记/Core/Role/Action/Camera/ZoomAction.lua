require "Core.Role.Action.AbsAction";

ZA_MoveType = {
    none = 1;
    moveTo = 2;
    stay = 3;
    go_back = 4;
}

ZoomAction = class("ZoomAction", AbsAction)
local BACK = Vector3.back;
function ZoomAction:New(zoomSpeed, continueTime, stayTime,onComplete, actionType)
    self = { };
    setmetatable(self, { __index = ZoomAction });
    self:Init();
    self.actionType = actionType or ActionType.COOPERATION;
    --logTrace("ZoomAction:New," .. tostring(actionType) .. ".." .. self.actionType)
    self.isPauseMainAction = true;

    self._zoomSpeed1 = zoomSpeed * 0.1;
    self._zoomSpeed2 = - self._zoomSpeed1;

    self._continueTime1 = continueTime;
    self._continueTime2 = continueTime;

    self._stayTime = stayTime;
    self._moveType = ZA_MoveType.none;
    self._onComplete = onComplete
    self._traceTarget = self.actionType ~= ActionType.COOPERATION
    return self;
end

function ZoomAction:_OnStartHandler()
    if (self._controller) then
        self.transform = self._controller.transform
        self._target = HeroController.GetInstance();
        self._distance = 0;
        self._moveType = ZA_MoveType.moveTo;
        self:_InitTimer(0, self._continueTime1 + self._continueTime2 + self._stayTime);
    end
end

function ZoomAction:_OnTimerHandler()
    if (self._target) then
        --local transform = self._controller.transform;
        local variable;

        if (self._continueTime1 > 0) then
            self._continueTime1 = self._continueTime1 - 1;
            if self._traceTarget then 
                self._distance = self._distance + self._zoomSpeed1;
            else
                self.transform:Translate(BACK * self._zoomSpeed1);
            end
        elseif (self._stayTime > 0) then
            self._stayTime = self._stayTime - 1;
        elseif (self._continueTime2 > 0) then
            self._continueTime2 = self._continueTime2 - 1;
            if self._traceTarget then 
                self._distance = self._distance + self._zoomSpeed2;
            else
                self.transform:Translate(BACK * self._zoomSpeed2);
            end
        end
        --log("ZoomAction:_OnTimerHandler,distance="..self._distance .. ",pos=" .. tostring(transform.position))
        if self._traceTarget then  self.transform:Translate(BACK * self._distance) end;
    end
end

function ZoomAction:_OnStopHandler()
    self.transform = nil
    if self._onComplete  then
        self._onComplete()
        self._onComplete = nil
    end 
end