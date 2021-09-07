-- 喊招
ShoutEffect = ShoutEffect or BaseClass(CombatBaseAction)

function ShoutEffect:__init(brocastCtx, actionData)
    self.actionData = actionData
    self.mixPanel = brocastCtx.controller.mainPanel.mixPanel
    -- self.assetWrapper = CombatManager.Instance.assetWrapper
    self.skill = brocastCtx.combatMgr:GetCombatSkillObject(actionData.skill_id, actionData.skill_lev)
    self.action = nil
    self.skillShout = nil
    self.self_Ctr = nil
    self.shoutType = 1
    self.notcycle = true
    self:Parse()
end

function ShoutEffect:Parse()
    local skill = self.skill
    if (not table.containValue(CombatUtil.specialList, self.actionData.skill_id)) and skill ~= nil and self.skill.is_shout == 1 then
        local skillShout = nil
        if skill.shout_id > 0 then
            local sprite = CombatManager.Instance.assetWrapper:GetSprite(AssetConfig.skill_shout, tostring(skill.shout_id))
            if sprite ~= nil then
                -- skillShout = CombatManager.Instance.objPool:Pop("skillShoutImage")
                if skillShout == nil then
                    skillShout = GameObject.Instantiate(self.mixPanel.skillShoutImage)
                end
                self.skillShout = skillShout
                skillShout.transform:SetParent(self.mixPanel.NumStrCanvas)
                skillShout.transform.localScale = Vector3(1, 1, 1)
                local img = skillShout.transform:FindChild("ShoutImage").gameObject:GetComponent(Image)
                img.sprite = sprite
                img:SetNativeSize()
                local fighterCtrl = self:FindFighter(self.actionData.self_id)
                self.self_Ctr = fighterCtrl
                if fighterCtrl ~= nil then
                    fighterCtrl:SetSkillShoutPosition(skillShout)
                end
                skillShout:SetActive(false)
            end
        end

        if skillShout == nil and skill ~= nil and self.actionData.action_type ~= 9 then
            self.shoutType = 2
            -- skillShout = CombatManager.Instance.objPool:Pop("shoutTextPanel")
            if skillShout == nil then
                skillShout = GameObject.Instantiate(self.mixPanel.shoutTextPanel)
            end
            self.skillShout = skillShout
            skillShout.transform:SetParent(self.mixPanel.NumStrCanvas)
            skillShout.transform.localScale = Vector3(1, 1, 1)
            skillShout.transform:FindChild("Text"):GetComponent(Text).text = skill.name
            local fighterCtrl = self:FindFighter(self.actionData.self_id)
            self.self_Ctr = fighterCtrl
            if fighterCtrl ~= nil then
                fighterCtrl:SetSkillShoutPosition(skillShout)
            end
            skillShout:SetActive(false)
        end

        if skillShout ~= nil then
            local comboAction = UIComboEffect.New(self.brocastCtx, skillShout)
            local scale1 = UIScaleEffect.New(self.brocastCtx, skillShout, Vector3(0.4, 0.4, 0.4), 0.01)
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
            local move2 = UIMoveEffect.New(self.brocastCtx, skillShout, UIMoveDir.Lef, 70, 0.8)
            local fade = UIFadeEffect.New(self.brocastCtx, skillShout, 0, 0.75)
            sync:AddAction(move2)
            sync:AddAction(fade)
            -- move:AddEvent(CombatEventType.End, sync)
            move2:AddEvent(
                CombatEventType.End,
                function()
                    self:Recycle()
                end
            )
            self.action = comboAction
        end
    end
end

function ShoutEffect:Play()
    self:InvokeDelay(self.OnActionEnd, 0.2, self)
    if self.skillShout ~= nil and self.self_Ctr ~= nil then
        self.self_Ctr:SetSkillShoutPosition(self.skillShout)
    end
    if self.action ~= nil then
        self.action:Play()
    end
end

function ShoutEffect:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end

function ShoutEffect:Recycle()
    if self.skillShout == nil then
        return
    end
    -- if self.shoutType == 1 and self.notcycle then
    --     self.skillShout.transform:FindChild("ShoutImage").gameObject:GetComponent(Image).sprite = nil
    --     self.skillShout.transform:FindChild("ShoutImage").gameObject:GetComponent(Image).color = Color.white
    --     CombatManager.Instance.objPool:Push(self.skillShout, "skillShoutImage")
    --     self.notcycle = false
    -- elseif self.notcycle then
    --     self.skillShout.transform:GetComponent(Image).color = Color.white
    --     CombatManager.Instance.objPool:Push(self.skillShout, "shoutTextPanel")
    --     self.notcycle = false
    -- end
    GameObject.DestroyImmediate(self.skillShout)
end
