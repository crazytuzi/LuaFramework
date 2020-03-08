local Lplus = require("Lplus")
local FightUnit = Lplus.Class("FightUnit")
local FightModel = require("Main.Fight.FightModel")
local FighterStatus = require("netio.protocol.mzm.gsp.fight.FighterStatus")
local ECGUIMan = Lplus.ForwardDeclare("ECGUIMan")
local EC = require("Types.Vector3")
local FightMgr = Lplus.ForwardDeclare("FightMgr")
local DAMAGE_DURATION = 1
local ECFxMan = require("Fx.ECFxMan")
local GameUnitType = require("consts/mzm/gsp/common/confbean/GameUnitType")
local SkillAttackType = require("consts.mzm.gsp.skill.confbean.SkillPlayType")
local BeHitType = require("consts.mzm.gsp.skill.confbean.SpecialActionEnum")
local FIGHT_TYPE = require("netio.protocol.mzm.gsp.fight.Fight")
local AttachType = require("consts.mzm.gsp.skill.confbean.EffectGuaDian")
local MovePlayType = require("consts.mzm.gsp.skill.confbean.MovePlayType")
local DEATH_TYPE = require("consts.mzm.gsp.skill.confbean.DeadStyle")
local BONE_EFF_POS = require("consts.mzm.gsp.skill.confbean.BonePositionEnum")
local MOVE_POS_TYPE = require("consts.mzm.gsp.skill.confbean.MovePosType")
local AttackResultBean = require("netio.protocol.mzm.gsp.fight.AttackResultBean")
local CounterAttack = require("netio.protocol.mzm.gsp.fight.CounterAttack")
local PlayChangeFighter = require("netio.protocol.mzm.gsp.fight.PlayChangeFighter")
local PlayChangeModel = require("netio.protocol.mzm.gsp.fight.PlayChangeModel")
local PlaySkillEnum = require("netio.protocol.mzm.gsp.fight.PlaySkill")
local GenderEnum = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
local EffectStatusType = require("consts.mzm.gsp.skill.confbean.EffectStatusType")
local FightUtils = require("Main.Fight.FightUtils")
local SkillPlayDirection = require("consts.mzm.gsp.skill.confbean.SkillPlayDirection")
local Buff = require("netio.protocol.mzm.gsp.fight.Buff")
local SkillSpecialAct = require("consts.mzm.gsp.skill.confbean.SkillSpecialAct")
local FightStateGroupState = require("consts.mzm.gsp.fight.confbean.FightStateGroupState")
local EffectMoveType = require("consts.mzm.gsp.skill.confbean.EffectMoveType")
local DAMAGE_TYPE = {
  HP = 1,
  MP = 2,
  RAGE = 3
}
local DEATH_STATUS = {
  ALIVE = 0,
  DEAD = 1,
  FAKEDEAD = 2
}
local BEHIT_POINT_TYPE = {
  PASS = 0,
  UPDATE_STATUS = 1,
  NORMAL = 2
}
local GRAVITY = 9.8
local DAMAGE_DELAY = 0.5
local SHATTER_TYPE = {HORIZONTAL = 1, VERTICAL = 2}
local LOOP_EFFECT_TYPE = {COMMON = 1, BLACKHOLE = 2}
local defenseEffect
local def = FightUnit.define
def.const("number").MAX_VALUE = 9999999
def.field("number").fightUnitType = 0
def.field("number").id = 0
def.field("userdata").roleId = nil
def.field("number").cfgId = 0
def.field("string").name = ""
def.field("number").menpai = -1
def.field("number").level = 0
def.field("number").gender = 0
def.field("number").initMenpai = -1
def.field("number").initGender = 0
def.field("number").pos = 0
def.field("number").modelId = 0
def.field("table").modelInfo = nil
def.field("table").status = nil
def.field("table").attack_result = nil
def.field("table").influences = nil
def.field("number").buff_status_type = 0
def.field("number").isDead = 0
def.field("table").model = nil
def.field("table").masterModel = nil
def.field("number").team = 0
def.field("number").group = -1
def.field("boolean").in_turn = false
def.field("boolean").online = true
def.field("number").actionType = 0
def.field("number").skillId = 0
def.field("number").defaultSkillId = 0
def.field("table").targets = nil
def.field("table").curAttackTargets = nil
def.field("table").beHitPoints = nil
def.field("number").totalHitNum = 0
def.field("table").curHitInfo = nil
def.field("table").beHitEffect = nil
def.field("table").damageLabels = nil
def.field("table").skill = nil
def.field("table").hitbackInfo = nil
def.field("table").dodgeInfo = nil
def.field("number").defendTime = -1
def.field("table").valishTime = nil
def.field("table").appearTime = nil
def.field("number").hitupTime = -1
def.field("table").hitupInitPos = nil
def.field("table").hitupTargetPos = nil
def.field("number").hitupSpeed = 0
def.field("table").additionalAttack = nil
def.field("table").flyMount = nil
def.field("boolean").isActionEnded = true
def.field("number").hp = 0
def.field("number").hpmax = 0
def.field("number").mp = 0
def.field("number").mpmax = 0
def.field("number").rage = 0
def.field("number").ragemax = 0
def.field("table").protect = nil
def.field("table").counterAttack = nil
def.field("boolean").isProtecter = false
def.field("boolean").protectReady = false
def.field("boolean").inDefense = false
def.field("boolean").hasCombo = false
def.field("boolean").isCounterAttacked = false
def.field("table").reviveStatus = nil
def.field("number").reviveSkillId = 0
def.field("number").playTime = -1
def.field("table").effectList = nil
def.field("table").playcfg = nil
def.field("table").soundCfg = nil
def.field("table").childEffects = nil
def.field("table").nextCallbacks = nil
def.field("table").deathInfo = nil
def.field("table").afterStatus = nil
def.field("table").delEffects = nil
def.field("boolean").showSelect = false
def.field("function").reviveCallback = nil
def.field("table").shake = nil
def.field("table").skillUsedData = nil
def.field("boolean").isHugeUnit = false
def.field("table").usedSkills = nil
def.field("table").deathSkills = nil
def.field("table").consecutiveAttack = nil
def.field("table").statusList = nil
def.field("number").updateStatusDuration = 0
def.field("table").fightMgr = nil
def.field("number").attr_class = 0
def.field("number").attr_class_level = 0
def.field("table").life_link_fxs = nil
def.field("table").black_hole_fxs = nil
def.field("table").specialAct = nil
def.field("table").avatars = nil
def.field("number").state_group = 0
def.field("number").state = 0
def.field("boolean").isInterrupted = false
def.field("userdata").pseudo_model = nil
def.field("table").loop_fxs = nil
def.field("table").next_target_data = nil
def.field("number").appearanceId = 0
def.field("boolean").isInModelChange = false
def.field("function").onModelChangeDone = nil
def.final("=>", FightUnit).new = function()
  return FightUnit()
end
def.final("number", "number", "number", "table", "string", "userdata", "number", "table", "=>", FightUnit).Create = function(id, team, pos_idx, modelInfo, name, nameColor, unitType, mgr)
  local inst = FightUnit()
  inst.model = FightModel.new(modelInfo.modelid, name, nameColor, unitType)
  inst.team = team
  inst.pos = pos_idx
  inst.model.fighterId = id
  inst.fightMgr = mgr
  local teamPos = mgr.fightPos[team].Pos
  local pos = teamPos[pos_idx]
  local dir = FightConst.TeamDir[team]
  inst.model:SetDefaultParentNode(inst.fightMgr.fightPlayerNodeRoot)
  inst.fightUnitType = unitType
  inst.id = id
  inst.appearanceId = id
  inst.name = name
  inst.model.initModelInfo = modelInfo
  inst.modelInfo = modelInfo
  if not _G.LoadModel(inst.model, modelInfo, pos.x, pos.y, dir, true, true) then
    return nil
  end
  inst.modelId = inst.model.mModelId
  inst.beHitPoints = {}
  inst.damageLabels = {}
  inst.childEffects = {}
  inst.delEffects = {}
  inst.nextCallbacks = {}
  local modelcfg = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, inst.modelId)
  if modelcfg == nil then
    warn("[[Fight]CreateFightUnit]model cfg is nil for id: ", inst.modelId)
  end
  local soundCfgId = DynamicRecord.GetIntValue(modelcfg, "sound")
  if soundCfgId and soundCfgId > 0 then
    inst.soundCfg = FightUtils.GetModelSound(soundCfgId)
  end
  return inst
end
def.method("number").UpdateShow = function(self, tick)
  self.model:Update(tick)
  self:UpdateHitUp(tick)
  self:UpdateDamage(tick)
  self:UpdateDefend(tick)
  self:UpdateValish(tick)
  self:UpdateShake(tick)
  self:UpdateLifeLinks()
  self:UpdateLoopFxs(tick)
end
def.method("number").Update = function(self, tick)
  if self.model == nil then
    return
  end
  _G.SafeCall(FightUnit.UpdateShow, self, tick)
  for k, callinfo in pairs(self.nextCallbacks) do
    callinfo.delay = callinfo.delay - tick
    if callinfo.delay <= 0 and (callinfo.condition == nil or callinfo.condition()) and callinfo.callback then
      self.nextCallbacks[k] = nil
      callinfo.callback(self)
      break
    end
  end
  if 0 < self.playTime then
    self.playTime = self.playTime - tick
    if 0 >= self.playTime then
      self:OnAttackEnd()
    end
  end
end
def.method("number").UpdateLoopFxs = function(self, tick)
  if self.loop_fxs then
    for k, v in pairs(self.loop_fxs) do
      if v.time then
        v.time = v.time + tick
      end
      if v.duration and v.time >= v.duration then
        ECFxMan.Instance():Stop(v.fx)
        self.loop_fxs[k] = nil
      end
    end
  end
end
def.method().PlayEffectList = function(self)
  for k, v in pairs(self.effectList) do
    self.fightMgr.playController:AddEvent({
      startTime = v.delay,
      callback = function(ctx)
        self:DoPlayEffect(ctx)
      end,
      context = v
    })
    self.effectList[k] = nil
  end
end
def.method("table").DoPlayEffect = function(self, effres)
  local posInfo = self:GetEffectPos(effres.effectMoveType, effres.posType, effres.attachPoint, effres.effectPosDest)
  for _, pos in pairs(posInfo) do
    if effres.effectMoveType ~= EffectMoveType.NONE then
      pos.playType = effres.effectMoveType
    end
    if pos.playType == EffectMoveType.FOLLOW then
      local rotationOffset = effres.rotate or 0
      self.model:AddChildEffect(effres.path, effres.attachPoint, rotationOffset)
    elseif pos.playType == EffectMoveType.STATIC then
      local u3dpos = Map2DPosTo3D(pos.from.x, pos.from.y)
      if pos.target then
        u3dpos = EC.Vector3.new(u3dpos.x, u3dpos.y + pos.target.model:GetBodyPartHeight(effres.attachPoint), u3dpos.z)
      end
      local rotation = self.model.m_model.localRotation
      if effres.rotate ~= 0 then
        local model_angle = self.model.m_model.transform.eulerAngles
        rotation = Quaternion.Euler(EC.Vector3.new(model_angle.x, model_angle.y + effres.rotate, model_angle.z))
      end
      self.fightMgr:PlayEffect(effres.path, nil, u3dpos, rotation)
      if self.avatars then
        for i = 1, #self.avatars do
          local avatar_pos = self.avatars:GetPos()
          local from_3dpos = Map2DPosTo3D(avatar_pos.x, avatar_pos.y)
          self.fightMgr:PlayEffect(effres.path, nil, from_3dpos, rotation)
        end
      end
    elseif pos.playType == EffectMoveType.FLY then
      local offsetY = 0
      local pelvis = self.model.m_model:FindDirect("Root/Bip01 Pelvis")
      if pelvis then
        offsetY = pelvis.localPosition.y
      else
        offsetY = self.model:GetBodyPartHeight(effres.attachPoint)
      end
      local from = Map2DPosTo3D(pos.from.x, pos.from.y)
      from = EC.Vector3.new(from.x, from.y + offsetY, from.z)
      local to = Map2DPosTo3D(pos.to.x, pos.to.y)
      if pos.toOffsetY and 0 < pos.toOffsetY then
        to = EC.Vector3.new(to.x, to.y + pos.toOffsetY, to.z)
      end
      local dist = math.sqrt((to.x - from.x) ^ 2 + (to.y - from.y) ^ 2 + (to.z - from.z) ^ 2)
      if effres.behitTime and 0 < effres.behitTime then
        self.fightMgr:PlayMovingEffect(effres.path, from, to, nil, dist / effres.behitTime, effres.behitTime, 0.2)
      else
        warn("[Fight]no fly time for effect: ", effres.path)
      end
    elseif pos.playType == EffectMoveType.LINK and effres.duration and 0 < effres.duration then
      local offsetY = self.model:GetBodyPartHeight(effres.attachPoint)
      local pelvis = self.model.m_model:FindDirect("Root/Bip01 Pelvis")
      if pelvis then
        offsetY = offsetY + pelvis.localPosition.y
      end
      local from = Map2DPosTo3D(pos.from.x, pos.from.y)
      from = EC.Vector3.new(from.x, from.y + offsetY, from.z)
      local to = Map2DPosTo3D(pos.to.x, pos.to.y)
      if pos.toOffsetY and 0 < pos.toOffsetY then
        to = EC.Vector3.new(to.x, to.y + pos.toOffsetY, to.z)
      end
      local dir = from - to
      local fx = self.fightMgr:PlayEffect(effres.path, nil, EC.Vector3.zero, Quaternion.identity)
      local fxpos = (from + to) / 2
      fx.localPosition = fxpos
      fx.localScale = EC.Vector3.new(1, 1, dir:get_Length() - 1)
      dir:Normalize()
      fx.forward = dir
      if self.loop_fxs == nil then
        self.loop_fxs = {}
      end
      self:AddLoopEffect({
        fx = fx,
        duration = effres.duration,
        time = 0,
        type = LOOP_EFFECT_TYPE.COMMON
      })
    end
    if 0 < effres.sound then
      self.fightMgr:PlaySoundEffect(effres.sound)
    end
  end
end
def.method("table").DoSpecialAct = function(self, sp_act)
  if sp_act == nil then
    return
  end
  if sp_act.act == SkillSpecialAct.AVATAR_APPEAR then
    if self.avatars == nil then
      self.avatars = {}
    end
    local moveAction = FightUtils.GetMoveActionCfg(self.skill.moveAction)
    for i = 2, #self.curAttackTargets do
      local target = self.curAttackTargets[i]
      local avatar = self.model:Clone(self.name, GetColorData(701300000))
      table.insert(self.avatars, avatar)
      local pos = self.fightMgr.fightPos[target.team].Attackpos_front[target.pos]
      if moveAction then
        pos = self:GetSpecifiedTargetPos(target, moveAction.targetPos)
      end
      avatar:SetPos(pos.x, pos.y)
      avatar:SetAlpha(0.01)
      avatar:Play(ActionName.FightStand)
    end
    self.avatars.appear_duration = sp_act.duration
    self.avatars.time = 0
  elseif sp_act.act == SkillSpecialAct.AVATAR_DISAPPEAR then
    if self.avatars then
      self.avatars.disappear_duration = 1
      self.avatars.time = 0
    end
  elseif sp_act.act == SkillSpecialAct.CHANGE_MODEL then
  end
end
def.method("number").UpdateValish = function(self, tick)
  if self.valishTime then
    self.valishTime.time = self.valishTime.time - tick
    if self.valishTime.time <= 0 then
      self.model:SetAlpha(0)
      self.model:SetVisible(false)
      self.valishTime = nil
      self:OnMoveEnd()
    else
      local alpha = self.valishTime.time / self.valishTime.duration
      self.model:ChangeAlpha(alpha)
    end
  end
  if self.appearTime then
    self.appearTime.time = self.appearTime.time - tick
    if 0 >= self.appearTime.time then
      self.model:CloseAlpha()
      self.appearTime = nil
      if self.flyMount then
        self.flyMount:Stand()
      end
      self:OnMoveEnd()
    elseif 0 < self.appearTime.duration then
      local alpha = 1 - self.appearTime.time / self.appearTime.duration
      self.model:ChangeAlpha(alpha)
    end
  end
  if self.avatars and self.avatars.disappear_duration and 0 < self.avatars.disappear_duration then
    self.avatars.time = self.avatars.time + tick
    local s = (self.avatars.disappear_duration - self.avatars.time) / self.avatars.disappear_duration
    if s <= 0.001 then
      for i = 1, #self.avatars do
        self.avatars[i]:CloseAlpha()
        self.avatars[i]:Destroy()
      end
      self.avatars = nil
    else
      for i = 1, #self.avatars do
        self.avatars[i]:ChangeAlpha(0.75 * s)
      end
    end
  end
  if self.avatars and self.avatars.appear_duration and 0 < self.avatars.appear_duration then
    self.avatars.time = self.avatars.time + tick
    local s = self.avatars.time / self.avatars.appear_duration
    if s > 1 then
      self.avatars.appear_duration = nil
      self.avatars.time = 0
    else
      for i = 1, #self.avatars do
        self.avatars[i]:ChangeAlpha(0.75 * s)
      end
    end
  end
end
def.method("number").UpdateDefend = function(self, tick)
  if self.defendTime <= -1 then
    return
  end
  self.defendTime = self.defendTime - tick
  if self.defendTime <= 0 then
    self.defendTime = -1
    self:BehitEnd()
  end
end
def.method("number", "number").SetHp = function(self, v, maxv)
  self.hp = v
  self.hpmax = maxv
  local hprate = 0
  if self.hpmax > 0 then
    hprate = v / maxv
  end
  self.model:SetHp(hprate)
  if self.fightMgr:tryget("SetUnitHp") then
    self.fightMgr:SetUnitHp(self, hprate)
  end
end
def.method("number", "number").SetMp = function(self, v, maxv)
  self.mp = v
  self.mpmax = maxv
  local mprate = 0
  if self.mpmax > 0 then
    mprate = v / maxv
  end
  self.model:SetMp(mprate)
  if self.fightMgr:tryget("SetUnitMp") then
    self.fightMgr:SetUnitMp(self, mprate)
  end
end
def.method("number", "number").SetRage = function(self, v, maxv)
  self.rage = v
  self.ragemax = maxv
end
def.method().SetFakeDeath = function(self)
  self.isDead = DEATH_STATUS.FAKEDEAD
  self.model.isDead = true
end
def.method("=>", "table").GetShapeShiftCardInfo = function(self)
  if self.model == nil or self.model.initModelInfo == nil then
    return nil
  end
  local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
  local info = {}
  info.cardId = self.model.initModelInfo.extraMap[ModelInfo.CHANGE_MODEL_CARD_CFGID] or 0
  info.level = self.model.initModelInfo.extraMap[ModelInfo.CHANGE_MODEL_CARD_LEVEL] or 0
  info.mini = self.model.initModelInfo.extraMap[ModelInfo.CHANGE_MODEL_CARD_MINI] or 0
  return info
end
def.method("string", "number", "number", "number", "function", "boolean", "number", "number").MoveTo = function(self, actionName, x, y, duration, callback, bSetDir, movetype, effid)
  if self.model == nil then
    Debug.LogWarning("[Fight]model is nil when moveto")
    return
  end
  if self.masterModel or self.isHugeUnit then
    if callback then
      callback(self)
    end
    return
  end
  local fx
  local function OnEnd()
    if fx then
      ECFxMan.Instance():Stop(fx)
    end
    self.model:SetPos(x, y)
    if callback then
      callback(self)
    end
  end
  self.model:Play(actionName)
  self.model:MoveTo(x, y, OnEnd, duration, bSetDir, movetype)
  if effid > 0 then
    local eff = GetEffectRes(effid)
    fx = self.model:AddChildEffect(eff.path, AttachType.BODY, 0)
    if 0 < eff.sound then
      self.fightMgr:PlaySoundEffect(eff.sound)
    end
  end
