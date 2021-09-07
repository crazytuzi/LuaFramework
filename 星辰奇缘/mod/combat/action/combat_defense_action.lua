-- 防御
DefenseAction = DefenseAction or BaseClass(CombatBaseAction)

function DefenseAction:__init(brocastCtx, actionData)
    self.actionData = actionData
    self.target = self:FindFighter(actionData.target_id)
    self.attacker = self:FindFighter(actionData.self_id)
    self.imageAction = DefenseImageAction.New(brocastCtx, self.target)
end

function DefenseAction:Play()
    self.target:PlayAction(FighterAction.Defense)
    self.imageAction:Play()
    self:InvokeDelay(self.OnActionEnd, 0.3, self)
end

function DefenseAction:OnActionEnd()
    local endAction = nil
    if self.actionData.is_target_die == 1 then
        if self.actionData.is_target_die_disappear == 1 then
            endAction = DeadFlyAction.New(self.brocastCtx, self.target.fighterData.id)
        else
            endAction = DeadAction.New(self.brocastCtx, self.target.fighterData.id)
        end
    else
        endAction = BattleStandAction.New(self.brocastCtx, self.target)
    end
    endAction:Play()
    self:InvokeAndClear(CombatEventType.End)
end

DefenseImageAction = DefenseImageAction or BaseClass(CombatBaseAction)

function DefenseImageAction:__init(brocastCtx, fighterCtrl)
    self.fighterCtrl = fighterCtrl
    self.mixPanel = self.brocastCtx.controller.mainPanel.mixPanel
    self.initImage = self.mixPanel.textImagePanel.transform:FindChild("DefenseImage").gameObject

    self.cloneImage = GameObject.Instantiate(self.initImage)
    self.cloneImage.transform:SetParent(self.mixPanel.transform)
    self.cloneImage.transform.localScale = Vector3(1, 1, 1)
    self.fighterCtrl:SetSkillShoutPosition(self.cloneImage)
    self.cloneImage:SetActive(false)


    self.syncAction = SyncSupporter.New(self.brocastCtx)
    local moveEvasion = UIMoveEffect.New(self.brocastCtx, self.cloneImage, UIMoveDir.Up, 50, 1)
    local fadeEvasion = UIFadeEffect.New(self.brocastCtx, self.cloneImage, 0, 1)
    self.syncAction:AddAction(moveEvasion)
    self.syncAction:AddAction(fadeEvasion)
    self.syncAction:AddEvent(CombatEventType.End, function() GameObject.DestroyImmediate(self.cloneImage) end)
end

function DefenseImageAction:Play()
    self.cloneImage:SetActive(true)
    self.syncAction:Play()
    self:InvokeDelay(self.OnActionEnd, 0.2, self)
end

function DefenseImageAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end
