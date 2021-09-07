-- 逃跑
EscapeAction = EscapeAction or BaseClass(CombatBaseAction)

function EscapeAction:__init(brocastCtx, minorAction, actionData)
    self.minorAction = minorAction
    self.actionData = actionData
    self.fighterCtrl = self:FindFighter(self.actionData.self_id)
    self.effectPath = "prefabs/effect/10008.unity3d"
    self.minorAction.resourceLoader:AddResPath({self.effectPath})

    self.behindPoint = nil
    self.effectObject = nil
    self.firstAction = nil
    if self.fighterCtrl ~= nil then
        self.fighterCtrl:SetDisappear(true)
    end
    self.Sync = SyncSupporter.New(brocastCtx)
    self.fighterCtrlList = self.brocastCtx:FindFighterByMaster_id(self.actionData.self_id)
    if self.fighterCtrlList ~= nil and #self.fighterCtrlList >0 and self.fighterCtrl.fighterData.type == 1 then
        for i,v in ipairs(self.fighterCtrlList) do
            if v.fighterData.is_die == 0 and v.IsDisappear == false then
                local cactionData = actionData
                cactionData.self_id = v.fighterData.id
                cactionData.target_id = v.fighterData.id
                local action = EscapeAction.New(brocastCtx, minorAction, cactionData)
                self.Sync:AddAction(action)
            end
        end
    end
end

function EscapeAction:Parse()
    self.behindPoint = CombatUtil.GetBehindPoint(self.fighterCtrl, 7)
    local effectPrefab = self.minorAction.assetwrapper:GetMainAsset(self.effectPath)
    self.effectObject = GameObject.Instantiate(effectPrefab)
    self.effectObject.transform:SetParent(self.fighterCtrl.tpose)
    self.effectObject.transform.localScale = Vector3(1, 1, 1)
    self.effectObject.transform.localPosition = Vector3(0, 0, 0)
    self.effectObject.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.effectObject.transform, "CombatModel")
    self.effectObject:SetActive(false)
    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end

    if self.actionData.is_hit == 1 then
        local faceTo = FaceToAction.New(self.brocastCtx, self.fighterCtrl, self.behindPoint)
        local stand = EscapeStandAction.New(self.brocastCtx, self.fighterCtrl, 0.5)
        local moveOut = EscapeMoveAction.New(self.brocastCtx, self.fighterCtrl, self.behindPoint)
        faceTo:AddEvent(CombatEventType.End, stand)
        stand:AddEvent(CombatEventType.End, moveOut)
        moveOut:AddEvent(CombatEventType.End, self.OnActionEnd, self)
        self.firstAction = faceTo
        self.fighterCtrl:SetDisappear(true)
        self.fighterCtrl:HideCommand()
    else
        local faceTo = FaceToAction.New(self.brocastCtx, self.fighterCtrl, self.behindPoint)
        local stand = EscapeStandAction.New(self.brocastCtx, self.fighterCtrl, 0.5)
        local fail = EscapeFailAction.New(self.brocastCtx, self.fighterCtrl, 2.5)
        local faceTo2 = FaceToAction.New(self.brocastCtx, self.fighterCtrl, self.fighterCtrl.originFaceToPos)
        faceTo:AddEvent(CombatEventType.End, stand)
        stand:AddEvent(CombatEventType.End, fail)
        fail:AddEvent(CombatEventType.End, faceTo2)
        faceTo2:AddEvent(CombatEventType.End, self.OnActionEnd, self)
        self.firstAction = faceTo
    end
end

function EscapeAction:Play()
    self:Parse()
    self.effectObject:SetActive(true)
    self.firstAction:Play()
    self.Sync:Play()
end

function EscapeAction:OnActionEnd()
    if self.actionData.is_hit == 1 and self.actionData.self_id == self.brocastCtx.controller.selfData.id then
        self.brocastCtx.controller.fightResult = 0
        self.brocastCtx.controller:EndOfCombat()
    end
    GameObject.DestroyImmediate(self.effectObject)
    self:InvokeAndClear(CombatEventType.End)
end


EscapeStandAction = EscapeStandAction or BaseClass(CombatBaseAction)

function EscapeStandAction:__init(brocastCtx, ctrl, time)
    self.ctrl = ctrl
    self.time = time
end

function EscapeStandAction:Play()
    self.ctrl:PlayAction(FighterAction.BattleMove)
    self:InvokeDelay(self.OnActionEnd, self.time, self)
end

function EscapeStandAction:OnActionEnd()
    -- self.ctrl:PlayAction(FighterAction.BattleStand)
    self:InvokeAndClear(CombatEventType.End)
end

EscapeMoveAction = EscapeMoveAction or BaseClass(CombatBaseAction)

function EscapeMoveAction:__init(brocastCtx, ctrl, point)
    self.ctrl = ctrl
    self.point = point
    self.mList = {
         {eventType = CombatEventType.MoveEnd, func = self.OnActionEnd, owner = self}
    }
end

function EscapeMoveAction:Play()
    local old = self.ctrl.speed
    self.ctrl.speed = 0.167
    self.ctrl:MoveTo(self.point, self.mList)
    self.ctrl.speed = old
end

function EscapeMoveAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end

--逃跑失败
EscapeFailAction = EscapeFailAction or BaseClass(CombatBaseAction)

function EscapeFailAction:__init(brocastCtx, ctrl, time)
    self.brocastCtx = brocastCtx
    self.ctrl = ctrl
    self.time = time
end

function EscapeFailAction:Play()
    self.ctrl:PlayAction(FighterAction.Dead)
    self:Talk()
    self:InvokeDelay(function()self.ctrl:PlayAction(FighterAction.Standup) end, 1.4)
    self:InvokeDelay(function()self.ctrl:PlayAction(FighterAction.BattleStand) end, 2.5)

    self:InvokeDelay(self.OnActionEnd, self.time, self)
end

function EscapeFailAction:Talk()
    local talkAction = TalkBubbleAction.New(self.brocastCtx, self.ctrl.fighterData.id, TI18N("哎哟,我去～{face_1, 8}"))
    talkAction:Play()
end

function EscapeFailAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end
