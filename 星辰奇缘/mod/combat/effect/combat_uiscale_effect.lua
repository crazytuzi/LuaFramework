-- 变大变小
UIScaleEffect = UIScaleEffect or BaseClass(CombatBaseAction)

-- endValue = Vector3
-- duration 秒
function UIScaleEffect:__init(brocastCtx, target, endValue, duration)
    self.target = target
    self.endValue = endValue
    self.duration = duration
    self.tween = nil
end

function UIScaleEffect:Play()
    if BaseUtils.isnull(self.target) then
        self:OnActionEnd()
        return
    end
    if self.duration == 0 then
        self.target.transform.localScale = self.endValue
        self:OnActionEnd()
    else
        -- tween:DoScale(self.target, self.target.transform.localScale, self.endValue, self.duration, function() self:OnActionEnd() end, "linear", 1)
        self.tween = Tween.Instance:Scale(self.target:GetComponent(RectTransform), self.endValue, self.duration, function() end, LeanTweenType.linear).id
        self:InvokeDelay(self.OnActionEnd, self.duration, self)
    end
end

function UIScaleEffect:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
    if self.tween ~= nil then
        Tween.Instance:Cancel(self.tween)
        self.tween = nil
    end
end
