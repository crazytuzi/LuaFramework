local Lplus = require("Lplus")
local FightUtils = Lplus.Class("FightUtils")
local def = FightUtils.define
def.static("number", "=>", "table").GetSkillPlayCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.SKILL_PLAY_CFG, id)
  if record == nil then
    warn("CSkillPlayCfg get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.nameEffectId = record:GetIntValue("nameEffectId")
  cfg.prepare = record:GetIntValue("prepare")
  cfg.returnStage = record:GetIntValue("returnStage")
  cfg.skillPlayType = record:GetIntValue("skillPlayType")
  cfg.direction = record:GetIntValue("direction")
  cfg.maleSoundId = record:GetIntValue("maleSoundId")
  cfg.femaleSoundId = record:GetIntValue("femaleSoundId")
  cfg.deathType = record:GetIntValue("deathType")
  cfg.deathTypeId = record:GetIntValue("deathTypeId")
  cfg.phases = {}
  local moveStruct = record:GetStructValue("moveStruct")
  local count = moveStruct:GetVectorSize("moveVector")
  local i = 1
  for i = 1, count do
    local phase = {}
    local move = moveStruct:GetVectorValueByIdx("moveVector", i - 1)
    local id = move:GetIntValue("moveId")
    table.insert(phase, id)
    local eff = moveStruct:GetVectorValueByIdx("effectVector", i - 1)
    id = eff:GetIntValue("effectId")
    table.insert(phase, id)
    table.insert(cfg.phases, phase)
  end
  return cfg
end
def.static("number", "=>", "table").GetSkillPlayPhaseCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.SKILL_PLAY_PHASE_CFG, id)
  if record == nil then
    warn("CSkillPlayStageCfg get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.specialAct = record:GetIntValue("specialAct")
  cfg.specialActTime = record:GetIntValue("specialActTime") / 1000
  cfg.specialActDuration = record:GetIntValue("specialActDuration") / 1000
  cfg.specialActParam = record:GetIntValue("specialActParam")
  cfg.action = record:GetIntValue("action")
  cfg.beAttackedAction = record:GetIntValue("beAttackedAction")
  cfg.shadow = record:GetIntValue("shadow")
  cfg.move = record:GetIntValue("move")
  cfg.moveCfgId = record:GetIntValue("moveCfgId")
  cfg.boneEffectId = record:GetIntValue("boneEffectId")
  cfg.cameraMoveId = record:GetIntValue("cameraMoveId")
  local effectStruct = record:GetStructValue("effectStruct")
  local count = effectStruct:GetVectorSize("effectVector")
  if count == 0 then
    return cfg
  end
  cfg.effects = {}
  local i = 1
  for i = 1, count do
    local effect = {}
    local effectRecord = effectStruct:GetVectorValueByIdx("effectVector", i - 1)
    effect.effectId = effectRecord:GetIntValue("effectId")
    effect.delay = effectRecord:GetIntValue("delay") / 1000
    table.insert(cfg.effects, effect)
  end
  return cfg
end
def.static("number", "=>", "table").GetBoneEffectCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.BONE_EFFECT_CFG, id)
  if record == nil then
    warn("CBoneEffectCfg get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  local effectStruct = record:GetStructValue("effectStruct")
  local count = effectStruct:GetVectorSize("effectVector")
  if count == 0 then
    return cfg
  end
  cfg.effects = {}
  local i = 1
  for i = 1, count do
    local effect = {}
    local effectRecord = effectStruct:GetVectorValueByIdx("effectVector", i - 1)
    effect.effectId = effectRecord:GetIntValue("effectId")
    effect.offsetX = effectRecord:GetIntValue("offsetX") / 1000
    effect.offsetY = effectRecord:GetIntValue("offsetY") / 1000
    effect.position = effectRecord:GetIntValue("position")
    table.insert(cfg.effects, effect)
  end
  return cfg
end
local actionCfg, actionCfgEntries, actionCfgIndex
def.static().LoadSkillActionCfg = function()
  if actionCfg then
    return
  end
  local entries = DynamicData.GetTable("data/cfg/mzm.gsp.skill.confbean.CAction.bny")
  actionCfgEntries = entries
  DynamicDataTable.SetCache(entries, true)
  local size = DynamicDataTable.GetRecordsCount(entries)
  actionCfg = {}
  actionCfgIndex = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, size - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local modelId = record:GetIntValue("modelId")
    local actionId = record:GetIntValue("actionId")
    local key = bit.lshift(modelId, 8) + actionId
    actionCfgIndex[key] = i
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
local function get_skill_action_cfg(index)
  local entries = actionCfgEntries
  local record = DynamicDataTable.GetRecordByIdx(entries, index)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.modelId = record:GetIntValue("modelId")
  cfg.actionId = record:GetIntValue("actionId")
  cfg.actionName = record:GetStringValue("actionName")
  cfg.sound = record:GetIntValue("sound")
  cfg.rotationOffset = record:GetCharValue("rotationOffset") ~= 0
  cfg.hasRelativeOffset = record:GetCharValue("hasRelativeOffset") ~= 0
  cfg.needReset = record:GetCharValue("needReset") ~= 0
  cfg.behitInfos = {}
  cfg.effectDelays = {}
  local hitTimeStruct = record:GetStructValue("behitStruct")
  local count = hitTimeStruct:GetVectorSize("behitVector")
  local i = 1
  for i = 1, count do
    local move = hitTimeStruct:GetVectorValueByIdx("behitVector", i - 1)
    local behitInfo = {}
    behitInfo.behitAction = move:GetIntValue("behitAction")
    behitInfo.paramId = move:GetIntValue("paramId")
    behitInfo.behitTime = move:GetIntValue("behitTime") / 1000
    behitInfo.camShake = move:GetIntValue("camShake")
    table.insert(cfg.behitInfos, behitInfo)
  end
  count = hitTimeStruct:GetVectorSize("effectVector")
  for i = 1, count do
    local eff = hitTimeStruct:GetVectorValueByIdx("effectVector", i - 1)
    if eff then
      local effectDelay = eff:GetIntValue("effectDelay") / 1000
      table.insert(cfg.effectDelays, effectDelay)
    end
  end
  return cfg
end
def.static("number", "number", "=>", "table").GetSkillActionCfg = function(modelId, actionId)
  if actionCfg == nil then
    FightUtils.LoadSkillActionCfg()
  end
  if actionCfg == nil then
    return nil
  end
  local key = bit.lshift(modelId, 8) + actionId
  local cfg = actionCfg[key]
  if not cfg then
    local index = actionCfgIndex[key]
    if index == nil then
      return nil
    end
    cfg = get_skill_action_cfg(index)
    actionCfg[key] = cfg
  end
  return cfg
end
def.static("number", "=>", "table").GetMoveActionCfg = function(skillId)
  local record = DynamicData.GetRecord(CFG_PATH.MOVE_ACTION_CFG, skillId)
  if record == nil then
    warn("CMoveAction get nil record for id: ", skillId)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.actionName = record:GetStringValue("actionName")
  cfg.duration = record:GetIntValue("duration") / 1000
  cfg.modelDisPlay = record:GetIntValue("modelDisPlay")
  cfg.targetPos = record:GetIntValue("targetPos")
  cfg.effectId = record:GetIntValue("effectId")
  return cfg
end
local effectPlayCfg
def.static().LoadEffectPlayCfg = function()
  local entries = DynamicData.GetTable("data/cfg/mzm.gsp.skill.confbean.CEffectPlayCfg.bny")
  local size = DynamicDataTable.GetRecordsCount(entries)
  effectPlayCfg = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, size - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    if record == nil then
      return
    end
    local cfg = {}
    cfg.modelId = record:GetIntValue("modelId")
    cfg.duration = record:GetIntValue("duration") / 1000
    cfg.effectPlayId = record:GetIntValue("effectPlayId")
    cfg.attackEffectId = record:GetIntValue("attackEffectId")
    cfg.femaleAttackEffectId = record:GetIntValue("femaleAttackEffectId")
    cfg.beAttackEffectId = record:GetIntValue("beAttackEffectId")
    cfg.effectMoveType = record:GetIntValue("effectMoveType")
    cfg.effectPosType = record:GetIntValue("effectPosType")
    cfg.attachPoint = record:GetIntValue("AttachPoint")
    cfg.effectPosDest = record:GetIntValue("effectPosDest")
    cfg.behitInfos = {}
    local hitTimeStruct = record:GetStructValue("behitStruct")
    local count = hitTimeStruct:GetVectorSize("behitVector")
    local i = 1
    for i = 1, count do
      local move = hitTimeStruct:GetVectorValueByIdx("behitVector", i - 1)
      local behitInfo = {}
      behitInfo.behitAction = move:GetIntValue("behitAction")
      behitInfo.paramId = move:GetIntValue("paramId")
      behitInfo.behitTime = move:GetIntValue("behitTime") / 1000
      behitInfo.camShake = move:GetIntValue("camShake")
      table.insert(cfg.behitInfos, behitInfo)
    end
    local key = bit.lshift(cfg.modelId, 16) + cfg.effectPlayId
    effectPlayCfg[key] = cfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.static("number", "number", "=>", "table").GetEffectPlayCfg = function(modelId, effId)
  if effectPlayCfg == nil then
    FightUtils.LoadEffectPlayCfg()
  end
  if effectPlayCfg == nil then
    return nil
  end
  local key = bit.lshift(modelId, 16) + effId
  return effectPlayCfg[key] or effectPlayCfg[effId]
end
def.static("number", "=>", "table").GetEffectGroupCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.EFFECT_GROUP_CFG, id)
  if record == nil then
    warn("CSkillEffectGroupCfg get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.effectgrouptype = record:GetIntValue("effectgrouptype")
  cfg.buffEffectId = record:GetIntValue("buffEffectId")
  return cfg
end
def.static("number", "=>", "table").GetEffectStatusCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.EFFECT_GROUP_STATUS_CFG, id)
  if record == nil then
    warn("CEffectGroupStatusCfg get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.icon = record:GetIntValue("icon")
  cfg.effectId = record:GetIntValue("effectId")
  cfg.effPos = record:GetIntValue("effPos")
  cfg.desc = record:GetStringValue("desc")
  cfg.name = record:GetStringValue("name")
  cfg.isShow = record:GetCharValue("isShow") ~= 0
  cfg.uiEffectType = record:GetIntValue("uiEffectType")
  return cfg
end
def.static("number", "=>", "string").GetTalkContent = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.AI_WORDS_CFG, id)
  if record == nil then
    warn("AI talk words get nil record for id: ", id)
    return ""
  end
  return record:GetStringValue("words")
