-- 漂血
AttrChangeEffect = AttrChangeEffect or BaseClass(CombatBaseAction)

-- IsStep 多段？
function AttrChangeEffect:__init(brocastCtx, changeList, fighterId, isCrit, ratio, IsStep, onlyshow)
    self.fighterId = fighterId
    self.isCrit = isCrit
    self.ratio = ratio
    self.IsStep = IsStep
    self.onlyshow = onlyshow
    self.changeList = {}
    if changeList ~= nil then
        for _, data in ipairs(changeList) do
            if data.change_type == 15 or data.change_val ~= 0 then
                table.insert(self.changeList, data)
            end
        end
    end
    self.syncAction = SyncSupporter.New(brocastCtx)
    self.syncAction:AddEvent(CombatEventType.End, self.OnActionEnd, self)
    self.syncAction.spanTime = 0.3

    self.mixPanel = self.brocastCtx.controller.mainPanel.mixPanel
    self.positionList = {}
    self.rubbish = {}
    self:Parse()
end

function AttrChangeEffect:Parse()
    local fighter = self:FindFighter(self.fighterId)
    if fighter == nil then
        return
    end

    for _, data in ipairs(self.changeList) do
        if data.change_type ~= 3 and data.change_type ~= 9 and data.change_type ~= 10 and data.change_type ~= 12 then
            local prefixList = {}
            -- local parent = CombatManager.Instance.objPool:Pop("AttrChange")
            local parent = nil
            if parent == nil then
                parent = GameObject.Instantiate(self.mixPanel.AttrChange)
            end
            parent.transform:SetParent(self.mixPanel.NumStrCanvas)
            parent.transform.localScale = Vector3(1, 1, 1)
            fighter:SetTopPosition(parent, -20, self.IsStep)
            table.insert(self.positionList, {fighter = fighter, parent = parent})
            parent:SetActive(false)

            local attrChgAction =UIComboEffect.New(self.brocastCtx, parent)
            local endTaper = TaperSupporter.New(self.brocastCtx)

            local prefix = "Num5_"
            local numberImage = ImageSpriteGroup.New(parent, prefix, prefixList, nil)
            endTaper:AddEvent(CombatEventType.End, function()
                    numberImage:Release()
                    for i,v in ipairs(self.rubbish) do
                        GameObject.DestroyImmediate(v)
                    end
                    GameObject.DestroyImmediate(parent)
                    -- CombatManager.Instance.objPool:Push(parent, "AttrChange")
                end
            )
            if data.change_type == 0 then -- 血
                if data.change_val >= 0 then -- 加血
                    if self.isCrit == 1 then
                        local crit = GameObject.Instantiate(self.mixPanel.textImagePanel.transform:FindChild("HealCritImage").gameObject)
                        crit.transform.localScale = Vector3(1, 1, 1)
                        crit:SetActive(true)
                        table.insert(self.rubbish, crit)
                        table.insert(prefixList, crit)
                    end
                    prefix = "Num6_"
                    local plus = numberImage:CreateNum(prefix, "+")
                    plus:SetActive(true)
                    table.insert(prefixList, plus)
                    local move = UIMoveEffect.New(self.brocastCtx, parent, UIMoveDir.Up, 50, 1.5)
                    local fade = UIFadeEffect.New(self.brocastCtx, parent, 0, 1)
                    move:AddEvent(CombatEventType.End, endTaper)
                    fade:AddEvent(CombatEventType.End, endTaper)
                    attrChgAction:AddAction(move)
                    attrChgAction:AddAction(fade)
                else -- 掉血
                    if self.IsStep then
                        prefix = "Num14_"
                    else
                        prefix = "Num5_"
                    end
                    local isCrit = self.isCrit
                    local fighter = self.brocastCtx:FindFighter(self.fighterId)
                    local selfdata = fighter.fighterData
                    -- if selfdata.is_die == 0 and selfdata.hp + data.change_val <= 0 then -- 是否扣血死亡
                    --     local deadAction = nil
                    --     if selfdata.is_die_disappear == 0 then
                    --         deadAction = DeadAction.New(self.brocastCtx, self.fighterId)
                    --     else
                    --         deadAction = DeadFlyAction.New(self.brocastCtx, self.fighterId)
                    --     end
                    --     self.syncAction:AddAction(deadAction)
                    -- end
                    if isCrit == 1 then
                        prefix = "Num8_"
                        local crit = GameObject.Instantiate(self.mixPanel.textImagePanel.transform:FindChild("CritImage").gameObject)
                        crit.transform.localScale = Vector3(1, 1, 1)
                        crit:SetActive(true)
                        table.insert(self.rubbish, crit)
                        table.insert(prefixList, crit)

                        local scale1 = UIScaleEffect.New(self.brocastCtx, parent, Vector3(2.5, 2.5, 2.5), 0)
                        local scale2 = UIScaleEffect.New(self.brocastCtx, parent, Vector3(1, 1, 1), 0.1)
                        local move = UIMoveEffect.New(self.brocastCtx, parent, UIMoveDir.Up, 70, 1.5)
                        local fade = UIFadeEffect.New(self.brocastCtx, parent, 0, 0.8)
                        attrChgAction:AddAwakdAction(scale1)
                        attrChgAction:AddAction(scale2)

                        local delay = DelayAction.New(self.brocastCtx, 100)
                        local delay2 = DelayAction.New(self.brocastCtx, 200)

                        delay2:AddEvent(CombatEventType.End, fade)
                        delay:AddEvent(CombatEventType.End, move)
                        delay:AddEvent(CombatEventType.End, delay2)
                        scale2:AddEvent(CombatEventType.End, delay)

                        attrChgAction:AddEvent(CombatEventType.End, endTaper)
                        fade:AddEvent(CombatEventType.End, endTaper)
                    else
                        local scale1 = UIScaleEffect.New(self.brocastCtx, parent, Vector3(2, 2, 2), 0)
                        local scale2 = UIScaleEffect.New(self.brocastCtx, parent, Vector3(1, 1, 1), 0.1)
                        local move = UIMoveEffect.New(self.brocastCtx, parent, UIMoveDir.Up, 70, 1.5)
                        local fade = UIFadeEffect.New(self.brocastCtx, parent, 0, 0.8)
                        attrChgAction:AddAwakdAction(scale1)
                        attrChgAction:AddAction(scale2)

                        local delay = DelayAction.New(self.brocastCtx, 100)
                        local delay2 = DelayAction.New(self.brocastCtx, 200)
                        delay2:AddEvent(CombatEventType.End, fade)
                        delay:AddEvent(CombatEventType.End, move)
                        delay:AddEvent(CombatEventType.End, delay2)
                        scale2:AddEvent(CombatEventType.End, delay)

                        attrChgAction:AddEvent(CombatEventType.End, endTaper)
                        fade:AddEvent(CombatEventType.End, endTaper)
                    end
                end
            elseif data.change_type == 1 then
                prefix = "Num7_"
                if data.change_val > 0 then
                    local plus = numberImage:CreateNum(prefix, "+")
                    plus:SetActive(true)
                    table.insert(prefixList, plus)
                else
                    local plus = numberImage:CreateNum(prefix, "-")
                    plus:SetActive(true)
                    table.insert(prefixList, plus)
                end
                local move = UIMoveEffect.New(self.brocastCtx, parent, UIMoveDir.Up, 50, 1.5)
                local fade = UIFadeEffect.New(self.brocastCtx, parent, 0, 1.5)
                move:AddEvent(CombatEventType.End, endTaper)
                fade:AddEvent(CombatEventType.End, endTaper)
                attrChgAction:AddAction(move)
                attrChgAction:AddAction(fade)
            elseif data.change_type == 4 and data.change_val > 0 then -- 吸收
                prefix = "Num9_"
                local absorb = GameObject.Instantiate(self.mixPanel.Absorb)
                absorb.transform.localScale = Vector3(1, 1, 1)
                absorb:SetActive(true)
                table.insert(self.rubbish, absorb)
                table.insert(prefixList, absorb)
                local move = UIMoveEffect.New(self.brocastCtx, parent, UIMoveDir.Up, 50, 1)
                local fade = UIFadeEffect.New(self.brocastCtx, parent, 0, 1)
                move:AddEvent(CombatEventType.End, endTaper)
                fade:AddEvent(CombatEventType.End, endTaper)
                attrChgAction:AddAction(move)
                attrChgAction:AddAction(fade)
            elseif data.change_type == 8 then -- 免疫
                prefix = "Num9_"
                data.change_val = nil
                local absorb = GameObject.Instantiate(self.mixPanel.UnUseImage)
                table.insert(self.rubbish, absorb)
                absorb.transform.localScale = Vector3(1, 1, 1)
                absorb:SetActive(true)
                table.insert(prefixList, absorb)
                local move = UIMoveEffect.New(self.brocastCtx, parent, UIMoveDir.Up, 50, 1)
                local fade = UIFadeEffect.New(self.brocastCtx, parent, 0, 1)
                move:AddEvent(CombatEventType.End, endTaper)
                fade:AddEvent(CombatEventType.End, endTaper)
                attrChgAction:AddAction(move)
                attrChgAction:AddAction(fade)
            elseif data.change_type == 11 and data.change_val > 0 then -- 吸收
                prefix = "Num9_"
                local block = GameObject.Instantiate(self.mixPanel.Block)
                block.transform.localScale = Vector3(1, 1, 1)
                block:SetActive(true)
                table.insert(self.rubbish, block)
                table.insert(prefixList, block)
                local move = UIMoveEffect.New(self.brocastCtx, parent, UIMoveDir.Up, 50, 1)
                local fade = UIFadeEffect.New(self.brocastCtx, parent, 0, 1)
                move:AddEvent(CombatEventType.End, endTaper)
                fade:AddEvent(CombatEventType.End, endTaper)
                attrChgAction:AddAction(move)
                attrChgAction:AddAction(fade)
            elseif data.change_type == 13 then
                local tmphp = GameObject.Instantiate(self.mixPanel.textImagePanel.transform:FindChild("TmpHp").gameObject)
                tmphp.transform.localScale = Vector3(1, 1, 1)
                tmphp:SetActive(true)
                -- table.insert(self.rubbish, tmphp)
                table.insert(prefixList, tmphp)
                prefix = "Num9_"
                if data.change_val > 0 then
                    local plus = numberImage:CreateNum(prefix, "+")
                    plus:SetActive(true)
                    table.insert(prefixList, plus)
                else
                    local plus = numberImage:CreateNum(prefix, "-")
                    plus:SetActive(true)
                    table.insert(prefixList, plus)
                end
                parent.transform.localScale = Vector3.one*0.8
                local delay = DelayAction.New(self.brocastCtx, 300)
                local move = UIMoveEffect.New(self.brocastCtx, parent, UIMoveDir.Up, 50, 1.5)
                local fade = UIFadeEffect.New(self.brocastCtx, parent, 0, 1.5)
                move:AddEvent(CombatEventType.End, endTaper)
                fade:AddEvent(CombatEventType.End, endTaper)
                attrChgAction:AddAwakdAction(delay)
                attrChgAction:AddAction(move)
                attrChgAction:AddAction(fade)
            elseif data.change_type == 15 then -- 免伤
                if self.IsStep then
                    prefix = "Num14_"
                else
                    prefix = "Num5_"
                end
                local isCrit = self.isCrit
                local fighter = self.brocastCtx:FindFighter(self.fighterId)
                local selfdata = fighter.fighterData
                -- if selfdata.is_die == 0 and selfdata.hp + data.change_val <= 0 then -- 是否扣血死亡
                --     local deadAction = nil
                --     if selfdata.is_die_disappear == 0 then
                --         deadAction = DeadAction.New(self.brocastCtx, self.fighterId)
                --     else
                --         deadAction = DeadFlyAction.New(self.brocastCtx, self.fighterId)
                --     end
                --     self.syncAction:AddAction(deadAction)
                -- end
                if isCrit == 1 then
                    prefix = "Num8_"
                    local crit = GameObject.Instantiate(self.mixPanel.textImagePanel.transform:FindChild("CritImage").gameObject)
                    crit.transform.localScale = Vector3(1, 1, 1)
                    crit:SetActive(true)
                    table.insert(self.rubbish, crit)
                    table.insert(prefixList, crit)

                    local scale1 = UIScaleEffect.New(self.brocastCtx, parent, Vector3(2.5, 2.5, 2.5), 0)
                    local scale2 = UIScaleEffect.New(self.brocastCtx, parent, Vector3(1, 1, 1), 0.1)
                    local move = UIMoveEffect.New(self.brocastCtx, parent, UIMoveDir.Up, 70, 1.5)
                    local fade = UIFadeEffect.New(self.brocastCtx, parent, 0, 0.8)
                    attrChgAction:AddAwakdAction(scale1)
                    attrChgAction:AddAction(scale2)

                    local delay = DelayAction.New(self.brocastCtx, 100)
                    local delay2 = DelayAction.New(self.brocastCtx, 200)

                    delay2:AddEvent(CombatEventType.End, fade)
                    delay:AddEvent(CombatEventType.End, move)
                    delay:AddEvent(CombatEventType.End, delay2)
                    scale2:AddEvent(CombatEventType.End, delay)

                    attrChgAction:AddEvent(CombatEventType.End, endTaper)
                    fade:AddEvent(CombatEventType.End, endTaper)
                else
                    local scale1 = UIScaleEffect.New(self.brocastCtx, parent, Vector3(2, 2, 2), 0)
                    local scale2 = UIScaleEffect.New(self.brocastCtx, parent, Vector3(1, 1, 1), 0.1)
                    local move = UIMoveEffect.New(self.brocastCtx, parent, UIMoveDir.Up, 70, 1.5)
                    local fade = UIFadeEffect.New(self.brocastCtx, parent, 0, 0.8)
                    attrChgAction:AddAwakdAction(scale1)
                    attrChgAction:AddAction(scale2)

                    local delay = DelayAction.New(self.brocastCtx, 100)
                    local delay2 = DelayAction.New(self.brocastCtx, 200)
                    delay2:AddEvent(CombatEventType.End, fade)
                    delay:AddEvent(CombatEventType.End, move)
                    delay:AddEvent(CombatEventType.End, delay2)
                    scale2:AddEvent(CombatEventType.End, delay)

                    attrChgAction:AddEvent(CombatEventType.End, endTaper)
                    fade:AddEvent(CombatEventType.End, endTaper)
                end
            end
            numberImage.prefix = prefix
            if data.change_val ~= nil then
                numberImage:SetNum(data.change_val * self.ratio)
            else
                numberImage:SetNum(nil)
            end

            self.syncAction:AddAction(attrChgAction)
        elseif data.change_type == 9 then

        end
    end
    -- self.syncAction:Play()
    -- 更新血条
