require "Core.Role.Action.AbsAction";

LerpAction = class("LerpAction", AbsAction)

function LerpAction:New(time, formPos, formAngle, toPos, toAngle, onComplete)
    self = { };
    setmetatable(self, { __index = LerpAction });
    self:Init();
    self.actionType = ActionType.NORMAL;
    self.isPauseMainAction = true;

    self._formAngle = formAngle
    self._formPos = formPos
    self._toAngle = toAngle
    self._toPos = toPos
    self._time = time or 2;
    self._onComplete = onComplete
    return self;
end

function LerpAction:_OnStartHandler()
    if (self._controller) then
        self._transform = self._controller.transform
        Util.SetPos(self._transform, self._formPos.x, self._formPos.y, self._formPos.z)
--        self._transform.position = self._formPos;
        self._transform.rotation = self._formAngle;
        self._timeCount = 0
        self:_InitTimer(0, -1);
    end
end

function LerpAction:_OnTimerHandler()
    self._timeCount = self._timeCount + Time.fixedDeltaTime
    self._progress = self._timeCount / self._time;
    if self._progress > 1 then self._progress = 1 end
    Util.SetPos(self._transform, Vector3.Lerp(self._formPos, self._toPos, self._progress))
    --    self._transform.position = Vector3.Lerp(self._formPos, self._toPos, self._progress);
    self._transform.rotation = Quaternion.Lerp(self._formAngle, self._toAngle, self._progress);
    if self._progress == 1 then self:_OnLerpComplete() end
end

function LerpAction:_OnLerpComplete()
    self:Stop()
end

function LerpAction:_OnStopHandler()
    self.transform = nil
    if self._onComplete then
        self._onComplete()
        self._onComplete = nil
    end
end