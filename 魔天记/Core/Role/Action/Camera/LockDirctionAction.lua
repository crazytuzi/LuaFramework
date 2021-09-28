require "Core.Role.Action.AbsAction";
require "Core.Role.Controller.HeroController"

LockDirctionAction = class("LockDirctionAction", CameraToAction)

function LockDirctionAction:New(angleX, heightY, distance, angleY)
    self = { };
    setmetatable(self, { __index = LockDirctionAction });
    self:Init();
    self.actionType = ActionType.NORMAL;
    self.angleX = cameraAngle
    self.heightY = cameraOffsetY
    self.distance = cameraDistance
    self.angleY = cameraLensRotation
    cameraAngle = angleX
    cameraOffsetY = heightY
    cameraDistance = distance
    cameraLensRotation = angleY
    return self;
end

function LockDirctionAction:_OnStartHandler()

    if not self._controller then return end

    local h = HeroController.GetInstance()
    --h:StopCurrentActAndAI()
    --self._isAutoFight = h:IsAutoFight()
    MainUIProxy.SetMainUIOperateEnable(false)
    local trf = self._controller.transform;
    self._formAngle = trf.rotation
    self._formPos = trf.position
    self.camera = MainCameraController.camera
    self.formFov = self.camera.fieldOfView

    self._target = h.transform;
    self._controller:LookTarget(self._target.position)

    self._toAngle = trf.rotation
    self._toPos = trf.position
    self.fovGap = self.formFov - self.camera.fieldOfView
    self._time = 2;

    self.lerped = false
    self.super._OnStartHandler(self)
end

function LockDirctionAction:_OnTimerHandler()
    if not self.lerped then
        self.super._OnTimerHandler(self)
    else
        self._controller:LookTarget(self._target.position)
        --[[local transform = self._controller.transform;
        local target = self._target.position
        transform.position = Vector3.New(target.x, target.y + cameraOffsetY, target.z);
        transform.rotation = Quaternion.Euler(cameraAngle, cameraLensRotation, 0);
        transform:Translate(vback * cameraDistance);--]]
    end
end
function LockDirctionAction:_OnLerpComplete()
    -- if self._isAutoFight then
    --     local h = HeroController.GetInstance()
        --h:StartAutoFight()
    -- end
    MainUIProxy.SetMainUIOperateEnable(true)
    self.lerped = true
end

-- 结束动作，子类可重写
function LockDirctionAction:_OnStopHandler()
    cameraAngle = self.angleX
    cameraOffsetY = self.heightY
    cameraDistance = self.distance
    cameraLensRotation = self.angleY
    self.transform = nil
    if self._onComplete  then
        self._onComplete()
        self._onComplete = nil
    end 
end