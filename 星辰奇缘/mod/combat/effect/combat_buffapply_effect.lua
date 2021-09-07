-- buff添加成功或者失败飘字
BuffApplyEffect = BuffApplyEffect or BaseClass(CombatBaseAction)

function BuffApplyEffect:__init(brocastCtx, buffPlayData)
    self.buffPlayData = buffPlayData
    self.targetCtrl = self:FindFighter(self.buffPlayData.target_id)
    self.buffbaseData = DataSkillBuff.data_skill_buff[buffPlayData.buff_id]
    self.mixPanel = self.brocastCtx.controller.mainPanel.mixPanel

    self.syncAction = SyncSupporter.New(brocastCtx)
    self.syncAction:AddEvent(CombatEventType.End, self.OnActionEnd, self)
    self.syncAction.spanTime = 0.3

    self:Parse()
end

function BuffApplyEffect:Parse()
    if self.targetCtrl == nil then
        return
    end
    local baseDesc = self.buffbaseData.add_desc
    local efflist = {}
    if self.buffPlayData.is_hit == 1 then
        local EffectText = nil
        -- local flag = nil
        local desc = nil
        -- if baseDesc ~= "" then
        --     flag = string.sub(baseDesc, 1, 1)
        --     desc = string.sub(baseDesc, 2, -1)
        -- end
        for i,v in ipairs(baseDesc) do
            desc = v.desc
            if v.type == 0 then
                -- EffectText = CombatManager.Instance.objPool:Pop("DeBuffEffectImage")
                if EffectText == nil then
                    EffectText = GameObject.Instantiate(self.mixPanel.DeBuffEffectImage)
                end
                EffectText:SetActive(false)
                EffectText.transform:Find("Text"):GetComponent(Text).text = desc
                EffectText.transform:SetParent(self.mixPanel.NumStrCanvas)
                EffectText.transform.localScale = Vector3(1, 1, 1)
                self.targetCtrl:SetTopPosition(EffectText, -25-i*20)
                self.buffeffectImg = EffectText
                table.insert(efflist, {go = EffectText, id = "DeBuffEffectImage"} )
            elseif v.type == 1 then
                -- EffectText = CombatManager.Instance.objPool:Pop("BuffEffectImage")
                if EffectText == nil then
                    EffectText = GameObject.Instantiate(self.mixPanel.BuffEffectImage)
                end
                EffectText:SetActive(false)
                EffectText.transform:Find("Text"):GetComponent(Text).text = desc
                EffectText.transform:SetParent(self.mixPanel.NumStrCanvas)
                EffectText.transform.localScale = Vector3(1, 1, 1)
                self.targetCtrl:SetTopPosition(EffectText, -25-i*20)
                self.buffeffectImg = EffectText
                table.insert(efflist, {go = EffectText, id = "BuffEffectImage"} )
            else
                -- EffectText = CombatManager.Instance.objPool:Pop("MissBuffImage")
                if EffectText == nil then
                    EffectText = GameObject.Instantiate(self.mixPanel.MissBuffImage)
                end
                EffectText:SetActive(false)
                EffectText.transform:Find("Text"):GetComponent(Text).text = desc
                EffectText.transform:SetParent(self.mixPanel.NumStrCanvas)
                EffectText.transform.localScale = Vector3(1, 1, 1)
                self.targetCtrl:SetTopPosition(EffectText, -25-i*20)
                self.buffeffectImg = EffectText
                table.insert(efflist, {go = EffectText, id = "MissBuffImage"} )
            end
        end
    else
        local EffectText = nil
        local baseDesc = self.buffbaseData.miss_desc
        if baseDesc ~= "" then
            -- EffectText = CombatManager.Instance.objPool:Pop("MissBuffImage")
            if EffectText == nil then
                EffectText = GameObject.Instantiate(self.mixPanel.MissBuffImage)
            end
            EffectText:SetActive(false)
            EffectText.transform:Find("Text"):GetComponent(Text).text = baseDesc
            EffectText.transform:SetParent(self.mixPanel.NumStrCanvas)
            EffectText.transform.localScale = Vector3(1, 1, 1)
            self.targetCtrl:SetTopPosition(EffectText, -20)
            self.buffeffectImg = EffectText
            table.insert(efflist, {go = EffectText, id = "MissBuffImage"} )
        end
    end
    if self.buffeffectImg ~= nil then
        for i,v in ipairs(efflist) do
            -- if self.buffPlayData.is_hit == 0 then
            local move = UIMoveEffect.New(self.brocastCtx, v.go, UIMoveDir.Up, 50, 1)
            -- end
            local delay = DelayAction.New(self.brocastCtx, 700)
            delay:AddEvent(CombatEventType.End, function()
                    self:OnActionEnd()
                end
            )
            move:AddEvent(CombatEventType.End, function()
                    -- CombatManager.Instance.objPool:Push(v.go, v.id)
                    GameObject.DestroyImmediate(v.go)
                end
            )

            self.syncAction:AddAction(move)
            self.syncAction:AddAction(delay)
        end
    end
end

function BuffApplyEffect:Play()
    if self.buffeffectImg ~= nil then
        self.buffeffectImg:SetActive(true)
    end

    self.syncAction:Play()
    if self.buffeffectImg == nil then
        self:OnActionEnd()
    end
end

function BuffApplyEffect:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end