end
def.static("number", "=>", "table").GetHitUpParam = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.HIT_UP_CFG, id)
  if record == nil then
    warn("CBeAttackFlyCfg get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.height = record:GetIntValue("height")
  cfg.duration = record:GetIntValue("duration") / 1000
  return cfg
end
def.static("number", "=>", "table").GetModelSound = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.MODEL_SOUND_CFG, id)
  if record == nil then
    warn("CModelSoundCfg get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.beAttacked = record:GetIntValue("beAttacked")
  cfg.dodge = record:GetIntValue("dodge1")
  cfg.dead = record:GetIntValue("dead")
  return cfg
end
def.static("number", "=>", "table").GetShadowCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.SHADOW_CFG, id)
  if record == nil then
    warn("CCanYingCfg get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.B = record:GetIntValue("B")
  cfg.G = record:GetIntValue("G")
  cfg.R = record:GetIntValue("R")
  cfg.intervalTime = record:GetIntValue("intervalTime") / 1000
  cfg.isPure = record:GetCharValue("isPure") ~= 0
  cfg.maxmum = record:GetIntValue("max")
  cfg.lastTime = record:GetIntValue("lastTime") / 1000
  cfg.startTime = record:GetIntValue("startTime") / 1000
  cfg.initAlpha = record:GetIntValue("transparency") / 100
  return cfg
end
def.static("number", "=>", "table").GetInterrupMoveCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.INTERRUPT_MOVE_CFG, id)
  if record == nil then
    warn("CDisplacementCfg get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.moves = {}
  local interruptMoveStruct = record:GetStructValue("InterruptMoveStruct")
  local count = interruptMoveStruct:GetVectorSize("InterruptMoveVector")
  local i = 1
  local totalTime = 0
  for i = 1, count do
    local moveRecord = interruptMoveStruct:GetVectorValueByIdx("InterruptMoveVector", i - 1)
    local move = {}
    move.duration = moveRecord:GetIntValue("duration") / 1000
    move.move = moveRecord:GetCharValue("isMove") ~= 0
    table.insert(cfg.moves, move)
    totalTime = totalTime + move.duration
  end
  cfg.totalTime = totalTime
  return cfg
end
def.static("number", "=>", "table").GetWorldBossActionCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.WORLDBOSS_ACTION_CFG, id)
  if record == nil then
    warn("WorldBossActionCfg get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.fightid = record:GetIntValue("fightid")
  cfg.actionRefs = {}
  local actionStruct = record:GetStructValue("actionStruct")
  local count = actionStruct:GetVectorSize("actionList")
  local i = 1
  for i = 1, count do
    local actionRef = {}
    local ref = actionStruct:GetVectorValueByIdx("actionList", i - 1)
    actionRef.pos = ref:GetIntValue("pos")
    actionRef.actionName = ref:GetStringValue("actionName")
    actionRef.refPos = ref:GetIntValue("refPos")
    actionRef.refActionName = ref:GetStringValue("refActionName")
    table.insert(cfg.actionRefs, actionRef)
  end
  return cfg
end
def.static("number", "=>", "table").GetShakeCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.SHAKE_CFG, id)
  if record == nil then
    warn("ShockCfg get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.duration = record:GetIntValue("duration") / 1000
  cfg.amplitude = record:GetIntValue("amplitude") / 10000
  return cfg
end
def.static("number", "=>", "table").GetCameraCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.CAMERA_CFG, id)
  if record == nil then
    warn("CCameroCfg get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.cameraAnimId = record:GetIntValue("cameraAnimId")
  cfg.initDistance = record:GetIntValue("initDistance") / 100
  cfg.initHeight = record:GetIntValue("initHeight") / 100
  cfg.initTime = record:GetIntValue("initTime") / 1000
  cfg.initXangle = record:GetIntValue("initXangle")
  cfg.initYangle = record:GetIntValue("initYangle")
  cfg.visiableType = record:GetIntValue("visiableType")
  cfg.skillNameEff = record:GetIntValue("skillNameEff")
  cfg.phases = {}
  local phaseStruct = record:GetStructValue("phaseStruct")
  local count = phaseStruct:GetVectorSize("phaseVector")
  local i = 1
  for i = 1, count do
    local phase = {}
    local phaseRecord = phaseStruct:GetVectorValueByIdx("phaseVector", i - 1)
    phase.delayTime = phaseRecord:GetIntValue("delayTime") / 1000
    phase.deltaX = phaseRecord:GetIntValue("deltaX") / 100
    phase.deltaY = phaseRecord:GetIntValue("deltaY") / 100
    phase.duration = phaseRecord:GetIntValue("duration") / 1000
    phase.XangleDelta = phaseRecord:GetIntValue("XangleDelta")
    phase.YangleDelta = phaseRecord:GetIntValue("YangleDelta")
    if phase.duration > 0 then
      table.insert(cfg.phases, phase)
    end
  end
  return cfg
end
def.static("number", "=>", "table").GetFightTypeCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.FIGHT_TYPE_CFG, id)
  if record == nil then
    warn("CFightTypeCfg get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.battleType = record:GetIntValue("battleType")
  cfg.escapeAllowed = record:GetCharValue("escapeAllowed") ~= 0
  cfg.enemyHp = record:GetCharValue("enemyHp") ~= 0
  cfg.showAdditionalCost = record:GetCharValue("isFellowSkillCost") ~= 0
  cfg.endPlayImmediately = record:GetCharValue("endPlayImmediately") ~= 0
  cfg.isShowCmdTip = record:GetCharValue("isShowCmdTip") ~= 0
  cfg.showHpInSpectating = record:GetCharValue("showHpInSpectating") ~= 0
  cfg.musics = {}
  cfg.bgIds = {}
  local sceneStruct = record:GetStructValue("sceneStruct")
  local count = sceneStruct:GetVectorSize("musicsVector")
  local i = 1
  for i = 1, count do
    local musicRecord = sceneStruct:GetVectorValueByIdx("musicsVector", i - 1)
    local musicid = musicRecord:GetIntValue("musicId")
    table.insert(cfg.musics, musicid)
  end
  count = sceneStruct:GetVectorSize("bgVector")
  for i = 1, count do
    local bgRecord = sceneStruct:GetVectorValueByIdx("bgVector", i - 1)
    local bgId = bgRecord:GetIntValue("bgId")
    table.insert(cfg.bgIds, bgId)
  end
  return cfg
end
def.static("number", "=>", "table").GetFightCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.CFIGHT_CFG, id)
  if record == nil then
    warn("GetFightCfg get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.isFlyBattle = record:GetCharValue("isFlyBattle") ~= 0
  return cfg
end
def.static("number", "=>", "table").GetFightTipCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.FIGHT_TIP_CFG, id)
  if record == nil then
    warn("[Fight]FightTipCfg get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.targetType = record:GetIntValue("type")
  cfg.tipStr = record:GetStringValue("tipStr")
  return cfg
end
def.static("number", "=>", "table").GetDissolveCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DISSOLVE_CFG, id)
  if record == nil then
    warn("[Fight]CRongJieCfg get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.A = record:GetIntValue("A") / 255
  cfg.B = record:GetIntValue("B") / 255
  cfg.G = record:GetIntValue("G") / 255
  cfg.R = record:GetIntValue("R") / 255
  cfg.effId = record:GetIntValue("effId")
  return cfg
end
def.static("number", "=>", "table").GetShatterCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.SHATTER_CFG, id)
  if record == nil then
    warn("[Fight]GetShatterCfg get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.f = record:GetIntValue("f")
  cfg.a = record:GetIntValue("a") / 1000
  cfg.duration = record:GetIntValue("duration") / 1000
  return cfg
end
def.static("number", "=>", "table").GetCompositeSkillCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.COMPOSITE_CFG, id)
  if record == nil then
    warn("[Fight]CComplexSkillCfg get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.activeMale = record:GetIntValue("activeMale")
  cfg.activeFemale = record:GetIntValue("activeFemale")
  cfg.passiveMale = record:GetIntValue("passiveMale")
  cfg.passiveFemale = record:GetIntValue("passiveFemale")
  cfg.skillIconid = record:GetIntValue("skillIconid")
  return cfg
end
def.static("number", "=>", "number").GetNormalAttackSkillId = function(menpai)
  if menpai <= 0 then
    return constant.FightConst.ATTACK_SKILL
  end
  local record = DynamicData.GetRecord(CFG_PATH.OCCUPATION_NORMAL_ATTACK_CFG, menpai)
  if record == nil then
    warn("[Fight]GetNormalAttackSkillId get nil record for id: ", menpai)
    return nil
  end
  return record:GetIntValue("normalSkillid")
end
def.static("number", "number", "=>", "boolean").IsNormalAttack = function(menpai, skillId)
  local normalSkillid = FightUtils.GetNormalAttackSkillId(menpai)
  return skillId == normalSkillid
end
def.static("number", "=>", "boolean").IsChangeModelFlyMount = function(feijianType)
  local FeijianType = require("consts.mzm.gsp.feijian.confbean.FeiJianType")
  return feijianType == FeijianType.BODY_SIT or feijianType == FeijianType.BODY_STAND
end
def.static("number", "=>", "string", "boolean").GetFlyMountModelPath = function(flymountId)
  local rec = DynamicData.GetRecord(CFG_PATH.DATA_FEIJIAN_CFG, flymountId)
  if rec then
    local flyMountModelId = rec:GetIntValue("modelId")
    local feijianType = rec:GetIntValue("feijianType") or -1
    if flyMountModelId > 0 then
      local modelpath = GetModelPath(flyMountModelId)
      local isChangeModel = FightUtils.IsChangeModelFlyMount(feijianType)
      return modelpath, isChangeModel
    end
  end
  return "", false
end
local funcBtnCfg
def.static("=>", "table").GetFuncBtnCfg = function()
  if funcBtnCfg then
    return funcBtnCfg
  end
  funcBtnCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_FUNC_OPEN)
  if entries == nil then
    return nil
  end
  local size = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, size - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    if record == nil then
      return nil
    end
    local show = record:GetCharValue("showInBattle") ~= 0
    local isopen = record:GetCharValue("isOpenForCensor") ~= 0
    if (GameUtil.IsEvaluation() == false or isopen) and show then
      local cfg = {}
      cfg.func = record:GetIntValue("func")
      cfg.level = record:GetIntValue("level")
      cfg.priority = record:GetIntValue("priority")
      cfg.iconName = record:GetStringValue("iconName")
      cfg.idip = record:GetIntValue("idip")
      table.insert(funcBtnCfg, cfg)
    end
  end
  table.sort(funcBtnCfg, function(a, b)
    return a.priority < b.priority
  end)
  return funcBtnCfg
