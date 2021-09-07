-- 人物召唤宠物
SummonPetAction = SummonPetAction or BaseClass(CombatBaseAction)

function SummonPetAction:__init(brocastCtx, actionData)
    self.actionData = actionData
    self.controller = self:FindFighter(self.actionData.self_id)
    self.fighterData = self.controller.fighterData
    self.motionId = 1000
    local classes = self.fighterData.classes
    if self.fighterData.type == FighterType.Role or self.fighterData.type == FighterType.Cloner then
        self.motionId = CombatUtil.GetNormalSKillMotion(classes)
    end

    self.attackEvents = {
        {eventType = CombatEventType.Start, func = self.OnStart, owner = self}
        ,{eventType = CombatEventType.Hit, func = self.OnHit, owner = self}
        ,{eventType = CombatEventType.MultiHit, func = self.OnMultiHit, owner = self}
        ,{eventType = CombatEventType.End, func = self.OnActionEnd, owner = self}
    }
end

function SummonPetAction:Play()
    if self.fighterData.type == FighterType.Role or self.fighterData.type == FighterType.Cloner then
        self.controller:PlaySkill(self.motionId, self.attackEvents)
    else
        self:OnHit()
        self:OnActionEnd()
    end
end

function SummonPetAction:OnStart()
    self:InvokeAndClear(CombatEventType.Start)
end

function SummonPetAction:OnHit()
    self:InvokeAndClear(CombatEventType.Hit)
end

function SummonPetAction:OnMultiHit()
    self:InvokeAndClear(CombatEventType.MultiHit)
end

function SummonPetAction:OnActionEnd()
    self.controller:PlayAction(FighterAction.BattleStand)
    self:InvokeAndClear(CombatEventType.End)
end
