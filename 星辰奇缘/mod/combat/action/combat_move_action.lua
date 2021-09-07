-- 移动
MoveAction = MoveAction or BaseClass(CombatBaseAction)

function MoveAction:__init(brocastCtx, actionData, moveType)
    self.actionData = actionData
    self.moveType = moveType
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

function MoveAction:Play()
    if self.moveType == MoveType.ToTarget then
        local targetPoint = self.targetBehindPoint
        local skill = self.brocastCtx.combatMgr:GetCombatSkillObject(self.actionData.skill_id, self.actionData.skill_lev)
        if CombatUtil.SkillRange(skill) == EffectRange.Group and self.actionData.skill_id ~= 60096 and self.actionData.skill_id ~= 69504 and self.actionData.skill_id ~= 120427 then  --(对60096这个神兽和69504这个圣堂技能特殊处理哎。。。)
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
        self.attacker:MoveTo(targetPoint, self.mList)
    elseif self.moveType == MoveType.ToTargetOrg then
        self.attacker:MoveTo(self.target.originPos, self.mList)
    elseif self.moveType == MoveType.ToSelf then
        self.attacker:FaceTo(self.attacker.originPos)
        self.attacker:MoveTo(self.attacker.originPos, self.mList)
    elseif self.moveType == MoveType.TargetToSelf then
        self.target:FaceTo(self.target.originPos)
        self.target:MoveTo(self.target.originPos, self.mList)
    elseif self.moveType == MoveType.BlinkToTarget then
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
end

function MoveAction:OnMoveEnd()
    if self.moveType == MoveType.ToSelf then
        self.attacker:FaceTo(self.attacker.originFaceToPos)
    elseif self.moveType == MoveType.TargetToSelf then
        self.target:FaceTo(self.target.originFaceToPos)
    end
    self:InvokeAndClear(CombatEventType.MoveEnd)
    self:InvokeAndClear(CombatEventType.End)
end