end
def.method().Attack = function(self)
  if self.model == nil then
    warn("[Fight]model is nil when play attack: ", self.name)
    return
  end
  if self.playcfg == nil then
    warn("[Fight]playcfg is nil when play attack: ", self.name)
    return
  end
  if self.skill == nil then
    warn("[Fight]skill is nil when play attack: ", self.name)
    return
  end
  if self.model:IsInLoading() then
    self:AddNextAction("NextAttack", function()
      return self.model:IsLoaded()
    end, function()
      self:Attack()
    end)
    return
  end
  local target = self.curAttackTargets and self.curAttackTargets[1]
  if target and target.counterAttack then
    self:AddNextAction("NextAttack", function()
      return target.counterAttack == nil
    end, function()
      self:Attack()
    end)
    return
  end
  self.fightMgr:AddLog(string.format("%s(%d) attack target: %s(%d)", self.name, self.id, tostring(target and target.name), target and target.id or 0))
  if target and self.playcfg and 0 < #self.playcfg.phases and (target.reviveStatus or target:CheckFightStatus(FighterStatus.STATUS_RELIVE)) then
    self:AddNextAction("NextAttack", function()
      return target.reviveStatus == nil and not target:CheckFightStatus(FighterStatus.STATUS_RELIVE)
    end, function()
      self:Attack()
    end)
    return
  end
  self:PlayEffectList()
  if target then
    local atk_ret = target.attack_result and target.attack_result[1]
    if atk_ret and atk_ret.attackOthers and 0 < #atk_ret.attackOthers then
      self.consecutiveAttack = atk_ret.attackOthers
    end
    if atk_ret then
      local shareTargetData = atk_ret.shareDamageTargets
      if shareTargetData and #shareTargetData > 0 then
        for _, stdata in pairs(shareTargetData) do
          if self:CheckSpecFightStatusSet(stdata.shareDamageStatus, FighterStatus.STATUS_BLACKHOLE_DAMAGE) and self.playcfg.skillPlayType == SkillAttackType.SINGLE then
            self:SetAffiliatedAttack(stdata)
          end
        end
      end
    end
  end
  if not self.counterAttack and target then
    target.hasCombo = target:CheckCombo(#self.beHitPoints)
    if target.hasCombo then
      local comboPhase = {}
      comboPhase[1] = 0
      comboPhase[2] = self.playcfg.phases[1][2]
      table.insert(self.playcfg.phases, 2, comboPhase)
    end
    target:CheckCounterAttack(#self.beHitPoints)
    self.fightMgr:AddLog(string.format("[FightLog]%s(%d) attack target %s(%d), has combo: %s, counterAttack: %s", self.name, self.id, target.name, target.id, tostring(target.hasCombo), tostring(target.counterAttack)))
    if target.counterAttack then
      target.targets = {self}
      target.curAttackTargets = target.targets
      self.isCounterAttacked = true
      local attack_result = {}
      attack_result.targetStatus = target.counterAttack.targetStatus
      attack_result.attackerStatus = target.counterAttack.attackerStatus
      attack_result.statusMap = target.counterAttack.statusMap
      self.influences = target.counterAttack.influences
      if self.attack_result then
        table.insert(self.attack_result, 1, attack_result)
      else
        self.attack_result = {attack_result}
      end
    end
  end
  if self.counterAttack then
    if target then
      self.fightMgr:AddLog(string.format("[FightLog]%s(%d) counterAttack target: %s(%d)", self.name, self.id, target.name, target.id))
    else
      self.fightMgr:AddLog(string.format("[FightLog]%s(%d) counterAttack, but target is nil", self.name, self.id))
    end
  end
  local actModel = self:GetActModel()
  if target and target.additionalAttack then
    self.additionalAttack = target.additionalAttack
    target.additionalAttack = nil
    self.fightMgr:AddLog(string.format("[FightLog]%s(%d) attack target %s(%d), has additional attack", self.name, self.id, target.name, target.id))
  end
  if self.skill.boneEffectId and 0 < self.skill.boneEffectId then
    self:SetBoneEffect(self.skill.boneEffectId)
  end
  if self.skill.cameraMoveId and 0 < self.skill.cameraMoveId then
    self.fightMgr:CameraCloseUpToTarget(self, self.skill.cameraMoveId)
  end
  if self.skill.ghostEffId and 0 < self.skill.ghostEffId then
    self:PlayGhostEffect(self.skill.ghostEffId)
  end
  self:SetAttackDir(actModel)
  self.playTime = 0
  if self.skill.effectDuration then
    self.playTime = self.skill.effectDuration
  end
  if self.skill.specialActDuraction and self.playTime < self.skill.specialActDuraction then
    self.playTime = self.skill.specialActDuraction
  end
  local isBoomingSkill = self.playcfg ~= nil and self.playcfg.skillType == PlaySkillEnum.DEATH_BOOMING
  if isBoomingSkill and self.playTime < FightConst.DEATH_EXPLODE_DURATION then
    self.playTime = FightConst.DEATH_EXPLODE_DURATION
  end
  if not isBoomingSkill and self.skill.actionName then
    local actionName = self.skill.actionName
    if self.masterModel then
      local masterActionName = self.fightMgr:GetMasterActionName(self.pos, self.skill.actionName)
      if masterActionName ~= "" then
        actionName = masterActionName
      end
    end
    if actModel:IsPlaying(actionName) then
      actModel:StopAnim(actionName)
    end
    if not actModel:HasAnimClip(actionName) then
      actionName = ActionName.Attack1
      if _G.isDebugBuild then
        Debug.LogError(string.format("action(%s) not found for model(%d)", actionName, actModel.mModelId))
      end
    end
    local actionDuration = actModel:GetAniDuration(actionName)
    if actionDuration > self.playTime then
      self.playTime = actionDuration
    end
    local ret = actModel:PlayAnim(actionName, function()
      if self.skill.needReset or self.playcfg and #self.playcfg.phases <= 1 and not self.skill.hasRelativeOffset then
        self:Stand()
      end
    end)
    if actModel.mECPartComponent then
      actModel.mECPartComponent:PlayAnimation(actionName, ActionName.Attack1)
    end
    if self.avatars then
      for i = 1, #self.avatars do
        self.avatars[i]:Play(actionName)
      end
    end
    if not ret then
      self.fightMgr:AddLog(string.format("[FightLog]%s Play animation failed : %s", self.name, actionName))
      self:EndAllAction()
      return
    end
  end
  if self.skill.sound and 0 < self.skill.sound then
    self.fightMgr:PlaySoundEffect(self.skill.sound)
  end
  if actModel.mECWingComponent then
    actModel.mECWingComponent:Attack()
  end
  if actModel.mECFabaoComponent then
    actModel.mECFabaoComponent:PlayShifaEffect()
  end
  if self.playcfg and self.playcfg.totalPhaseNum == 1 and #self.beHitPoints == 0 then
    self.fightMgr.playController:AddEvent({
      startTime = 0,
      callback = function(targets)
        self:EndTargetAction(targets)
      end,
      context = self.curAttackTargets
    })
  end
  if self.specialAct then
    self.fightMgr.playController:AddEvent({
      startTime = self.specialAct.delay,
      callback = function(ctx)
        self:DoSpecialAct(ctx)
      end,
      context = self.specialAct
    })
    self.specialAct = nil
  end
  if self.curAttackTargets and #self.curAttackTargets > 0 then
    if self.playcfg then
      self.playcfg.isAttackPhase = 0 < #self.beHitPoints
    end
    if self.curAttackTargets and self.playcfg and self.playcfg.isAttackPhase then
      for k, v in pairs(self.curAttackTargets) do
        v.defendTime = -1
      end
    end
    for k, v in pairs(self.beHitPoints) do
      local behitInfo = v
      self.fightMgr.playController:AddEvent({
        startTime = v.behitTime,
        callback = function(ctx)
          self:OnBehit(ctx)
        end,
        context = behitInfo
      })
      self.totalHitNum = self.totalHitNum + 1
    end
  elseif 0 >= self.playTime then
    self:EndAction()
  end
end
def.method("table").EndTargetAction = function(self, targets)
  if targets == nil then
    return
  end
  for k, v in pairs(targets) do
    if v.id == self.id then
      local islast = self.attack_result == nil or #self.attack_result <= 0
      self.fightMgr:OnActionEnd({
        v.id,
        islast
      })
    else
      v:EndAction()
    end
  end
end
def.method("table").SetAttackDir = function(self, actModel)
  if self.playcfg then
    local target = self.targets and self.targets[1]
    if self.playcfg.movePos == MOVE_POS_TYPE.ENERMY_LOW then
      actModel:SetDir(120)
    elseif self.playcfg.movePos == MOVE_POS_TYPE.ENERMY_TOP then
      actModel:SetDir(300)
      local targetpos = self:GetTargetPos(MOVE_POS_TYPE.ENERMY_LOW)
      actModel.m_model.forward = Map2DPosTo3D(targetpos.x, targetpos.y) - actModel.m_model.localPosition
    elseif self.playcfg.direction == SkillPlayDirection.FRIEND then
      actModel:SetDir(FightConst.TeamDir[self.team] + 180)
    elseif self.playcfg.direction == SkillPlayDirection.TARGET and target then
      if target.id == self.id then
        actModel:SetDir(FightConst.TeamDir[self.team])
      else
        actModel:LookAtTarget(target.model)
      end
    elseif self.playcfg.direction == SkillPlayDirection.ENEMY then
      actModel:SetDir(FightConst.TeamDir[self.team])
    else
      actModel:SetDir(FightConst.TeamDir[self.team])
    end
  end
end
def.method().CheckAndRemoveCurrentPhase = function(self)
  self:RemoveCurrentPhase()
end
def.method().RemoveCurrentPhase = function(self)
  if self.playcfg and self.playcfg.phases and #self.playcfg.phases > 0 and not self.playcfg.curPhaseFinished then
    table.remove(self.playcfg.phases, 1)
    self.playcfg.curPhaseFinished = true
  end
end
def.method("=>", "boolean").HasConsecutiveAttack = function(self)
  return self.consecutiveAttack ~= nil and #self.consecutiveAttack > 0
end
def.method().OnAttackEnd = function(self)
  self:StopGhostEffect(false)
  self:ClearDelEffects()
  local actModel = self:GetActModel()
  if self.skill == nil or not self.skill.hasRelativeOffset then
    actModel:SetDir(FightConst.TeamDir[self.team])
  end
  self:CheckAndRemoveCurrentPhase()
  local target = self.targets and self.targets[1]
  if self.isInterrupted and self.playcfg and self.playcfg.isAttackPhase then
    self.fightMgr:AddLog(string.format("[FightLog]OnAttackEnd, %s(%d) is interrupted", self.name, self.id))
  elseif self.isCounterAttacked then
    self.fightMgr:AddLog(string.format("[FightLog]OnAttackEnd, %s(%d) is CounterAttacked", self.name, self.id))
    self.isCounterAttacked = false
    actModel:Stand()
  elseif self.counterAttack then
    self.fightMgr:AddLog(string.format("[FightLog]OnAttackEnd, %s(%d) has counterAttack, has combo:%s", self.name, self.id, tostring(self.hasCombo)))
    self.counterAttack = nil
    self.playcfg = nil
    if self.hasCombo then
      actModel:Stand()
    elseif self.isActionEnded then
      self:EndAction()
    end
  elseif target and target.hasCombo then
    local function SetComboAttack()
      self:NextPhase()
    end
    if target.reviveStatus or target:CheckFightStatus(FighterStatus.STATUS_RELIVE) then
      self:AddNextAction("ComboAttack", function()
        return target.reviveStatus == nil and not target:CheckFightStatus(FighterStatus.STATUS_RELIVE)
      end, SetComboAttack)
    else
      SetComboAttack()
    end
  elseif not self.status.isRebound then
    if self.additionalAttack and #self.additionalAttack.targets > 0 then
      self:AdditionalAttack()
    else
      self:NextPhase()
    end
  end
end
def.method().AdditionalAttack = function(self)
  local tar = self.fightMgr:GetFightUnit(self.additionalAttack.targets[1])
  if tar then
    local function DoAdditionalAttack()
      tar.attack_result = self.additionalAttack.status_map[tar.id].attackResultBeans
      self.targets = {tar}
      self.curAttackTargets = self.targets
      local playCfg = self:SetAdditionalPhase(constant.FightConst.ATTACK_SKILL)
      if playCfg == nil then
        warn("[Fight]additional attack: no play cfg found!")
        return
      end
      local phase = playCfg.phases[1]
      if phase and phase[1] > 0 then
        local moveCfg = FightUtils.GetSkillPlayPhaseCfg(phase[1])
        if moveCfg then
          local moveAction = FightUtils.GetMoveActionCfg(moveCfg.action)
          local targetPos = self:GetTargetPos(moveAction.targetPos)
          self:MoveTo(moveAction.actionName, targetPos.x, targetPos.y, moveAction.duration, FightUnit.OnAttackRunFinished, true, 0, moveAction.effectId)
        end
      else
        warn("[Fight]additional attack: no move phase found!")
      end
      table.remove(self.additionalAttack.targets, 1)
      if #self.additionalAttack.targets == 0 then
        self.additionalAttack = nil
      end
    end
    if tar.isProtecter then
      self:AddNextAction("AdditionalAttack", function()
        return tar.isProtecter == false
      end, DoAdditionalAttack)
    else
      DoAdditionalAttack()
    end
  end
end
def.method("string", "function", "function").AddNextAction = function(self, k, condition, callback)
  local callinfo = {}
  callinfo.delay = 0
  callinfo.condition = condition
  callinfo.callback = callback
  self.nextCallbacks[k] = callinfo
end
def.method("string", "=>", "boolean").HasNextAction = function(self, k)
  return self.nextCallbacks[k] ~= nil
end
def.method().EndAction = function(self)
  self.isActionEnded = true
  local actModel = self:GetActModel()
  if self.reviveStatus then
    self.status = self.reviveStatus
    self.reviveStatus = nil
  end
  self.fightMgr:AddLog(string.format("[FightLog]end action call: %s(%d)", self.name, self.id))
  local target = self.targets and self.targets[1]
  if self:CheckFightStatus(FighterStatus.STATUS_RELIVE) then
    self.fightMgr:AddLog(string.format("[FightLog]%s(%d) has revive status", self.name, self.id))
    self:Revive()
  elseif self.isInterrupted then
    self.fightMgr:AddLog(string.format("[FightLog]%s(%d) is interrupted", self.name, self.id))
  elseif self.isCounterAttacked then
    self.isCounterAttacked = false
    if actModel then
      actModel:Stand()
    end
    self.fightMgr:AddLog(string.format("[FightLog]%s(%d) is counter attacked", self.name, self.id))
  elseif self.counterAttack then
    if target and target.isInterrupted then
      self.fightMgr:AddLog(string.format("[FightLog]%s(%d) counterAttack, but target(%s(%d)) is interrupted , wait to be done", self.name, self.id, target.name, target.id))
      self:AddNextAction("InterruptResume", function()
        return not target.isInterrupted
      end, function()
        self:CounterAttack()
      end)
    elseif target and (target.isCounterAttacked or target.status.isRebound) then
      self.fightMgr:AddLog(string.format("[FightLog]%s(%d) has counter attack to be done", self.name, self.id))
      target:AddNextAction("CounterAttack", function()
        return not target.isCounterAttacked and not target.status.isRebound and target.reviveStatus == nil and not target:CheckFightStatus(FighterStatus.STATUS_RELIVE)
      end, function()
        self:CounterAttack()
      end)
    else
      self:CounterAttack()
    end
  elseif target and target.hasCombo then
    if target and target.isInterrupted then
      self.fightMgr:AddLog(string.format("[FightLog]%s(%d) target(%s(%d)) has combo but is interrupted , wait to be done", self.name, self.id, target.name, target.id))
      self:AddNextAction("InterruptResume", function()
        return not target.isInterrupted
      end, function()
        self:EndAction()
      end)
      return
    end
    self.fightMgr:AddLog(string.format("[FightLog]%s(%d) has combo, target: %s(%d), counterAttack:%s", self.name, self.id, target.name, target.id, tostring(target.counterAttack)))
    if not self:HasNextAction("ComboAttack") then
      local function SetComboAttack()
        self:NextPhase()
      end
      self:AddNextAction("ComboAttack", function()
        return target.counterAttack == nil and target.reviveStatus == nil and not target:CheckFightStatus(FighterStatus.STATUS_RELIVE)
      end, SetComboAttack)
    end
    if actModel then
      actModel:Stand()
    end
  else
    if self.isDead == DEATH_STATUS.ALIVE then
      if self:CheckFightStatus(FighterStatus.STATUS_COUNTER_ATTACK) then
        self.fightMgr:AddLog(string.format("[FightLog]%s(%d) clear counter status and go next, target status(%s)", self.name, self.id, tostring(target and target.counterAttack)))
        local function DoNext()
          self:ClearFightStatus(FighterStatus.STATUS_COUNTER_ATTACK)
          self:NextPhase()
        end
        if target and target.counterAttack then
          self:AddNextAction("Return", function()
            return target.counterAttack == nil
          end, DoNext)
        else
          DoNext()
        end
        return
      elseif self.playcfg and self.playcfg.phases and #self.playcfg.phases > 0 then
        if self.playcfg.curPhaseFinished then
          self:NextPhase()
        end
        return
      elseif self.model then
        local pos_list = self.fightMgr.fightPos[self.team]
        local pos = pos_list and pos_list.Pos[self.pos]
        local curPos = self.model:GetPos()
        if self.isProtecter or pos ~= nil and (math.abs(pos.x - curPos.x) > 16 or 16 < math.abs(pos.y - curPos.y)) then
          self:Return(ActionName.FightRun, FightConst.PLAY_TIME.RETURN_POS)
          return
        else
          self:ResetPos()
        end
      end
    elseif self.model and not self.model.m_visible then
      self.model:SetVisible(true)
      self.model:CloseAlpha()
    end
    if self.attack_result == nil or #self.attack_result == 0 or self.curHitInfo and self.curHitInfo.type == BEHIT_POINT_TYPE.UPDATE_STATUS then
      if (self.isDead == DEATH_STATUS.ALIVE or self.isDead == DEATH_STATUS.FAKEDEAD or self:HasDeathAction()) and self.afterStatus then
        if self.playcfg and (self.playcfg.skillType == PlaySkillEnum.DEATH_TRIGGER or self.playcfg.skillType == PlaySkillEnum.DEATH_BOOMING) and self.deathSkills and self.deathSkills then
          local idx = table.indexof(self.deathSkills, self.playcfg.skillId)
          if idx > 0 then
            table.remove(self.deathSkills, idx)
          end
          if #self.deathSkills == 0 then
            self.deathSkills = nil
          end
        end
        local curStatus = self.afterStatus
        self.afterStatus = nil
        if self:UpdateStatus(curStatus, true) then
          return
        end
      end
      if self.statusList then
        if 0 < #self.statusList then
          local status = table.remove(self.statusList, 1)
          self.updateStatusDuration = self.updateStatusDuration + FightConst.PLAY_TIME.UPDATE_STATUS_DURATION
          local ret = self:UpdateStatus(status, true)
          if not ret then
            GameUtil.AddGlobalTimer(0, true, function()
              if self.fightMgr.isInFight then
                self:EndAction()
              end
            end)
          end
        else
          self:CheckAbnormalStatus()
          self.statusList = nil
          GameUtil.AddGlobalTimer(self.updateStatusDuration, true, function()
            if self.fightMgr.isInFight then
              self:EndAction()
            end
          end)
        end
        return
      end
      if self.playcfg and (self.playcfg.skillType == PlaySkillEnum.DEATH_TRIGGER or self.playcfg.skillType == PlaySkillEnum.DEATH_BOOMING) then
        self.playcfg.skillType = nil
      end
      self.playTime = -1
      self.fightMgr:AddLog(string.format("[FightLog]%s(%d) has end all action", self.name, self.id))
      self.fightMgr:OnActionEnd({
        self.id,
        true
      })
    end
  end
end
def.method("table").OnBehit = function(self, behitInfo)
  self.totalHitNum = self.totalHitNum - 1
  if self.playcfg and #self.targets > 0 then
    self.curHitInfo = behitInfo
    local targets = {}
    if self.playcfg.skillPlayType == SkillAttackType.MULTI then
      targets = self.targets
    elseif self.playcfg.skillPlayType == SkillAttackType.SINGLE then
      targets[1] = self.targets[1]
      if self.playcfg.isAttackOtherSkill or 1 < #self.targets and not self.targets[1].hasCombo then
        table.remove(self.targets, 1)
      end
    end
    if self.playcfg.skillType == PlaySkillEnum.DEATH_BOOMING and behitInfo then
      behitInfo.attacker = self
      behitInfo.duration = FightConst.PLAY_TIME.HITBACK_DEFAULT_DURATION * 2
    end
    for k, v in pairs(targets) do
      v.deathInfo = {}
      v.deathInfo.deathType = self.playcfg.deathType
      v.deathInfo.deathTypeId = self.playcfg.deathTypeId
      if v.deathInfo.deathType == DEATH_TYPE.JISUI then
        local effres = GetEffectRes(FightConst.SHATTER_HORIZONTAL)
        self.fightMgr:LoadEffectRes(effres.path)
        effres = GetEffectRes(FightConst.SHATTER_VERTICAL)
        self.fightMgr:LoadEffectRes(effres.path)
      end
      local attackResult = v:GetAttackResult()
      if attackResult == nil then
        local skillModelId, skillActionId = 0, 0
        if self.skill then
          skillModelId = self.skill.modelId or -1
          skillActionId = self.skill.actionId or -1
        end
        self.fightMgr:AddLog(string.format("[Fight error]%s attack %s , attackResult is nil on attack point!!! skill modelId: %d, skill actionID: %d", self.name, v.name, skillModelId, skillActionId))
        v:EndAction()
        return
      end
      self:UpdateStatus(attackResult.attackerStatus, true)
      local reviveStatus = attackResult.statusMap[AttackResultBean.TARGET_RELIVE]
      if reviveStatus then
        v:SetReliveStatus(reviveStatus)
      end
      reviveStatus = attackResult.statusMap[AttackResultBean.RELEASER_RELIVE]
      if reviveStatus then
        self:SetReliveStatus(reviveStatus)
      end
      self:ShowFightStatus(v, attackResult.targetStatus)
      local shareTargetData = attackResult.shareDamageTargets
      if shareTargetData and #shareTargetData > 0 then
        for _, stdata in pairs(shareTargetData) do
          local shareTarget = self.fightMgr:GetFightUnit(stdata.targetid)
          if shareTarget then
            if self:CheckSpecFightStatusSet(stdata.shareDamageStatus, FighterStatus.STATUS_BLACKHOLE_DAMAGE) and self.playcfg.skillPlayType == SkillAttackType.SINGLE then
              reviveStatus = stdata.statusMap[AttackResultBean.TARGET_RELIVE]
              if reviveStatus then
                shareTarget:SetReliveStatus(reviveStatus)
              end
              v:ShowFightStatus(shareTarget, stdata.shareDamageStatus)
            else
              local shareReviveStatus = stdata.statusMap[AttackResultBean.TARGET_RELIVE]
              if shareReviveStatus then
                shareTarget:SetReliveStatus(shareReviveStatus)
              end
              shareTarget:UpdateStatus(stdata.shareDamageStatus, true)
            end
          end
        end
      end
      if v.influences and (v.attack_result == nil or #v.attack_result == 0) then
        for unitid, infStatus in pairs(v.influences.otherMap) do
          if unitid > 0 then
            local unit = self.fightMgr:GetFightUnit(unitid)
            local infReviveStatus = v.influences.otherMap[-unitid]
            if infReviveStatus then
              unit:SetReliveStatus(infReviveStatus)
            end
            if self:CheckSpecFightStatusSet(infStatus, FighterStatus.STATUS_BLACKHOLE_DAMAGE) then
              self:ShowFightStatus(unit, infStatus)
            else
              unit:UpdateStatus(infStatus, true)
              unit:CheckAbnormalStatus()
            end
          end
        end
      end
      local rebound = attackResult.statusMap[AttackResultBean.REBOUND]
      if rebound then
        rebound.isRebound = true
        self.status = rebound
        if 0 < self.playTime then
          self:CheckAndRemoveCurrentPhase()
          self.playTime = FightUnit.MAX_VALUE
        end
        self.fightMgr:AddLog(string.format("[FightLog]%s(%d) is rebounded, show rebound fight status ", self.name, self.id))
        self:ShowFightStatus(self, rebound)
      end
      if v.protect and 0 < #v.protect.protecterids then
        local protecter = self.fightMgr:GetFightUnit(v.protect.protecterids[1])
        if protecter then
          protecter.protectReady = false
          self:ShowFightStatus(protecter, v.protect.protecterStatuses[1])
        end
        v:RemoveTitleIcon()
        protecter:RemoveTitleIcon()
        table.remove(v.protect.protecterids, 1)
        table.remove(v.protect.protecterStatuses, 1)
      end
    end
  end
end
def.method(FightUnit, "table").ShowFightStatus = function(self, target, fighter_status)
  if fighter_status == nil then
    error(target.name .. " fight_status is nil")
  end
  local isAttacked = false
  local isCritical = false
  local isDodge = false
  local isDead = false
  local isFakeDead = false
  local isAbsorb = false
  local isMiss = false
  local revive = false
  target.inDefense = false
  for k, v in pairs(fighter_status.status_set) do
    if v == FighterStatus.STATUS_DEAD then
      isDead = true
    elseif v == FighterStatus.STATUS_FAKE_DEAD then
      isFakeDead = true
    elseif v == FighterStatus.STATUS_RELIVE then
      revive = true
    elseif v == FighterStatus.STATUS_ATTACKED then
      isAttacked = true
    elseif v == FighterStatus.STATUS_CRITICAL_ATTACK then
      isCritical = true
    elseif v == FighterStatus.STATUS_DODGE then
      isDodge = true
    elseif v == FighterStatus.STATUS_ABSORB_DAMAGE then
      isAbsorb = true
    elseif v == FighterStatus.STATUS_DEFENSE then
      target.inDefense = true
    elseif v == FighterStatus.STATUS_SEAL_NOT_HIT then
      isMiss = true
    elseif v == FighterStatus.STATUS_IMMUNE then
      target.model:ShowTitleIcon(9003, 1)
    end
  end
  target:ShowPassiveSkillTitle(fighter_status.triggerPassiveSkills)
  target:SetBuffStatus(fighter_status)
  target.status = fighter_status
  self.fightMgr:AddLog(string.format("[FightLog]%s(%d) Show fight status, target:%s(%d), status set: isAttacked(%s) isDodge(%s) isDead(%s) isFakeDead(%s) isAbsorb(%s) revive(%s)", self.name, self.id, target.name, target.id, tostring(isAttacked), tostring(isDodge), tostring(isDead), tostring(isFakeDead), tostring(isAbsorb), tostring(revive)))
  local hpdelta = fighter_status.hpchange
  target:SetHp(fighter_status.curHp, fighter_status.hpMax)
  target:SetMp(fighter_status.curMp, fighter_status.mpMax)
  target:SetRage(fighter_status.curAnger, fighter_status.angerMax)
  if self.fightMgr:IsMyUnit(target.id) then
    Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.MODEL_PROP_CHANGED, {
      type = target.fightUnitType,
      hp = target.hp,
      hpmax = target.hpmax,
      mp = target.mp,
      mpmax = target.mpmax,
      rage = target.rage,
      ragemax = target.ragemax
    })
  end
  if isMiss then
    target.model:ShowTitleIcon(9001, 1)
  end
  if revive then
    if not self.fightMgr:CheckTargetIsWaited(target.id) then
      self.fightMgr:AddTargetToBeWaited(target.id)
    end
    target:Revive()
    return
  end
  local isLastHit = target.attack_result == nil or #target.attack_result == 0 or target.hasCombo == true
  if not isLastHit and target.reviveStatus == nil and not self.counterAttack then
    self.fightMgr:AddLog(string.format("[FightLog]is not last hit, set target(%s(%d)) to alive", target.name, target.id))
    target.isDead = DEATH_STATUS.ALIVE
    isDead = false
    isFakeDead = false
  end
  if isDead or isFakeDead then
    local behitInfo = self.curHitInfo
    if behitInfo == nil then
      self.fightMgr:AddLog(string.format("[FightLog]%s(%d) is dead, but behit info is nil on behitpoint, skill playcfg id: %d ", self.name, self.id, self.playcfg and self.playcfg.id or -1))
      target:EndAction()
      return
    end
    if hpdelta < 0 then
      if behitInfo.type ~= BEHIT_POINT_TYPE.UPDATE_STATUS and behitInfo.camShake and 0 < behitInfo.camShake then
        self.fightMgr:SetShakeParam(behitInfo.camShake, 0)
      end
      target:ShowPropChange(fighter_status, isCritical)
    end
    if behitInfo.type == BEHIT_POINT_TYPE.UPDATE_STATUS then
      if target.isDead == DEATH_STATUS.ALIVE then
        target:Die(isFakeDead)
      else
        target:EndAction()
      end
      return
    end
    if behitInfo.behitAction == BeHitType.NULL and (target:HasDeathAction() or isFakeDead or target.deathInfo == nil or target.deathInfo.deathType ~= DEATH_TYPE.JISUI) then
      if target.beHitEffect then
        target.model:AddEffectWithRotation(target.beHitEffect.path, AttachType.BODY)
        if 0 < target.beHitEffect.sound then
          self.fightMgr:PlaySoundEffect(target.beHitEffect.sound)
        end
      end
      if target.isDead == DEATH_STATUS.ALIVE then
        target:Die(isFakeDead)
      else
        target:EndAction()
      end
    else
      local deathValue = DEATH_STATUS.DEAD
      if isFakeDead then
        deathValue = DEATH_STATUS.FAKEDEAD
      end
      target.isDead = deathValue
      behitInfo.isLastHit = isLastHit
      target:BeHit(behitInfo)
    end
  elseif isDodge then
    target.model:ShowTitleIcon(9004, 1)
    target:Dodge()
  elseif isAttacked then
    if isAbsorb then
      target.model:ShowTitleIcon(9007, 1)
    end
    local behitInfo = self.curHitInfo
    if behitInfo then
      behitInfo.isLastHit = isLastHit
    end
    if hpdelta ~= 0 or fighter_status.mpchange ~= 0 then
      if hpdelta ~= 0 then
        target:ShowDamage(hpdelta, isCritical, DAMAGE_TYPE.HP)
      end
      if fighter_status.mpchange ~= 0 then
        target:ShowDamage(fighter_status.mpchange, isCritical, DAMAGE_TYPE.MP)
      end
      local show_behit = hpdelta < 0 or 0 > fighter_status.mpchange
      if show_behit then
        target:BeHit(behitInfo)
      else
        target:EndAction()
      end
    else
      target:EndAction()
    end
  else
    target:ShowPropChange(fighter_status, isCritical)
    if 1 >= self.totalHitNum and target.isActionEnded then
      if self.id == target.id then
        local islast = self.attack_result == nil or #self.attack_result <= 0
        self.fightMgr:AddLog(string.format("[FightLog]%s(%d) ShowPropChange end", self.name, self.id))
        self.fightMgr:OnActionEnd({
          self.id,
          islast
        })
      else
        target:EndAction()
      end
    end
  end
end
def.method("table", "boolean", "=>", "boolean").UpdateStatus = function(self, status, showmp)
  if status == nil then
    warn(self.name .. " [UpdateStatus]status is nil")
    return false
  end
  local isCritical = false
  local isDead = false
  local isFakeDead = false
  local revive = false
  local isAbsorb = false
  for k, v in pairs(status.status_set) do
    if v == FighterStatus.STATUS_CRITICAL_ATTACK then
      isCritical = true
    elseif v == FighterStatus.STATUS_DEAD then
      isDead = true
    elseif v == FighterStatus.STATUS_FAKE_DEAD then
      isFakeDead = true
    elseif v == FighterStatus.STATUS_RELIVE then
      revive = true
    elseif v == FighterStatus.STATUS_ABSORB_DAMAGE then
      isAbsorb = true
    elseif v == FighterStatus.STATUS_IMMUNE then
      self.model:ShowTitleIcon(9003, 1)
    end
  end
  self.fightMgr:AddLog(string.format("[FightLog]%s(%d) UpdateStatus, status set: isDead(%s) isFakeDead(%s) isAbsorb(%s) revive(%s)", self.name, self.id, tostring(isDead), tostring(isFakeDead), tostring(isAbsorb), tostring(revive)))
  self:ShowPassiveSkillTitle(status.triggerPassiveSkills)
  if revive then
    if not self.fightMgr:CheckTargetIsWaited(self.id) then
      self.fightMgr:AddTargetToBeWaited(self.id)
    end
    self.status = status
    self:Revive()
    return true
  end
  self:SetHp(status.curHp, status.hpMax)
  self:SetMp(status.curMp, status.mpMax)
  self:SetRage(status.curAnger, status.angerMax)
  if self.fightMgr:IsMyUnit(self.id) then
    Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.MODEL_PROP_CHANGED, {
      type = self.fightUnitType,
      hp = self.hp,
      hpmax = self.hpmax,
      mp = self.mp,
      mpmax = self.mpmax,
      rage = self.rage,
      ragemax = self.ragemax
    })
  end
  if status.hpchange ~= 0 then
    self:ShowDamage(status.hpchange, isCritical, DAMAGE_TYPE.HP)
  end
  if showmp and 0 > status.mpchange or 0 < status.mpchange then
    self:ShowDamage(status.mpchange, isCritical, DAMAGE_TYPE.MP)
  end
  if status.angerchange ~= 0 then
    self:ShowDamage(status.angerchange, isCritical, DAMAGE_TYPE.RAGE)
  end
  self:ShowStatus(status)
  self.status = status
  if not self:HasDeathAction() and (self.playcfg and (self.playcfg.skillType == PlaySkillEnum.DEATH_TRIGGER or self.playcfg.skillType == PlaySkillEnum.DEATH_BOOMING) or self.isDead == DEATH_STATUS.ALIVE and (isFakeDead or isDead)) then
    if self.playcfg and self.playcfg.skillType == PlaySkillEnum.DEATH_BOOMING then
      self:OnDieEnd()
    else
      self:Die(isFakeDead)
    end
    return true
  end
  return false
end
def.method("table").SetStatus = function(self, status)
  if status == nil then
    warn(self.name .. " [SetStatus]status is nil")
    return
  end
  for k, v in pairs(status.status_set) do
    if v == FighterStatus.STATUS_DEAD then
      self.isDead = DEATH_STATUS.DEAD
    elseif v == FighterStatus.STATUS_FAKE_DEAD then
      self.isDead = DEATH_STATUS.FAKEDEAD
    end
  end
  self:SetHp(status.curHp, status.hpMax)
  self:SetMp(status.curMp, status.mpMax)
  self:SetRage(status.curAnger, status.angerMax)
  if self.fightMgr:IsMyUnit(self.id) then
    Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.MODEL_PROP_CHANGED, {
      type = self.fightUnitType,
      hp = self.hp,
      hpmax = self.hpmax,
      mp = self.mp,
      mpmax = self.mpmax,
      rage = self.rage,
      ragemax = self.ragemax
    })
  end
  self:ShowStatus(status)
  self.status = status
  self.model:SetStance()
