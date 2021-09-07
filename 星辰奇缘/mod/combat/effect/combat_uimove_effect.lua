-- UI移动
UIMoveEffect = UIMoveEffect or BaseClass(CombatBaseAction)

function UIMoveEffect:__init(brocastCtx, target, dir, endValue, duration)
    self.target = target
    self.dir = dir
    self.endValue = endValue
    self.duration = duration
    self.tween = nil
end

function UIMoveEffect:Play()
    if self.target == nil or BaseUtils.isnull(self.target) or BaseUtils.isnull(self.target.transform) then
        self:OnActionEnd()
        return
    end
    self.startPoint = self.target.transform.localPosition
    local pos = self.startPoint
    if self.endValue > 0 then
        if self.dir == UIMoveDir.Up then
            -- tween:DoPosition(self.target, Vector2(pos.x, pos.y), Vector2(pos.x, pos.y + self.endValue), self.duration, function()  end, "linear", 1)
            self.tween = Tween.Instance:MoveLocal(self.target, Vector3(pos.x, pos.y + self.endValue, pos.z), self.duration, function()  end, LeanTweenType.linear).id
        elseif self.dir == UIMoveDir.Down then
            -- tween:DoPosition(self.target, Vector2(pos.x, pos.y), Vector2(pos.x, pos.y - self.endValue), self.duration, function()  end, "linear", 1)
            self.tween = Tween.Instance:MoveLocal(self.target, Vector3(pos.x, pos.y - self.endValue, pos.z), self.duration, function()  end, LeanTweenType.linear).id
        elseif self.dir == UIMoveDir.Lef then
            -- tween:DoPosition(self.target, Vector2(pos.x, pos.y), Vector2(pos.x - self.endValue, pos.y), self.duration, function()  end, "linear", 1)
            self.tween = Tween.Instance:MoveLocal(self.target, Vector3(pos.x - self.endValue, pos.y, pos.z), self.duration, function()  end, LeanTweenType.linear).id
        elseif self.dir == UIMoveDir.Right then
            -- tween:DoPosition(self.target, Vector2(pos.x, pos.y), Vector2(pos.x + self.endValue, pos.y), self.duration, function()  end, "linear", 1)
            self.tween = Tween.Instance:MoveLocal(self.target, Vector3(pos.x + self.endValue, pos.y, pos.z), self.duration, function()  end, LeanTweenType.linear).id
        end
        self:InvokeDelay(self.OnActionEnd, self.duration, self)
    else
        self:OnActionEnd()
    end
end

function UIMoveEffect:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
    if self.tween ~= nil then
        Tween.Instance:Cancel(self.tween)
        self.tween = nil
    end
end
