require "Core.Role.Action.AbsAction";
require "Core.Role.Controller.HeroController"

TrackTargetAction = class("TrackTargetAction", AbsAction)
TrackTargetAction.Mode = { immediate = 1, time = 2, box = 3 }
local vback = Vector3.back
local updateDistance1 = 100 updateDistance2 = 9 -- 判断镜头切换速度的距离平方
local rotateSpeed = 5 rotateSpeed1 = 2 rotateSpeed2 = 1 -- 不同距离的镜头切换速度
local updateSpeed = rotateSpeed2
function TrackTargetAction:New()
    self = { };
    setmetatable(self, { __index = TrackTargetAction });
    self:Init();
    self.actionType = ActionType.NORMAL;
    self.updateCount = 0
    self.updateMode = TrackTargetAction.Mode.time
    self.angleX = cameraAngle
    self.heightY = cameraOffsetY
    self.distance = cameraDistance
    self.angleY = cameraLensRotation
    return self;
end

function TrackTargetAction:_OnStartHandler()
    if (self._controller) then
        self._target = HeroController.GetInstance();
        self.transform = self._controller.transform
        self.targetTransform = self._target.transform
        self:_InitTimer(0, -1);
    end
end

function TrackTargetAction:_OnTimerHandler()
    if self._target and self.targetTransform then
        local ht, camParam = self._target:GetAttackBoss()
        if ht then
            -- 针对特定的boss 时的特殊镜头, camParam镜头参数{Y角度,y高,距离}
            cameraAngle = camParam[1]
            cameraOffsetY = camParam[2]
            cameraDistance = camParam[3]
            local target = self.targetTransform.position
            local htPos = ht.transform.position
            local vGap = target - htPos
            local dis = vGap.sqrMagnitude
            Util.SetPos(self.transform, target.x, target.y + cameraOffsetY, target.z)
            --            self.transform.position = Vector3.New(target.x, target.y + cameraOffsetY, target.z)
            if self.updateMode == TrackTargetAction.Mode.immediate then
                self.transform:LookAt(htPos)
            else
                local t = Time.fixedDeltaTime
                local curretnAngle = self.transform.rotation
                if self.updateMode == TrackTargetAction.Mode.time then
                    self._fromAngle = curretnAngle
                    self.transform:LookAt(htPos)
                    self._toAngle = self.transform.rotation
                    updateSpeed = dis > updateDistance1 and rotateSpeed or(dis > updateDistance2 and rotateSpeed1 or rotateSpeed2)
                    self.deltaTime = 0
                elseif self.updateMode == TrackTargetAction.Mode.box then

                end
                if curretnAngle ~= self._toAngle then
                    self.deltaTime = self.deltaTime + t
                    self.transform.rotation = Quaternion.Lerp(self._fromAngle, self._toAngle, self.deltaTime * updateSpeed)
                end
            end
            cameraLensRotation = self.transform.eulerAngles.y
            self.transform.eulerAngles = Vector3(cameraAngle, cameraLensRotation, 0)
            self.transform:Translate(vback * cameraDistance);
        else
            self._controller:LockHero()
        end
    end
end

-- 结束动作，子类可重写
function TrackTargetAction:_OnStopHandler()
    cameraAngle = self.angleX
    cameraOffsetY = self.heightY
    cameraDistance = self.distance
    cameraLensRotation = self.angleY
end