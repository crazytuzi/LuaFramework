-- 移动
MoveOnlyAction = MoveOnlyAction or BaseClass(CombatBaseAction)

function MoveOnlyAction:__init(brocastCtx, ctrl, point, speed)
    self.ctrl = ctrl
    self.point = point
    self.speed = speed
    self.oldSpeed = self.ctrl.speed
    self.mList = {
         {eventType = CombatEventType.MoveEnd, func = self.OnActionEnd, owner = self}
    }
end

function MoveOnlyAction:Play()
    self.ctrl.speed = self.speed
    self.ctrl:MoveTo(self.point, self.mList)
end

function MoveOnlyAction:OnActionEnd()
    self.ctrl.speed = self.oldSpeed
    self:InvokeAndClear(CombatEventType.End)
end
