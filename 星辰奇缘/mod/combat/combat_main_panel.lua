-- 战斗UI逻辑
-- 2016-5-24 怒气技能扩充 huangzefeng
CombatMainPanel = CombatMainPanel or BaseClass()

function CombatMainPanel:__init()
    self.combatMgr = CombatManager.Instance
    -- self.combatMgr.assetWrapper = self.combatMgr.assetWrapper
    self.gameObject = nil
    self.transform = nil

    self.controller = nil
    self.skillareaPanel = nil
    self.headInfoPanel = nil
    self.counterInfoPanel = nil
    self.mixPanel = nil
    self.functionIconPanel = nil
    self.extendPanel = nil
    self.selectSkillId = 0
    self.selectList = {}
    self.commandList = {}
    self.selectID = nil

    self.isAutoFighting = false
    self.isWatching = self.combatMgr.isWatching
    self.IsSelectingSkill = false
    self.round = 0
    self.InitFinish = false

    self.buffDetailList = {}

    self.selectState = CombatSeletedState.Idel

    self.waittime = {begintime = 0, waittime = 0}
    self.autoaction = nil
    self.RguideAction = {}
    self.PguideAction = {}

    self.currSelectItem = nil
    self.ColorAlpha1 = Color(1,1,1,1)
    self.ColorAlpha0 = Color(1,1,1,0)
    self.HoldTag = false
    self.HoldTime = 0
    self.lastSkillSelectData = nil
end

function CombatMainPanel:__delete()
    GameObject.DestroyImmediate(self.gameObject)
    self.skillareaPanel:DeleteMe()
    self.headInfoPanel:DeleteMe()
    self.counterInfoPanel:DeleteMe()
    self.mixPanel:DeleteMe()
    self.functionIconPanel:DeleteMe()
    self.extendPanel:DeleteMe()
    -- self.guidePanel:DeleteMe()
    self.skillareaPanel = nil
    self.headInfoPanel = nil
    self.counterInfoPanel = nil
    self.mixPanel = nil
    self.functionIconPanel = nil
    self.extendPanel = nil
end

function CombatMainPanel:Hide()
    if self.skillareaPanel ~= nil then
        self.skillareaPanel:DeleteMe()
    end
    self.skillareaPanel = nil
    if self.headInfoPanel ~= nil then
        self.headInfoPanel.transform.anchoredPosition = Vector2(0, -1000)
    end
    if self.counterInfoPanel ~= nil then
        self.counterInfoPanel.transform.anchoredPosition = Vector2(0, -1000)
    end
    if self.mixPanel ~= nil then
        self.mixPanel.transform.anchoredPosition = Vector2(0, -1000)
        if self.mixPanel.watchSkillItem ~= nil then
            self.mixPanel.watchSkillItem:Hide()
        end
        if self.mixPanel.watchRewardItemPanel ~= nil then
            self.mixPanel.watchRewardItemPanel:Hide()
        end
    end
    if self.functionIconPanel ~= nil then
        self.functionIconPanel.transform.anchoredPosition = Vector2(0, -1000)
        self.functionIconPanel:Hide()
    end
    if self.extendPanel ~= nil then
        self.extendPanel.transform.anchoredPosition = Vector2(0, -1000)
    end
    if self.transform ~= nil then
        self.transform.anchoredPosition = Vector2(0, -1000)
    end
    -- self.counterInfoPanel:Hide()
    -- self.mixPanel:Hide()
    -- self.extendPanel:Hide()
    self.InitFinish = false
end

function CombatMainPanel:Show()
    self.commandList = {}
    self.selectList = {}
    self.isWatching = self.combatMgr.isWatching
    self.skillareaPanel = CombatSkilareaPanel.New(self.controller.skillareaPath, self)
    -- self.skillareaPanel.transform:SetSiblingIndex(2)
    self.functionIconPanel:Show()
    self.extendPanel:Show()
    self.counterInfoPanel:Show()
    self.mixPanel:Show()
    self.headInfoPanel:Show()
    self.headInfoPanel.transform.anchoredPosition = Vector2.zero
    self.counterInfoPanel.transform.anchoredPosition = Vector2.zero
    self.mixPanel.transform.anchoredPosition = Vector2.zero
    self.functionIconPanel.transform.anchoredPosition = Vector2.zero
    self.extendPanel.transform.anchoredPosition = Vector2.zero
    self.transform.anchoredPosition = Vector2.zero
    self.InitFinish = true
end

function CombatMainPanel:OnUiLoadedCompleted()
    if self.gameObject == nil then
        self:InitPanel()
    else
        self:Show()
    end
end

function CombatMainPanel:InitPanel()
    if self.gameObject == nil then
        self.gameObject = GameObject.Instantiate(self.combatMgr.assetWrapper:GetMainAsset(self.controller.mainPanelPath))
        self.transform = self.gameObject.transform
        self.combatMgr = CombatManager.Instance
        UIUtils.AddUIChild(self.combatMgr.combatCanvas, self.gameObject)
        self.mixPanel = CombatMixPanel.New(self.controller.mixareaPath, self)
        self.counterInfoPanel = CombatCounterinfoPanel.New(self.controller.counterinfoareaPath, self)
        self.functionIconPanel = CombatFunctionIconPanel.New(self.controller.functioniconPath, self)
        self.skillareaPanel = CombatSkilareaPanel.New(self.controller.skillareaPath, self)
        self.headInfoPanel = CombatHeadinfoPanel.New(self.controller.headinfoareaPath, self)
        self.extendPanel = CombatExtendPanel.New(self.controller.extendPath, self)

        self.extendPanel.transform:SetAsFirstSibling()
        self.counterInfoPanel.transform:SetAsFirstSibling()
        self.headInfoPanel.transform:SetAsFirstSibling()
        -- self.skillareaPanel.transform:SetAsFirstSibling()
        self.functionIconPanel.transform:SetAsFirstSibling()
        self.mixPanel.transform:SetAsFirstSibling()
    end
    self.InitFinish = true
end


-- 播报
function CombatMainPanel:OnFighting10720(data)
    self.selectState = CombatSeletedState.Idel
    if not BaseUtils.is_null(self.controller.teamquestPanel) then
        self.controller.teamquestPanel:SetActive(true)
    end
    self.counterInfoPanel:StopCountDown()
    self.functionIconPanel.SummonPanel:OnCloseBtnClick()
    self.functionIconPanel.ItemPanel:OnCloseBtnClick()
    self.waittime.waittime = 0
    self.counterInfoPanel:SetRound(data.round)
    self.round = data.round

    self.combatMgr.OnDanmakuPoolChange:Fire()
end

