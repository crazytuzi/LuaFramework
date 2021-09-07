-- 捕宠
CatchPetAction = CatchPetAction or BaseClass(CombatBaseAction)

function CatchPetAction:__init(brocastCtx, actionData)
    self.actionData = actionData
    self.attackCtrl = self:FindFighter(self.actionData.self_id)
    self.targetCtrl = self:FindFighter(self.actionData.target_id)

    self.targetBehindPoint = CombatUtil.GetBehindPoint(self.targetCtrl, 0 - (500 / 1000))
    self.speed = self.attackCtrl.speed
    self.firstAction = nil
    self:Parse()
end

function CatchPetAction:Parse()
    local endTaperSupporter = TaperSupporter.New(self.brocastCtx)
    endTaperSupporter:AddEvent(CombatEventType.End, self.OnActionEnd, self)

    local aMove = MoveOnlyAction.New(self.brocastCtx, self.attackCtrl, self.targetBehindPoint, self.speed / 2)
    local playAction = PlayNormalAction.New(self.brocastCtx, self.attackCtrl, FighterAction.Idle, 1)
    local aMoveBack = MoveOnlyAction.New(self.brocastCtx, self.attackCtrl, self.attackCtrl.originPos, self.speed / 6)
    local delay = DelayAction.New(self.brocastCtx, 50)

    aMove:AddEvent(CombatEventType.End, playAction)
    playAction:AddEvent(CombatEventType.End, aMoveBack)
    playAction:AddEvent(CombatEventType.End, delay)
    playAction:AddEvent(CombatEventType.End, FaceToAction.New(self.brocastCtx, self.attackCtrl, self.attackCtrl.originPos))
    aMoveBack:AddEvent(CombatEventType.End, endTaperSupporter)

    if self.actionData.is_hit == 1 then
        playAction:AddEvent(CombatEventType.End, function() self:Alert(TI18N("捕捉成功")) end)
        local petMove = MoveOnlyAction.New(self.brocastCtx, self.targetCtrl, self.attackCtrl.originPos, self.speed / 6)
        delay:AddEvent(CombatEventType.End, petMove)
        petMove:AddEvent(CombatEventType.End, endTaperSupporter)
        petMove:AddEvent(CombatEventType.End, function() self:HideFighter(self.targetCtrl) end)
    else
        -- playAction:AddEvent(CombatEventType.End, function() self:Alert(TI18N("捕捉失败")) end)
        local x = (self.targetCtrl.originPos.x + self.attackCtrl.originPos.x) / 2
        local z = (self.targetCtrl.originPos.z + self.attackCtrl.originPos.z) / 2
        local petMove = MoveOnlyAction.New(self.brocastCtx, self.targetCtrl, Vector3(x, self.targetCtrl.originPos.y, z), self.speed / 6)
        local petMoveBack = MoveOnlyAction.New(self.brocastCtx, self.targetCtrl, self.targetCtrl.originPos, self.speed / 3)
        petMove:AddEvent(CombatEventType.End, petMoveBack)
        petMove:AddEvent(CombatEventType.End, FaceToAction.New(self.brocastCtx, self.targetCtrl, self.targetCtrl.originPos))
        petMoveBack:AddEvent(CombatEventType.End, endTaperSupporter)
        petMoveBack:AddEvent(CombatEventType.End, FaceToAction.New(self.brocastCtx, self.targetCtrl, self.targetCtrl.originFaceToPos))
        delay:AddEvent(CombatEventType.End, petMove)
    end
    self.firstAction = aMove
end

function CatchPetAction:Play()
    self.firstAction:Play()
end

function CatchPetAction:OnActionEnd()
    self.attackCtrl:FaceTo(self.attackCtrl.originFaceToPos)
    self:InvokeAndClear(CombatEventType.End)
end

function CatchPetAction:HideFighter(ctrl)
    -- ctrl:SetAlpha(0)
    CombatUtil.SetMesh(ctrl.tpose, false)
    ctrl:HideBloodBar()
    ctrl:HideCommand()
    ctrl:HideNameText()
    ctrl:SetDisappear(true)
    ctrl:ShowShadow(false)
end

function CatchPetAction:Alert(msg)
    NoticeManager.Instance:FloatTipsByString(msg)
end