end

function AttrChangeEffect:Play()
    for _, data in ipairs(self.positionList) do
        data.fighter:SetTopPosition(data.parent, -20, self.IsStep)
    end
    self.syncAction:Play()
    local fighterCtrl = self:FindFighter(self.fighterId)
    if fighterCtrl == nil then
        return
    end
    local fighterData = fighterCtrl.fighterData
    for _, data in ipairs(self.changeList) do
        if data.change_type == 10 then
            fighterCtrl.fighterData.hp_max = data.change_val
            fighterCtrl:UpdateHpBar()
        elseif data.change_type == 13 then
            fighterCtrl.fighterData.tmp_hp_max = fighterCtrl.fighterData.tmp_hp_max + data.change_val
        end
    end
    for _, data in ipairs(self.changeList) do
        if data.change_type == 0 then
            local max = fighterData.hp_max
            local nval = fighterData.hp
            if self.onlyshow ~= true then
                nval = fighterData.hp + data.change_val * self.ratio
            end
            if nval > max then
                nval = max
            elseif nval < 0 then
                nval = 0
            end
            fighterData.hp = nval
            fighterCtrl:UpdateHpBar()
        elseif data.change_type == 9 and self.IsStep ~= true then
            if fighterData.id == self.brocastCtx.controller.selfData.id then
                -- if data.change_val ~= 0 then
                --     print("怒气变化：")
                --     print(data.change_val)
                -- end
                self.brocastCtx.controller.enterData.anger = Mathf.Clamp(data.change_val + self.brocastCtx.controller.enterData.anger, 0, CombatManager.Instance.MaxAnger)
                self.brocastCtx.controller.mainPanel.headInfoPanel:UpdateRoleInfo(self.brocastCtx.controller.selfData)
            end
        elseif data.change_type == 10 then
        elseif data.change_type == 14 then
            if fighterData.id == self.brocastCtx.controller.selfData.id then
                self.brocastCtx.controller.enterData.energy = data.change_val
            end
        end
    end
end

function AttrChangeEffect:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end