-- 开始选招10731
function CombatMainPanel:OnBeginFighting(data)

    if not self.combatMgr.isBrocasting then
        EventMgr.Instance:Fire(event_name.begin_fight_round, data.round)
    end

    if self.combatMgr.isBrocasting then
        self.functionIconPanel:HideReslectButton()    --战斗开始后再隐藏返回按钮
        self.controller.brocastCtx:SetEndData(data)
        return
    elseif self.combatMgr.isWatching then
        -- print("观战下个回合")
        self.functionIconPanel:ShowButton("ButtonPanel1", function() end)
        return
    elseif self.combatMgr.isWatchRecorder then
        self.functionIconPanel:ShowButton("ButtonPanel1", function() end)
        self.counterInfoPanel:StartCountDown(data.time)
        LuaTimer.Add(3000, function () self.combatMgr:Send10745() end)
        return
    end
    self.lastSkillSelectData = data
    self.currSelectItem = nil
    self.round = data.round

    self.selectState = CombatSeletedState.Role
    self.waittime.begintime = Time.time
    self.waittime.waittime = data.time
    self.isAutoFighting = self.isAutoFighting
    if not BaseUtils.is_null(self.controller.teamquestPanel) then
        self.controller.teamquestPanel:SetActive(self.isAutoFighting)
    end
    if (self.round == 1 or data.combat_result == 2) and self.combatMgr.isAutoFighting then
        LuaTimer.Add(3000, function ()
            if self.isAutoFighting and data.combat_result == 2 then
                self.combatMgr:Send10731(1)
            elseif self.isAutoFighting then
                self.combatMgr:Send10731(data.round)
            end
        end)
        self.isAutoFighting = true
    end
    if self.controller.enterData.guide == 100 then
        -- 第一场战斗不要倒计时直接开打
        data.time = 0
    end

    if not self.isAutoFighting then
        self.skillareaPanel:ShowPanel("Role", function() end)
        self.functionIconPanel:HideButton("Pet", function() end)
        self.functionIconPanel:ShowButton("Role", function() end)
        self.counterInfoPanel:StartCountDown(data.time)
        -- self:DealGuideAction(data, self.controller.enterData.guide)
        self:DealGuideAction(data, self.controller.enterData.guide)
    elseif self.round == 1 and data.combat_result ~= 2 then
        self.skillareaPanel:HidePanel(function() end)
        self.functionIconPanel:HideButton("Pet", function() end)
        self.functionIconPanel:HideButton("Role", function() end)
        self.counterInfoPanel:StartCountDown(data.time)
    else
        LuaTimer.Add(3000, function ()
            if self.isAutoFighting and data.combat_result == 2 then
                self.combatMgr:Send10731(1)
            elseif self.isAutoFighting then
                self.combatMgr:Send10731(data.round)
            end
        end)
        self.counterInfoPanel:StartCountDown(data.time)
    end
    self:DealTalkBubble(self.round)
    self.functionIconPanel:ActiveProcBut()
    self.counterInfoPanel:SetRound(data.round)
    self.skillareaPanel:UpdateSkillCD(data.skill_cooldown_list)
    self.cdList = data.skill_cooldown_list
    self.skillareaPanel:UpdateSkillCD(data.skill_cooldown_list_pet)
    self.skillareaPanel:SetPreSkill(nil)
    self.skillareaPanel:SetPetPreSkill(nil)
    self.skillareaPanel:UpdateSkillMp()

    local eastList = self.controller.eastFighterList
    local westList = self.controller.westFighterList
    self:SetPreparing(true, eastList)
    self:SetPreparing(true, westList)

    -- self.skillareaPanel:OnSkillIconClick(CombatUtil.GetNormalSKill(self.controller.selfData.classes), 1)
    if self.isAutoFighting == false then
        self:OnSkillIconClick(CombatUtil.GetNormalSKill(self.controller.selfData.classes), 1, "UnSelect")
    end

    self.functionIconPanel.SummonPanel:SetData10731(data)
    self.functionIconPanel.ItemPanel:SetData10731(data)
end

function CombatMainPanel:OnSkillIconClick(skillId, skillLev, fromType)
    self:OnBackToControlButtonClick()
    self.IsSelectingSkill = true
    local baseTargetHalo = self.mixPanel.targetHaloButton
    local key = CombatUtil.Key(skillId, skillLev)
    local combatSkill = self.combatMgr:GetCombatSkillObject(skillId, skillLev)
    local eastList = self.controller.eastFighterList
    local westList = self.controller.westFighterList
    local selectList = {}
    -- print(debug.traceback())
    -- BaseUtils.dump(combatSkill, "==============================combatSkill==========================")
    if combatSkill.target_type == SkillTargetType.All then
        for _, combo in ipairs(eastList) do
            if not self:IsDisappear(combo) then
                table.insert(selectList, combo)
            end
        end
        for _, combo in ipairs(westList) do
            if not self:IsDisappear(combo) then
                table.insert(selectList, combo)
            end
        end
    elseif combatSkill.target_type == SkillTargetType.Enemy then
        for _, combo in ipairs(westList) do
            if not self:IsDisappear(combo) then
                table.insert(selectList, combo)
            end
        end
    elseif combatSkill.target_type == SkillTargetType.SelfGroup then
        for _, combo in ipairs(eastList) do
            if not self:IsDisappear(combo) then
                if skillId == 1003 then
                    if fromType == "Role" and combo.fighter ~= self.controller.selfFighter then
                        table.insert(selectList, combo)
                    elseif fromType == "Pet" and combo.fighter ~= self.controller.selfPet then
                        table.insert(selectList, combo)
                    end
                else
                    table.insert(selectList, combo)
                end
            end
        end
    elseif combatSkill.target_type == SkillTargetType.Self then
        if self.controller.selfFighter ~= nil then
            if self.selectState == CombatSeletedState.Pet then
                for _, combo in ipairs(eastList) do
                    if not self:IsDisappear(combo) then
                        if combo.fighterId == self.controller.selfPetData.id then
                            table.insert(selectList, combo)
                        end
                    end
                end
                self.selectSkillId = skillId
                self.selectList = selectList
                self:OnPetHaloButtonClick(self.controller.selfPetData.id, skillId, selectList)
                return
            else
                table.insert(selectList, FighterCombo.New(self.controller.selfData.id, self.controller.selfFighter))
                self.selectSkillId = skillId
                self.selectList = selectList
                self:OnHaloButtonClick(self.controller.selfData.id, skillId, selectList, skillLev)
                return
            end
        end
    elseif combatSkill.target_type == SkillTargetType.SelfGroupNotSelf then
        for _, combo in ipairs(eastList) do
            if not self:IsDisappear(combo) then
                if combo.fighter ~= self.controller.selfFighter then
                    table.insert(selectList, combo)
                end
            end
        end
    elseif combatSkill.target_type == SkillTargetType.Couple then
        for _, combo in ipairs(eastList) do
            if combo.fighterData.rid == RoleManager.Instance.RoleData.lover_id then
                table.insert(selectList, combo)
            end
        end
    elseif combatSkill.target_type == SkillTargetType.None then
        local fighterId = 0
        for _, combo in ipairs(westList) do
            if fighterId == 0 and combo.fighterData.type == 3 and not self:IsDisappear(combo) then
                fighterId = combo.fighterId
            end
        end
        -- self.combatMgr:Send10732(skillId, fighterId, 0)
        self.mixPanel:HidePreSkillImage()
        self:SendRoleSkill(skillId, fighterId, 0)
        return
    elseif combatSkill.target_type == SkillTargetType.EnemyGroupPet then
        for _, combo in ipairs(westList) do
            if not self:IsDisappear(combo) then
                if combo.fighterData ~= nil and combo.fighterData.type == FighterType.Pet then
                    table.insert(selectList, combo)
                end
            end
        end
    elseif combatSkill.target_type == SkillTargetType.SelfGroupPet then
        for _, combo in ipairs(eastList) do
            if not self:IsDisappear(combo) then
                if combo.fighterData ~= nil and combo.fighterData.type == FighterType.Pet then
                    table.insert(selectList, combo)
                end
            end
        end
    end

    self.selectSkillId = skillId
    self.selectList = selectList
    for _, combo in ipairs(selectList) do
        local fighterId = combo.fighterId
        if combo.halo == nil then
            -- local tHalo = CombatManager.Instance.objPool:Pop("baseTargetHalo")
            local tHalo = nil
            if tHalo == nil then
                tHalo = GameObject.Instantiate(baseTargetHalo)
            end
            -- table.insert(self.controller.uiResCacheList, {id = "baseTargetHalo", go = tHalo})
            tHalo.transform:SetParent(self.mixPanel.StaticItemCanvas)
            tHalo.name = "Halo" .. combo.fighter.name
            tHalo:SetActive(true)
            if self.combatMgr.combatType ~= 52 and combo.fighterData ~= nil and combo.fighterData.classes ~= 0 and (combo.fighterData.type == 1 or combo.fighterData.type == 4) then
                tHalo.transform:Find("Text"):GetComponent(Text).text = string.format("%s%s", tostring(combo.fighterData.lev), KvData.classes_name[combo.fighterData.classes])
                tHalo.transform:Find("Text").gameObject:SetActive(true)
            else
                tHalo.transform:Find("Text").gameObject:SetActive(false)
            end
            local fp = combo.fighter.transform.position
            local sp = CombatUtil.WorldToUIPoint(self.controller.combatCamera, fp)
            tHalo.transform.localPosition = Vector3(sp.x, sp.y + 20, 1)
            tHalo.transform.localScale = Vector3(1, 1, 1)
            combo.halo = tHalo
            combo.haloImg = tHalo.transform:GetComponent(Image)
            local fctrl = combo.fighter.transform:GetComponent(LuaBehaviourDownUpBase)
            local fighterController = fctrl:GetClass()
            local cButton = tHalo:GetComponent(CustomButton) or tHalo:AddComponent(CustomButton)
            cButton.onDown:RemoveAllListeners()
            cButton.onUp:RemoveAllListeners()
            cButton.onHold:RemoveAllListeners()
            cButton.onDown:AddListener(function (eventData) fighterController:OnPointerDown(eventData) end)
            cButton.onUp:AddListener(function(eventData) fighterController:OnPointerUp(eventData) end);
            cButton.onHold:AddListener(function() self:OnPointerHold(fighterController.fighterData) end)
            cButton.onClick:RemoveAllListeners()
            if fromType == "Pet" or (fromType == "UnSelect" and skillId == 1000) then
                cButton.onClick:AddListener(function() if self.selectState == CombatSeletedState.Idel or combo.haloImg.color.a == 0  then return end self:OnPetHaloButtonClick(fighterId, skillId, selectList) end)
            else
                cButton.onClick:AddListener(function() if self.selectState == CombatSeletedState.Idel or combo.haloImg.color.a == 0  then return end self:OnHaloButtonClick(fighterId, skillId, selectList, skillLev) end)
            end
            combo.haloImg.color = self.ColorAlpha1
        else
            local tHalo = combo.halo
            local cButton = tHalo:GetComponent(CustomButton) or tHalo:AddComponent(CustomButton)
            cButton.onClick:RemoveAllListeners()
            if fromType == "Pet" or (fromType == "UnSelect" and skillId == 1000) then
                cButton.onClick:AddListener(function() if self.selectState == CombatSeletedState.Idel or combo.haloImg.color.a == 0  then return end self:OnPetHaloButtonClick(fighterId, skillId, selectList) end)
            else
                cButton.onClick:AddListener(function() if self.selectState == CombatSeletedState.Idel or combo.haloImg.color.a == 0  then return end self:OnHaloButtonClick(fighterId, skillId, selectList, skillLev) end)
            end
            combo.halo:SetActive(true)
            combo.haloImg.color = self.ColorAlpha1
        end
    end
    if fromType == "UnSelect" then -- 未选择技能
        self.skillareaPanel.gameObject:SetActive(true)
        self.functionIconPanel:ActiveAll(true)
    else
        self.skillareaPanel.gameObject:SetActive(false)
        self.functionIconPanel:ActiveAll(false)
        self.mixPanel:ShowBackToControlImage(skillId, skillLev, fromType)
        self.extendPanel:HideExtendButton()
    end
