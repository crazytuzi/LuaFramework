-- 闪躲
EvasionAction = EvasionAction or BaseClass(CombatBaseAction)

function EvasionAction:__init(brocastCtx, actionData)
    self.actionData = actionData
    self.controller = self:FindFighter(actionData.target_id)
    self.fighter = self.controller.transform.gameObject
    self.layout = self.controller.layout
    self.originPos = self.controller.originPos

    self.mixPanel = self.brocastCtx.controller.mainPanel.mixPanel
    self.evasionImage = self.mixPanel.textImagePanel.transform:FindChild("EvasionImage").gameObject

    self.evasion = GameObject.Instantiate(self.evasionImage)
    self.evasion.transform:SetParent(self.mixPanel.transform)
    self.evasion.transform.localScale = Vector3(1, 1, 1)
    self.controller:SetSkillShoutPosition(self.evasion)

    self.syncEvasion = SyncSupporter.New(self.brocastCtx)
    local moveEvasion = UIMoveEffect.New(self.brocastCtx, self.evasion, UIMoveDir.Up, 50, 1)
    local fadeEvasion = UIFadeEffect.New(self.brocastCtx, self.evasion, 0, 1)
    self.syncEvasion:AddAction(moveEvasion)
    self.syncEvasion:AddAction(fadeEvasion)
    self.syncEvasion:AddEvent(CombatEventType.End, function() GameObject.DestroyImmediate(self.evasion) end)

    self.point0 = self.originPos
    self.point1 = CombatUtil.GetBehindPoint(self.controller, 0.2)
    self.point2 = CombatUtil.GetBehindPoint(self.controller, 0.3)
    self.point3 = CombatUtil.GetBehindPoint(self.controller, 0.4)
end

function EvasionAction:Play()
    -- 漂字
    self.evasion:SetActive(true)
    self.syncEvasion:Play()
    self.controller:SetAlpha(0.5)

    -- local ePoint = CombatUtil.GetBehindPoint(self.controller, 0.2)
    -- self.fighter.transform.position = ePoint

    self.originPos = self.controller.transform.position
    self.point0 = self.originPos
    self.point1 = CombatUtil.GetBehindPointCur(self.controller, 0.2)
    self.point2 = CombatUtil.GetBehindPointCur(self.controller, 0.3)
    self.point3 = CombatUtil.GetBehindPointCur(self.controller, 0.4)

    local queue = {
        self.point2
        ,self.point3
        ,self.point3
        ,self.point3
        ,self.point3
        ,self.point3
        ,self.point2
        ,self.point2
        ,self.point1
        ,self.point0
    }
    self.controller:SetHitQueue(queue)
    self:InvokeDelay(self.MoveBack, 0.2, self)
end

function EvasionAction:MoveBack()
    self.controller:SetAlpha(1)
    self.fighter.transform.position = self.originPos
    self:OnActionEnd()
end

function EvasionAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end
