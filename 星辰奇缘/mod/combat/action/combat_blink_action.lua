-- 瞬移
BlinkAction = BlinkAction or BaseClass(CombatBaseAction)

function BlinkAction:__init(brocastCtx, actionData, minoraction, firstAttacker)
    self.actionData = actionData
    self.minoraction = minoraction
    self.firstAttacker = firstAttacker
    self.attacker = self:FindFighter(actionData.self_id)
    self.target = self:FindFighter(actionData.target_id)
    local pointInfo = self:GetAttackSKillEffect(actionData)
    self.distance = 500
    if pointInfo ~= nil then
        self.distance = pointInfo.hit_distance
    end
    self.targetBehindPoint = CombatUtil.GetBehindPoint(self.target, 0 - (self.distance / 1000))
    self.mList = {
         {eventType = CombatEventType.MoveEnd, func = self.OnMoveEnd, owner = self}
    }
    self.targetGroup = targetGroup
end

function BlinkAction:Play()
    if self.attacker.fighterData.type == FighterType.Pet then
        -- self.attacker.animator:Play("2000")
        self.attacker:PlaySkill(2000)

        local effectObject = CombatManager.Instance:GetEffectObject(163311)
        local actionData = { target_id = self.attacker.fighterData.id }
        local effect = SimpleEffect.New(self.brocastCtx, actionData, effectObject, self.minoraction)
        effect:Play()
    end
    local delayaction = DelayAction.New(self.brocastCtx, 300)
    delayaction:AddEvent(CombatEventType.End, self.DoBlink, self)
    delayaction:Play()
end

function BlinkAction:DoBlink()
    local targetPoint = self.targetBehindPoint
    local skill = self.brocastCtx.combatMgr:GetCombatSkillObject(self.actionData.skill_id, self.actionData.skill_lev)
    if CombatUtil.SkillRange(skill) == EffectRange.Group then
        local faceTo = self.brocastCtx.controller.MiddleWestPoint.transform.position
        local oPos = self.brocastCtx.controller.MiddleEastPoint.transform.position
        local layout = FighterLayout.EAST
        if self.target.layout == FighterLayout.WEST then
            faceTo = self.brocastCtx.controller.MiddleEastPoint.transform.position
            oPos = self.brocastCtx.controller.MiddleWestPoint.transform.position
            layout = FighterLayout.WEST
        end
        targetPoint = CombatUtil.GetBehindPoint2(faceTo, oPos, layout, 0 - (self.distance / 1000))
    end
    self.attacker:BlinkTo(targetPoint, self.mList)
end

function BlinkAction:OnMoveEnd()
    self:InvokeAndClear(CombatEventType.MoveEnd)
    self:InvokeAndClear(CombatEventType.End)
end