end

function CombatMainPanel:OnSkillItemIconClick(itemId)
    self:OnBackToControlButtonClick()
    self.IsSelectingSkill = true
    local baseTargetHalo = self.mixPanel.targetHaloButton
    local eastList = self.controller.eastFighterList
    local westList = self.controller.westFighterList
    local selectList = {}
    local skillId = 1004
    local skillLev = 1
    for _, combo in ipairs(eastList) do
        if not self:IsDisappear(combo) then
            table.insert(selectList, combo)
        end
    end

    self.selectSkillId = 1004
    self.selectList = selectList
    for _, combo in ipairs(selectList) do
        local fighterId = combo.fighterId
        if combo.halo == nil then
            -- local tHalo = CombatManager.Instance.objPool:Pop("baseTargetHalo")
            local tHalo = nil
            if tHalo == nil then
                tHalo = GameObject.Instantiate(baseTargetHalo)
            end
            -- table.insert(self.controller.uiResCacheList, {id = "baseTargetHalo", go = tHalo})
            tHalo.transform:SetParent(self.mixPanel.StaticItemCanvas)
            tHalo.name = "Halo" .. combo.fighter.name
            tHalo:SetActive(true)
            local fp = combo.fighter.transform.position
            local sp = CombatUtil.WorldToUIPoint(self.controller.combatCamera, fp)
            tHalo.transform.localPosition = Vector3(sp.x, sp.y + 58, 1)
            tHalo.transform.localScale = Vector3(1, 1, 1)
            combo.halo = tHalo
            combo.haloImg = tHalo.transform:GetComponent(Image)
            local fctrl = combo.fighter.transform:GetComponent(LuaBehaviourDownUpBase)
            local fighterController = fctrl:GetClass()
            local cButton = tHalo:GetComponent(CustomButton) or tHalo:AddComponent(CustomButton)
            cButton.onDown:RemoveAllListeners()
            cButton.onUp:RemoveAllListeners()
            cButton.onHold:RemoveAllListeners()
            cButton.onDown:AddListener(function (eventData) fighterController:OnPointerDown(eventData) end)
            cButton.onUp:AddListener(function(eventData) fighterController:OnPointerUp(eventData) end);
            cButton.onHold:AddListener(function() self:OnPointerHold(fighterController.fighterData) end)
            cButton.onClick:RemoveAllListeners()
            if self.selectState == CombatSeletedState.Role then
                cButton.onClick:AddListener(function() if self.selectState == CombatSeletedState.Idel or combo.haloImg.color.a == 0  then return end self.currSelectItem = itemId self:OnHaloItemButtonClick(fighterId, skillId, selectList, itemId) end)
            elseif self.selectState == CombatSeletedState.Pet then
                cButton.onClick:AddListener(function() if self.selectState == CombatSeletedState.Idel or combo.haloImg.color.a == 0  then return end self.currSelectItem = itemId self:OnPetHaloItemButtonClick(fighterId, skillId, selectList, itemId) end)
            end
            combo.haloImg.color = self.ColorAlpha1
        else
            local tHalo = combo.halo
            local cButton = tHalo:GetComponent(Button) or tHalo:AddComponent(Button)
            cButton.onClick:RemoveAllListeners()
            if self.selectState == CombatSeletedState.Role then
                cButton.onClick:AddListener(function() if self.selectState == CombatSeletedState.Idel or combo.haloImg.color.a == 0  then return end self.currSelectItem = itemId self:OnHaloItemButtonClick(fighterId, skillId, selectList, itemId) end)
            elseif self.selectState == CombatSeletedState.Pet then
                cButton.onClick:AddListener(function() if self.selectState == CombatSeletedState.Idel or combo.haloImg.color.a == 0  then return end self.currSelectItem = itemId self:OnPetHaloItemButtonClick(fighterId, skillId, selectList, itemId) end)
            end
            combo.halo:SetActive(true)
            combo.haloImg.color = self.ColorAlpha1
        end
    end

    self.skillareaPanel.gameObject:SetActive(false)
    self.functionIconPanel:ActiveAll(false)
    self.mixPanel:ShowBackToControlImage(1004, 1, "Role")
end

function CombatMainPanel:DealGuideAction(data, guide)
    if self.round == 1 and guide == 1001 then
        local selectSkillAction = CombatGuideAction.New(self,{type = "RoleSkill", })
        local selectTargetAction = CombatGuideAction.New(self,{type = "SkillTarget", name = TI18N("林雷"), frometype = "Role", msg = TI18N("选择<color='#ffff00'>攻击目标</color>")})
        selectSkillAction:AddEvent(CombatEventType.End, function() selectTargetAction:Play()  end)
        selectSkillAction:Play()
        table.insert(self.RguideAction, selectSkillAction)
        table.insert(self.RguideAction, selectTargetAction)
    elseif data.guide == 1002 then
        self.autoaction = CombatGuideAction.New(self, {type = "Auto"})
        self.autoaction:Play()
    elseif data.guide == 10004 then
        local action1 = CombatGuideAction.New(self, {type = "Catch"})
        local action2 = CombatGuideAction.New(self, {type = "CancelAuto"})
        table.insert(self.RguideAction, action1)
        table.insert(self.RguideAction, action2)
        action1:Play()
        action2:Play()
    end
end


