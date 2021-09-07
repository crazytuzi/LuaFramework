-- 保护
ProtectAction = ProtectAction or BaseClass(CombatBaseAction)

function ProtectAction:__init(brocastCtx, actionData)
    self.actionData = actionData
    self.attackCtrl = self:FindFighter(actionData.self_id)
    self.targetCtrl = self:FindFighter(actionData.target_id)
    self.firstAction = nil
    if self.actionData.action_type == 1 then
        local faceTo = FaceToAction.New(self.brocastCtx, self.attackCtrl, self.targetCtrl.originFaceToPos)
        local shoutEffect = ShoutEffect.New(self.brocastCtx, actionData)
        local action = ProtectDefenseAction.New(self.brocastCtx, actionData)
        local attrchange = AttrChangeEffect.New(brocastCtx, actionData.self_changes, actionData.self_id, actionData.is_crit, 1, true)

        faceTo:AddEvent(CombatEventType.End, action)
        faceTo:AddEvent(CombatEventType.End , shoutEffect)
        action:AddEvent(CombatEventType.End, self.OnActionEnd, self)
        action:AddEvent(CombatEventType.End, attrchange)
        self.firstAction = faceTo
    else
        local action = ProtectDefenseAction.New(self.brocastCtx, actionData)
        local attrchange = AttrChangeEffect.New(brocastCtx, actionData.self_changes, actionData.self_id, actionData.is_crit, 1, true)
        action:AddEvent(CombatEventType.End, self.OnActionEnd, self)
        action:AddEvent(CombatEventType.End, attrchange)
        self.firstAction = action
    end
end

function ProtectAction:Play()
    self.firstAction:Play()
end

function ProtectAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end

function ProtectAction.AddProtectAction(brocastCtx, beforesync, syncAction, protectData, IsMove)
    local proAtkCtrl = brocastCtx:FindFighter(protectData.self_id)
    local proTargetCtrl = brocastCtx:FindFighter(protectData.target_id)
    if not IsMove and protectData.action_type == 1 then
        -- local move = GoToAction.New(brocastCtx, proAtkCtrl, CombatUtil.GetBehindPoint(proTargetCtrl, -0.2))
        local move = MoveAction.New(brocastCtx, protectData, MoveType.ToTargetOrg)
        beforesync:AddAction(move)
    end
    local protect = ProtectAction.New(brocastCtx, protectData)
    syncAction:AddAction(protect)
    return protect
end

function ProtectAction.MoveBack(brocastCtx, protectData, lastProtect)
    local proAtkCtrl = brocastCtx:FindFighter(protectData.self_id)
    -- local move = GoToAction.New(brocastCtx, proAtkCtrl, proAtkCtrl.originPos)
    if protectData.is_self_die == 1 then
        if protectData.is_self_die_disappear == 1 then
            local die_fly = DeadFlyAction.New(brocastCtx, protectData.self_id)
            lastProtect:AddEvent(CombatEventType.End, die_fly)
        else
            local die = DeadAction.New(brocastCtx, protectData.self_id)
            lastProtect:AddEvent(CombatEventType.End, die)
        end
    else
        local move = MoveAction.New(brocastCtx, protectData, MoveType.ToSelf)
        local faceTo = FaceToAction.New(brocastCtx, proAtkCtrl, proAtkCtrl.originFaceToPos)
        lastProtect:AddEvent(CombatEventType.End, move)
        lastProtect:AddEvent(CombatEventType.End, faceTo)
    end
end

-- 保护防御动作
ProtectDefenseAction = ProtectDefenseAction or BaseClass(CombatBaseAction)

function ProtectDefenseAction:__init(brocastCtx, actionData)
    self.actionData = actionData
    self.defense = self:FindFighter(actionData.self_id)
end

function ProtectDefenseAction:Play()
    if self.actionData.action_type == 1 then
        self.defense:PlayAction(FighterAction.Defense)
    end
    self:InvokeDelay(self.OnActionEnd, 0.8, self)
end

function ProtectDefenseAction:OnActionEnd()
    local endAction = nil
    if self.actionData.is_target_die == 1 then
        endAction = DeadAction.New(self.brocastCtx, self.defense.fighterData.id)
    else
        endAction = BattleStandAction.New(self.brocastCtx, self.defense)
    end
    endAction:Play()
    self:InvokeAndClear(CombatEventType.End)
end