end
def.static("table", "table", "=>", "number").GetOvercomeValue = function(host, enemy)
  if host == nil or enemy == nil then
    return -1
  end
  local cfg = require("Main.TurnedCard.TurnedCardUtils").GetClassLevelCfg(host.attr_class)
  if cfg == nil then
    return -1
  end
  local cur_level_cfg = cfg.classLevels[host.attr_class_level]
  if cur_level_cfg == nil then
    return 0
  end
  local overcome_map = cur_level_cfg.damageAddRates
  local overcome_value = 0
  for i = 1, #overcome_map do
    if overcome_map[i].classType == enemy.attr_class then
      overcome_value = overcome_map[i].value
      break
    end
  end
  return overcome_value
end
def.static("table", "table", "=>", "string").GetOvercomeDesc = function(host, enemy)
  local host_to_enemy = FightUtils.GetOvercomeValue(host, enemy)
  if host_to_enemy < 0 then
    return ""
  end
  if host_to_enemy > 0 then
    return string.format(textRes.Fight[90], tostring(host_to_enemy / 100))
  else
    local enemy_to_host = FightUtils.GetOvercomeValue(enemy, host)
    if enemy_to_host > 0 then
      return string.format(textRes.Fight[91], tostring(enemy_to_host / 100))
    else
      return textRes.Fight[92]
    end
  end