-- 人物选招
function CombatMainPanel:OnHaloButtonClick(fighterId, skillId, selectList, lev)
    local baseData = DataCombatSkill.data_combat_skill[string.format("%s_%s", tostring(skillId), tostring(lev))]
    local tips = false
    local attr = ""
    local rate = ""
    local skillname = ""
    if baseData ~= nil and baseData.self_cond_cli[1] ~= nil then
        skillname = baseData.name
        -- BaseUtils.dump(baseData.self_cond_cli, "asdsadsdsadsadsa$#$@#$@#$%#@$@")
        if baseData.self_cond_cli[1].self_cond_type == 2 then
            attr = TI18N("生命值")
            rate = tostring(baseData.self_cond_cli[1].self_cond_val/10).."%"
            if baseData.self_cond_cli[1].self_cond_op then
                tips = baseData.self_cond_cli[1].self_cond_val/1000 > self.controller.selfData.hp/self.controller.selfData.hp_max
            else
                tips = baseData.self_cond_cli[1].self_cond_val/1000 > self.controller.selfData.hp/self.controller.selfData.hp_max
            end
        end
    elseif baseData ~= nil then
        local rate_count = 1
        if self.controller.enterData.use_anger_ratio ~= nil then
            rate_count = self.controller.enterData.use_anger_ratio/1000
        end
        if self.combatMgr.controller.selfData.mp < baseData.cost_mp then
            attr = TI18N("魔法值")
            rate = tostring(baseData.cost_mp)
            tips = true
        elseif baseData.cost_anger ~= nil and self.controller.enterData.anger < baseData.cost_anger * rate_count then
            attr = TI18N("怒气值")
            rate = tostring(baseData.cost_anger * rate_count)
            tips = true
        end
    end
    local callback = function()
        self.IsSelectingSkill = false
        for _, combo in ipairs(selectList) do
            if self:IsDisappear(combo) then
                -- combo.halo:SetActive(false)
            end
            if not BaseUtils.isnull(combo.haloImg) then
                combo.haloImg.color = self.ColorAlpha0
            end
        end
        self.mixPanel.backToControlImage:SetActive(false)
        self.mixPanel:HidePreSkillImage()
        -- self.combatMgr:Send10732(self.selectSkillId, fighterId, 0)
        self:SendRoleSkill(self.selectSkillId, fighterId, 0)
    end
    if tips then
        if self.combatMgr.combatType == 52 then
            NoticeManager.Instance:FloatTipsByString(TI18N("没有雪球可丢，请先搓个雪球"))
            return
        end
        local str = string.format(TI18N("当前%s不足<color='#ffff00'>%s</color>，如果<color='#ffff00'>使用前没有足够%s</color>将无法使用<color='#ffff00'>%s</color>，是否继续？"), attr, tostring(rate), attr, skillname)
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = str
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = callback
        NoticeManager.Instance:ConfirmTips(data)
    else
        callback()
    end
end

-- 人物物品选招
function CombatMainPanel:OnHaloItemButtonClick(fighterId, skillId, selectList, itemId)
    self.IsSelectingSkill = false
    for _, combo in ipairs(selectList) do
        if self:IsDisappear(combo) then
                -- combo.halo:SetActive(false)
            end
        -- combo.haloImg.color = self.ColorAlpha0
    end
    self.mixPanel.backToControlImage:SetActive(false)
    self.mixPanel:HidePreSkillImage()
    self.combatMgr:Send10732(self.selectSkillId, fighterId, itemId)
end

-- 宠物物品选招
function CombatMainPanel:OnPetHaloItemButtonClick(fighterId, skillId, selectList, itemId)
    self.IsSelectingSkill = false
    for _, combo in ipairs(selectList) do
        if self:IsDisappear(combo) then
                -- combo.halo:SetActive(false)
            end
        -- combo.haloImg.color = self.ColorAlpha0
    end
    self.mixPanel.backToControlImage:SetActive(false)
    self:SendPetSkill(self.selectSkillId, fighterId, itemId)
    self:OnBackToControlButtonClick()
end
-- 宠物选招
function CombatMainPanel:OnPetHaloButtonClick(fighterId, skillId, selectList)
    -- self.IsSelectingSkill = false
    -- for _, combo in ipairs(selectList) do
    --     if self:IsDisappear(combo) then
    --             -- combo.halo:SetActive(false)
    --         end
    --     combo.haloImg.color = self.ColorAlpha0
    -- end
    -- self.mixPanel.backToControlImage:SetActive(false)
    -- self:SendPetSkill(self.selectSkillId, fighterId, 0)
    -- self:OnBackToControlButtonClick()

    local baseData = DataCombatSkill.data_combat_skill[string.format("%s_%s", tostring(skillId), "1")]
    local tips = false
    local attr = ""
    local rate = ""
    local skillname = ""
    if baseData ~= nil and baseData.self_cond_cli[1] ~= nil then
        skillname = baseData.name
        -- BaseUtils.dump(baseData.self_cond_cli, "asdsadsdsadsadsa$#$@#$@#$%#@$@")
        if baseData.self_cond_cli[1].self_cond_type == 2 then
            attr = TI18N("生命值")
            rate = tostring(baseData.self_cond_cli[1].self_cond_val/10).."%"
            if baseData.self_cond_cli[1].self_cond_op then
                tips = baseData.self_cond_cli[1].self_cond_val/1000 > self.controller.selfPetData.hp/self.controller.selfPetData.hp_max
            else
                tips = baseData.self_cond_cli[1].self_cond_val/1000 > self.controller.selfPetData.hp/self.controller.selfPetData.hp_max
            end
        end
    elseif baseData ~= nil then
        local rate_count = 1
        -- if self.controller.enterData.use_anger_ratio ~= nil then
        --     rate_count = self.controller.enterData.use_anger_ratio/1000
        -- end
        if self.combatMgr.controller.selfPetData.mp < baseData.cost_mp then
            attr = TI18N("魔法值")
            rate = tostring(baseData.cost_mp)
            tips = true
        elseif baseData.cost_anger ~= nil and self.controller.enterData.anger < baseData.cost_anger * rate_count then
            attr = TI18N("怒气值")
            rate = tostring(baseData.cost_anger * rate_count)
            tips = true
        end
    end
    local callback = function()
        self.IsSelectingSkill = false
        for _, combo in ipairs(selectList) do
            if self:IsDisappear(combo) then
                -- combo.halo:SetActive(false)
            end
            if not BaseUtils.isnull(combo.haloImg) then
                combo.haloImg.color = self.ColorAlpha0
            end
        end
        self.mixPanel.backToControlImage:SetActive(false)
        self:SendPetSkill(self.selectSkillId, fighterId, 0)
        self:OnBackToControlButtonClick()
    end
    if tips then
        if self.combatMgr.combatType == 52 then
            NoticeManager.Instance:FloatTipsByString(TI18N("没有雪球可丢，请先搓个雪球"))
            return
        end
        local str = string.format(TI18N("当前%s不足<color='#ffff00'>%s</color>，如果<color='#ffff00'>使用前没有足够%s</color>将无法使用<color='#ffff00'>%s</color>，是否继续？"), attr, tostring(rate), attr, skillname)
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = str
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = callback
        NoticeManager.Instance:ConfirmTips(data)
    else
        callback()
    end
end

-- 防御
function CombatMainPanel:OnDefenceButClick()
    self:HidePanelOnSelectedSkill()
    local selfId = self.controller.selfData.id
    self.combatMgr:Send10732(1001, selfId, 0);
    self:OnBackToControlButtonClick()
    self.mixPanel:HidePreSkillImage()
end

-- 宠物防御
function CombatMainPanel:OnPetDefenceButClick()
    self:HidePanelOnSelectedSkill()
    local selfId = self.controller.selfData.id
    self:SendPetSkill(1001, self.controller.selfPetData.id, 0);
    self:OnBackToControlButtonClick()
end

-- 保护
function CombatMainPanel:OnProtectButClick()
    self:HidePanelOnSelectedSkill()
    self:OnSkillIconClick(1003, 1, "Role")
end

-- 宠物保护
function CombatMainPanel:OnPetProtectButClick()
    self:HidePanelOnSelectedSkill()
    self:OnSkillIconClick(1003, 1, "Pet")
end

-- 捕宠
function CombatMainPanel:OnCatchpetButClick()
    self:HidePanelOnSelectedSkill()
    self:OnSkillIconClick(1006, 1, "Role")
end

