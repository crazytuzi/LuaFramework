require "Core.Role.Action.AbsAction";
require "Core.Role.Action.LerpAction";

CameraToAction = class("CameraToAction", LerpAction)

function CameraToAction:New(time, formPos, formAngle, toPos, toAngle, onComplete, camera, formFov, toFov)
    self = { };
    setmetatable(self, { __index = CameraToAction });
    self:Init();
    self.actionType = ActionType.NORMAL;
    self.isPauseMainAction = true;

    self._formAngle = formAngle
    self._formPos = formPos
    self._toAngle = toAngle
    self._toPos = toPos
    self._time = time or 2;
    self._onComplete = onComplete

    self.camera = camera
    self.formFov = formFov
    self.fovGap = formFov - toFov
    return self;
end

function CameraToAction:_OnStartHandler()
    if (self._controller) then
        self._transform = self._controller.transform
        Util.SetPos(self._transform, self._formPos.x, self._formPos.y, self._formPos.z)
        --        self._transform.position = self._formPos;
        self._transform.rotation = self._formAngle;
        self._timeCount = 0
        self:_InitTimer(0, -1);
    end
    self.camera.fieldOfView = self.formFov
end

function CameraToAction:_OnTimerHandler()
    self._timeCount = self._timeCount + Time.fixedDeltaTime
    self._progress = self._timeCount / self._time;
    if self._progress > 1 then self._progress = 1 end
    Util.SetPos(self._transform, Vector3.Lerp(self._formPos, self._toPos, self._progress))
    --    self._transform.position = Vector3.Lerp(self._formPos, self._toPos, self._progress);
    self._transform.rotation = Quaternion.Lerp(self._formAngle, self._toAngle, self._progress);
    if self._progress == 1 then self:_OnLerpComplete() end
    self.camera.fieldOfView = self.formFov - self.fovGap * self._progress
end
