-- 受击
HitAction = HitAction or BaseClass(CombatBaseAction)

function HitAction:__init(brocastCtx, actionData, islast)
    self.actionData = actionData
    self.targetCtrl = self:FindFighter(actionData.target_id)

    self.isFianl = true

    -- 受击后退
    self.hitBack = true
    self.hitTime = 0
    self.pointInfo = self:GetAttackSKillEffect(actionData)
    if self.pointInfo ~= nil then
        if self.pointInfo.hit_back == 0  then
            self.hitBack = false
        end
        self.hitTime = self.pointInfo.hit_time
    end
    -- if self.targetCtrl ~= nil and islast ~= false then
    --     local modelid = self.targetCtrl:GetModelId()
    --     local key = 1
    --     if self.targetCtrl.fighterData.type == FighterType.Role or self.targetCtrl.fighterData.type == FighterType.Cloner then
    --         key = BaseUtils.Key(0, self.targetCtrl.fighterData.classes, self.targetCtrl.fighterData.sex)
    --     else
    --         key = BaseUtils.Key(modelid, 0, 0)
    --     end
    --     local data = DataSkillSound.data_skill_sound_hit[key]
    --     if data ~= nil then
    --         self.soundaction = SoundAction.New(self.brocastCtx, data)
    --     end
    -- end
end

function HitAction:Play()
    if self.soundaction ~= nil then
        self.soundaction:Play()
    end
    if self.targetCtrl == nil or BaseUtils.isnull(self.targetCtrl.tpose) then
        return self:OnEnd()
    else
        self.target = self.targetCtrl.transform
        self.targetTpose = self.targetCtrl.tpose
    end
    self.origin = self.targetTpose.localPosition
    self.movePoint = CombatUtil.GetBehindPointCur(self.targetCtrl, 0.3)
    self.IsHitMove = false
    self.firstAction = nil
    if self.hitBack then
        if self.hitTime == 0 then
            self.IsHitMove = true
            if self:IsTargetDieDiappear() then
                self.firstAction = DelayAction.New(self.brocastCtx, 200)
            else
                self.firstAction = DelayAction.New(self.brocastCtx, 300)
            end
            self.firstAction:AddEvent(CombatEventType.End, self.OnEnd, self)
        else
            local gotom = GoToAction.New(self.brocastCtx, self.targetCtrl, self.movePoint)
            -- local gotoback = GoToAction.New(self.brocastCtx, self.targetCtrl, self.targetCtrl.originPos)
            local delay = DelayAction.New(self.brocastCtx, self.hitTime)
            gotom:AddEvent(CombatEventType.End, delay)
            delay:AddEvent(CombatEventType.End, self.OnEnd, self)
            if not self:IsTargetDieDiappear() then
                local gotoback = MoveAction.New(self.brocastCtx, self.actionData, MoveType.TargetToSelf)
                delay:AddEvent(CombatEventType.End, gotoback)
            end
            self.firstAction = gotom
        end
    else
        local delay = DelayAction.New(self.brocastCtx, self.hitTime)
        delay:AddEvent(CombatEventType.End, self.OnEnd, self)
        self.firstAction = delay
    end


    self.targetCtrl:PlayAction(FighterAction.Hit)
    if self.IsHitMove then
        local queue = {
            "keyframe"
            ,"keyframe"
            ,"keyframe"
            ,"keyframe"
            ,"keyframe"
            ,"keyframe"
            ,"keyframe"
            ,"keyframe"
            ,"keyframe"
            ,"keyframe"
            ,"keyframe"
            ,"keyframe"
        }
        self.targetCtrl:SetHitQueue(queue)
    end
    self.firstAction:Play()
end

function HitAction:OnEnd()
    if self:IsTargetDieDiappear() or self.targetCtrl == nil or BaseUtils.isnull(self.targetCtrl.tpose) then
        self:OnActionEnd()
    else
        if self.isFianl then
            self.targetCtrl = self:FindFighter(self.actionData.target_id)
            if not BaseUtils.isnull(self.targetCtrl.transform) then
                self.targetTpose = self.targetCtrl.tpose
                self.targetTpose.localPosition = self.origin
            else
                Log.Debug("HitAction，Line:95,找不到targetCtr")
            end
        end
        self:InvokeDelay(self.OnActionEnd, 0.03, self)
    end
end

function HitAction:OnActionEnd()
    if self.actionData.is_target_die == 1 and self.isFianl then
        if not self:IsAttackSelf() and self.actionData.is_target_die_disappear == 1 and self:CanDeadFly(self.actionData.sub_order, self.actionData.target_id) then
            local deadFlyAction = DeadFlyAction.New(self.brocastCtx, self.actionData.target_id)
            deadFlyAction:Play()
        else
            local deadAction = DeadAction.New(self.brocastCtx, self.actionData.target_id)
            deadAction:Play()
        end
    else
        self.targetCtrl:PlayAction(FighterAction.BattleStand)
    end
    if self.actionData.is_self_die == 1 and self.isFianl then
        if self.actionData.is_target_die_disappear == 1 then
            local deadFlyAction = DeadFlyAction.New(self.brocastCtx, self.actionData.self_id)
            deadFlyAction:Play()
        else
            local deadAction = DeadAction.New(self.brocastCtx, self.actionData.self_id)
            deadAction:Play()
        end
    end
    self:InvokeAndClear(CombatEventType.End)
end

function HitAction:ChainEvent(time, pos)
    local delay = DelayAction.New(self.brocastCtx, time)
    local gotoAction = GoToAction.New(self.brocastCtx, self.targetCtrl, pos)
    delay:AddEvent(CombatEventType.End, gotoAction)
    return delay
end

function HitAction:IsTargetDieDiappear()
    if self.actionData.is_target_die == 1 and self.actionData.is_target_die_disappear == 1 and self.isFianl then
        return true
    else
        return false
    end
end

function HitAction:CanDeadFly(subOrder, fighterId)
    if self.brocastCtx.majorCtx == nil then
        return false
    end
    local list = self.brocastCtx.majorCtx.groupList
    for _, dataList in ipairs(list) do
        for _, data in ipairs(dataList) do
            if data.sub_order > subOrder then
                if data.self_id == fighterId or data.target_id == fighterId then
                    return false
                end
            end
        end
    end
    return true
end

function HitAction:IsAttackSelf()
    if self.actionData.target_id == self.actionData.self_id then
        return true
    else
        return false
    end
end