-- 逃跑
function CombatMainPanel:OnEscapeButClick()
    if self.combatMgr.combatType == 43 then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("逃跑后本次成绩将无法进入排行榜，确认逃跑？")
        data.sureLabel = TI18N("逃跑")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function()
                self:HidePanelOnSelectedSkill()
                self.combatMgr:Send10732(1002, self.controller.selfData.id, 0)
                self:OnBackToControlButtonClick()
                self.mixPanel:HidePreSkillImage()
            end
        NoticeManager.Instance:ConfirmTips(data)
    else
        self:HidePanelOnSelectedSkill()
        self.combatMgr:Send10732(1002, self.controller.selfData.id, 0)
        self:OnBackToControlButtonClick()
        self.mixPanel:HidePreSkillImage()
    end
end
-- 宠物逃跑
function CombatMainPanel:OnPetEscapeButClick()
    self:HidePanelOnSelectedSkill()
    self:SendPetSkill(1002, self.controller.selfPetData.id, 0)
    self:OnBackToControlButtonClick()
end

function CombatMainPanel:OnSummonButClick(petId, ischild)
    self:HidePanelOnSelectedSkill()
    if ischild then
        self.combatMgr:Send10732(1009, self.controller.selfData.id, petId)
    else
        self.combatMgr:Send10732(1008, self.controller.selfData.id, petId)
    end
    self:OnBackToControlButtonClick()
    self.mixPanel:HidePreSkillImage()
end

-- 隐藏面板
function CombatMainPanel:HidePanelOnSelectedSkill()
    self.skillareaPanel.gameObject:SetActive(false)
    self.functionIconPanel:ActiveAll(false)
end
-- 显示面板
function CombatMainPanel:ShowPanelOnSelectedSkill()
    self.skillareaPanel.gameObject:SetActive(true)
    self.functionIconPanel:ActiveAll(true)
end

function CombatMainPanel:UpdaFunctionAtkButton(RoleSp, PetSp)
    -- self.functionIconPanel:UpdateAtkList(RoleSp, PetSp)
end

function CombatMainPanel:SwitchSkillPanel(fromType, subType)
    if fromType == "Role" then
        if subType == 1 then
            self:OnSkillIconClick(CombatUtil.GetNormalSKill(self.controller.selfData.classes), 1, "Role")
            self.skillareaPanel:ClickRoleAttack()
        elseif subType == 2 then
            self.skillareaPanel:SwitchRoleSkillPanel()
        else
            self.skillareaPanel:SwitchRoleSpSkillPanel()
        end
    else
        if subType == 1 then
            self:OnSkillIconClick(1000, 1, "Pet")
            self.skillareaPanel:ClickPetAttack()
        elseif subType == 2 then
            self.skillareaPanel:SwitchPetSkillPanel()
        else
            self.skillareaPanel:SwitchPetSpSkillPanel()
        end
    end
end

-- On10732  玩家选招 技能结果
function CombatMainPanel:OnSelectedSkill(data)
    local result = data.result
    local msg = data.msg
    if result == 0 then
        if msg == TI18N("已经选择过技能") then
            self:HidePanelOnSelectedSkill()
        else
            self:ShowPanelOnSelectedSkill()
        end
        NoticeManager.Instance:FloatTipsByString(msg)
    end
end

-- On10733 通知玩家选招情况
function CombatMainPanel:OnSkillSelectedResult(data)
    local fighterId = data.id
    local result = data.result
    if result == 1 and fighterId == self.controller.selfData.id and not self.combatMgr.isBrocasting  then -- 自己的人物技能
        -- 判断是否前置技能
        local combatSkill = self.combatMgr:GetCombatSkillObject(data.skill_id, data.skill_lev)
        if combatSkill ~= nil and combatSkill.type == 4 then -- 是前置技能，继续选择角色技能
            self.skillareaPanel:SetPreSkill(data.skill_id)
            self.mixPanel:ShowPreSkillImage(data.skill_id, data.skill_lev)
            -- self.functionIconPanel:HideButton("Role", function() self.functionIconPanel:ShowButton("Role", function() end) end)
            self.skillareaPanel:HidePanel(function() self.skillareaPanel:ShowPanel("Role", function() end) end)
            for k,v in pairs(self.RguideAction) do
                v:OnActionEnd()
            end
            self.RguideAction = {}
        else
            -- 判断是否需要选择宠物技能
            if self.controller.selfPetData ~= nil
                and (self.controller.selfPetData.is_die == 0
                and (not self.controller.brocastCtx:FindFighter(self.controller.selfPetData.id).IsDisappear))then
                if self.isAutoFighting and self.selectState == CombatSeletedState.Role then
                    self.selectState = CombatSeletedState.Role
                else
                    self.selectState = CombatSeletedState.Pet
                end
                if not self.isAutoFighting then
                    self.functionIconPanel:HideButton("Role", function()  self.functionIconPanel:ShowButton("Pet", function() end) end)
                    self.skillareaPanel:HidePanel(function() self.skillareaPanel:ShowPanel("Pet", function() end) end)
                    for k,v in pairs(self.RguideAction) do
                        v:OnActionEnd()
                    end
                    self.RguideAction = {}
                    if self.round == 1 and self.controller.enterData.guide == 1001 then
                        local selectSkillAction = CombatGuideAction.New(self,{type = "PetSkill", })
                        local selectTargetAction = CombatGuideAction.New(self,{type = "SkillTarget", name = TI18N("林雷"), frometype = "Pet", msg = TI18N("直接<color='#ffff00'>点击目标</color>指挥<color='#ffff00'>宠物</color>普攻")})
                        selectSkillAction:AddEvent(CombatEventType.End, function() selectTargetAction:Play()  end)
                        selectSkillAction:Play()
                        table.insert(self.PguideAction, selectSkillAction)
                        table.insert(self.PguideAction, selectTargetAction)
                    end
                end
            else -- 不需要选择宠物技能
                self:OnBackToControlButtonClick()
                self.functionIconPanel:HideButton("Pet", function() end)
                self.functionIconPanel:HideButton("Role", function() end)
                self.skillareaPanel:HidePanel(function() end)
                if not self.isAutoFighting then
                    self.counterInfoPanel:StopCountDown()
                end
            end
        end
    elseif result == 0 and fighterId == self.controller.selfData.id and not self.combatMgr.isBrocasting  then -- 自己的人物取消前置技能
        local combatSkill = self.combatMgr:GetCombatSkillObject(data.skill_id, data.skill_lev)
        if combatSkill ~= nil and combatSkill.type == 4 then -- 是前置技能，继续选择角色技能
            self.skillareaPanel:SetPreSkill(nil)
            self.mixPanel:HidePreSkillImage()
            self:OnSkillIconClick(CombatUtil.GetNormalSKill(self.controller.selfData.classes), 1, "UnSelect")
            -- self.functionIconPanel:HideButton("Role", function() self.functionIconPanel:ShowButton("Role", function() end) end)
            self.skillareaPanel:HidePanel(function() self.skillareaPanel:ShowPanel("Role", function() end) end)
            for k,v in pairs(self.RguideAction) do
                v:OnActionEnd()
            end
            self.RguideAction = {}
        end
    elseif result == 1 and self.controller.selfPetData ~= nil and fighterId == self.controller.selfPetData.id and not self.combatMgr.isBrocasting then -- 自己的宠物技能
        -- 判断是否前置技能
        local combatSkill = self.combatMgr:GetCombatSkillObject(data.skill_id, data.skill_lev)
        if combatSkill ~= nil and combatSkill.type == 4 then -- 是前置技能，继续选择宠物技能
            self.skillareaPanel:SetPetPreSkill(data.skill_id)
            self.mixPanel:ShowPreSkillImage(data.skill_id, data.skill_lev)
            self.functionIconPanel:HideButton("Role", function()  self.functionIconPanel:ShowButton("Pet", function() end) end)
            self.skillareaPanel:HidePanel(function() self.skillareaPanel:ShowPanel("Pet", function() end) end)
            for k,v in pairs(self.RguideAction) do
                v:OnActionEnd()
            end
            self.RguideAction = {}
        else
            self.mixPanel:HidePreSkillImage()
            if self.isAutoFighting and self.selectState == CombatSeletedState.Pet then
                self.selectState = CombatSeletedState.Pet
            else
                self.selectState = CombatSeletedState.Idel
            end
            for k,v in pairs(self.PguideAction) do
                v:OnActionEnd()
            end
            self.PguideAction = {}
            self.selectState = CombatSeletedState.Idel
            self.functionIconPanel:HideButton("Pet", function() end)
            self.functionIconPanel:HideButton("Role", function() end)
            self.skillareaPanel:HidePanel(function() end)
            if not self.isAutoFighting then
                self.counterInfoPanel:StopCountDown()
            end
        end
    elseif result == 0 and self.controller.selfPetData ~= nil and fighterId == self.controller.selfPetData.id and not self.combatMgr.isBrocasting  then -- 自己的宠物取消前置技能
        local combatSkill = self.combatMgr:GetCombatSkillObject(data.skill_id, data.skill_lev)
        if combatSkill ~= nil and combatSkill.type == 4 then -- 是前置技能，继续选择角色技能
            self.skillareaPanel:SetPetPreSkill(nil)
            self.mixPanel:HidePreSkillImage()
            self:OnSkillIconClick(1000, 1, "UnSelect")
            self.functionIconPanel:HideButton("Role", function()  self.functionIconPanel:ShowButton("Pet", function() end) end)
            self.skillareaPanel:HidePanel(function() self.skillareaPanel:ShowPanel("Pet", function() end) end)
            for k,v in pairs(self.RguideAction) do
                v:OnActionEnd()
            end
            self.RguideAction = {}
        end
    end

    if result == 1 then
        self:SetFighterPreparing(false, fighterId)
    end
