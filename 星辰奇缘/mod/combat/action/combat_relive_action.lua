-- 复活
ReliveAction = ReliveAction or BaseClass(CombatBaseAction)

function ReliveAction:__init(brocastCtx, fighterCtrl)
    self.fighterCtrl = fighterCtrl
end

function ReliveAction:Play()
    if self.fighterCtrl.buffCtrl ~= nil then
        self.fighterCtrl.buffCtrl:CheckShake()
    end
    self.fighterCtrl:SetDisappear(false)
    self.fighterCtrl.fighterData.is_die = 0
    self.fighterCtrl:GoTo(self.fighterCtrl.originPos)
    self.fighterCtrl:SetAlpha(1)
    self.fighterCtrl:ShowBloodBar()
    self.fighterCtrl:ShowShadow(true)
    self.fighterCtrl.transform.rotation = Quaternion.identity
    -- self.fighterCtrl:UpdateHpBar()
    self.fighterCtrl:PlayAction(FighterAction.Standup)
    self.fighterCtrl:ShowWing()
    self:InvokeDelay(self.OnActionEnd, 1, self)
end

function ReliveAction:OnActionEnd()
    self.fighterCtrl:PlayAction(FighterAction.BattleStand)
    self.fighterCtrl:FaceTo(self.fighterCtrl.originFaceToPos)
    self:InvokeAndClear(CombatEventType.End)
end