end
def.static("number", "number", "number", "=>", "number").GetSkillPlayMappingCfg = function(id, group, state)
  local record = DynamicData.GetRecord(CFG_PATH.SKILL_PLAY_MAPPING_CFG, id)
  if record == nil then
    return 0
  end
  local mappingStruct = record:GetStructValue("mappingStruct")
  local count = mappingStruct:GetVectorSize("mappingVector")
  local i = 1
  for i = 1, count do
    local rec = mappingStruct:GetVectorValueByIdx("mappingVector", i - 1)
    local fightStateGroupId = rec:GetIntValue("fightStateGroupId")
    local fightState = rec:GetIntValue("fightState")
    if fightStateGroupId == group and fightState == state then
      return rec:GetIntValue("finalSkillPlayid")
    end
  end
  return 0
end
def.static("number", "=>", "boolean").IsFightItemType = function(itemType)
  local record = DynamicData.GetRecord(CFG_PATH.ITEMTYPE_INFIGHT_CFG, itemType)
  return record ~= nil
end
def.static("number", "number", "=>", "table").GetSkillChangeModelCfg = function(state, gender)
  local entries = DynamicData.GetTable(CFG_PATH.SKILL_CHANGE_MODEL_CFG)
  if entries == nil then
    return nil
  end
  local size = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, size - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    if record == nil then
      return nil
    end
    local _state = record:GetIntValue("fightState")
    local _gender = record:GetIntValue("gender")
    if _state == state and _gender == gender then
      local cfg = {}
      cfg.modelId = record:GetIntValue("modelId")
      cfg.appearanceId = record:GetIntValue("appearanceId")
      return cfg
    end
  end
  return nil