end
def.method("table").ShowPassiveSkillTitle = function(self, passiveSkills)
  for _, skillId in pairs(passiveSkills) do
    if skillId == 110630012 or skillId == 110630013 or skillId == 110630014 or skillId == 110661408 then
      self.reviveSkillId = skillId
    else
      self:ShowSkillTitle(skillId)
    end
  end
end
def.method("number", "=>", "boolean").CheckCombo = function(self, startIdx)
  if self.attack_result == nil then
    return false
  end
  local fighter_status = self.attack_result[startIdx + 1]
  if fighter_status == nil then
    return false
  end
  local targetStatus = fighter_status.targetStatus
  if targetStatus == nil or targetStatus.status_set == nil then
    return false
  end
  for _, v in pairs(targetStatus.status_set) do
    if v == FighterStatus.STATUS_COMBO_ATTACKED then
      return true
    end
  end
  return false
end
def.method("number").CheckCounterAttack = function(self, startIdx)
  if self.attack_result == nil then
    self.counterAttack = nil
    return
  end
  local fighter_status = self.attack_result[startIdx]
  if fighter_status == nil then
    self.counterAttack = nil
    return
  end
  self.counterAttack = fighter_status.counterAttack
  if self.counterAttack and (self.counterAttack.skill == nil or self.counterAttack.skill == 0) then
    self.counterAttack = nil
  end
end
local damage_temp_pos = EC.Vector3.new(0, 0, 0)
def.method("number").UpdateDamage = function(self, dt)
  if self.damageLabels == nil then
    return
  end
  for k, v in pairs(self.damageLabels) do
    if v.delay > 0 then
      v.delay = v.delay - dt
      if v.delay <= 0 then
        v.obj:SetActive(true)
      end
    else
      v.time = v.time + dt
      if v.time >= DAMAGE_DURATION or v.obj:get_isnil() then
        if v.obj and not v.obj:get_isnil() then
          v.obj:Destroy()
        end
        self.damageLabels[k] = nil
      else
        if v.isCritical then
          v.obj.localPosition = v.initPos
        else
          damage_temp_pos.x = v.initPos.x
          damage_temp_pos.y = v.initPos.y + 50 * v.scale.y * math.sin(0.5 * math.pi * (v.time / DAMAGE_DURATION))
          v.obj.localPosition = damage_temp_pos
        end
        v.obj.localScale = v.scale
      end
    end
  end
end
def.method("table", "boolean").ShowPropChange = function(self, status, crit)
  if status.hpchange ~= 0 then
    self:ShowDamage(status.hpchange, crit, DAMAGE_TYPE.HP)
  end
  if status.mpchange ~= 0 then
    self:ShowDamage(status.mpchange, crit, DAMAGE_TYPE.MP)
  end
  if status.angerchange ~= 0 then
    self:ShowDamage(status.angerchange, crit, DAMAGE_TYPE.RAGE)
  end
  self:SetHp(status.curHp, status.hpMax)
  self:SetMp(status.curMp, status.mpMax)
  self:SetRage(status.curAnger, status.angerMax)
  if self.fightMgr:IsMyUnit(self.id) then
    Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.MODEL_PROP_CHANGED, {
      type = self.fightUnitType,
      hp = self.hp,
      hpmax = self.hpmax,
      mp = self.mp,
      mpmax = self.mpmax,
      rage = self.rage,
      ragemax = self.ragemax
    })
  end