end

-- On10771 通知玩家选招情况
function CombatMainPanel:OnTalismanSkillSelectedResult(data)
    self.functionIconPanel:HideButton("Role", function() self.functionIconPanel:ShowButton("Role", function() end) end)
    self.skillareaPanel:HidePanel(function() self.skillareaPanel:ShowPanel("Role", function() end) end)
    for k,v in pairs(self.RguideAction) do
        v:OnActionEnd()
    end
    self.RguideAction = {}
end

function CombatMainPanel:OnBackToControlButtonClick(BackType)
    self.IsSelectingSkill = false
    self.mixPanel.backToControlImage:SetActive(false)
    self.skillareaPanel.gameObject:SetActive(true)
    if self.isAutoFighting == false then
        self.functionIconPanel:ActiveAll(true)
    end
    for _, combo in ipairs(self.selectList) do
        if combo.halo ~= nil then
            combo.haloImg.color = self.ColorAlpha0
            if self:IsDisappear(combo) then
                -- combo.halo:SetActive(false)
            end
        end
    end
    if BackType == "Role" then
        self:OnSkillIconClick(CombatUtil.GetNormalSKill(self.controller.selfData.classes), 1, "UnSelect")
    elseif BackType == "Pet" then
        self:OnSkillIconClick(1000, 1, "UnSelect")
    end
end

-- On10740
function CombatMainPanel:OnAutoSetting(data)
    -- self:OnBackToControlButtonClick()
    for _, combo in ipairs(self.selectList) do
        if combo.halo ~= nil then
            combo.haloImg.color = self.ColorAlpha0
            if self:IsDisappear(combo) then
                -- combo.halo:SetActive(false)
            end
        end
    end
    local flag = data.flag
    local result = data.result
    local skillId = data.skill_id
    local petSkillId = data.pet_skill_id
    local msg = data.msg
    if self.isAutoFighting and data.flag == 1 then
        return
    end
    if not self.InitFinish then
        self.isAutoFighting = flag == 1 and true or false
        return
    end

    self.isAutoFighting = flag == 1 and true or false
    if self.isAutoFighting then
        self.counterInfoPanel:StopCountDown()
        if not BaseUtils.is_null(self.controller.teamquestPanel) then
            self.controller.teamquestPanel:SetActive(true)
        end
    else
        if self.controller.teamquestPanel ~= nil and not self.controller.teamquestPanel:Equals(NULL) then
            self.controller.teamquestPanel:SetActive(false)
        end
    end
    self.functionIconPanel:OnAutoSetting(flag, result, msg)
    self.skillareaPanel:OnAutoSetting(flag, result, msg)
    if flag == 1 then
        for k,v in pairs(self.RguideAction) do
            v:OnActionEnd()
        end
        self.RguideAction = {}
        for k,v in pairs(self.PguideAction) do
            v:OnActionEnd()
        end
        self.PguideAction = {}
    end
    self.IsSelectingSkill = false
    if #self.selectList > 0 then
        for _, combo in ipairs(self.selectList) do
            if self:IsDisappear(combo) then
                -- combo.halo:SetActive(false)
            end
            -- combo.haloImg.color = self.ColorAlpha0
        end
    end

    self.mixPanel:HideBackToControlImage()
    self.mixPanel:HidePreSkillImage()

    if not self.isAutoFighting and self.waittime.waittime > 1 then
        local ctime = self.waittime.waittime - (Time.time - self.waittime.begintime)
        if ctime > 30 then
            ctime = 30
        elseif ctime < 1 then
            ctime = 1
        end
        self.counterInfoPanel:SetRound(self.round)
        self.counterInfoPanel:StartCountDown(math.ceil(ctime))
    end
end

function CombatMainPanel:InitUiPanel()
    local selfData = self.controller.selfData
    self:InitRoleHeadPanel(selfData)
    if self.skillareaPanel == nil then
        self.skillareaPanel = CombatSkilareaPanel.New(self.controller.skillareaPath, self)
    end
    self.skillareaPanel:InitPetPanel()
    self.extendPanel:OnLoadFinish()
    self.mixPanel:InitCommandPanel()
end

function CombatMainPanel:InitRoleHeadPanel(fighterData)
    self.headInfoPanel:UpdateRoleInfo(fighterData)
    self.headInfoPanel:SetRoleFace(fighterData)
end

function CombatMainPanel:InitPetHeadPanel(fighterData)
    self.headInfoPanel:UpdatePetInfo(fighterData)
    self.headInfoPanel:SetPetFace(fighterData)
end

function CombatMainPanel:OnFighterClick(fighterData)
    if self.HoldTag == true and self.HoldTime+1> Time.time then
        self.HoldTag = false
        return
    end
    self.HoldTag = false
    if not self.IsSelectingSkill then
        if self.selectState == CombatSeletedState.Role then
            local classes = self.controller.selfData.classes
            local skillId = CombatUtil.GetNormalSKill(classes)
            self:HidePanelOnSelectedSkill()
            self.mixPanel:HidePreSkillImage()
            self.combatMgr:Send10732(skillId, fighterData.id, 0)
        elseif self.selectState == CombatSeletedState.Pet then
            self:HidePanelOnSelectedSkill()
            self:SendPetSkill(1000, fighterData.id, 0)
        end
    end
end