end
local skills_state_cache = {}
def.static("number", "=>", "table").GetSkillStateCfg = function(group)
  if skills_state_cache[group] then
    return skills_state_cache[group]
  end
  local record = DynamicData.GetRecord(CFG_PATH.SKILL_STATE_CFG, group)
  if record == nil then
    return nil
  end
  local skills_state = {}
  skills_state_cache[group] = skills_state
  local stateStruct = record:GetStructValue("stateStruct")
  local count = stateStruct:GetVectorSize("stateVector")
  for i = 1, count do
    local state_rec = stateStruct:GetVectorValueByIdx("stateVector", i - 1)
    local state = state_rec:GetIntValue("state")
    local skillStruct = state_rec:GetStructValue("skillStruct")
    local skill_count = skillStruct:GetVectorSize("skillVector")
    for j = 1, skill_count do
      local skill_rec = skillStruct:GetVectorValueByIdx("skillVector", j - 1)
      local skillId = skill_rec:GetIntValue("skillId")
      local states = skills_state[skillId]
      if states == nil then
        states = {}
        skills_state[skillId] = states
      end
      table.insert(states, state)
    end
  end
  return skills_state
end
def.static("number", "=>", "number").GetFightPosByPetFormationPos = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.PET_FORMATION_MAP_CFG, id)
  if record == nil then
    return 0
  end
  return record:GetIntValue("fightPostion") + 1
end
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
def.static("=>", "boolean").IsRestrictEnable = function()
  local heroProp = require("Main.Hero.Interface"):GetBasicHeroProp()
  local isEnable = heroProp.level >= constant.CChangeModelCardConsts.OPEN_LEVEL
  if not isEnable then
    return false
  end
  isEnable = _G.IsFeatureOpen(Feature.TYPE_CLASS_RESTRICTION)
  return isEnable
end
FightUtils.Commit()
return FightUtils