end
def.method("number", "boolean", "number").ShowDamage = function(self, hpDelta, isCritical, damageType)
  if self.damageLabels == nil or self.model == nil then
    return
  end
  local temp = self.fightMgr:GetDamageTemplate()
  if temp == nil then
    return
  end
  local pos = self.model:GetPos()
  if pos == nil then
    warn("[Fight Error](ShowDamage) model pos is nil , unit: ", self.name, self.id)
    return
  end
  local damageLabel = {}
  damageLabel.time = 0
  damageLabel.obj = Object.Instantiate(temp, "GameObject")
  local critBg = damageLabel.obj:FindChild("Lab_Hurt/Texture")
  if critBg then
    critBg:SetActive(isCritical)
  end
  local idx = #self.damageLabels or 1
  damageLabel.obj.name = "damage_panel_" .. self.id .. tostring(idx + 1)
  damageLabel.obj.parent = self.fightMgr.damageRoot
  damageLabel.obj.localScale = EC.Vector3.one
  damageLabel.obj:SetLayer(ClientDef_Layer.FIGHT_UI)
  local fonts = self.fightMgr:GetFonts()
  local damage = tostring(math.abs(hpDelta))
  if damageType == DAMAGE_TYPE.HP then
    damageLabel.label = damageLabel.obj:FindChild("Lab_Hurt")
    local hpLabel = damageLabel.label:GetComponent("UILabel")
    if hpDelta > 0 then
      hpLabel.font = fonts[FightConst.NUMBER_COLOR.GREEN]
      if isCritical then
        hpLabel.font = fonts[FightConst.NUMBER_COLOR.CRIT_CURE]
      end
    else
      hpLabel.font = fonts[FightConst.NUMBER_COLOR.RED]
      if isCritical then
        hpLabel.font = fonts[FightConst.NUMBER_COLOR.CRIT]
      end
    end
    damageLabel.offset = 125
    if isCritical then
      self.fightMgr:SetShakeParam(161100000, 0)
    end
    hpLabel.text = damage
  elseif damageType == DAMAGE_TYPE.MP then
    damageLabel.label = damageLabel.obj:FindChild("Lab_Mp")
    local mpLabel = damageLabel.label:GetComponent("UILabel")
    mpLabel.font = fonts[FightConst.NUMBER_COLOR.BLUE]
    if hpDelta > 0 then
      damage = "+" .. damage
    elseif hpDelta < 0 then
      damage = "-" .. damage
    end
    damageLabel.offset = 100
    mpLabel.text = damage
  elseif damageType == DAMAGE_TYPE.RAGE then
    damageLabel.label = damageLabel.obj:FindChild("Lab_Hurt")
    local rageLabel = damageLabel.label:GetComponent("UILabel")
    rageLabel.font = fonts[FightConst.NUMBER_COLOR.YELLOW]
    if hpDelta > 0 then
      damage = "+" .. damage
    elseif hpDelta < 0 then
      damage = "-" .. damage
    end
    damageLabel.offset = 100
    rageLabel.text = damage
  end
  local scalePower = 1
  damageLabel.initPos = EC.Vector3.new(pos.x, pos.y + damageLabel.offset, 0)
  if self.fightMgr.isPerspective then
    local pos3d = self.model.m_uiNameHandle.localPosition
    scalePower = 300
    damageLabel.obj.parent = ECGUIMan.Instance():GetHudTopBoardRoot()
    damageLabel.obj:SetLayer(ClientDef_Layer.PateText)
    damageLabel.initPos = EC.Vector3.new(pos3d.x, pos3d.y + (damageLabel.offset + 50) * scalePower, 0)
  end
  damageLabel.scale = EC.Vector3.new(scalePower, scalePower, 1)
  damageLabel.obj.localPosition = damageLabel.initPos
  if isCritical and damageType == DAMAGE_TYPE.HP then
    damageLabel.isCritical = true
    local ani = damageLabel.label:AddComponent("Animation")
    local clip = Object.Instantiate(FightMgr.Instance().damageAnim, "GameObject")
    ani:AddClip(clip, "moveup")
    ani.clip = clip
    ani:Play_3("moveup", PlayMode.StopSameLayer)
  else
    damageLabel.isCritical = false
  end
  if #self.damageLabels > 0 then
    local lastone = self.damageLabels[#self.damageLabels]
    damageLabel.delay = DAMAGE_DELAY + lastone.delay - lastone.time
    if 0 < damageLabel.delay then
      damageLabel.obj:SetActive(false)
    end
  else
    damageLabel.delay = 0
  end
  table.insert(self.damageLabels, damageLabel)
end
def.method().ShowSelect = function(self)
  self.showSelect = true
  if self.model and self.model.m_selectIcon then
    local img = self.model.m_selectIcon:FindDirect("Pate/Img_Sign")
    img:SetActive(true)
    img:GetComponent("UITexture").mainTexture = FightMgr.Instance().selectTexture
    local info = ""
    local bg = self.model.m_selectIcon:FindDirect("Pate/Img_Sign/Img_BgLable")
    bg:SetActive(true)
    local infoLabel = bg:FindDirect("Label_LV")
    if self.fightMgr.fightType == FIGHT_TYPE.TYPE_PVP then
      if self.fightUnitType == GameUnitType.ROLE and self.menpai > 0 then
        infoLabel:SetActive(true)
        info = string.format("%d %s", self.level, textRes.Fight[100 + self.menpai])
        infoLabel:GetComponent("UILabel").text = info
      elseif self.fightUnitType == GameUnitType.PET then
        local petCfg = require("Main.Pet.PetUtility").Instance():GetPetCfg(self.cfgId)
        if petCfg and petCfg.modelId ~= self.model.mModelId then
          infoLabel:SetActive(true)
          infoLabel:GetComponent("UILabel"):set_text(petCfg.shortName)
        else
          infoLabel:GetComponent("UILabel"):set_text("")
        end
      else
        infoLabel:SetActive(false)
      end
    else
      infoLabel:SetActive(false)
    end
    local unit = self.fightMgr:GetCurrentControllable()
    local isOpen = FightUtils.IsRestrictEnable()
    local classLabel = bg:FindDirect("Label_Restrain")
    if isOpen and unit then
      local overcome_desc = FightUtils.GetOvercomeDesc(unit, self)
      classLabel:GetComponent("UILabel"):set_text(overcome_desc)
      classLabel:SetActive(true)
    else
      classLabel:SetActive(false)
    end
  end
end
def.method().HideSelect = function(self)
  self.showSelect = false
  if self.model and not _G.IsNil(self.model.m_selectIcon) then
    self.model.m_selectIcon:FindDirect("Pate/Img_Sign"):SetActive(false)
  end
end
def.method().HideClassOvercome = function(self)
  if self.model and not _G.IsNil(self.model.m_selectIcon) then
    local bg = self.model.m_selectIcon:FindDirect("Pate/Img_Sign/Img_BgLable")
    if bg then
      bg:FindDirect("Label_Restrain"):SetActive(false)
    end
  end
end
def.method().RemoveDamageLabel = function(self)
  if self.damageObj then
    self.damageObj:Destroy()
    self.damageObj = nil
    self.damageTime = -1
    self.damageLabel = nil
  end
end
def.static(FightUnit).OnAttackRunFinished = function(unit)
  unit:StopGhostEffect(false)
  unit:ClearDelEffects()
  local target = unit.targets[1]
  local protecter
  if target and target.protect then
    for i = 1, #target.protect.protecterids do
      protecter = unit.fightMgr:GetFightUnit(target.protect.protecterids[i])
      if protecter then
        protecter:Protect(target)
      end
    end
  end
  local function gonext()
    if unit.skill == nil then
      table.remove(unit.playcfg.phases, 1)
      unit:NextPhase()
    else
      unit:Attack()
    end
  end
  if protecter and not protecter.protectReady then
    unit:AddNextAction("Attack", function()
      return protecter.protectReady
    end, gonext)
  else
    gonext()
  end
end
def.method("table").BeHit = function(self, behitInfo)
  self:StopGhostEffect(true)
  self.isActionEnded = false
  if behitInfo == nil then
    self.fightMgr:AddLog(string.format("[FightLog]%s(%d) behit , but behitInfo is nil", self.name, self.id))
    self:BehitEnd()
    return
  end
  if behitInfo.camShake and behitInfo.camShake > 0 then
    self.fightMgr:SetShakeParam(behitInfo.camShake, 0)
  end
  local actModel = self:GetActModel()
  if self.inDefense then
    if self.skill then
      local actionCfg = FightUtils.GetSkillActionCfg(self.modelId, self.skill.actionId)
      if 0 < actionCfg.sound then
        self.fightMgr:PlaySoundEffect(actionCfg.sound)
      end
      local defEffPath = self:GetDefenseEffect()
      if defEffPath ~= "" then
        actModel:AddEffectWithRotation(defEffPath, AttachType.BODY)
      end
    end
    self.dodgeInfo = nil
    local actionName = ActionName.Defend
    if self.masterModel then
      local masterActionName = self.fightMgr:GetMasterActionName(self.pos, actionName)
      if masterActionName ~= "" then
        actionName = masterActionName
      end
    end
    actModel:Play(actionName)
    self.defendTime = FightConst.PLAY_TIME.DEFEND_DURATION
    if actModel.mECWingComponent then
      actModel.mECWingComponent:Defend()
    end
    return
  end
  local behitName = ActionName.BeHit
  if not self.masterModel and not self.isHugeUnit then
    if behitInfo.behitAction == BeHitType.SKY then
      self.dodgeInfo = nil
      self:HitUp(behitInfo.paramId)
      return
    end
    if behitInfo.behitAction == BeHitType.EARTH then
      behitName = ActionName.BeHitDown
    end
  elseif self.masterModel then
    local masterActionName = self.fightMgr:GetMasterActionName(self.pos, behitName)
    if masterActionName ~= "" then
      behitName = masterActionName
    end
  end
  if self.soundCfg and 0 < self.soundCfg.beAttacked then
    self.fightMgr:PlaySoundEffect(self.soundCfg.beAttacked)
  end
  if self.beHitEffect then
    actModel:AddEffectWithRotation(self.beHitEffect.path, AttachType.BODY)
    if 0 < self.beHitEffect.sound then
      self.fightMgr:PlaySoundEffect(self.beHitEffect.sound)
    end
  end
  if self:CheckBuffStatus(FighterStatus.BUFF_ST__ICECOOL) or self:CheckBuffStatus(FighterStatus.BUFF_ST__STONE) then
    self:BehitEnd()
  else
    local hitbackDuration = actModel:GetAniDuration(behitName)
    if self.masterModel or self.isHugeUnit then
      actModel:Play(behitName)
      if self.attack_result == nil or #self.attack_result == 0 then
        table.insert(self.nextCallbacks, {
          delay = hitbackDuration,
          callback = self.BehitEnd
        })
      end
      return
    end
    if behitInfo.behitAction == BeHitType.NULL then
      if self.hitbackInfo == nil then
        local ret = actModel:Play(behitName)
        if not ret then
          self:BehitEnd()
          return
        end
      end
      if hitbackDuration == 0 then
        hitbackDuration = FightConst.PLAY_TIME.HITBACK_DEFAULT_DURATION
      end
      if behitInfo.duration then
        hitbackDuration = behitInfo.duration
      end
      if behitInfo.attacker and behitInfo.attacker.id ~= self.id then
        actModel:LookAtTarget(behitInfo.attacker.model)
      end
      self:HitBack(hitbackDuration, behitInfo.isLastHit)
    end
  end
end
def.method().BehitEnd = function(self)
  if self.isDead > 0 then
    self:Die(self.isDead == DEATH_STATUS.FAKEDEAD)
    return
  end
  self.isActionEnded = true
  if self.isInterrupted then
    self.fightMgr:AddLog(string.format("[FightLog]%s(%d) interrupt end", self.name, self.id))
    self.isInterrupted = false
    self:EndAction()
    return
  end
  if self.status.isRebound then
    self.status.isRebound = nil
    self.fightMgr:AddLog(string.format("[FightLog]%s(%d) rebound end", self.name, self.id))
    if 0 < self.playTime then
      self.fightMgr:AddLog(string.format("[FightLog]%s(%d) continue to do attack end ", self.name, self.id))
      self.playTime = -1
      self:OnAttackEnd()
      return
    end
  end
  if self.isProtecter then
    self:Return(ActionName.FightRun, FightConst.PLAY_TIME.RETURN_POS)
    return
  end
  if self.attack_result == nil or #self.attack_result == 0 then
    self.beHitEffect = nil
    if not self:CheckBuffStatus(FighterStatus.BUFF_ST__ICECOOL) and not self:CheckBuffStatus(FighterStatus.BUFF_ST__STONE) then
      self:Stand()
    end
    self:EndAction()
  elseif self.counterAttack then
    self:EndAction()
  end
end
def.method("number", "boolean").HitBack = function(self, hitbackDuration, isLastHit)
  local pos = self.model.m_node2d.localPosition
  local targetPos, moveBackTime
  local function OnArrive()
    if self.hitbackInfo == nil then
      return
    end
    self.model:PauseAnim(true)
    if self.attack_result and #self.attack_result > 0 and not self.hasCombo and not self.status.isRebound and not isLastHit and not self.counterAttack and not self:CheckFightStatus(FighterStatus.STATUS_COUNTER_ATTACK) and self:CheckFightStatus(FighterStatus.STATUS_ATTACKED) and self.isDead == DEATH_STATUS.ALIVE and not self.isInterrupted then
      self:StartShake()
      return
    end
    table.insert(self.nextCallbacks, {
      delay = 0.2,
      callback = self.HitRecovery
    })
    self.hitbackInfo.isBacking = true
  end
  local dist = FightConst.HIT_BACK_DISTANCE
  if self.hitbackInfo then
    if isLastHit then
      if self.hitbackInfo.isBacking then
        for k, v in pairs(self.nextCallbacks) do
          if v.callback == self.HitRecovery then
            self.nextCallbacks[k] = nil
            break
          end
        end
      end
      dist = FightConst.HIT_BACK_DISTANCE / 5
    elseif self.counterAttack then
      self:StopShake()
      self.hitbackInfo = nil
      table.insert(self.nextCallbacks, {
        delay = 0.2,
        callback = self.BehitEnd
      })
      return
    else
      return
    end
  end
  targetPos = {}
  if self.dodgeInfo then
    targetPos.x = self.dodgeInfo.x
    targetPos.y = self.dodgeInfo.y
    pos.x = self.dodgeInfo.initX
    pos.y = self.dodgeInfo.initY
    self.dodgeInfo = nil
  else
    local angle = (270 - self.model:GetDir()) / 180 * math.pi
    targetPos.x = pos.x + dist * math.cos(angle)
    targetPos.y = pos.y + dist * math.sin(angle)
  end
  moveBackTime = hitbackDuration / 2
  if self.hitbackInfo == nil then
    self.hitbackInfo = {}
    self.hitbackInfo.pos = pos
  end
  self.hitbackInfo.hitbackDuration = hitbackDuration
  self.hitbackInfo.recoverTime = hitbackDuration / 2
  self.hitbackInfo.targetPos = targetPos
  self.hitbackInfo.isBacking = false
  self.hitbackInfo.forceDir = self.model.m_model.forward
  self.model:MoveTo(targetPos.x, targetPos.y, OnArrive, moveBackTime, false, 0)
  self.model:SetForward(self.hitbackInfo.forceDir)
  if self.flyMount then
    self.flyMount:SwitchToBackStance(true)
  end
end
def.method().HitRecovery = function(self)
  if self:IsReallyDead() and self.deathInfo and self.deathInfo.deathType == DEATH_TYPE.JISUI then
    self.model:StopAnimAndCallback()
    if self.soundCfg and self.soundCfg.dead > 0 then
      self.fightMgr:PlaySoundEffect(self.soundCfg.dead)
    end
    do
      local islast = self.fightMgr:IsLastRound()
      local shatterCfg = FightUtils.GetShatterCfg(self.deathInfo.deathTypeId)
      self.deathInfo.shatter_type = SHATTER_TYPE.HORIZONTAL
      self:StopShake()
      self.model:Shatter(shatterCfg.f, shatterCfg.a, shatterCfg.duration, function()
        self:OnShatterEnd(islast)
      end)
      return
    end
  end
  if self.hitbackInfo == nil then
    return
  end
  local targetPos = self.hitbackInfo.pos
  local function OnEnd()
    self.hitbackInfo = nil
    self.model:SetPos(targetPos.x, targetPos.y)
    if self.flyMount then
      self.flyMount:SwitchToBackStance(false)
    end
    self:StopShake()
    if (self.targets == nil or self.targets[1] == nil or not self.targets[1].hasCombo and not self:CheckFightStatus(FighterStatus.STATUS_COUNTER_ATTACK) and self.status and not self.status.isRebound and not self.isInterrupted) and (self.attack_result == nil or #self.attack_result == 0) then
      self:ResetPos()
    end
    self:BehitEnd()
  end
  self.model:PauseAnim(false)
  if self.hasCombo and not self.counterAttack then
    self.model:MoveTo(targetPos.x, targetPos.y, nil, self.hitbackInfo.hitbackDuration / 2, true, 0)
  else
    self.model:MoveTo(targetPos.x, targetPos.y, OnEnd, self.hitbackInfo.hitbackDuration / 2, true, 0)
  end
  if self.hitbackInfo.forceDir then
    self.model:SetForward(self.hitbackInfo.forceDir)
  end
  if self.hasCombo then
    self.hitbackInfo = nil
  end
end
def.method().Dodge = function(self)
  if self.masterModel or self.isHugeUnit then
    self:EndAction()
    return
  end
  if self.shake then
    if self.counterAttack then
      local pos = self.fightMgr.fightPos[self.team].Pos[self.pos]
      self.model:SetPos(pos.x, pos.y)
      self.model:SetDir(FightConst.TeamDir[self.team])
      self:EndAction()
    elseif self.attack_result == nil or #self.attack_result == 0 then
      table.insert(self.nextCallbacks, {
        delay = 0.1,
        callback = self.HitRecovery
      })
      self.hitbackInfo.isBacking = true
    end
    return
  end
  local pos = self.model.m_node2d.localPosition
  local function OnArrive()
    if not self.fightMgr.isInFight then
      return
    end
    local function OnEnd()
      if self.model == nil then
        return
      end
      self:Stand()
      if self.flyMount then
        self.flyMount:SwitchToBackStance(false)
      end
      self.dodgeInfo = nil
      self:StopGhostEffect(true)
      if self.attack_result == nil or #self.attack_result == 0 or self.counterAttack then
        self:EndAction()
      end
    end
    if self.dodgeInfo then
      self.model:MoveTo(self.dodgeInfo.initX, self.dodgeInfo.initY, OnEnd, FightConst.PLAY_TIME.DODGE, true, 0)
    else
      OnEnd()
    end
  end
  if self.dodgeInfo == nil then
    self.dodgeInfo = {}
    local angle = (270 - self.model:GetDir()) / 180 * math.pi
    self.dodgeInfo.x = pos.x + 100 * math.cos(angle)
    self.dodgeInfo.y = pos.y + 100 * math.sin(angle)
    self:PlayGhostEffect(160900000)
    self.dodgeInfo.initX = pos.x
    self.dodgeInfo.initY = pos.y
  else
    self.model:StopMoving()
  end
  self.model:MoveTo(self.dodgeInfo.x, self.dodgeInfo.y, OnArrive, FightConst.PLAY_TIME.DODGE, false, 0)
  if self.flyMount then
    self.flyMount:SwitchToBackStance(true)
  end
  if self.soundCfg and 0 < self.soundCfg.dodge then
    self.fightMgr:PlaySoundEffect(self.soundCfg.dodge)
  end
end
def.method().OnDieEnd = function(self)
  if not self:HasDeathAction() then
    self.deathInfo = nil
  end
  self.model.isDead = true
  if self.model.mECWingComponent then
    self.model.mECWingComponent:Death()
  end
  if self:IsReallyDead() then
    self.fightMgr:RemoveFightUnit(self.id)
  end
  if self.reviveStatus == nil then
    self.isInterrupted = false
  end
  self.isActionEnded = true
  self:EndAction()
end
def.method("boolean").Die = function(self, isFakeDead)
  local function OnDead(m, aniName)
    if not self.fightMgr:IsLastRound() and not isFakeDead then
      self:EndAction()
    end
    if isFakeDead or self:HasDeathAction() then
      self:OnDieEnd()
      return
    end
    if self.model == nil then
      return
    end
    if self.deathInfo and self.deathInfo.deathType == DEATH_TYPE.RONGJIE then
      local dissolveCfg = FightUtils.GetDissolveCfg(self.deathInfo.deathTypeId)
      if dissolveCfg == nil then
        self:OnDieEnd()
        return
      end
      local dissolveEff = GetEffectRes(dissolveCfg.effId)
      if dissolveEff then
        self.model:AddEffectWithRotation(dissolveEff.path, AttachType.FOOT)
        if dissolveEff.sound > 0 then
          self.fightMgr:PlaySoundEffect(dissolveEff.sound)
        end
      end
      local color = Color.Color(dissolveCfg.R, dissolveCfg.G, dissolveCfg.B, dissolveCfg.A)
      self.model:Dissolve(color, function()
        self:OnDieEnd()
      end)
    else
      local dissolveEff = GetEffectRes(702000002)
      if dissolveEff then
        self.model:AddEffectWithRotation(dissolveEff.path, AttachType.FOOT)
        if dissolveEff.sound > 0 then
          self.fightMgr:PlaySoundEffect(dissolveEff.sound)
        end
      end
      GameUtil.AddGlobalTimer(0.5, true, function()
        if self.fightMgr.isInFight then
          self:OnDieEnd()
        end
      end)
    end
  end
  self.isActionEnded = false
  self.hitbackInfo = nil
  self:StopShake()
  self:StopGhostEffect(true)
  self.isDead = DEATH_STATUS.FAKEDEAD
  if not isFakeDead then
    self.isDead = DEATH_STATUS.DEAD
  end
  local ret = self.model:PlayAnim(ActionName.Death1, OnDead)
  if self.soundCfg and self.soundCfg.dead > 0 then
    self.fightMgr:PlaySoundEffect(self.soundCfg.dead)
  end
  if not ret then
    OnDead()
  end
end
def.method().Revive = function(self)
  if self.model == nil then
    return
  end
  local function OnReviveEnd()
    if self.model == nil then
      return
    end
    self:ClearFightStatus(FighterStatus.STATUS_RELIVE)
    self:Stand()
    self.model.isDead = false
    self.fightMgr:AddLog(string.format("[FightLog]%s(%d) is revived", self.name, self.id))
    if self.model.mECWingComponent then
      self.model.mECWingComponent:Born()
    end
    if self.reviveCallback then
      local cb = self.reviveCallback
      self.reviveCallback = nil
      cb()
    end
    if self.isInterrupted then
      self.fightMgr:AddLog(string.format("[FightLog]%s(%d) interrupt end", self.name, self.id))
      self.isInterrupted = false
    end
    self:EndAction()
  end
  local function ReviveAction()
    if self.model == nil then
      return
    end
    self.fightMgr:AddLog(string.format("[FightLog]%s(%d) is playing revive action", self.name, self.id))
    self.isDead = DEATH_STATUS.ALIVE
    self:ShowPropChange(self.status, false)
    if self:CheckFightStatus(FighterStatus.STATUS_RELIVE_TIME_BACK) then
      self.model:PlayAnim(ActionName.Revive, OnReviveEnd)
    elseif self.model:HasAnimClip(ActionName.Revive) then
      self.model:PlayAnim(ActionName.Revive, OnReviveEnd)
    else
      OnReviveEnd()
    end
  end
  if self.reviveSkillId > 0 then
    self:ShowSkillTitle(self.reviveSkillId)
    self.reviveSkillId = 0
  end
  local effres = GetEffectRes(702020005)
  if effres then
    self.fightMgr:PlayEffect(effres.path, nil, self.model.m_model.localPosition, Quaternion.identity)
  end
  table.insert(self.nextCallbacks, {
    delay = FightConst.PLAY_TIME.REVIVE_DELAY,
    callback = ReviveAction
  })
end
def.method("number").HitUp = function(self, id)
  local param = FightUtils.GetHitUpParam(id)
  if self.fightMgr.isPerspective then
    self.hitupInitPos = self.model.m_model.localPosition
    if self.hitupInitPos.y <= 0 then
      self.hitupInitPos = EC.Vector3.new(self.hitupInitPos.x, 0, self.hitupInitPos.z)
    end
    local height = param.height * cam_2d_to_3d_scale
    self.hitupTargetPos = EC.Vector3.new(self.hitupInitPos.x, self.hitupInitPos.y, param.height * cam_2d_to_3d_scale)
    local duration = param.duration * (1 + 0.1 * (3 - math.random(5)))
    GRAVITY = 2 * param.height * cam_2d_to_3d_scale / (duration * duration)
    self.hitupSpeed = GRAVITY * duration
  else
    self.hitupInitPos = self.model.m_node2d.localPosition
    local pos = self.fightMgr.fightPos[self.team].Pos[self.pos]
    if self.hitupInitPos.y <= pos.y then
      self.hitupInitPos = EC.Vector3.new(pos.x, pos.y, 0)
    end
    self.hitupTargetPos = EC.Vector3.new(self.hitupInitPos.x, self.hitupInitPos.y + param.height, 0)
    local duration = param.duration * (1 + 0.1 * (3 - math.random(5)))
    GRAVITY = 2 * param.height / (duration * duration)
    self.hitupSpeed = GRAVITY * duration
  end
  self.hitupTime = 0
  self.model:Play("Hit_Up_c")
  if self.flyMount and not self.flyMount.isDetached then
    self.model.flyMountModel = self.flyMount.m_model
    if self.model:DetachFlyMount() then
      self.flyMount.isDetached = true
    end
  end
  self.model:DetachShadow()
  if self.soundCfg then
    self.fightMgr:PlaySoundEffect(self.soundCfg.beAttacked)
  end
end
local temp_pos = EC.Vector3.new(0, 0, 0)
def.method("number").UpdateHitUp = function(self, dt)
  if self.model == nil or self.model.m_node2d == nil or self.model.m_model == nil then
    return
  end
  if self.hitupTargetPos == nil then
    return
  end
  if self.hitupTime < 0 then
    return
  end
  self.hitupTime = self.hitupTime + dt
  local speed = self.hitupSpeed - GRAVITY * self.hitupTime
  if speed < 0 then
    self.model:Play("Hit_Down_c")
  end
  local offset = self.hitupSpeed * self.hitupTime - 0.5 * GRAVITY * self.hitupTime * self.hitupTime
  local pos
  if self.fightMgr.isPerspective then
    local curPos = self.hitupInitPos.y + offset
    if curPos < 0 then
      curPos = 0
    end
    temp_pos.x = self.model.m_model.localPosition.x
    temp_pos.y = curPos
    temp_pos.z = self.model.m_model.localPosition.z
    self.model.m_model.localPosition = temp_pos
  else
    pos = self.fightMgr.fightPos[self.team].Pos[self.pos]
    local curPosY = self.hitupInitPos.y + offset
    if curPosY < pos.y then
      curPosY = pos.y
    end
    temp_pos.x = self.hitupInitPos.x
    temp_pos.y = curPosY
    temp_pos.z = 0
    self.model.m_node2d.localPosition = temp_pos
    self.model.m_model.localPosition = Map2DPosTo3D(self.model.m_node2d.localPosition.x, self.model.m_node2d.localPosition.y)
  end
  if self.fightMgr.isPerspective and 0 >= self.model.m_model.localPosition.y or not self.fightMgr.isPerspective and self.model.m_node2d.localPosition.y <= pos.y then
    local function OnBounceEnd()
      if self.hitupTime >= 0 then
        return
      end
      if self.attack_result and 0 < #self.attack_result then
        return
      end
      self.model:AttachShadow()
      if self.flyMount and self.model:AttachFlyMount() then
        self.flyMount.isDetached = false
      end
      self.beHitEffect = nil
      if 0 < self.isDead then
        if self.model:HasAnimClip("Hit_Idle2_c") then
          self.model:Play("Hit_Idle2_c")
          if self.isDead == DEATH_STATUS.FAKEDEAD or self:HasDeathAction() then
            self:OnDieEnd()
          elseif self.deathInfo and self.deathInfo.deathType == DEATH_TYPE.RONGJIE then
            local dissolveCfg = FightUtils.GetDissolveCfg(self.deathInfo.deathTypeId)
            if dissolveCfg == nil then
              self:OnDieEnd()
              return
            end
            local dissolveEff = GetEffectRes(dissolveCfg.effId)
            if dissolveEff then
              self.model:AddEffectWithRotation(dissolveEff.path, AttachType.FOOT)
            end
            local color = Color.Color(dissolveCfg.R, dissolveCfg.G, dissolveCfg.B, dissolveCfg.A)
            self.model:Dissolve(color, function()
              self:OnDieEnd()
            end)
          elseif self.deathInfo and self.deathInfo.deathType == DEATH_TYPE.JISUI then
            do
              local shatterCfg = FightUtils.GetShatterCfg(self.deathInfo.deathTypeId)
              self.deathInfo.shatter_type = SHATTER_TYPE.VERTICAL
              local isLast = self.fightMgr:IsLastRound()
              self.model:Shatter(shatterCfg.f, shatterCfg.a, shatterCfg.duration, function()
                self:OnShatterEnd(isLast)
              end)
            end
          else
            local dissolveEff = GetEffectRes(702000002)
            if dissolveEff then
              self.model:AddEffectWithRotation(dissolveEff.path, AttachType.FOOT)
            end
            self:OnDieEnd()
          end
        else
          local OnLand = function(self)
            local ret = self.model:PlayAnim(ActionName.Death1, function()
              self:OnDieEnd()
            end)
            if not ret then
              self:OnDieEnd()
            end
          end
          table.insert(self.nextCallbacks, {delay = 0, callback = OnLand})
        end
        if self.soundCfg then
          self.fightMgr:PlaySoundEffect(self.soundCfg.dead)
        end
      else
        table.insert(self.nextCallbacks, {
          delay = 0,
          callback = FightUnit.GetUp
        })
      end
    end
    self.hitupTargetPos = nil
    self.hitupTime = -1
    local eff = GetEffectRes(702000004)
    self.model:AddChildEffect(eff.path, AttachType.FOOT, 0)
    self.fightMgr:PlaySoundEffect(720070000)
    if self.model:HasAnimClip("Hit_Idle1_c") then
      self.model:PlayAnim("Hit_Idle1_c", OnBounceEnd)
    else
      OnBounceEnd()
    end
  end
end
def.method().GetUp = function(self)
  local function OnGetUpEnd()
    self:EndAction()
  end
  if self.model:HasAnimClip(ActionName.Revive) then
    self.model:PlayAnim(ActionName.Revive, OnGetUpEnd)
  else
    self:Stand()
    self:EndAction()
  end
end
def.method("string", "number").Return = function(self, actionName, duration)
  if self.model == nil then
    Debug.LogWarning("[FightError]fight unit model is nil when playing Return")
    Debug.LogWarning(debug.traceback())
    return
  end
  local pos = self.fightMgr.fightPos[self.team].Pos[self.pos]
  local function OnEnd()
    if self.isProtecter then
      self.isProtecter = false
    end
    self:ResetPos()
    self:EndAction()
  end
  if self.skill and self.skill.hasRelativeOffset then
    self.model:ResetModelPos()
  end
  self.model:SetVisible(true)
  self:MoveTo(actionName, pos.x, pos.y, duration, OnEnd, true, 0, 0)
end
def.method().ResetPos = function(self)
  if self.model == nil then
    warn("[Fight]model is nil when reset pos : ", self.name)
    return
  end
  local pos_list = self.fightMgr.fightPos[self.team]
  local pos = pos_list and pos_list.Pos[self.pos]
  if pos then
    self.model:SetPos(pos.x, pos.y)
  end
  local dir = FightConst.TeamDir[self.team]
  if dir then
    self.model:SetDir(dir)
  end
  if self.model.mECWingComponent then
    self.model.mECWingComponent:Stand()
  end
  if self.flyMount then
    self.flyMount:SwitchToBackStance(false)
  end
  self:CheckAbnormalStatus()
end
def.method().CheckAbnormalStatus = function(self)
  if self.model == nil or self.isDead == DEATH_STATUS.DEAD or self.isDead == DEATH_STATUS.FAKEDEAD then
    return
  end
  if self:CheckBuffStatus(FighterStatus.BUFF_ST__ICECOOL) then
    self.model:StopCurrentAnim()
  elseif self:CheckBuffStatus(FighterStatus.BUFF_ST__STONE) then
    self.model:TurnToStone()
    self.model:StopCurrentAnim()
  else
    if self.model.m_IsStone then
      self.model:RecoverFromStone()
    end
    local isInvisible = self:CheckBuffStatus(FighterStatus.BUFF_ST__INVISIBLE)
    if isInvisible then
      self.model:SetAlpha(0.5)
    elseif self.model.m_IsAlpha then
      self.model:CloseAlpha()
    end
    if self:NeedResetAction() then
      self:Stand()
    end
    if self:CheckBuffStatus(FighterStatus.BUFF_ST__SLEEP) then
      self.model:Play(ActionName.Stand)
    end
  end
end
def.method().Stand = function(self)
  local actModel = self:GetActModel()
  if actModel == nil then
    return
  end
  if self:CheckBuffStatus(FighterStatus.BUFF_ST__HOUFA_MISSILE) then
    actModel.stand_stance = "Skill4_2_c"
  else
    actModel.stand_stance = ActionName.FightStand
  end
  actModel:Stand()
  if actModel.mECWingComponent then
    actModel.mECWingComponent:Stand()
  end
end
def.method("number", "number").MeleeAttack = function(self, moveActionId, shadowId)
  if self.masterModel or self.isHugeUnit then
    self:Attack()
  else
    local moveAction = FightUtils.GetMoveActionCfg(moveActionId)
    if moveAction then
      local targetPos = self:GetTargetPos(moveAction.targetPos)
      self:MoveTo(moveAction.actionName, targetPos.x, targetPos.y, moveAction.duration, FightUnit.OnAttackRunFinished, true, 0, moveAction.effectId)
      self.playcfg.movePos = moveAction.targetPos
      if shadowId > 0 then
        self:PlayGhostEffect(shadowId)
      end
    end
  end
end
def.method().CounterAttack = function(self)
  if self.counterAttack == nil then
    warn("[Fight]counterAttack is nil: ", self.name)
    return
  end
  self.model:ShowTitleIcon(9002, 1)
  self.playcfg = self:SetAdditionalPhase(self.counterAttack.skill)
  self.curAttackTargets = self.targets
  self:Attack()
end
def.method("number", "=>", "table").SetAdditionalPhase = function(self, skillId)
  local skillcfg = self.fightMgr:GetSkillCfg(skillId)
  if skillcfg == nil then
    warn("[Fight]SetAdditionalPhase skill cfg is nil: ", skillId)
    return nil
  end
  local playcfg = FightUtils.GetSkillPlayCfg(skillcfg.skillPlayid)
  if playcfg == nil then
    warn("[Fight]SetAdditionalPhase skillplay cfg is nil: ", skillId, skillcfg.skillPlayid)
    return nil
  end
  if playcfg.nameEffectId > 0 then
    self.model:ShowTitleIcon(playcfg.nameEffectId, 1)
    local soundId = playcfg.maleSoundId
    if self.gender == GenderEnum.FEMALE then
      soundId = playcfg.femaleSoundId
    end
    if soundId and self.fightUnitType == GameUnitType.ROLE and soundId > 0 then
      self.fightMgr:PlaySoundEffect(soundId)
    end
  end
  self.skill = nil
  local phase = playcfg.phases[1]
  if phase then
    playcfg.curPhaseFinished = false
    if 0 < phase[2] then
      local actionPhaseCfg = FightUtils.GetSkillPlayPhaseCfg(phase[2])
      if actionPhaseCfg == nil then
        return playcfg
      end
      local actionCfg = FightUtils.GetSkillActionCfg(self.modelId, actionPhaseCfg.action)
      if actionPhaseCfg.action == 0 then
        actionCfg = {}
      end
      if actionCfg == nil then
        warn("[[Fight]Error SetAdditionalPhase] no actionCfg found for model id and action id: ", self.modelId, actionPhaseCfg.action)
        self:EndAllAction()
        return playcfg
      end
      self.skill = {}
      self.skill.modelId = actionCfg.modelId
      self.skill.actionId = actionCfg.actionId
      self.skill.actionName = actionCfg.actionName
      self.skill.sound = actionCfg.sound
      self.skill.hasRelativeOffset = actionCfg.hasRelativeOffset
      self.skill.needReset = actionCfg.needReset
      self.skill.ghostEffId = actionPhaseCfg.shadow
      self.skill.cameraMoveId = actionPhaseCfg.cameraMoveId
      self.skill.boneEffectId = actionPhaseCfg.boneEffectId
      self.beHitPoints = {}
      if actionCfg.behitInfos then
        for k, v in pairs(actionCfg.behitInfos) do
          local behitInfo = {}
          behitInfo.behitAction = v.behitAction
          behitInfo.paramId = v.paramId
          behitInfo.behitTime = v.behitTime
          behitInfo.camShake = v.camShake
          self.beHitPoints[k] = behitInfo
        end
      end
      self.effectList = {}
      self.skill.effectDuration = 0
      if actionPhaseCfg.effects and 0 < #actionPhaseCfg.effects then
        local i = 1
        for i = 1, #actionPhaseCfg.effects do
          local v = actionPhaseCfg.effects[i]
          if 0 > v.delay then
            v.delay = actionCfg.effectDelays[i]
          end
          local effPlay = FightUtils.GetEffectPlayCfg(self.modelId, v.effectId)
          if effPlay then
            local duration = effPlay.duration
            if 0 < v.delay then
              duration = duration + v.delay
            end
            if duration > self.skill.effectDuration then
              self.skill.effectDuration = duration
            end
            local atkEffId = self.gender == GenderEnum.FEMALE and effPlay.femaleAttackEffectId or 0
            if atkEffId <= 0 then
              atkEffId = effPlay.attackEffectId
            end
            if atkEffId > 0 then
              local effres = GetEffectRes(atkEffId)
              if effres then
                self.fightMgr:LoadEffectRes(effres.path)
                effres.delay = v.delay
                effres.duration = v.duration
                effres.effectMoveType = effPlay.effectMoveType
                effres.posType = effPlay.effectPosType
                effres.attachPoint = effPlay.attachPoint
                effres.effectPosDest = effPlay.effectPosDest
                if 0 < #effPlay.behitInfos then
                  effres.behitTime = effPlay.behitInfos[1].behitTime
                end
                table.insert(self.effectList, effres)
              else
                warn("[[Fight] Error SetAdditionalPhase] attack Effect is nil for effPlay : " .. effPlay.id)
              end
            end
            local beHitEff
            if 0 < effPlay.beAttackEffectId then
              local effres = GetEffectRes(effPlay.beAttackEffectId)
              if effres then
                beHitEff = effres
                self.fightMgr:LoadEffectRes(effres.path)
              end
            end
            for _, target in pairs(self.targets) do
              target.beHitEffect = beHitEff
            end
            for _, info in pairs(effPlay.behitInfos) do
              if 0 <= info.behitTime then
                local behitInfo = {}
                behitInfo.behitAction = info.behitAction
                behitInfo.paramId = info.paramId
                behitInfo.behitTime = info.behitTime
                behitInfo.camShake = info.camShake
                if 0 < v.delay then
                  behitInfo.behitTime = behitInfo.behitTime + v.delay
                end
                table.insert(self.beHitPoints, behitInfo)
              end
            end
          end
        end
      end
    end
  end
  return playcfg
end
def.method("boolean").Escape = function(self, success)
  local escapeDuration = constant.FightConst.ESCAPE_ACTION_TIME / 1000
  local fxEscape
  local function OnEscapeSuccess()
    local function OnEnd()
      if self.model == nil then
        return
      end
      if fxEscape then
        ECFxMan.Instance():Stop(fxEscape)
        fxEscape = nil
      end
      if self.fightMgr:GetFightUnit(self.id).roleId == gmodule.moduleMgr:GetModule(ModuleId.HERO).roleId then
        self.fightMgr:EndFight()
      else
        local all_units = self.fightMgr.fightUnits
        if all_units then
          for k, v in pairs(all_units) do
            if k ~= self.id then
              v:RemoveLinkedEffectWithTarget(self.id)
            end
          end
        end
        self.fightMgr:RemoveFightUnit(self.id)
        self.isDead = DEATH_STATUS.DEAD
        self:EndAction()
      end
    end
    local angle = (270 - FightConst.TeamDir[self.team]) / 180 * math.pi
    local x = self.model.m_node2d.localPosition.x + 1000 * math.cos(angle)
    local y = self.model.m_node2d.localPosition.y + 1000 * math.sin(angle)
    self.model:Play(ActionName.Run)
    self.model:MoveTo(x, y, OnEnd, escapeDuration, true, 0)
    if self.fightUnitType == GameUnitType.ROLE then
      local pet = self.fightMgr.groups[self.group].pet
      if pet then
        pet.model:Play(ActionName.Run)
        pet.model:MoveTo(x, y, nil, escapeDuration * 1.1, true, 0)
      end
    end
  end
  local function OnRunEnd()
    if success then
      OnEscapeSuccess()
    else
      if fxEscape then
        ECFxMan.Instance():Stop(fxEscape)
        fxEscape = nil
      end
      self:EndAction()
    end
  end
  self.model:SetDir((FightConst.TeamDir[self.team] + 180) % 360)
  self.model:Play(ActionName.Run)
  fxEscape = self.model:AddChildEffect(RESPATH.ESCAPE_EFFECT, AttachType.FOOT, 0)
  GameUtil.AddGlobalTimer(escapeDuration, true, OnRunEnd)
end
def.method().PrepareToJoin = function(self)
  local angle = (270 - FightConst.TeamDir[self.team]) / 180 * math.pi
  local dist = 600
  local x = self.model.m_node2d.localPosition.x + dist * math.cos(angle)
  local y = self.model.m_node2d.localPosition.y + dist * math.sin(angle)
  self.model:SetPos(x, y)
end
def.method().Join = function(self)
  local joinDuration = constant.FightConst.ESCAPE_ACTION_TIME / 400
  local fxEscape
  local function OnRunEnd()
    if self.model == nil then
      return
    end
    if fxEscape then
      ECFxMan.Instance():Stop(fxEscape)
      fxEscape = nil
    end
    self:Stand()
    self.fightMgr:OnActionEnd({
      self.id
    })
  end
  local pos = self.fightMgr.fightPos[self.team].Pos[self.pos]
  self.model:Play(ActionName.Run)
  self.model:MoveTo(pos.x, pos.y, OnEnd, joinDuration, true, 0)
  fxEscape = self.model:AddChildEffect(RESPATH.ESCAPE_EFFECT, AttachType.FOOT, 0)
  GameUtil.AddGlobalTimer(joinDuration, true, OnRunEnd)
end
def.method(FightUnit).DoProtect = function(self, target)
  self.isProtecter = true
  local pos = self.fightMgr.fightPos[target.team].ProtectPos[target.pos]
  local function OnProtectRunFinished()
    self.model:SetPos(pos.x, pos.y)
    self.model:SetDir(target.model:GetDir())
    self:Stand()
    self.protectReady = true
  end
  local maskType = 1
  if target.team == FightConst.RIGHT_BOTTOM then
    maskType = 2
  end
  if self.fightMgr.isFlyBattle then
    maskType = 0
  end
  self:MoveTo(ActionName.FightRun, pos.x, pos.y, FightConst.PLAY_TIME.PROTECT_RUN, OnProtectRunFinished, true, maskType, 0)
  self.model:ShowTitleIcon(7009, 1)
  target.model:ShowTitleIcon(7009, 1)
end
def.method(FightUnit).Protect = function(self, target)
  if self.isProtecter then
    self:AddNextAction("Protect", function()
      return self.isProtecter == false
    end, function()
      self:DoProtect(target)
    end)
  else
    self:DoProtect(target)
  end
end
def.method(FightUnit, "boolean").Capture = function(self, target, success)
  local pos = self.fightMgr.fightPos[target.team].Attackpos_front[target.pos]
  local function OnCaptureRunFinished()
    self.model:SetPos(pos.x, pos.y)
    local function OnCaptureEnd()
      local tip = textRes.Fight[12]
      if success then
        self.fightMgr:RemoveFightUnit(target.id)
        tip = textRes.Fight[11]
      end
      Toast(tip)
      if self.model.mECWingComponent then
        self.model.mECWingComponent:Stand()
      end
      self:Return(ActionName.FightRun, FightConst.PLAY_TIME.RETURN_POS)
    end
    self:GetActModel():PlayAnim(ActionName.Magic, OnCaptureEnd)
    if self.model.mECWingComponent then
      self.model.mECWingComponent:Attack()
    end
    if self.model.mECPartComponent then
      self.model.mECPartComponent:PlayAnimation(ActionName.Magic, ActionName.Attack)
    end
    local eff = GetEffectRes(FightConst.CAPTURE)
    if eff then
      local u3dpos = target.model.m_model.localPosition
      local rotation = target.model.m_model.localRotation
      self.fightMgr:PlayEffect(eff.path, nil, u3dpos, rotation)
    end
  end
  self:MoveTo(ActionName.FightRun, pos.x, pos.y, FightConst.PLAY_TIME.RETURN_POS, OnCaptureRunFinished, true, 0, 0)
end
def.method("table").Summon = function(self, action)
  local PlaySummon = require("netio.protocol.mzm.gsp.fight.PlaySummon")
  local teamId = FightConst.ACTIVE_TEAM
  if action.team == PlaySummon.PASSIVE_TEAM then
    teamId = FightConst.PASSIVE_TEAM
  end
  local teamPos = self.fightMgr.fightPos[teamId].Pos
  local function OnSummonEnd()
    if action.result == PlaySummon.SUMMON then
      local pet = self.fightMgr.groups[self.group].pet
      if pet then
        self.fightMgr:RemoveFightUnit(pet.id)
        self.fightMgr.groups[self.group].pet = nil
      end
      self.fightMgr:WaitForNewCreatedUnits()
      for k, v in pairs(action.fighters) do
        local unit = self.fightMgr:CreateFighter(k, v, teamId, action.groupid)
        if unit == self.fightMgr:GetMyPet() then
          Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.MODEL_PROP_CHANGED, {
            type = unit.fightUnitType,
            hp = unit.hp,
            hpmax = unit.hpmax,
            mp = unit.mp,
            mpmax = unit.mpmax,
            rage = unit.rage,
            ragemax = unit.ragemax
          })
          if unit.fightUnitType == GameUnitType.PET and self.fightMgr:tryget("summonPetTimes") then
            self.fightMgr.summonPetTimes = self.fightMgr.summonPetTimes - 1
            if self.fightMgr.summonPetTimes < 0 then
              self.fightMgr.summonPetTimes = 0
            end
          elseif unit.fightUnitType == GameUnitType.CHILDREN and self.fightMgr:tryget("summonChildTimes") then
            self.fightMgr.summonChildTimes = self.fightMgr.summonChildTimes - 1
            if 0 > self.fightMgr.summonChildTimes then
              self.fightMgr.summonChildTimes = 0
            end
          end
        end
      end
      require("Main.Fight.ui.DlgFight").Instance():ShowAutoSkill()
    elseif action.result == PlaySummon.SUMMON_BACK then
      for k, _ in pairs(action.fighters) do
        self.fightMgr:RemoveFightUnit(k)
      end
    end
    self:EndAction()
  end
  if teamId ~= self.team then
    OnSummonEnd()
    return
  end
  self:GetActModel():PlayAnim(ActionName.Magic, OnSummonEnd)
  if self.model.mECWingComponent then
    self.model.mECWingComponent:Attack()
  end
  if self.model.mECPartComponent then
    self.model.mECPartComponent:PlayAnimation(ActionName.Magic, ActionName.Attack)
  end
  for k, v in pairs(action.fighters) do
    local effpos = teamPos[v.pos + 1]
    local u3dpos = Map2DPosTo3D(effpos.x, effpos.y)
    local effcfg = GetEffectRes(702020005)
    if effcfg == nil then
      warn("[Fight]summon effect is nil")
      return
    end
    self.fightMgr:PlayEffect(effcfg.path, nil, u3dpos, Quaternion.identity)
  end
end
def.method("table").Talk = function(self, action)
  local words = FightUtils.GetTalkContent(action.strid)
  local content = words
  if #action.args > 0 then
    content = string.format(content, unpack(action.args))
  end
  local duration = constant.FightConst.WORDS_DURATION / 1000
  self.model:Talk(content, duration)
  local endDelay = constant.FightConst.WORDS_ROUND_TIME / 1000
  table.insert(self.nextCallbacks, {
    delay = endDelay,
    callback = self.EndAction
  })
end
def.method("table", "table", "table").UseItem = function(self, status, targets, targetStatus)
  if self.fightMgr:IsMyUnit(self.id) and self.fightMgr:tryget("useItemTimes") then
    self.fightMgr.useItemTimes = self.fightMgr.useItemTimes - 1
    if self.fightMgr.useItemTimes < 0 then
      self.fightMgr.useItemTimes = 0
    end
  end
  local function OnEffEnd()
    for _, v in pairs(targets) do
      if not v:UpdateStatus(targetStatus[v.id], true) then
        v:EndAction()
      end
    end
    if not self:UpdateStatus(status, true) then
      self:EndAction()
    end
  end
  local function OnActEnd()
    self:GetActModel():CrossFade(ActionName.FightStand, 0.1)
    local EffectPosType = require("consts.mzm.gsp.skill.confbean.EffectPosType")
    for _, v in pairs(targets) do
      local effres = GetEffectRes(702020005)
      if effres then
        v.effectList = {}
        self.fightMgr:LoadEffectRes(effres.path)
        effres.delay = 0
        effres.posType = EffectPosType.RELESER
        effres.effectPosDest = EffectPosType.RELESER
        effres.attachPoint = AttachType.FOOT
        effres.effectMoveType = EffectMoveType.NONE
        table.insert(v.effectList, effres)
        v:PlayEffectList()
      end
    end
    table.insert(self.nextCallbacks, {
      delay = FightConst.PLAY_TIME.USE_ITEM,
      callback = OnEffEnd
    })
  end
  self:GetActModel():PlayAnim(ActionName.Magic, OnActEnd)
  if self.model.mECWingComponent then
    self.model.mECWingComponent:Attack()
  end
  if self.model.mECPartComponent then
    self.model.mECPartComponent:PlayAnimation(ActionName.Magic, ActionName.Attack)
  end
end
def.method().ResetAction = function(self)
  self.in_turn = self:IsActionEnable()
  self.actionType = require("consts.mzm.gsp.fight.confbean.OperateType").OP_SKILL
  self.skillId = FightUtils.GetNormalAttackSkillId(self.menpai)
end
def.method("number", "number").PlaySkill = function(self, skillId, skillType)
  self.fightMgr:AddLog(string.format("[FightLog]%s(%d) play skill : %d", self.name, self.id, skillId))
  local skillcfg = self.fightMgr:GetSkillCfg(skillId)
  local useddata = self.skillUsedData[skillId]
  if useddata == nil and (skillcfg.count > 0 or 0 < skillcfg.cdRound) then
    useddata = {}
    if skillcfg.count > 0 then
      useddata.skillUseCount = 0
    end
    if 0 < skillcfg.cdRound then
      useddata.skillUseRound = 0
    end
    self.skillUsedData[skillId] = useddata
  end
  if useddata then
    if useddata.skillUseCount then
      useddata.skillUseCount = useddata.skillUseCount + 1
    end
    if useddata.skillUseRound then
      useddata.skillUseRound = skillcfg.cdRound + self.fightMgr.curRound
    end
  end
  if skillcfg == nil then
    warn("[Fight]skill cfg is nil : ", skillId)
    return
  end
  local skill_play_id = skillcfg.skillPlayid
  if 0 < self.state_group then
    local mapping_play_id = FightUtils.GetSkillPlayMappingCfg(skill_play_id, self.state_group, self.state)
    if mapping_play_id > 0 then
      skill_play_id = mapping_play_id
    end
  end
  local playcfg = FightUtils.GetSkillPlayCfg(skill_play_id)
  if playcfg == nil then
    warn("[Fight]skillplay cfg is nil : ", skillId)
    return
  end
  self.playcfg = playcfg
  self.totalHitNum = 0
  self.playcfg.skillId = skillId
  if skillId == constant.FightConst.DEFENCE_SKILL or skillId == 110000004 then
    local actionPhaseCfg = FightUtils.GetSkillPlayPhaseCfg(playcfg.phases[1][2])
    self.skill = FightUtils.GetSkillActionCfg(self.modelId, actionPhaseCfg.action)
    self.attack_result = nil
    self.playcfg = nil
    self:EndAllAction()
    return
  end
  local isCombo = skillType == PlaySkillEnum.LIAN_JI
  self.playcfg.skillType = skillType
  if skillType == PlaySkillEnum.SKILL_COUNTER_ATTACK then
    self.model:ShowTitleIcon(9002, 1)
  elseif not isCombo and 0 < playcfg.nameEffectId then
    self.model:ShowTitleIcon(playcfg.nameEffectId, 1)
  end
  if self.fightMgr.playVoice and self.fightUnitType == GameUnitType.ROLE and (self.usedSkills == nil or self.usedSkills[skillId] == nil) then
    local soundId = playcfg.maleSoundId
    if self.gender == GenderEnum.FEMALE then
      soundId = playcfg.femaleSoundId
    end
    if soundId and soundId > 0 then
      self.fightMgr:PlaySoundEffect(soundId)
    end
    if self.usedSkills == nil then
      self.usedSkills = {}
    end
    self.usedSkills[skillId] = true
  end
  if self.playcfg.skillPlayType == SkillAttackType.SINGLE then
    local phasesNum = #self.playcfg.phases
    local targetsNum = 0
    for i = 1, #self.targets do
      local target = self.targets[i]
      targetsNum = targetsNum + #target.attack_result
      local attack_others = target.attack_result[1].attackOthers
      if attack_others and #attack_others > 0 then
        self.playcfg.isAttackOtherSkill = true
        targetsNum = targetsNum + #attack_others
      end
    end
    local offset = 0
    for i = 1, phasesNum do
      local k = i - offset
      local phaseid = self.playcfg.phases[k][2]
      local behitNum = self:GetBehitPoint(phaseid)
      if phaseid > 0 and behitNum > 0 then
        if targetsNum <= 0 then
          table.remove(self.playcfg.phases, k)
          offset = offset + 1
        end
        targetsNum = targetsNum - behitNum
      end
    end
    if targetsNum > 0 then
    end
  end
  if _G.isDebugBuild and skillId ~= constant.FightConst.ATTACK_SKILL and not self:CheckSkillValid() then
    Debug.LogWarning(string.format("[Fight error]Skill is not valid : %d", skillId))
  end
  self.playcfg.totalPhaseNum = #self.playcfg.phases
  if 0 < playcfg.prepare then
    local phaseCfg = FightUtils.GetSkillPlayPhaseCfg(playcfg.prepare)
    if phaseCfg then
      local action = FightUtils.GetSkillActionCfg(phaseCfg.action)
      if action then
        local function OnEnd()
          FightUnit.NextPhase(self)
        end
        self:GetActModel():PlayAnim(action.name, OnEnd)
        if self.model.mECWingComponent then
          self.model.mECWingComponent:Attack()
        end
      end
    end
  else
    self:NextPhase()
  end
end
def.method("table", "table").Play = function(self, action, targets)
  self.targets = targets
  self.curAttackTargets = targets
  local PlayType = require("netio.protocol.mzm.gsp.fight.PlayType")
  if action.actionType == PlayType.PLAY_SKILL then
    if action.releaser then
      self:UpdateStatus(action.releaser, false)
    end
    if self.isInModelChange then
      action.releaser = nil
      function self.onModelChangeDone()
        self.onModelChangeDone = nil
        self:Play(action, targets)
      end
      return
    end
    if action.afterReleaser then
      self.afterStatus = action.afterReleaser
    end
    if self.deathSkills == nil and action.deathfighter2Skills[self.id] then
      self.deathSkills = action.deathfighter2Skills[self.id].skillList
    end
    if targets and #targets > 0 then
      for i = 1, #targets do
        local death_skills = action.deathfighter2Skills[targets[i].id]
        if death_skills then
          targets[i].deathSkills = death_skills.skillList
        end
      end
    end
    if action.skillplayType == action.LIAN_XIE_JI and self.fightMgr:IsNeedShowDlgPrelude() then
      local activeUnit = self.fightMgr:GetFightUnit(action.extra[action.EXTRA_LIAN_XIE_JI_TIGGER_ID])
      local compsiteCfgId = action.extra[action.EXTRA_LIAN_XIE_JI_CFG_ID]
      local function cb()
        require("Main.Fight.ui.DlgPrelude").Instance():Hide()
        self:PlaySkill(action.skill, action.skillplayType)
      end
      if activeUnit then
        require("Main.Fight.ui.DlgPrelude").Instance():ShowDlg(compsiteCfgId, activeUnit.gender, self.gender)
        self.fightMgr:SetShakeParam(161100003, 0.3)
      end
      table.insert(self.nextCallbacks, {
        delay = FightConst.PLAY_TIME.LIAN_XIE_JI,
        callback = cb
      })
    else
      self:PlaySkill(action.skill, action.skillplayType)
    end
  elseif action.actionType == PlayType.PLAY_CAPTURE then
    local target = self.fightMgr:GetFightUnit(action.capturedFighterid)
    local success = action.result == require("netio.protocol.mzm.gsp.fight.PlayCapture").CAPTURE_SUCCESS
    self:Capture(target, success)
  elseif action.actionType == PlayType.PLAY_SUMMON then
    self:Summon(action)
  elseif action.actionType == PlayType.PLAY_ESCAPE then
    local success = action.suc == require("netio.protocol.mzm.gsp.fight.PlayEscape").SUCCESS
    if self.fightMgr:IsMyHero(self.id) then
      Toast(string.format(textRes.Fight[4], tostring(action.sucRate)))
    end
    self:Escape(success)
  elseif action.actionType == PlayType.PLAY_TALK then
    self:Talk(action)
  elseif action.actionType == PlayType.PLAY_CHANGE_FIGHTER then
    self:Evolve(action)
  elseif action.actionType == PlayType.PLAY_CHANGE_MODEL then
    self:ChangeModel(action)
  end
end
def.method("=>", "boolean").PrepareNextPhase = function(self)
  if self.playcfg.isAttackPhase and self:HasConsecutiveAttack() then
    self.next_target_data = table.remove(self.consecutiveAttack, 1)
    local attack_result_bean = target and target.attack_result[#target.attack_result]
    local hasRevive = attack_result_bean and attack_result_bean.statusMap[AttackResultBean.TARGET_RELIVE]
    if hasRevive then
      self:AddNextAction("NextConsecutiveAttack", function()
        return #target.attack_result == 0 and target.reviveStatus == nil
      end, function()
        self.fightMgr:SetConsecutiveAttack(self)
        self:NextPhase()
      end)
      return false
    end
    self.fightMgr:SetConsecutiveAttack(self)
  end
  return true
end
def.method().NextPhase = function(self)
-- fail 477
unluac.decompile.expression.TableReference@448139f0
-1
  self.fightMgr:AddLog(string.format("[next phase]%s(%d) phase left: %d", self.name, self.id, self.playcfg and #self.playcfg.phases or -1))
  if self.playcfg == nil then
    self.fightMgr:AddLog(string.format("[FightLog]%s(%d) playcfg is nil when play nextphase", self.name, self.id))
    self:EndAction()
    return
  end
  if self.playcfg.skillType ~= PlaySkillEnum.DEATH_TRIGGER and self.playcfg.skillType ~= PlaySkillEnum.DEATH_BOOMING and (self.isDead == DEATH_STATUS.FAKEDEAD or self.isDead == DEATH_STATUS.DEAD) then
    if self.reviveStatus or self:CheckFightStatus(FighterStatus.STATUS_RELIVE) then
      return
    end
    self.fightMgr:AddLog(string.format("[FightLog]%s(%d) is dead when play nextphase, isActionEnded: %s", self.name, self.id, tostring(self.isActionEnded)))
    self.playcfg.phases = nil
    if not self.isActionEnded then
      return
    end
  end
  if self.next_target_data == nil and not self:PrepareNextPhase() then
    return
  end
  if self.playcfg.phases == nil or #self.playcfg.phases == 0 then
    if self.playcfg.returnStage and 0 < self.playcfg.returnStage then
      local returnPhaseCfg = FightUtils.GetSkillPlayPhaseCfg(self.playcfg.returnStage)
      if returnPhaseCfg then
        self.fightMgr:StopCloseUpCamera()
        local moveAction = FightUtils.GetMoveActionCfg(returnPhaseCfg.action)
        local pos = self.fightMgr.fightPos[self.team].Pos[self.pos]
        self:Return(moveAction.actionName, moveAction.duration)
      end
    else
      self:EndAction()
    end
    return
  end
  self.skill = nil
  local phase = self.playcfg.phases[1]
  if phase then
    self.playcfg.curPhaseFinished = false
    if 0 < phase[2] then
      local actionPhaseCfg = FightUtils.GetSkillPlayPhaseCfg(phase[2])
      if actionPhaseCfg == nil then
        return
      end
      local actionCfg = FightUtils.GetSkillActionCfg(self.modelId, actionPhaseCfg.action)
      if actionPhaseCfg.action == 0 then
        actionCfg = {}
      end
      if actionCfg == nil then
        self.fightMgr:AddLog(string.format("[Fight Error] no actionCfg found for model id(%d) and action id(%d)", self.modelId, actionPhaseCfg.action))
        self:EndAllAction()
        return
      end
      self.skill = {}
      self.skill.modelId = actionCfg.modelId
      self.skill.actionId = actionCfg.actionId
      self.skill.actionName = actionCfg.actionName
      self.skill.sound = actionCfg.sound
      self.skill.hasRelativeOffset = actionCfg.hasRelativeOffset
      self.skill.needReset = actionCfg.needReset
      self.skill.ghostEffId = actionPhaseCfg.shadow
      self.skill.cameraMoveId = actionPhaseCfg.cameraMoveId
      self.skill.boneEffectId = actionPhaseCfg.boneEffectId
      self.skill.specialActDuraction = actionPhaseCfg.specialActTime + actionPhaseCfg.specialActDuration
      if 0 >= self.skill.specialActDuraction then
        self.skill.specialActDuraction = 0.5
      end
      self.beHitPoints = {}
      if actionCfg.behitInfos then
        for k, v in pairs(actionCfg.behitInfos) do
          local behitInfo = {}
          behitInfo.behitAction = v.behitAction
          behitInfo.paramId = v.paramId
          behitInfo.behitTime = v.behitTime
          behitInfo.camShake = v.camShake
          table.insert(self.beHitPoints, behitInfo)
        end
      end
      self.effectList = {}
      self.skill.effectDuration = 0
      if actionPhaseCfg.effects and 0 < #actionPhaseCfg.effects then
        local i = 1
        for i = 1, #actionPhaseCfg.effects do
          local v = actionPhaseCfg.effects[i]
          if 0 > v.delay then
            v.delay = actionCfg.effectDelays and actionCfg.effectDelays[i] or 0
          end
          local effPlay = FightUtils.GetEffectPlayCfg(self.modelId, v.effectId)
          if effPlay then
            local duration = effPlay.duration
            if 0 < v.delay then
              duration = duration + v.delay
            end
            if duration > self.skill.effectDuration then
              self.skill.effectDuration = duration
            end
            local atkEffId = self.gender == GenderEnum.FEMALE and effPlay.femaleAttackEffectId or 0
            if atkEffId <= 0 then
              atkEffId = effPlay.attackEffectId
            end
            if atkEffId > 0 then
              local effres = GetEffectRes(atkEffId)
              if effres then
                self.fightMgr:LoadEffectRes(effres.path)
                effres.delay = v.delay
                effres.duration = effPlay.duration
                effres.posType = effPlay.effectPosType
                effres.attachPoint = effPlay.attachPoint
                effres.effectPosDest = effPlay.effectPosDest
                effres.effectMoveType = effPlay.effectMoveType
                if 0 < #effPlay.behitInfos then
                  effres.behitTime = effPlay.behitInfos[1].behitTime
                end
                table.insert(self.effectList, effres)
              else
                self.fightMgr:AddLog(string.format("[Fight warning]attack Effect res is nil for effPlay : %d", atkEffId))
              end
            end
            local behitEff
            if 0 < effPlay.beAttackEffectId then
              local effres = GetEffectRes(effPlay.beAttackEffectId)
              if effres then
                behitEff = effres
                self.fightMgr:LoadEffectRes(effres.path)
              end
            end
            if self.curAttackTargets and 0 < #self.curAttackTargets then
              for _, target in pairs(self.curAttackTargets) do
                target.beHitEffect = behitEff
              end
            end
            for _, info in pairs(effPlay.behitInfos) do
              if 0 <= info.behitTime then
                local behitInfo = {}
                behitInfo.behitAction = info.behitAction
                behitInfo.paramId = info.paramId
                behitInfo.behitTime = info.behitTime
                behitInfo.camShake = info.camShake
                if 0 < v.delay then
                  behitInfo.behitTime = behitInfo.behitTime + v.delay
                end
                table.insert(self.beHitPoints, behitInfo)
              end
            end
          end
        end
      end
      if actionPhaseCfg.specialAct and 0 < actionPhaseCfg.specialAct then
        if self.specialAct == nil then
          self.specialAct = {}
        end
        self.specialAct.act = actionPhaseCfg.specialAct
        self.specialAct.delay = actionPhaseCfg.specialActTime
        self.specialAct.duration = actionPhaseCfg.specialActDuration
        self.specialAct.param = actionPhaseCfg.specialActParam
      end
      if 0 < phase[1] then
        local movePhaseCfg = FightUtils.GetSkillPlayPhaseCfg(phase[1])
        if movePhaseCfg then
          if 0 < movePhaseCfg.boneEffectId then
            self:SetBoneEffect(movePhaseCfg.boneEffectId)
          end
          self.skill.moveAction = movePhaseCfg.action
          self:MeleeAttack(movePhaseCfg.action, movePhaseCfg.shadow)
        end
      elseif 0 < actionPhaseCfg.move then
        FightUnit.OnAttackRunFinished(self)
        local pos = self:GetActionMoveTargetPos(actionPhaseCfg.move)
        self:InterruptMoveToPos(pos.x, pos.y, actionPhaseCfg.moveCfgId)
      else
      end
    elseif 0 < phase[1] then
      do
        local movePhaseCfg = FightUtils.GetSkillPlayPhaseCfg(phase[1])
        if 0 < movePhaseCfg.boneEffectId then
          self:SetBoneEffect(movePhaseCfg.boneEffectId)
        end
        local moveAction = FightUtils.GetMoveActionCfg(movePhaseCfg.action)
        self.playcfg.movePos = moveAction.targetPos
        if moveAction.modelDisPlay == MovePlayType.DISAPPEAR_SLOWLY then
          self.model:Play(moveAction.actionName)
          self.valishTime = {
            time = moveAction.duration,
            duration = moveAction.duration
          }
          self.model:SetAlpha(1)
          if self.model.mECPartComponent then
            self.model.mECPartComponent:SetAlpha(1)
          end
        elseif moveAction.modelDisPlay == MovePlayType.APPEAR_SLOWLY then
          self.appearTime = {
            time = moveAction.duration,
            duration = moveAction.duration
          }
          self.model:SetVisible(true)
          self.model:SetAlpha(0)
          local targetPos = self:GetTargetPos(moveAction.targetPos)
          self.model:SetPos(targetPos.x, targetPos.y)
        elseif moveAction.modelDisPlay == MovePlayType.SHAN_XIAN then
          self.model:SetVisible(false)
          local function appear()
            local targetPos = self:GetTargetPos(moveAction.targetPos)
            self.model:SetPos(targetPos.x, targetPos.y)
            self.model:SetVisible(true)
            self:RemoveCurrentPhase()
            self:NextPhase()
          end
          table.insert(self.nextCallbacks, {delay = 0.1, callback = appear})
        elseif moveAction.modelDisPlay == MovePlayType.NORMAL_MOVE then
          self:MeleeAttack(movePhaseCfg.action, movePhaseCfg.shadow)
        end
      end
    end
  end
end
def.method("table").SetAffiliatedAttack = function(self, attack_result)
  if self.playcfg == nil or attack_result == nil then
    return
  end
  local target = self.fightMgr:GetFightUnit(attack_result.targetid)
  if target == nil then
    self.fightMgr:AddLog(string.format("[SetAffiliatedAttack]target(%d) not found", targetId))
    return
  end
  self.fightMgr:AddLog(string.format("[FightLog]SetAffiliatedAttack target: %s(%d)", target.name, target.id))
  local phase = self.playcfg.phases[1]
  if phase == nil or phase[2] == nil or phase[2] <= 0 then
    return
  end
  local actionPhaseCfg = FightUtils.GetSkillPlayPhaseCfg(phase[2])
  if actionPhaseCfg == nil then
    return
  end
  local actionCfg = FightUtils.GetSkillActionCfg(self.modelId, actionPhaseCfg.action)
  if actionPhaseCfg.action == 0 then
    actionCfg = {}
  end
  if actionCfg == nil then
    return
  end
  target.effectList = {}
  if actionPhaseCfg.effects and 0 < #actionPhaseCfg.effects then
    local i = 1
    for i = 1, #actionPhaseCfg.effects do
      local v = actionPhaseCfg.effects[i]
      local effPlay = FightUtils.GetEffectPlayCfg(self.modelId, v.effectId)
      if effPlay then
        local duration = effPlay.duration
        local atkEffId = self.gender == GenderEnum.FEMALE and effPlay.femaleAttackEffectId or 0
        if atkEffId <= 0 then
          atkEffId = effPlay.attackEffectId
        end
        if atkEffId > 0 then
          local effres = GetEffectRes(atkEffId)
          if effres then
            self.fightMgr:LoadEffectRes(effres.path)
            effres.delay = 0
            effres.posType = 0
            effres.effectMoveType = EffectMoveType.NONE
            effres.attachPoint = effPlay.attachPoint
            effres.effectPosDest = 0
            effres.rotate = effres.rotate + 180
            if 0 < #effPlay.behitInfos then
              effres.behitTime = effPlay.behitInfos[1].behitTime
            end
            table.insert(target.effectList, effres)
          end
        end
        if 0 < effPlay.beAttackEffectId then
          local effres = GetEffectRes(effPlay.beAttackEffectId)
          if effres then
            self.fightMgr:LoadEffectRes(effres.path)
            target.beHitEffect = effres
          end
        end
      end
    end
  end
  if target.id == self.id then
    self.fightMgr:AddLog(string.format("[FightLog](SetAffiliatedAttack) %s(%d) is interrupted", target.name, target.id))
    target.isInterrupted = true
  end
  target:PlayEffectList()
end
def.method("number", "number", "number").InterruptMoveToPos = function(self, targetX, targetY, moveCfgId)
  local mypos = self.fightMgr.fightPos[self.team].Pos[self.pos]
  local interruptPos = {}
  local cfg = FightUtils.GetInterrupMoveCfg(moveCfgId)
  if cfg == nil then
    return
  end
  local prevDelay = 0
  local foreDelay = 0
  local moveDuration = 0
  local distance = 0
  local function NextMove()
    if #cfg.moves == 0 then
      self:StopGhostEffect(false)
      self:SetAttackDir(self.model)
      return
    end
    moveDuration = 0
    prevDelay = foreDelay
    foreDelay = 0
    local del = 0
    local i = 1
    for i = 1, #cfg.moves do
      del = del + 1
      local m = cfg.moves[i]
      distance = distance + m.duration
      if m.move then
        moveDuration = moveDuration + m.duration
      else
        if moveDuration == 0 then
          prevDelay = prevDelay + m.duration
          break
        end
        foreDelay = foreDelay + m.duration
        break
      end
    end
    for i = 1, del do
      table.remove(cfg.moves, 1)
    end
    local function BeginToMove()
      if moveDuration > 0 then
        local ratio = distance / cfg.totalTime
        interruptPos.x = mypos.x + (targetX - mypos.x) * ratio
        interruptPos.y = mypos.y + (targetY - mypos.y) * ratio
        self.model:MoveTo(interruptPos.x, interruptPos.y, NextMove, moveDuration, true, 0)
      else
        NextMove()
      end
    end
    if prevDelay > 0 then
      table.insert(self.nextCallbacks, {delay = prevDelay, callback = BeginToMove})
      prevDelay = 0
    else
      BeginToMove()
    end
  end
  NextMove()
end
def.method().OnMoveEnd = function(self)
  self:ClearDelEffects()
  self:RemoveCurrentPhase()
  self.valishTime = nil
  self.appearTime = nil
  self:NextPhase()
end
def.method().EndAllAction = function(self)
  if self.targets then
    for _, target in pairs(self.targets) do
      target:EndAction()
    end
  end
  table.insert(self.nextCallbacks, {
    delay = 0.1,
    callback = self.EndAction
  })
end
def.method("number", "=>", "table").GetTargetPos = function(self, posType)
  if posType == MOVE_POS_TYPE.TARGET_QIAN_MIAN then
    if self.targets == nil or self.targets[1] == nil then
      self.fightMgr:AddLog(string.format("[FightLog]GetTargetPos: no target! use center instead, skillId: ", self.playcfg and self.playcfg.skillId))
      return self.fightMgr.fightPos[3]
    end
    local attackPointTable = self.fightMgr.fightPos[self.targets[1].team].Attackpos_front
    return attackPointTable[self.targets[1].pos]
  elseif posType == MOVE_POS_TYPE.TARGET_QIAN_FANG then
    if self.targets == nil or self.targets[1] == nil then
      self.fightMgr:AddLog(string.format("[FightLog]GetTargetPos: no target! use center instead, skillId: ", self.playcfg and self.playcfg.skillId))
      return self.fightMgr.fightPos[3]
    end
    local attackPointTable = self.fightMgr.fightPos[self.targets[1].team].Attackpos_ahead
    return attackPointTable[self.targets[1].pos]
  elseif posType == MOVE_POS_TYPE.FIHGT_CENTER then
    return self.fightMgr.fightPos[3]
  elseif posType == MOVE_POS_TYPE.RELESER_POS then
    return self.fightMgr.fightPos[self.team].Pos[self.pos]
  elseif posType == MOVE_POS_TYPE.ENERMY_LOW then
    local oppoTeam = self.fightMgr:GetOpponentTeam(self.team)
    return self.fightMgr.fightPos[oppoTeam.teamId].Left
  elseif posType == MOVE_POS_TYPE.ENERMY_TOP then
    local oppoTeam = self.fightMgr:GetOpponentTeam(self.team)
    return self.fightMgr.fightPos[oppoTeam.teamId].Right
  elseif posType == MOVE_POS_TYPE.TARGET_SCREEN_QIAN_FANG then
    return self.fightMgr.fightPos[self.team].FarPos[self.pos % 5]
  end
end
def.method("table", "number", "=>", "table").GetSpecifiedTargetPos = function(self, target, posType)
  if posType == MOVE_POS_TYPE.TARGET_QIAN_MIAN then
    local attackPointTable = self.fightMgr.fightPos[target.team].Attackpos_front
    return attackPointTable[target.pos]
  elseif posType == MOVE_POS_TYPE.TARGET_QIAN_FANG then
    local attackPointTable = self.fightMgr.fightPos[target.team].Attackpos_ahead
    return attackPointTable[target.pos]
  end
  return nil
end
def.method("number", "number", "number", "number", "=>", "table").GetEffectPos = function(self, effectMoveType, effectPosType, attachPoint, effDest)
  local targets
  if self.playcfg and self.playcfg.skillPlayType == SkillAttackType.SINGLE then
    targets = {
      self.curAttackTargets[1]
    }
  else
    targets = self.curAttackTargets or {}
  end
  local EffectPosType = require("consts.mzm.gsp.skill.confbean.EffectPosType")
  local pos = {}
  if effectPosType == EffectPosType.TARGET then
    for i = 1, #targets do
      local p = {}
      p.from = targets[i].model:GetPos()
      p.playType = EffectMoveType.STATIC
      p.target = targets[i]
      pos[i] = p
    end
  elseif effectPosType == EffectPosType.RELESER then
    pos[1] = {}
    pos[1].from = self.model:GetPos()
    if attachPoint == AttachType.NONE then
      pos[1].playType = EffectMoveType.STATIC
    else
      pos[1].playType = EffectMoveType.FOLLOW
    end
    pos[1].target = self
  elseif effectPosType == EffectPosType.ENERMY_D then
    pos[1] = {}
    local team
    if self.team == FightConst.LEFT_TOP then
      team = FightConst.RIGHT_BOTTOM
    else
      team = FightConst.LEFT_TOP
    end
    pos[1].from = self.fightMgr.fightPos[team].Attack_center
    pos[1].playType = EffectMoveType.STATIC
  elseif effectPosType == EffectPosType.FRIEND_D then
    pos[1] = {}
    pos[1].from = self.fightMgr.fightPos[self.team].Attack_center
    pos[1].playType = EffectMoveType.STATIC
  elseif effectPosType == EffectPosType.CENTER_D then
    pos[1] = {}
    pos[1].from = self.fightMgr.fightPos[3]
    pos[1].playType = EffectMoveType.STATIC
  elseif effectPosType == 0 then
    pos[1] = {}
    local my_pos = self.model:GetPos()
    local my_dir = self.model:GetDir()
    local angle = (90 - my_dir) / 180 * math.pi
    my_pos.x = my_pos.x + 1000 * math.cos(angle)
    my_pos.y = my_pos.y + 1000 * math.sin(angle)
    pos[1].from = my_pos
    pos[1].playType = EffectMoveType.STATIC
  end
  if effDest == effectPosType or #pos == 0 then
    return pos
  end
  if effDest == EffectPosType.TARGET then
    for i = 1, #targets do
      local p = pos[i]
      if p == nil then
        p = {}
        p.from = pos[1].from
        pos[i] = p
      end
      p.to = targets[i].model:GetPos()
      local offsetY = targets[i].model:GetBodyPartHeight(AttachType.BODY)
      if offsetY > 0 then
        p.toOffsetY = offsetY
      end
      p.playType = EffectMoveType.FLY
    end
  elseif effDest == EffectPosType.RELESER then
    pos[1].to = self.model:GetPos()
    local offsetY = self.model:GetBodyPartHeight(AttachType.BODY)
    if offsetY > 0 then
      pos[1].toOffsetY = offsetY
    end
    pos[1].playType = EffectMoveType.FLY
  elseif effDest == EffectPosType.ENERMY_D then
    pos[1].to = self.fightMgr.fightPos[targets[1].team].Attack_center
    local offsetY = targets[1].model:GetBodyPartHeight(AttachType.BODY)
    if offsetY > 0 then
      pos[1].toOffsetY = offsetY
    end
    pos[1].playType = EffectMoveType.FLY
  elseif effDest == EffectPosType.FRIEND_D then
    pos[1].to = self.fightMgr.fightPos[self.team].Attack_center
    pos[1].playType = EffectMoveType.FLY
  elseif effDest == EffectPosType.CENTER_D then
    pos[1].to = self.fightMgr.fightPos[3]
    pos[1].playType = EffectMoveType.FLY
  end
  return pos
end
def.method("number", "=>", "table").GetActionMoveTargetPos = function(self, posType)
  local ACTION_MOVE = require("consts.mzm.gsp.skill.confbean.DisplacementEnum")
  if posType == ACTION_MOVE.TARGET_FRONT then
    local attackPointTable = self.fightMgr.fightPos[self.curAttackTargets[1].team].Attackpos_front
    return attackPointTable[self.curAttackTargets[1].pos]
  elseif posType == ACTION_MOVE.TARGET_AHEAD then
    local attackPointTable = self.fightMgr.fightPos[self.curAttackTargets[1].team].Attackpos_ahead
    return attackPointTable[self.curAttackTargets[1].pos]
  elseif posType == ACTION_MOVE.CENTER then
    return self.fightMgr.fightPos[3]
  end
end
def.method().Destroy = function(self)
  self:DestroyPseudoModel()
  if self.loop_fxs then
    for _, v in pairs(self.loop_fxs) do
      ECFxMan.Instance():Stop(v.fx)
    end
    self.loop_fxs = nil
  end
  if self.avatars then
    for i = 1, #self.avatars do
      self.avatars[i]:CloseAlpha()
      self.avatars[i]:Destroy()
    end
    self.avatars = nil
  end
  self:RemoveLifeLinkEffect()
  if self.flyMount then
    self.flyMount:Destroy()
  end
  self.usedSkills = nil
  self:StopGhostEffect(true)
  self.shake = nil
  for _, v in pairs(self.damageLabels) do
    v.obj:Destroy()
  end
  self.damageLabels = nil
  self:RemoveChildEffects()
  self.model:Destroy()
  self.model = nil
  self.appearanceId = 0
end
def.method("table", "number", "=>", "boolean").HasBuff = function(self, buff_set, buff)
  if buff_set == nil then
    return false
  end
  for k, v in pairs(buff_set) do
    if buff == v then
      return true
    end
  end
  return false
end
def.method("=>", "table").GetAttackResult = function(self)
  if self.attack_result == nil then
    return nil
  end
  self.fightMgr:AddLog(string.format("[FightLog]%s(%d) GetAttackResult 1 from %d", self.name, self.id, #self.attack_result))
  local status = self.attack_result[1]
  table.remove(self.attack_result, 1)
  return status
end
def.method("table").ShowStatus = function(self, status)
  self:SetBuffStatus(status)
end
def.method("table").SetBuffStatus = function(self, status)
  if self.model == nil or status == nil or status.buffs == nil then
    return
  end
  self:PreProcessBuffData(status.buffs)
  self.buff_status_type = EffectStatusType.NORMAL
  for k, v in pairs(self.childEffects) do
    v.exist = false
  end
  local buffIcons = {}
  for k, v in pairs(status.buffs) do
    if v.buffid > 0 then
      local buffEffectCfg = FightUtils.GetEffectGroupCfg(v.buffid)
      if buffEffectCfg then
        self.buff_status_type = bit.bor(self.buff_status_type, buffEffectCfg.effectgrouptype)
        if 0 < buffEffectCfg.buffEffectId then
          local eff = self.childEffects[buffEffectCfg.buffEffectId]
          if eff == nil then
            local buffCfg = FightUtils.GetEffectStatusCfg(buffEffectCfg.buffEffectId)
            if buffCfg and 0 < buffCfg.effectId then
              local effCfg = GetEffectRes(buffCfg.effectId)
              if effCfg then
                local fx = self.model:AddChildEffect(effCfg.path, buffCfg.effPos, 0)
                if fx then
                  fx:GetComponent("FxOne"):set_Stable(true)
                  self.childEffects[buffEffectCfg.buffEffectId] = {
                    fx = fx,
                    uifx = buffCfg.uiEffectType,
                    exist = true
                  }
                else
                  self.fightMgr:AddLog(string.format("[FightWarning]%s(%d) can not request buff fx: %s", self.name, self.id, effCfg.path))
                end
              end
            end
            if buffCfg and 0 < buffCfg.uiEffectType then
              buffIcons[buffEffectCfg.buffEffectId] = buffCfg.uiEffectType
            end
          else
            eff.exist = true
            buffIcons[buffEffectCfg.buffEffectId] = self.childEffects[buffEffectCfg.buffEffectId].uifx
          end
        end
      end
    end
  end
  for k, v in pairs(self.childEffects) do
    if not v.exist then
      ECFxMan.Instance():Stop(v.fx)
      self.childEffects[k] = nil
    end
  end
  self.model:SetBuff(buffIcons)
end
def.method("table").AddLoopEffect = function(self, eff)
  if self.loop_fxs == nil then
    self.loop_fxs = {}
  end
  table.insert(self.loop_fxs, eff)
end
def.method("table").RemoveLoopEffect = function(self, condition)
  if self.loop_fxs == nil or condition == nil then
    return
  end
  for fxk, eff in pairs(self.loop_fxs) do
    local is_target = true
    for k, v in pairs(condition) do
      if eff[k] ~= v then
        is_target = false
      end
    end
    if is_target then
      ECFxMan.Instance():Stop(eff.fx)
      self.loop_fxs[fxk] = nil
    end
  end
end
def.method("number").ShowBlackHole = function(self, unitId)
  local target = self.fightMgr:GetFightUnit(unitId)
  if not target or not target.model or not target.model:IsLoaded() then
    GameUtil.AddGlobalTimer(0.1, true, function()
      if self.model == nil then
        return
      end
      self:ShowBlackHole(unitId)
    end)
    return
  end
  if self.black_hole_fxs == nil then
    self.black_hole_fxs = {}
  end
  local eff = self.black_hole_fxs[unitId]
  if eff == nil then
    local effres = GetEffectRes(702009072)
    local fx = self.fightMgr:PlayEffect(effres.path, target.model.m_model, EC.Vector3.zero, Quaternion.identity)
    fx:GetComponent("FxOne"):set_Stable(true)
    eff = {targetId = unitId, exist = true}
    target:AddLoopEffect({
      fx = fx,
      src = self.id,
      type = LOOP_EFFECT_TYPE.BLACKHOLE
    })
    self.black_hole_fxs[unitId] = eff
  else
    eff.exist = true
  end
end
local life_link_scale = EC.Vector3.new(5, 5, 5)
local t_eff_pos = EC.Vector3.new(0, 0.8, 0)
def.method("number").ShowLifeLink = function(self, targetId)
  local target = self.fightMgr:GetFightUnit(targetId)
  if not self.model:IsLoaded() or not target or not target.model or not target.model:IsLoaded() then
    GameUtil.AddGlobalTimer(0.1, true, function()
      if self.model == nil then
        return
      end
      self:ShowLifeLink(targetId)
    end)
    return
  end
  if self.life_link_fxs == nil then
    self.life_link_fxs = {}
  end
  local eff = self.life_link_fxs[targetId]
  if eff == nil then
    local effres = GetEffectRes(702009083)
    if target == nil then
      self.fightMgr:AddLog(string.format("[Fight error]Life link target is nil for id : %d", targetId))
      return
    end
    local dir = self.model.m_model.localPosition - target.model.m_model.localPosition
    local fx = self.fightMgr:PlayEffect(effres.path, nil, EC.Vector3.zero, Quaternion.identity)
    fx:GetComponent("FxOne"):set_Stable(true)
    local fxpos = (self.model.m_model.localPosition + target.model.m_model.localPosition) / 2
    fxpos.y = fxpos.y + 0.8
    fx.localPosition = fxpos
    life_link_scale.z = dir:get_Length() - 1
    fx.localScale = life_link_scale
    dir:Normalize()
    fx.forward = dir
    local terminal_eff = GetEffectRes(702009082)
    t_eff_pos.x = self.model.m_model.localPosition.x + self.model.m_model.forward.x * 0.5
    t_eff_pos.y = self.model.m_model.localPosition.y + self.model.m_model.forward.y * 0.5 + 0.8
    t_eff_pos.z = self.model.m_model.localPosition.z + self.model.m_model.forward.z * 0.5
    local fx_t1 = self.fightMgr:PlayEffect(terminal_eff.path, nil, t_eff_pos, Quaternion.identity)
    fx_t1:GetComponent("FxOne"):set_Stable(true)
    fx_t1.localScale = EC.Vector3.one * 3
    fx_t1.forward = self.model.m_model.forward
    t_eff_pos.x = target.model.m_model.localPosition.x + target.model.m_model.forward.x * 0.5
    t_eff_pos.y = target.model.m_model.localPosition.y + target.model.m_model.forward.y * 0.5 + 0.8
    t_eff_pos.z = target.model.m_model.localPosition.z + target.model.m_model.forward.z * 0.5
    local fx_t2 = self.fightMgr:PlayEffect(terminal_eff.path, nil, t_eff_pos, Quaternion.identity)
    fx_t2:GetComponent("FxOne"):set_Stable(true)
    fx_t2.forward = target.model.m_model.forward
    fx_t2.localScale = EC.Vector3.one * 3
    eff = {
      fx = fx,
      exist = true,
      t1 = fx_t1,
      t2 = fx_t2,
      src = self,
      dest = target
    }
    self.life_link_fxs[targetId] = eff
  end
end
def.method().UpdateLifeLinks = function(self)
  if self.life_link_fxs then
    for k, v in pairs(self.life_link_fxs) do
      if v.src and v.src.model and not _G.IsNil(v.src.model.m_model) and v.dest and v.dest.model and not _G.IsNil(v.dest.model.m_model) and not _G.IsNil(v.fx) and not _G.IsNil(v.t1) and not _G.IsNil(v.t2) then
        local dir = v.src.model.m_model.localPosition - v.dest.model.m_model.localPosition
        local fxpos = (v.src.model.m_model.localPosition + v.dest.model.m_model.localPosition) / 2
        fxpos.y = fxpos.y + 0.8
        v.fx.localPosition = fxpos
        life_link_scale.z = dir:get_Length() - 1.6
        v.fx.localScale = life_link_scale
        dir:Normalize()
        v.fx.forward = dir
        t_eff_pos.x = v.src.model.m_model.localPosition.x + v.src.model.m_model.forward.x * 0.5
        t_eff_pos.y = v.src.model.m_model.localPosition.y + v.src.model.m_model.forward.y * 0.5 + 0.8
        t_eff_pos.z = v.src.model.m_model.localPosition.z + v.src.model.m_model.forward.z * 0.5
        v.t1.localPosition = t_eff_pos
        t_eff_pos.x = v.dest.model.m_model.localPosition.x + v.dest.model.m_model.forward.x * 0.5
        t_eff_pos.y = v.dest.model.m_model.localPosition.y + v.dest.model.m_model.forward.y * 0.5 + 0.8
        t_eff_pos.z = v.dest.model.m_model.localPosition.z + v.dest.model.m_model.forward.z * 0.5
        v.t2.localPosition = t_eff_pos
      end
    end
  end
end
def.method().RemoveLifeLinkEffect = function(self)
  if self.life_link_fxs then
    for k, v in pairs(self.life_link_fxs) do
      ECFxMan.Instance():Stop(v.fx)
      ECFxMan.Instance():Stop(v.t1)
      ECFxMan.Instance():Stop(v.t2)
      self.life_link_fxs[k] = nil
    end
    self.life_link_fxs = nil
  end
end
def.method("number").RemoveLinkedEffectWithTarget = function(self, targetId)
  if self.life_link_fxs then
    for k, v in pairs(self.life_link_fxs) do
      if v.dest == nil or v.dest.id == targetId then
        ECFxMan.Instance():Stop(v.fx)
        ECFxMan.Instance():Stop(v.t1)
        ECFxMan.Instance():Stop(v.t2)
        self.life_link_fxs[k] = nil
      end
    end
  end
  if self.black_hole_fxs then
    local eff = self.black_hole_fxs[targetId]
    if eff and eff.targetId == targetId then
      self.black_hole_fxs[targetId] = nil
    end
  end
end
def.method("table").PreProcessBuffData = function(self, buff_data)
  local tmpBuff
  if self.black_hole_fxs then
    for _, v in pairs(self.black_hole_fxs) do
      v.exist = false
    end
  end
  if self.life_link_fxs then
    for _, v in pairs(self.life_link_fxs) do
      v.exist = false
    end
  end
  local skill_seq = 0
  for k, tmpBuff in pairs(buff_data) do
    if 0 > tmpBuff.buffid then
      if tmpBuff.buffid == Buff.DATA_CHANGE_MODEL_CARD then
        self.attr_class = bit.rshift(tmpBuff.round, 16)
        self.attr_class_level = bit.band(65535, tmpBuff.round)
      elseif tmpBuff.buffid <= Buff.LIFE_LINK_START and tmpBuff.buffid >= Buff.LIFE_LINK_END then
        self:ShowLifeLink(tmpBuff.round)
        local eff = self.life_link_fxs and self.life_link_fxs[tmpBuff.round]
        if eff then
          eff.exist = true
        end
      elseif tmpBuff.buffid <= Buff.BLACK_HOLE_START and tmpBuff.buffid >= Buff.BLACK_HOLE_END then
        self:ShowBlackHole(tmpBuff.round)
        local eff = self.black_hole_fxs and self.black_hole_fxs[tmpBuff.round]
        if eff then
          eff.exist = true
        end
      elseif tmpBuff.buffid == Buff.MIRROR_FIGHTER_ID then
        self:ChangeToUnit(tmpBuff.round, self.state)
      elseif tmpBuff.buffid <= Buff.FIGHT_STATE_GROUP_START and tmpBuff.buffid >= Buff.FIGHT_STATE_GROUP_END then
        self.state_group = tmpBuff.round
      elseif tmpBuff.buffid <= Buff.FIGHT_STATE_START and tmpBuff.buffid >= Buff.FIGHT_STATE_END then
        if self.state == FightStateGroupState.YINENG_ULTIMATE and tmpBuff.round == FightStateGroupState.YINENG_COMMON then
          self:ChangeToUnit(self.id, tmpBuff.round)
        elseif self.state ~= FightStateGroupState.YINENG_ULTIMATE and tmpBuff.round == FightStateGroupState.YINENG_ULTIMATE then
          self:ChangeToConfigModel(tmpBuff.round)
        end
        self.state = tmpBuff.round
      elseif tmpBuff.buffid == Buff.SYN_SKILL_KEY then
        skill_seq = tmpBuff.round
      end
    end
  end
  if skill_seq > 0 and self.fightMgr:IsMyHero(self.id) then
    self.fightMgr:SwitchSkills(skill_seq)
    require("Main.Fight.ui.DlgFight").Instance():ShowAutoSkill()
  end
  if self.black_hole_fxs then
    for k, v in pairs(self.black_hole_fxs) do
      if not v.exist then
        local target = self.fightMgr:GetFightUnit(v.targetId)
        if target then
          target:RemoveLoopEffect({
            src = self.id,
            type = LOOP_EFFECT_TYPE.BLACKHOLE
          })
        end
        self.black_hole_fxs[k] = nil
      end
    end
  end
  if self.life_link_fxs then
    for k, v in pairs(self.life_link_fxs) do
      if not v.exist then
        ECFxMan.Instance():Stop(v.fx)
        ECFxMan.Instance():Stop(v.t1)
        ECFxMan.Instance():Stop(v.t2)
        self.life_link_fxs[k] = nil
      end
    end
  end
end
def.method("=>", "boolean").IsActionEnable = function(self)
  local enable = true
  for k, v in pairs(self.status.buff_status_set) do
    if v == FighterStatus.BUFF_ST__HOUFA or v == FighterStatus.BUFF_ST__HOUFA_MISSILE then
      enable = false
      break
    end
  end
  return enable
end
def.method("=>", "boolean").NeedResetAction = function(self)
  local need = true
  for k, v in pairs(self.status.buff_status_set) do
    if v == FighterStatus.BUFF_ST__HOUFA_MISSILE then
      need = false
      break
    end
  end
  return need
end
def.method("table").ShowStatusChange = function(self, statusList)
  self.updateStatusDuration = 0
  self.statusList = statusList
  self:EndAction()
end
def.method("boolean").SetReady = function(self, isReady)
  if isReady then
    self:RemoveTitleIcon()
    self.in_turn = false
  else
    self.model:ShowTitleIcon(7011, -1)
  end
end
def.method().Reset = function(self)
  self.reviveCallback = nil
  self.influences = nil
  self.playTime = -1
  self.beHitEffect = nil
  self.playcfg = nil
  self.protect = nil
  self.effectList = nil
  self.inDefense = false
  self.isProtecter = false
  self.protectReady = false
  self:ClearFightData()
  self:StopGhostEffect(true)
  self.hitbackInfo = nil
  self.dodgeInfo = nil
end
def.method().ClearFightData = function(self)
  self.counterAttack = nil
  self.hasCombo = false
  self.attack_result = nil
  self.additionalAttack = nil
  self.shake = nil
  self.isInterrupted = false
  self.isInModelChange = false
  self.onModelChangeDone = nil
end
def.method().RemoveChildEffects = function(self)
  for k, v in pairs(self.childEffects) do
    ECFxMan.Instance():Stop(v.fx)
  end
  self.childEffects = {}
end
def.method().RemoveTitleIcon = function(self)
  if self.online then
    self.model.titleIcon = 0
  else
    self.model.titleIcon = 7010
  end
  self.model:ShowTitleIcon(self.model.titleIcon, -1)
end
def.method("number").PlayGhostEffect = function(self, shadowId)
  local model = self.model.m_model
  if model == nil then
    return
  end
  local shadowCfg = FightUtils.GetShadowCfg(shadowId)
  if shadowCfg == nil then
    return
  end
  local eff = model:GetComponent("PlayerGhostEffect")
  if eff == nil then
    eff = model:AddComponent("PlayerGhostEffect")
  end
  if not shadowCfg.isPure then
    eff:set_mShadowMatType(0)
  else
    eff:set_mShadowMatType(1)
    local color = Color.Color(shadowCfg.R / 255, shadowCfg.G / 255, shadowCfg.B / 255, 1)
    eff:set_mColor(color)
  end
  eff:SetEffectArgs(shadowCfg.initAlpha, shadowCfg.startTime, shadowCfg.intervalTime, shadowCfg.lastTime, shadowCfg.maxmum)
  eff:Begin()
end
def.method("boolean").StopGhostEffect = function(self, close)
  if self.model == nil then
    return
  end
  local model = self.model.m_model
  if model == nil then
    return
  end
  local eff = model:GetComponent("PlayerGhostEffect")
  if eff == nil then
    return
  end
  if close then
    eff:CloseEffect()
  else
    eff:StopCreateEffect()
  end
end
def.method("number", "=>", "boolean").CheckFightStatus = function(self, s)
  if self.status == nil then
    return false
  end
  for _, v in pairs(self.status.status_set) do
    if v == s then
      return true
    end
  end
  return false
end
def.method("table", "number", "=>", "boolean").CheckSpecFightStatusSet = function(self, status, s)
  if status == nil then
    return false
  end
  for _, v in pairs(status.status_set) do
    if v == s then
      return true
    end
  end
  return false
end
def.method("number").ClearFightStatus = function(self, s)
  if self.status == nil then
    return
  end
  for k, v in pairs(self.status.status_set) do
    if v == s then
      self.status.status_set[k] = nil
      return
    end
  end
end
def.method("boolean").OnShatterEnd = function(self, isLastRound)
  local effid = 702000008
  local attach = AttachType.BODY
  if self.deathInfo.shatter_type == SHATTER_TYPE.VERTICAL then
    effid = 702000009
    attach = AttachType.FOOT
  end
  local shatterEff = GetEffectRes(effid)
  if shatterEff then
    self.model:AddEffectWithRotation(shatterEff.path, attach)
    if shatterEff.sound > 0 then
      self.fightMgr:PlaySoundEffect(shatterEff.sound)
    end
  end
  if isLastRound then
    self.model:SetVisible(false)
    table.insert(self.nextCallbacks, {
      delay = 1.5,
      callback = self.OnDieEnd
    })
  else
    self:OnDieEnd()
  end
end
def.method("=>", "boolean").IsDead = function(self)
  return self.isDead == DEATH_STATUS.DEAD or self.isDead == DEATH_STATUS.FAKEDEAD
end
def.method("=>", "boolean").IsReallyDead = function(self)
  return self.isDead == DEATH_STATUS.DEAD and not self:HasDeathAction()
end
def.method("=>", "boolean").HasDeathAction = function(self)
  return self.deathSkills ~= nil and #self.deathSkills > 0
end
def.method("number").SetBoneEffect = function(self, effid)
  if self.model == nil or self.model.m_model == nil or self.model.m_model.isnil then
    return
  end
  local cfg = FightUtils.GetBoneEffectCfg(effid)
  for i = 1, #cfg.effects do
    local eff = cfg.effects[i]
    local parent = self.model.m_model:FindChild("Root")
    if eff.position == BONE_EFF_POS.FOOT then
      parent = self.model.m_model:FindChild("Bip01 L Foot")
    elseif eff.position == BONE_EFF_POS.CHEST then
      parent = self.model.m_model:FindChild("Bip01 Pelvis")
    elseif eff.position == BONE_EFF_POS.HEAD then
      parent = self.model.m_model:FindChild("Bip01 Head")
    elseif eff.position == BONE_EFF_POS.LEFT_HAND then
      parent = self.model.m_model:FindChild("Bip01 L Hand")
    elseif eff.position == BONE_EFF_POS.RIGHT_HAND then
      parent = self.model.m_model:FindChild("Bip01 R Hand")
    elseif eff.position == BONE_EFF_POS.LEFT_WEAPON then
      parent = self.model.m_model:FindChild("Bip01_LeftWeapon")
    elseif eff.position == BONE_EFF_POS.RIGHT_WEAPON then
      parent = self.model.m_model:FindChild("Bip01_RightWeapon")
    end
    local effres = GetEffectRes(eff.effectId)
    if effres then
      local fx = self.fightMgr:PlayEffect(effres.path, parent, EC.Vector3.new(eff.offsetX, eff.offsetY, 0), Quaternion.identity)
      if fx then
        table.insert(self.delEffects, fx)
      end
    end
  end
end
def.method().ClearDelEffects = function(self)
  for k, v in pairs(self.delEffects) do
    ECFxMan.Instance():Stop(v)
  end
  self.delEffects = {}
end
def.method("number", "=>", "boolean").CheckBuffStatus = function(self, buff)
  if self.status == nil then
    return false
  end
  for k, v in pairs(self.status.buff_status_set) do
    if v == buff then
      return true
    end
  end
  return false
end
def.method("number", "=>", "number").GetBehitPoint = function(self, phaseid)
  local actionPhaseCfg = FightUtils.GetSkillPlayPhaseCfg(phaseid)
  if actionPhaseCfg == nil then
    return 0
  end
  local behitNum = 0
  local actionCfg = FightUtils.GetSkillActionCfg(self.modelId, actionPhaseCfg.action)
  if actionCfg then
    behitNum = behitNum + #actionCfg.behitInfos
  end
  if actionPhaseCfg.effects and 0 < #actionPhaseCfg.effects then
    local i = 1
    for i = 1, #actionPhaseCfg.effects do
      local v = actionPhaseCfg.effects[i]
      local effPlay = FightUtils.GetEffectPlayCfg(self.modelId, v.effectId)
      if effPlay then
        behitNum = behitNum + #effPlay.behitInfos
      end
    end
  end
  return behitNum
end
def.method("=>", "boolean").CheckSkillValid = function(self)
  if self.playcfg == nil or self.playcfg.id == 160100000 or self.targets == nil or #self.targets == 0 then
    return true
  end
  local behitNum = 0
  for i = 1, #self.playcfg.phases do
    local phase = self.playcfg.phases[i]
    if phase and 0 < phase[2] then
      behitNum = behitNum + self:GetBehitPoint(phase[2])
    end
  end
  local fightStatusNum = 0
  if self.playcfg.skillPlayType == SkillAttackType.MULTI or #self.targets == 1 then
    fightStatusNum = self.targets[1].attack_result and #self.targets[1].attack_result or 0
  elseif self.playcfg.skillPlayType == SkillAttackType.SINGLE then
    for i = 1, #self.targets do
      if self.targets[i].attack_result then
        fightStatusNum = fightStatusNum + #self.targets[i].attack_result
      end
    end
  end
  if fightStatusNum ~= behitNum then
    Debug.LogWarning(string.format("[Fight Error](%s(%d) skill(play id: %d) Behit num[%d] is not equal to fight_status num[%d]", self.name, self.id, self.playcfg.id, behitNum, fightStatusNum))
    return false
  end
  return true
end
def.method("=>", "boolean").CheckRebound = function(self)
  local ret = self.attack_result and self.attack_result[1] and self.attack_result[1].statusMap[AttackResultBean.REBOUND]
  return ret ~= nil
end
def.method().StartShake = function(self)
  if self.shake then
    return
  end
  self.shake = {}
  self.shake.initPos = self.model.m_model.localPosition
  self.shake.flag = 1
  self.shake.tick = 0
  self.shake.angle = (270 - FightConst.TeamDir[self.team]) / 180 * math.pi
end
local shake_pos = EC.Vector3.new(0, 0, 0)
def.method("number").UpdateShake = function(self, tick)
  if not self.shake then
    return
  end
  self.shake.tick = self.shake.tick + tick
  if self.shake.tick < 0.125 then
    return
  end
  self.shake.tick = self.shake.tick - 0.125
  local offset = self.shake.flag * 0.05
  shake_pos.x = self.shake.initPos.x + offset * math.cos(self.shake.angle)
  shake_pos.y = self.shake.initPos.y
  shake_pos.z = self.shake.initPos.z + offset * math.sin(self.shake.angle)
  self.model.m_model.localPosition = shake_pos
  self.shake.flag = self.shake.flag * -1
end
def.method().StopShake = function(self)
  if self.shake then
    self.model.m_model.localPosition = self.shake.initPos
  end
  self.shake = nil
end
def.method("string").SetCommand = function(self, cmdName)
  if self.model == nil then
    return
  end
  self.model:SetCommand(cmdName)
end
def.method().RemoveCommand = function(self)
  if self.model == nil then
    return
  end
  self.model:RemoveCommand()
end
def.method("table").Evolve = function(self, action)
  local targetpos = self.model:GetPos()
  local function OnEvolveEnd()
    local team = self.team
    local groupId = self.group
    self.fightMgr:RemoveFightUnit(action.fighterid)
    self.fightMgr:WaitForNewCreatedUnits()
    self.fightMgr:CreateFighter(action.changeFighterid, action.fighter, team, groupId)
    self.fightMgr:OnActionEnd({
      action.fighterid
    })
  end
  self:GetActModel():PlayAnim(ActionName.Magic, OnEvolveEnd)
  if self.model.mECWingComponent then
    self.model.mECWingComponent:Attack()
  end
  if self.model.mECPartComponent then
    self.model.mECPartComponent:PlayAnimation(ActionName.Magic, ActionName.Attack)
  end
  local u3dpos = Map2DPosTo3D(targetpos.x, targetpos.y)
  local effcfg = GetEffectRes(702020005)
  if effcfg == nil then
    return
  end
  self.fightMgr:PlayEffect(effcfg.path, nil, u3dpos, Quaternion.identity)
end
def.method("table").ChangeModel = function(self, action)
  local targetpos = self.model:GetPos()
  local function BeginChangeModel()
    self:DoModelChange(action.model.modelid, action.model, function()
      self:EndAction()
    end)
  end
  self:GetActModel():PlayAnim(ActionName.Magic, BeginChangeModel)
  if self.model.mECWingComponent then
    self.model.mECWingComponent:Attack()
  end
  if self.model.mECPartComponent then
    self.model.mECPartComponent:PlayAnimation(ActionName.Magic, ActionName.Attack)
  end
  local u3dpos = Map2DPosTo3D(targetpos.x, targetpos.y)
  local effcfg = GetEffectRes(702020005)
  if effcfg == nil then
    return
  end
  self.fightMgr:PlayEffect(effcfg.path, nil, u3dpos, Quaternion.identity)
end
def.method("number", "number").ChangeToUnit = function(self, unitId, state)
  local unit = self.fightMgr:GetFightUnit(unitId)
  if unit == nil then
    self.fightMgr:AddToBeSetAppearance(self.id, unitId)
    return
  end
  if self.appearanceId == unitId and self.state == state then
    return
  end
  self.appearanceId = unitId
  self.menpai = unit.initMenpai
  self.gender = unit.initGender
  self.isInModelChange = true
  local function DoChange()
    if self.model == nil then
      return
    end
    self:DoModelChange(unit.modelInfo.modelid, unit.modelInfo, function()
      if self.onModelChangeDone then
        GameUtil.AddGlobalTimer(0.5, true, self.onModelChangeDone)
      end
    end)
  end
  if unitId == self.id then
    local pos = self.model:GetPos()
    if pos then
      local effres = _G.GetEffectRes(702009151)
      if effres then
        local u3dpos = Map2DPosTo3D(pos.x, pos.y)
        local fx = self.fightMgr:PlayEffect(effres.path, nil, u3dpos, Quaternion.identity)
      end
    end
    GameUtil.AddGlobalTimer(0.5, true, DoChange)
  else
    DoChange()
  end
end
def.method("number", "table", "function").DoModelChange = function(self, modelId, modelInfo, cb)
  self.isInModelChange = true
  local nameColor = self.model.m_uNameColor
  local dir = self.model.m_ang
  if self.fightMgr.isFlyBattle and self.flyMount then
    self.model.flyMountModel = self.flyMount.m_model
    self.model:DetachFlyMount()
    self.model.flyMountModel = nil
  end
  local pos = self.model:GetPos()
  if pos == nil then
    pos = self.fightMgr.fightPos[self.team].Pos[self.pos]
  end
  local cam = self.fightMgr:GetMainCam()
  self.pseudo_model = GameObject.GameObject("pseudo_model")
  if cam.parent == self.model.m_model then
    self.pseudo_model.parent = self.model.m_model.parent
    self.pseudo_model.localPosition = self.model.m_model.localPosition
    self.pseudo_model:SetLayer(self.model.m_model.layer)
    cam.parent = self.pseudo_model
  end
  for k, v in pairs(self.childEffects) do
    if not _G.IsNil(v.fx) then
      v.fx.parent = self.pseudo_model
    end
  end
  if self.loop_fxs then
    for k, v in pairs(self.loop_fxs) do
      if v.type == LOOP_EFFECT_TYPE.BLACKHOLE and not _G.IsNil(v.fx) then
        v.fx.parent = self.pseudo_model
      end
    end
  end
  local hpvisible = self.model.showHP
  self.model:Destroy()
  self.fightMgr:WaitForNewCreatedUnits()
  self.fightMgr:RemoveWaitUnit(self.id)
  self.model = FightModel.new(modelId, self.name, nameColor, self.fightUnitType)
  self.model.fighterId = self.id
  self.model.parentNode = self.fightMgr.fightPlayerNodeRoot
  self.modelId = modelId
  self.model:SetHpVisible(hpvisible)
  local modelpath, modelColor = GetModelPath(self.modelId)
  self.model.colorId = modelColor
  local function OnNewModelLoaded()
    if self.model == nil then
      return
    end
    self:SetHp(self.hp, self.hpmax)
    self:SetMp(self.mp, self.mpmax)
    self.model.isDead = self.isDead ~= DEATH_STATUS.ALIVE
    self.model:SetStance()
    if self.fightMgr.isFlyBattle and self.flyMount then
      self.model.flyMountModel = self.flyMount.m_model
      if self.model:AttachFlyMount() then
        self.flyMount.isDetached = false
      end
    end
    if self.fightMgr.isPerspective then
      cam.parent = self.model.m_model
    end
    self:DestroyPseudoModel()
    for k, v in pairs(self.childEffects) do
      if not _G.IsNil(v.fx) then
        v.fx.parent = self.model.m_model
      end
    end
    if self.loop_fxs then
      for k, v in pairs(self.loop_fxs) do
        if v.type == LOOP_EFFECT_TYPE.BLACKHOLE and not _G.IsNil(v.fx) then
          v.fx.parent = self.model.m_model
        end
      end
    end
    self.isInModelChange = false
    if cb then
      _G.SafeCall(cb)
    end
  end
  self.model:AddOnLoadCallback("FightChangeModel", OnNewModelLoaded)
  _G.LoadModel(self.model, modelInfo, pos.x, pos.y, dir, true, true)
  local modelcfg = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, self.modelId)
  if modelcfg == nil then
    self.fightMgr:AddLog(string.format("[Fight error](CreateFightUnit)model cfg is nil for id: ", self.modelId))
  end
  local soundCfgId = DynamicRecord.GetIntValue(modelcfg, "sound")
  if soundCfgId and soundCfgId > 0 then
    self.soundCfg = FightUtils.GetModelSound(soundCfgId)
  else
    self.soundCfg = nil
  end
end
def.method("number").ChangeToConfigModel = function(self, state)
  self.isInModelChange = true
  local nameColor = self.model.m_uNameColor
  local dir = self.model:GetDir()
  local cur_pos = self.model:GetPos()
  local hpvisible = self.model.showHP
  if self.fightMgr.isFlyBattle and self.flyMount then
    self.model.flyMountModel = self.flyMount.m_model
    self.model:DetachFlyMount()
    self.model.flyMountModel = nil
  end
  local cam = self.fightMgr:GetMainCam()
  self.pseudo_model = GameObject.GameObject("pseudo_model")
  if self.fightMgr.isPerspective then
    self.pseudo_model.parent = self.model.m_model.parent
    self.pseudo_model.localPosition = self.model.m_model.localPosition
    self.pseudo_model:SetLayer(self.model.m_model.layer)
    cam.parent = self.pseudo_model
  end
  for k, v in pairs(self.childEffects) do
    if not _G.IsNil(v.fx) then
      v.fx.parent = self.pseudo_model
    end
  end
  if self.loop_fxs then
    for k, v in pairs(self.loop_fxs) do
      if v.type == LOOP_EFFECT_TYPE.BLACKHOLE and not _G.IsNil(v.fx) then
        v.fx.parent = self.pseudo_model
      end
    end
  end
  self.model:Destroy()
  self.fightMgr:WaitForNewCreatedUnits()
  self.fightMgr:RemoveWaitUnit(self.id)
  local changeModelCfg = FightUtils.GetSkillChangeModelCfg(state, self.gender)
  if changeModelCfg == nil then
    self.fightMgr:AddLog(string.format("[Fight error](ChangeToConfigModel)changeModelCfg is nil for state(%d) and gender(%d) ", state, self.gender))
    return
  end
  self.modelId = changeModelCfg.modelId
  self.model = FightModel.new(self.modelId, self.name, nameColor, self.fightUnitType)
  self.model.fighterId = self.id
  self.model.parentNode = self.fightMgr.fightPlayerNodeRoot
  self.model:SetHpVisible(hpvisible)
  local modelpath, modelColor = GetModelPath(self.modelId)
  local function OnNewModelLoaded()
    if self.model == nil then
      return
    end
    self:SetHp(self.hp, self.hpmax)
    self:SetMp(self.mp, self.mpmax)
    self.model.isDead = self.isDead ~= DEATH_STATUS.ALIVE
    if self.fightMgr.isFlyBattle and self.flyMount then
      self.model.flyMountModel = self.flyMount.m_model
      if self.model:AttachFlyMount() then
        self.flyMount.isDetached = false
      end
    end
    if self.fightMgr.isPerspective then
      cam.parent = self.model.m_model
    end
    self:DestroyPseudoModel()
    for k, v in pairs(self.childEffects) do
      if not _G.IsNil(v.fx) then
        v.fx.parent = self.model.m_model
      end
    end
    if self.loop_fxs then
      for k, v in pairs(self.loop_fxs) do
        if v.type == LOOP_EFFECT_TYPE.BLACKHOLE and not _G.IsNil(v.fx) then
          v.fx.parent = self.model.m_model
        end
      end
    end
    self.usedSkills = nil
    self.isInModelChange = false
  end
  self.model:AddOnLoadCallback("FightChangeModel", OnNewModelLoaded)
  self.model:LoadModel2(modelpath, cur_pos.x, cur_pos.y, dir, true)
  local modelcfg = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, self.modelId)
  if modelcfg == nil then
    self.fightMgr:AddLog(string.format("[Fight error](ChangeToConfigModel)model cfg is nil for id: ", self.modelId))
  end
  local soundCfgId = DynamicRecord.GetIntValue(modelcfg, "sound")
  if soundCfgId and soundCfgId > 0 then
    self.soundCfg = FightUtils.GetModelSound(soundCfgId)
  else
    self.soundCfg = nil
  end
end
def.method("=>", FightModel).GetActModel = function(self)
  local actModel = self.model
  if self.masterModel then
    actModel = self.masterModel
  end
  return actModel
end
def.method("=>", "string").GetDefenseEffect = function(self)
  if defenseEffect and defenseEffect[self.modelId] then
    return defenseEffect[self.modelId]
  end
  if defenseEffect == nil then
    defenseEffect = {}
  end
  local skillcfg = self.fightMgr:GetSkillCfg(constant.FightConst.DEFENCE_SKILL)
  local playcfg = FightUtils.GetSkillPlayCfg(skillcfg.skillPlayid)
  if playcfg then
    local actionPhaseCfg = FightUtils.GetSkillPlayPhaseCfg(playcfg.phases[1][2])
    local effPlay = FightUtils.GetEffectPlayCfg(self.modelId, actionPhaseCfg.effects[1].effectId)
    local atkEffId = effPlay.femaleAttackEffectId or effPlay.attackEffectId or 0
    if atkEffId <= 0 then
      return ""
    end
    defenseEffect[self.modelId] = GetEffectRes(atkEffId).path
    return defenseEffect[self.modelId]
  else
    warn("[Fight]defense skill action cfg is nil")
    return ""
  end
end
def.method("table").SetReliveStatus = function(self, reviveStatus)
  if not self.fightMgr:CheckTargetIsWaited(self.id) then
    self.fightMgr:AddTargetToBeWaited(self.id)
  end
  self.reviveStatus = reviveStatus
end
def.method("number").ShowSkillTitle = function(self, skillId)
  if skillId > 0 then
    local record = DynamicData.GetRecord(CFG_PATH.DATA_PASSIVE_SKILL_CFG, skillId)
    if record then
      local title = record:GetIntValue("title")
      if title > 0 then
        self.model:ShowTitleIcon(title, 1)
      end
    end
  end
end
def.method().DestroyPseudoModel = function(self)
  if self.pseudo_model then
    self.pseudo_model:Destroy()
  end
  self.pseudo_model = nil
end
def.method("number").SetAppearance = function(self, appUnitId)
  if appUnitId ~= self.id then
    self:ChangeToUnit(appUnitId, self.state)
  end
end
FightUnit.Commit()
return FightUnit
