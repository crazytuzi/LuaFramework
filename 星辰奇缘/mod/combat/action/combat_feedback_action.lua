-- 反射
FeedBackAction = FeedBackAction or BaseClass(CombatBaseAction)

function FeedBackAction:__init(brocastCtx, actionData, minoraction)
    -- BaseUtils.dump(actionData, "反射")
    self.actionData = actionData
    self.minoraction = minoraction
    self.attrChgAction = EffectFactory.AttrChangeEffectByAction(brocastCtx, self.actionData, 1)
    self.attrChgAction:AddEvent(CombatEventType.End, self.OnActionEnd, self)
    if self.actionData.is_target_die == 1 then
        self.deadAction = DeadAction.New(brocastCtx, self.actionData.target_id)
    end
    local show_actionData = actionData
    local isfeedback = false
    for i,v in ipairs(actionData.target_changes) do
        if v.change_type == 0 and v.change_val < 0 then
            isfeedback = true
        end
    end
    -- show_actionData.target_id = actionData.self_id
    -- show_actionData.self_id = actionData.target_id
    show_actionData.skill_id = 60032
    self.syncaction = SyncSupporter.New(brocastCtx)
    -- BaseUtils.dump(show_actionData, "逆反射")
    if isfeedback then
        self.shoutEffect = ShoutEffect.New(brocastCtx, show_actionData)
        local effectObject = CombatManager.Instance:GetEffectObject(161481)
        local effect = SimpleEffect.New(brocastCtx, actionData, effectObject, self.minoraction)
        local hitaction = HitAction.New(brocastCtx, show_actionData)
        self.syncaction:AddAction(effect)
        self.syncaction:AddAction(self.shoutEffect)
        self.syncaction:AddAction(hitaction)
    end
    self.delayaction = DelayAction.New(brocastCtx, 300)
    self.delayaction:AddEvent(CombatEventType.End, self.syncaction)
    self.syncaction:AddAction(self.attrChgAction)
end

function FeedBackAction:Play()
    self.delayaction:Play()
    -- self.syncaction:Play()
    -- self.attrChgAction:Play()
    if self.actionData.is_target_die == 1 then
        self:InvokeDelay(function() self.deadAction:Play() end, 1.5, self)
    end
end

function FeedBackAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end

function FeedBackAction:OnTargetDead()

end