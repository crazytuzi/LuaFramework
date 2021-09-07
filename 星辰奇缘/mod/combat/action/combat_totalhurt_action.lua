-- 总伤害
CombatTotalHurtAction = CombatTotalHurtAction or BaseClass(CombatBaseAction)

function CombatTotalHurtAction:__init(brocastCtx, actionData)
    self.actionData = actionData
    self.changeList = actionData.target_changes
    self.total = 0
    self.fighterId = self.actionData.target_id
    for _, data in ipairs(self.changeList) do
        if data.change_type == 0 then
            self.total = data.change_val
        end
    end
    self.mixPanel = self.brocastCtx.controller.mainPanel.mixPanel

    self.syncAction = SyncSupporter.New(brocastCtx)
    self.syncAction:AddEvent(CombatEventType.End, self.OnActionEnd, self)
    self:Parse()
end

function CombatTotalHurtAction:Parse()
    local parent = GameObject("TotalHurtImagePanel")
    local prefix = "Num5_"
    local prefixList = {}
    parent:AddComponent(RectTransform)
    parent.transform:SetParent(self.mixPanel.NumStrCanvas)
    parent.transform.localScale = Vector3(1, 1, 1)
    local fighter = self:FindFighter(self.fighterId)
    fighter:SetTopPosition(parent, -20)
    parent:SetActive(false)
    self.numberImage = ImageSpriteGroup.New(parent, prefix, prefixList, nil)


    local total = GameObject.Instantiate(self.mixPanel.TotalHurtImage)
    total.transform.localScale = Vector3(1, 1, 1)
    total:SetActive(true)
    table.insert(prefixList, total)

    local uiChange = UIComboEffect.New(self.brocastCtx, parent)
    local endTaper = TaperSupporter.New(self.brocastCtx)
    endTaper:AddEvent(CombatEventType.End, function()
            self.numberImage:Release()
            GameObject.DestroyImmediate(parent)
        end
    )

    local scale1 = UIScaleEffect.New(self.brocastCtx, parent, Vector3(2.5, 2.5, 2.5), 0)
    local scale2 = UIScaleEffect.New(self.brocastCtx, parent, Vector3(1, 1, 1), 0.1)
    local move = UIMoveEffect.New(self.brocastCtx, parent, UIMoveDir.Up, 70, 1.2)
    local fade = UIFadeEffect.New(self.brocastCtx, parent, 0, 0.8)
    uiChange:AddAwakdAction(scale1)
    uiChange:AddAction(scale2)

    local delay = DelayAction.New(self.brocastCtx, 100)
    local delay2 = DelayAction.New(self.brocastCtx, 200)

    delay2:AddEvent(CombatEventType.End, fade)
    delay:AddEvent(CombatEventType.End, move)
    delay:AddEvent(CombatEventType.End, delay2)
    scale2:AddEvent(CombatEventType.End, delay)

    uiChange:AddEvent(CombatEventType.End, endTaper)
    self.numberImage:SetNum(self.total)
    fade:AddEvent(CombatEventType.End, endTaper)
    self.syncAction:AddAction(uiChange)
end

function CombatTotalHurtAction:Play()
    for _, data in ipairs(self.changeList) do
        if data.change_type == 9 and self.fighterId == self.brocastCtx.controller.selfData.id then
            self.brocastCtx.controller.enterData.anger = Mathf.Clamp(data.change_val + self.brocastCtx.controller.enterData.anger, 0, CombatManager.Instance.MaxAnger)
            self.brocastCtx.controller.mainPanel.headInfoPanel:UpdateRoleInfo(self.brocastCtx.controller.selfData)
        elseif data.change_type == 14 and self.fighterId == self.brocastCtx.controller.selfData.id then
            self.brocastCtx.controller.enterData.energy = data.change_val
        end
    end
    self.syncAction:Play()
end

function CombatTotalHurtAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end

