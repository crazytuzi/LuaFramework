-- 死亡
DeadAction = DeadAction or BaseClass(CombatBaseAction)

function DeadAction:__init(brocastCtx, fighterId)
    self.controller = self:FindFighter(fighterId)
    if self.controller == nil then
        return
    end
    self.controller.fighterData.is_die = 1
    if self.controller ~= nil and islast ~= false then
        local modelid = self.controller:GetModelId()
        local key = 1
        if self.controller.fighterData.type == FighterType.Role or self.controller.fighterData.type == FighterType.Cloner then
            key = BaseUtils.Key(0, self.controller.fighterData.classes, self.controller.fighterData.sex)
        else
            key = BaseUtils.Key(modelid, 0, 0)
        end
        local data = DataSkillSound.data_skill_sound_hit[key]
        if data ~= nil then
            self.soundaction = SoundAction.New(self.brocastCtx, data)
        end
    end
end

function DeadAction:Play()
    if self.controller == nil then
        self:InvokeDelay(self.OnActionEnd, 0.2, self)
        return
    end
    if self.soundaction ~= nil then
        self.soundaction:Play()
    end
    -- self.controller:DestroyTalkBubble()
    self.controller:DoShake(false)
    self.controller:PlayAction(FighterAction.Dead)
    self.controller:HideBloodBar()
    self.controller:SetAlpha(0.5)
    self.controller:HideWing()
    if self.controller.fighterData ~= nil then
        self.controller.fighterData.is_die = 1
    end
    self:InvokeDelay(self.OnActionEnd, 0.2, self)
end

function DeadAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end


