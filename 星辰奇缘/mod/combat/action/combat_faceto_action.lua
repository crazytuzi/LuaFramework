-- 改朝向
FaceToAction = FaceToAction or BaseClass(CombatBaseAction)

function FaceToAction:__init(brocastCtx, controller, point)
    self.controller = controller
    self.point = point
end

function FaceToAction:Play()
    self.controller:FaceTo(self.point)
    self:InvokeDelay(self.OnActionEnd, 0.01, self)
end

function FaceToAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end
