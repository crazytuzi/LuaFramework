-- 被动技能
CombatPassiveSkillAction = CombatPassiveSkillAction or BaseClass(CombatBaseAction)

function CombatPassiveSkillAction:__init(brocastCtx, passiveData, minor, firstAttacker)
    self.minorAction = minor
    self.passiveData = passiveData
    self.mixPanel = brocastCtx.controller.mainPanel.mixPanel
    self.figher = self:FindFighter(passiveData.id)
    self.skillData = CombatManager.Instance:GetCombatSkillObject(passiveData.skill_id, 1)
    self.shoutIndex = 0

    self.syncAction = SyncSupporter.New(brocastCtx)
    self.syncAction:AddEvent(CombatEventType.End, self.OnActionEnd, self)
    self.effect = {}
    local EffectList = CombatManager.Instance:GetSkillEffectList(self.passiveData.skill_id, 0)
    if EffectList == nil then
        EffectList = {}
    end
    for _,v in pairs(EffectList) do
        local effectData = DataEffect.data_effect[v.effect_id]
        local effectPath = CombatUtil.CheckSubpackEffect(effectData.res_id, self.minorAction.subpkgEffectDict)
        self.minorAction.resourceLoader:AddResPath({effectPath})
        local targetPoint = self.minorAction:GetEffectTarget(self.minorAction.firstAction, v)
        local effectAction = EffectFactory.CreateGeneral(brocastCtx, self.minorAction, passiveData, firstAttacker.transform.gameObject, targetPoint, v, effectData)
        self.syncAction:AddAction(effectAction)
    end

end

function CombatPassiveSkillAction:Parse()
    if BaseUtils.isnull(self.mixPanel.PassiveSkillPanel) then
        return
    end
    if self.skillData ~= nil then
        if self.skillData.is_showname == 1 then
            -- local skillShout = CombatManager.Instance.objPool:Pop("PassiveSkillPanel")
            local skillShout = nil
            if skillShout == nil then
                skillShout = GameObject.Instantiate(self.mixPanel.PassiveSkillPanel)
            end
            skillShout.transform:Find("BG"):GetComponent(Image).color = Color.white
            skillShout.transform:SetParent(self.mixPanel.NumStrCanvas)
            skillShout.transform.localScale = Vector3(1, 1, 1)
            skillShout.transform:FindChild("Text"):GetComponent(Text).text = self.skillData.name
            self.figher:SetSkillShoutPosition(skillShout)
            skillShout:SetActive(false)

            local comboAction = UIComboEffect.New(self.brocastCtx, skillShout)
            local scale1 = UIScaleEffect.New(self.brocastCtx, skillShout, Vector3(0.4, 0.4, 0.4), 0)
            comboAction:AddAwakdAction(scale1)
            local scale2 = UIScaleEffect.New(self.brocastCtx, skillShout, Vector3(1.5, 1.5, 1.5), 0.25)
            comboAction:AddAction(scale2)
            local scale3 = UIScaleEffect.New(self.brocastCtx, skillShout, Vector3(1, 1, 1), 0.15)
            scale2:AddEvent(CombatEventType.End, scale3)
            local delay = DelayAction.New(self.brocastCtx, 200)
            scale3:AddEvent(CombatEventType.End,  delay)
            --local move = UIMoveEffect.New(self.brocastCtx, skillShout, UIMoveDir.Lef, 35, 0.1)
            local sync = SyncSupporter.New(self.brocastCtx)
            delay:AddEvent(CombatEventType.End, sync)
            -- local move2 = UIMoveEffect.New(self.brocastCtx, skillShout, UIMoveDir.Lef, 70, 0.8)
            local fade = UIFadeEffect.New(self.brocastCtx, skillShout, 0, 0.75)

            sync:AddAction(move2)
            sync:AddAction(fade)

            fade:AddEvent(CombatEventType.End, function() GameObject.DestroyImmediate(skillShout) end)

            if self.shoutIndex > 0 then
                local pos = skillShout.transform.localPosition
                skillShout.transform.localPosition = pos + Vector3(10 * self.shoutIndex, 20 * self.shoutIndex, 0)

                local delay = DelayAction.New(self.brocastCtx, 100 * self.shoutIndex)
                delay:AddEvent(CombatEventType.End, comboAction)
                self.syncAction:AddAction(delay)
            else
                self.syncAction:AddAction(comboAction)    
            end
        end

        local key = CombatUtil.Key(self.skillData.id, 0)
        local effectDataList = DataSkillEffect.skill_effectData[key]
        if effectDataList ~= nil then
            local shakeMark = false
            for index, value in ipairs(effectDataList) do
                if value.shake == 1 then
                    shakeMark = true
                    break
                end
            end

            if shakeMark then
                self.syncAction:AddAction(ShakeCameraAction.New(self.brocastCtx, CombatShakeType.Normal))
            end
        end
    end
end

function CombatPassiveSkillAction:SetShoutIndex(index)
    if BaseUtils.isnull(self.mixPanel.PassiveSkillPanel) then
        return
    end
    if self.skillData ~= nil then
        if self.skillData.is_showname == 1 then
            self.shoutIndex = index
            index = index + 1
        end
    end
    return index
end

function CombatPassiveSkillAction:Play()
    if BaseUtils.isnull(self.mixPanel.PassiveSkillPanel) then
        self:OnActionEnd()
        return
    end
    self:Parse()
    self.syncAction:Play()
end

function CombatPassiveSkillAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end
