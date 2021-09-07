 -- 技能动作播放
SkillMotionAction = SkillMotionAction or BaseClass(CombatBaseAction)

function SkillMotionAction:__init(brocastCtx, majorCtx, actionData)
   self.majorCtx = majorCtx
   self.actionData = actionData
   self.motionId = 1000
   local combatSkillObj = brocastCtx.combatMgr:GetCombatSkillObject(actionData.skill_id, actionData.skill_lev)
   if combatSkillObj == nil then
       Log.Error(string.format("[战斗]缺少战斗技能信息:skillId.%s, skillLev.%s", actionData.skill_id, actionData.skill_lev))
   end
   self.motionId = 1000
   if #combatSkillObj.motion_id == 1 then
       self.motionId = combatSkillObj.motion_id[1]
   elseif #combatSkillObj.motion_id > 1 then
       self.motionId = self.majorCtx:GetMotionId(actionData)
   end

   self.controller = self:FindFighter(actionData.self_id)

   if self.controller ~= nil and self.motionId == 9999 and self.controller.fighterData.type == FighterType.Role then
       local classes = self.controller.fighterData.classes
       self.motionId = CombatUtil.GetNormalSKillMotion(classes)
   elseif self.controller ~= nil and self.motionId == 9999 and (self.controller.fighterData.type == FighterType.Pet or self.controller.fighterData.type == FighterType.Child) then
       self.motionId = 1000
   elseif self.controller ~= nil and self.motionId == 9999 then
        self.motionId = 1000
   end
   self.attackEvents = {
       {eventType = CombatEventType.Start, func = self.OnStart, owner = self}
       ,{eventType = CombatEventType.Hit, func = self.OnHit, owner = self}
       ,{eventType = CombatEventType.MultiHit, func = self.OnMultiHit, owner = self}
       ,{eventType = CombatEventType.End, func = self.OnEnd, owner = self}
   }
   self.speed = 1
   self.specialMotionIds = {9997}
   self.fastSkill = {60068, 120050, 120201} -- 加快动作播放速度的技能
   if table.containValue(self.fastSkill, actionData.skill_id) then
      self.speed = 3.5
   end
   
    -- 熊猫的被动技能60517风雷护盾使用特殊动作3000
    -- 狮子的被动技能60536-60541轮盘x使用特殊动作3000
    if self.controller ~= nil and self.controller.fighterData.type == FighterType.Pet then
        local modelPath, ctrlPath, skinPath, modelId, usePack = CombatManager.Instance.controller:GetNPCResources(actionData.self_id)
        if modelId == 30257 or modelId == 30057 or modelId == 30157 or modelId == 30257 or modelId == 30457 then
            for _, passive_skill in ipairs(actionData.show_passive_skills) do
                if 60517 == passive_skill.skill_id then
                    self.motionId = 3000
                end
            end
        elseif modelId == 30062 or modelId == 30162 or modelId == 30262 then
            for _, passive_skill in ipairs(actionData.show_passive_skills) do
                if 60536 <= passive_skill.skill_id and 60541 >= passive_skill.skill_id then
                    self.motionId = 3000
                end
            end
        end
    end
end

function SkillMotionAction:Play()
    if  self.controller ~= nil and not table.containValue(self.specialMotionIds, self.motionId) then
        self.controller:PlaySkill(self.motionId, self.attackEvents, self.speed, self.actionData.skill_id)
    else
        self:OnStart()
        self:OnHit()
        self:OnMultiHit()
        self:OnEnd()
    end
end

function SkillMotionAction:OnStart()
    self:InvokeAndClear(CombatEventType.Start)
end

function SkillMotionAction:OnHit()
    self:InvokeAndClear(CombatEventType.Hit)
end

function SkillMotionAction:OnMultiHit()
    self:InvokeAndClear(CombatEventType.MultiHit)
end

function SkillMotionAction:OnEnd()
    if self.controller ~= nil and not table.containValue(self.specialMotionIds, self.motionId) then
        self.controller:PlayAction(FighterAction.BattleStand)
    end
    LuaTimer.Add(100, function () self.OnActionEnd(self) end)
    -- ctx:InvokeDelay(self.OnActionEnd, 0.01, self)
end

function SkillMotionAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end