function CombatMainPanel:OnPointerHold(fighterData)
    -- BaseUtils.dump(self.controller.enterData.fighter_list,"长按数据1111111111111111111111111111111")
    -- BaseUtils.dump(fighterData,"长按数据2222222222222222222222222222")
    self.HoldTag = true
    self.HoldTime = Time.time
    self.selectID = fighterData.id
    local preid = self.controller.fighterNum
    if self.selectID - 1 > 0 then
        preid = self.selectID -1
    end
    local nextid = self.selectID % self.controller.fighterNum + 1

    local preData = self.controller.brocastCtx:FindFighter(preid)
    local nextData = self.controller.brocastCtx:FindFighter(nextid)

    local buffPanel = self.mixPanel.BuffDetailPanel
    buffPanel.transform:SetParent(self.mixPanel.transform)

    buffPanel.transform:Find("LButton"):GetComponent(Button).onClick:RemoveAllListeners()
    buffPanel.transform:Find("LButton"):GetComponent(Button).onClick:AddListener(function() if preData == nil then return end  buffPanel:SetActive(false) self:OnPointerHold(preData.fighterData) end)
    buffPanel.transform:Find("RButton"):GetComponent(Button).onClick:RemoveAllListeners()
    buffPanel.transform:Find("RButton"):GetComponent(Button).onClick:AddListener(function() if nextData == nil then return end buffPanel:SetActive(false) self:OnPointerHold(nextData.fighterData) end)
    buffPanel:SetActive(true)
    if fighterData.classes == 0 then
        if fighterData.master_fid ~= 0 then
            local master = self.controller.brocastCtx:FindFighter(fighterData.master_fid)
            if master ~= nil then
                buffPanel.transform:FindChild("Name"):GetComponent(Text).text = string.format(TI18N("%s %s级 (%s)"), fighterData.name, tostring(fighterData.lev), master.fighterData.name)
            else
                buffPanel.transform:FindChild("Name"):GetComponent(Text).text = string.format(TI18N("%s %s级"), fighterData.name, tostring(fighterData.lev))
            end
        else
            buffPanel.transform:FindChild("Name"):GetComponent(Text).text = string.format(TI18N("%s %s级"), fighterData.name, tostring(fighterData.lev))
        end
    else
        buffPanel.transform:FindChild("Name"):GetComponent(Text).text = string.format(TI18N("%s %s级 %s"), fighterData.name, tostring(fighterData.lev), KvData.classes_name[fighterData.classes])
    end
    buffPanel.transform:FindChild("RoundText"):GetComponent(Text).text = string.format(TI18N("第%s回合"), tostring(self.round))

    local basePanel = buffPanel.transform:FindChild("Mask/Container/Detail").gameObject
    local baseTransformBuffPanel = buffPanel.transform:FindChild("Mask/Container/DetailTransformBuff").gameObject
    local container = buffPanel.transform:FindChild("Mask/Container").gameObject
    if self.controller.brocastCtx:FindFighter(fighterData.id) == nil then
        return
    end
    local buffCtrl = self.controller.brocastCtx:FindFighter(fighterData.id).buffCtrl
    local list = buffCtrl.buffUiDataList


    for _, old in ipairs(self.buffDetailList) do
        GameObject.DestroyImmediate(old)
    end

    self.buffDetailList = {}

-- BaseUtils.dump(list, "list")
    for _, data in ipairs(list) do
        if data.special == nil then
            local buffData = self.combatMgr:GetCombatBuffData(data.buffId)
            if buffData ~= nil and buffData.isActive == 0 then
                local panel = GameObject.Instantiate(basePanel)
                panel.transform:SetParent(container.transform)
                panel.transform.localScale = Vector3(1, 1, 1)
                panel.transform:FindChild("NamePale/BuffName"):GetComponent(Text).text = buffData.name
                panel.transform:FindChild("DetailTxt"):GetComponent(Text).text = buffData.detail
                if data.durationLeft > 0 then
                    panel.transform:FindChild("CD"):GetComponent(Text).text = string.format(TI18N("剩余%s回合"), data.durationLeft)
                else
                    panel.transform:FindChild("CD"):GetComponent(Text).text = tostring(TI18N("永久存在"))
                end
                panel.transform:FindChild("NamePale/Lev"):GetComponent(Text).text = ""
                local sprite = self.combatMgr.assetWrapper:GetSprite(AssetConfig.bufficon, tostring(buffData.iconResId))
                if sprite == nil then
                    sprite = self.combatMgr.assetWrapper:GetSprite(AssetConfig.bufficon, "10001")
                end
                panel.transform:FindChild("NamePale/Icon"):GetComponent(Image).sprite = sprite
                panel:SetActive(true)
                table.insert(self.buffDetailList, panel)
            end
        -- elseif data.special == 1 and not SceneManager.Instance.sceneElementsModel.Show_Transform_Mark then
        elseif data.special == 1 then
            local buffData = DataBuff.data_list[data.buffId]
            if buffData ~= nil then
                local panel = GameObject.Instantiate(baseTransformBuffPanel)
                panel.transform:SetParent(container.transform)
                panel.transform.localScale = Vector3(1, 1, 1)
                panel.transform:FindChild("NamePale/BuffName"):GetComponent(Text).text = buffData.name
                -- panel.transform:FindChild("DetailTxt"):GetComponent(Text).text = buffData.desc
                -- panel.transform:FindChild("CD"):GetComponent(Text).text = tostring(TI18N("永久存在"))
                -- panel.transform:FindChild("NamePale/Lev"):GetComponent(Text).text = ""
                local attrsText = ""
                local attrText = ""
                for i,v in ipairs(buffData.attr) do
                    local name = KvData.attr_name[v.attr_type]
                    local value = v.val
                    if value > 0 then
                        value = string.format("+%s%s", v.val/10, "%")
                    else
                        value = string.format("%s%s", v.val/10, "%")
                    end

                    if i == 1 then
                        attrsText = TI18N("附带属性：")
                        attrText = string.format("%s %s", tostring(name), tostring(value))
                    else
                        attrsText = string.format("%s\n", attrsText)
                        attrText = string.format("%s\n%s %s", attrText, tostring(name), tostring(value))
                    end
                end

                if #buffData.effect > 0 then
                    local skillData = DataSkill.data_skill_other[buffData.effect[1].val]
                    local skillname = skillData.name
                    panel.transform:Find("SkillText"):GetComponent(Text).text = string.format(TI18N("附带技能： <color='#00ffff'>[%s]</color>"), skillname)
                    local skillTextButton = panel.transform:Find("SkillText").gameObject
                    local info = {gameObject = skillTextButton, skillData = skillData, type = Skilltype.petskill}
                    skillTextButton:GetComponent(Button).onClick:AddListener(function() TipsManager.Instance:ShowSkill(info, true) end)
                else
                    panel.transform:Find("SkillText"):GetComponent(Text).text = TI18N("技能： 无")
                end

                panel.transform:Find("AttrsText"):GetComponent(Text).text = attrsText
                panel.transform:Find("AttrsText/AttrText"):GetComponent(Text).text = string.format(TI18N("<color='#00ff00'>%s</color>"), attrText)

                local sprite = self.combatMgr.assetWrapper:GetSprite(AssetConfig.normalbufficon, tostring(buffData.icon))
                if sprite == nil then
                    sprite = self.combatMgr.assetWrapper:GetSprite(AssetConfig.bufficon, "10001")
                end
                panel.transform:FindChild("NamePale/Icon"):GetComponent(Image).sprite = sprite
                panel:SetActive(true)
                table.insert(self.buffDetailList, panel)
            end
        end
    end
    self.mixPanel:UpdateCmdPanel(fighterData.group)
end

function CombatMainPanel:IsDisappear(combo)
    local fighterId = combo.fighterId
    local ctrl = self.controller.brocastCtx:FindFighter(fighterId)
    if ctrl ~= nil then
        if ctrl.IsDisappear then
            if not BaseUtils.isnull(combo.halo) then
                GameObject.Destroy(combo.halo)
                combo.halo = nil
            end
            return true
        else
            return false
        end
    else
        if not BaseUtils.isnull(combo.halo) then
            GameObject.Destroy(combo.halo)
            combo.halo = nil
        end
    end
    return true
end

function CombatMainPanel:DealTalkBubble(round)
    local eastList = self.controller.eastFighterList
    local westList = self.controller.westFighterList
    -- for _, combo in ipairs(eastList) do
    --     local ctrl = self.controller.brocastCtx:FindFighter(combo.fighterId)
    --     self:ShowTalkBubble(ctrl, round)
    -- end
    -- for _, combo in ipairs(westList) do
    --     local ctrl = self.controller.brocastCtx:FindFighter(combo.fighterId)
    --     self:ShowTalkBubble(ctrl, round)
    -- end
end

function CombatMainPanel:ShowTalkBubble(fighterCtrl, round)
    local data = fighterCtrl.fighterData
    if data.type == FighterType.Unit then
        local baseId = data.base_id
        local talkData = self.combatMgr:GetNpcTalkData(baseId, round, 1)
        if talkData ~= nil then
            local action = TalkBubbleAction.New(self.controller.brocastCtx, fighterCtrl.fighterData.id, talkData.talk)
            action:Play()
            -- local talkPanel = GameObject.Instantiate(self.mixPanel.TalkBubblePanel)
            -- talkPanel.transform:FindChild("Content"):GetComponent(Text).text = talkData.talk
            -- local TextEXT = MsgItemExt.New(talkPanel.transform:FindChild("Content"):GetComponent(Text), 140)
            -- TextEXT:SetData(talkData.talk)
            -- talkPanel:SetActive(true)
            -- talkPanel.transform:SetParent(self.mixPanel.transform)
            -- talkPanel.transform.localScale = Vector3(1, 1, 1)
            -- fighterCtrl:SetTalkBubblePanel(talkPanel)
            -- LuaTimer.Add(3000, function () fighterCtrl:DestroyTalkBubble() end)
        end
    end
