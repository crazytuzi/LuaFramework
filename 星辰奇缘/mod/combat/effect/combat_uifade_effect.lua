-- 渐变
UIFadeEffect = UIFadeEffect or BaseClass(CombatBaseAction)

function UIFadeEffect:__init(brocastCtx, target, endValue, duration)
    self.target = target
    self.endValue = endValue
    self.duration = duration
    self.tweenid = nil
end

function UIFadeEffect:Play()
    -- tween:DoCombatAlpha(self.target, 1, self.endValue, self.duration, function() self:OnActionEnd() end, "linear", 1)
    if BaseUtils.isnull(self.target) then
        self:OnActionEnd()
        return
    end
    local rts = self.target.transform:GetComponent(RectTransform)
    if rts:GetComponent(Image) ~= nil then
        self.tweenid = Tween.Instance:Alpha(rts, self.endValue, self.duration, function()  end).id
    else
        self.tweenid = Tween.Instance:Alpha(self.target, self.endValue, self.duration, function()  end).id
    end
    self:PraseChild(rts)
    self:InvokeDelay(self.OnActionEnd, self.duration, self)
end

function UIFadeEffect:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
    if self.tweenid ~= nil then
        Tween.Instance:Cancel(self.tweenid)
        self.tweenid = nil
    end
end

function UIFadeEffect:PraseChild(rts)
    for i = 1,rts.childCount do
        local target = rts:GetChild(i-1)
        if target:GetComponent(Image) ~= nil then
            Tween.Instance:Alpha(target, self.endValue, self.duration, function()end)
        end
        if target.childCount>0 then
            self:PraseChild(target)
        end
    end
end