end

function CombatMainPanel:OnFinalPanelButtonClick()
    scene_manager:JumpToScene("Normal")
end

function CombatMainPanel:ShowFinalPanel(result, msg, gainList)
    -- scene_manager:JumpToScene("Normal")
    self.controller:EndOfCombat()
    -- ctx:InvokeDelay(self.OnFinalPanelButtonClick, 0.5, self)
end

function CombatMainPanel:ShowFinalPanel_old(result, msg, gainList)
    if result == 1 then
        local finalPanel = self.mixPanel.FinalWinPanel
        local winText = finalPanel.transform:FindChild("WinText").gameObject
        local light = finalPanel.transform:FindChild("Light").gameObject
        light:SetActive(false)
        winText.transform.localScale = Vector3(2, 2, 2)
        finalPanel.transform:SetParent(self.mixPanel.transform)
        local text = finalPanel.transform:FindChild("ClickToContinue/Text"):GetComponent(Text)
        text.text = "2"
        LuaTimer.Add(1000, function () self:ChangeContinueText(text, 2) end)

        for i = 1, 4 do
            local itemPanel = finalPanel.transform:FindChild("Loack" .. i).gameObject
            if #gainList >= i then
                local baseId = gainList[i].base_id
                local val = gainList[i].val
                self:SetItemSlot(itemPanel, baseId, val)
            end
        end
        self.mixPanel.FinalWinPanel:SetActive(true)
        tween:DoScale(winText, Vector3(2, 2, 2), Vector3(1, 1, 1), 0.1, function() light:SetActive(true) end, "linear", 1)
    else
        self.mixPanel.FinalLosePanel:SetActive(true)
        self.mixPanel.FinalLosePanel.transform:SetParent(self.mixPanel.transform)
        LuaTimer.Add(1000, function () self:OnFinalPanelButtonClick() end)
    end
end

function CombatMainPanel:ChangeContinueText(text, count)
    count = count - 1
    if count > 0 then
        text.text = "" .. count
        LuaTimer.Add(1000, function () self:ChangeContinueText(text, count) end)
    else
        self:OnFinalPanelButtonClick()
    end
end

function CombatMainPanel:SetItemSlot(parent, baseId, num)
    local slot = ctx:PathInstantiate(config.resources.item_slot)
    UIUtils.AddUIChild(parent, slot)
    local item = data_item.data_get[baseId]
    local info = {trans = slot.transform, data = {base = item, quantity = num}, is_equip = false, num_need = 0, show_num = true, is_lock = false, show_name = "", is_new = false, is_select = false, inbag = false, show_tips = true, show_select = true, drop_only = true}
    slot_item.set_data(info)
end

function CombatMainPanel:SetPreparing(IsShow, FighterComboList)
    if not self.combatMgr.isFighting then
        return
    end
    for _, combo in ipairs(FighterComboList) do
        local fighterId = combo.fighterId
        local ctrl = self.controller.brocastCtx:FindFighter(fighterId)
        if ctrl.fighterData.type == FighterType.Role and fighterId ~= self.controller.selfData.id then
            if IsShow then
                ctrl:ShowPreparing()
            else
                ctrl:HidePreparing()
            end
        end
    end
end

function CombatMainPanel:SetFighterPreparing(IsShow, fighterId)
    local ctrl = self.controller.brocastCtx:FindFighter(fighterId)
    if ctrl == nil then
        Log.Info("找不到目标控制器，无法设置准备状态")
        return
    end
    if ctrl.fighterData.type == FighterType.Role and fighterId ~= self.controller.selfData.id then
        if IsShow then
            ctrl:ShowPreparing()
        else
            ctrl:HidePreparing()
        end
    end
end

function CombatMainPanel:OnPlayEnd()
    if self.controller.brocastCtx == nil or self.controller.brocastCtx.brocastData == nil then
        return
    end
    local round = self.controller.brocastCtx.brocastData.round
    self.extendPanel:OnPlayEnd(round)
end

function CombatMainPanel:OnFighting()
    for _, combo in ipairs(self.selectList) do
        if combo.halo ~= nil then
            if self:IsDisappear(combo) then

            end
        end
    end
    if self.selectState == CombatSeletedState.Pet then
        self.IsSelectingSkill = false
        if #self.selectList > 0 then
            for _, combo in ipairs(self.selectList) do
                if self:IsDisappear(combo) then
                    -- if not BaseUtils.isnull(combo.halo) then
                    --     GameObject.Destroy(combo.halo)
                    --     combo.halo = nil
                    -- end
                end
            end
        end
        self.mixPanel:HideBackToControlImage()
        self.mixPanel:HidePreSkillImage()
        self.functionIconPanel:HideButton("Pet", function() end)
        self.functionIconPanel:HideButton("Role", function() end)
        self.skillareaPanel:HidePanel(function() end)
    end
end

function CombatMainPanel:ReSelectSkill(data)
    local ctime = self.waittime.waittime - (Time.time - self.waittime.begintime)
    if ctime > 30 then
        ctime = 30
    elseif ctime < 1 then
        ctime = 1
    end

    self.lastSkillSelectData = self.lastSkillSelectData or {}
    self.lastSkillSelectData.time = ctime
    if self.lastSkillSelectData ~= nil then
        if self.controller.selfPetData ~= nil and data.id == self.controller.selfPetData.id then 
            self.selectState = CombatSeletedState.Pet
            self.skillareaPanel:ShowPanel("Pet", function() end)
            self.functionIconPanel:HideButton("Role", function() end)
            self.functionIconPanel:ShowButton("Pet", function() end)
            self.counterInfoPanel:StopCountDown()
            self.counterInfoPanel:StartCountDown(ctime)
        else  
            self:OnBeginFighting(self.lastSkillSelectData)
        end
    end
end

function CombatMainPanel:Relocatecombo()
    local eastList = self.controller.eastFighterList
    local westList = self.controller.westFighterList
    for _,combo in pairs(eastList) do
        if not BaseUtils.isnull(combo.halo) then
            local fp = combo.fighter.transform.position
            local sp = CombatUtil.WorldToUIPoint(self.controller.combatCamera, fp)
            combo.halo.transform.localPosition = Vector3(sp.x, sp.y + 20, 1)
        end
    end
    for _,combo in pairs(westList) do
        if not BaseUtils.isnull(combo.halo) then
            local fp = combo.fighter.transform.position
            local sp = CombatUtil.WorldToUIPoint(self.controller.combatCamera, fp)
            combo.halo.transform.localPosition = Vector3(sp.x, sp.y + 20, 1)
        end
    end
end

function CombatMainPanel:SendRoleSkill(skillId, targetId, otherId)
    local combatSkill = self.combatMgr:GetCombatSkillObject(skillId, 1)
    -- BaseUtils.dump(combatSkill, "CombatMainPanel:SendRoleSkill(skillId, targetId, otherId)")
    if combatSkill.type == 4 then
        self.combatMgr:Send10771(skillId, targetId, otherId)
    else
        self.combatMgr:Send10732(skillId, targetId, otherId)
    end
end

function CombatMainPanel:SendPetSkill(skillId, targetId, otherId)
    local combatSkill = self.combatMgr:GetCombatSkillObject(skillId, 1)
    -- BaseUtils.dump(combatSkill, "CombatMainPanel:SendRoleSkill(skillId, targetId, otherId)")
    if combatSkill ~= nil and combatSkill.type == 4 then
        self.combatMgr:Send10773(skillId, targetId, otherId)
    else
        self.combatMgr:Send10734(skillId, targetId, otherId)
    end
end

--------------------------------------------------
-- 华丽的分隔线
--------------------------------------------------
CombatUiState = CombatUiState or BaseClass()

function CombatUiState:__init()
    self.state = self.StateIdel
end

