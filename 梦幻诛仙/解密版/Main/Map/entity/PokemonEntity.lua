local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local EntityBase = import(".EntityBase")
local HomelandUtils = require("Main.Homeland.HomelandUtils")
local PokemonUtils = require("Main.Pokemon.PokemonUtils")
local ECPlayer = require("Model.ECPlayer")
local PokemonData = require("Main.Pokemon.data.PokemonData")
local Vector = require("Types.Vector")
local ECGame = require("Main.ECGame")
local PokemonEntity = Lplus.Extend(EntityBase, CUR_CLASS_NAME)
local def = PokemonEntity.define
def.const("table").BehaviorStateEnum = {
  NONE = 0,
  STROLL = 1,
  REST = 2,
  CONVENE = 3,
  STANDBY = 4,
  TALKING = 5
}
def.const("table").LifeStageEnum = {
  NONE = 0,
  EGG = 1,
  ADULT = 2,
  COOLDOWN = 3,
  AWARD = 4
}
def.field("table")._ecmodel = nil
def.field("number")._curBehaviorState = 0
def.field("number")._curLifeStage = 0
def.field("number")._idleTimerId = 0
def.field("number")._curEffectId = 0
def.field("number")._instanceId = 0
def.field("number")._pokemonStage = 0
def.field("number")._eggCfgId = 0
def.field("number")._hatchDays = 0
def.field("number")._pokemonId = 0
def.field("number")._lastMateTime = 0
def.field("number")._awardId = 0
def.field("string")._pokemonName = ""
def.field("string")._ownerName = ""
def.override().OnCreate = function(self)
  local Location = require("netio.protocol.mzm.gsp.map.Location")
  local pt = MapScene.FindRandomValidPoint(gmodule.moduleMgr:GetModule(ModuleId.MAP).scene)
  if pt == nil then
    warn("[ERROR][PokemonEntity:OnCreate] MapScene.FindRandomValidPoint nil, random init location failed!.")
  else
    self.loc = Location.new(pt:x(), pt:y())
    self.locs = {}
    table.insert(self.locs, self.loc)
  end
end
def.override().OnDestroy = function(self)
  self:OnLeaveView()
end
def.override().OnEnterView = function(self)
  warn("[PokemonEntity:OnEnterView] pokemon enterview, self.instanceid:", tostring(self.instanceid))
  self:UpdatePokemonEntityInfo()
  self:StartIdle(PokemonEntity.BehaviorStateEnum.REST)
end
def.override().OnLeaveView = function(self)
  warn("[PokemonEntity:OnLeaveView] pokemon leave view, self.instanceid:", tostring(self.instanceid))
  self:_RemovePokemonEffect()
  self:_ClearIdleTimer()
  if self._ecmodel and not self._ecmodel:IsDestroyed() then
    self._ecmodel:Destroy()
  end
  self._ecmodel = nil
end
def.override("table").OnSyncMove = function(self, locs)
  warn("[PokemonEntity:OnSyncMove] OnSyncMove, self.instanceid:", tostring(self.instanceid))
end
def.method().OnConvene = function(self)
  self:Convene()
end
def.method("userdata").OnTalkStart = function(self, instanceId)
  if Int64.eq(instanceId, self.instanceid) then
    self:Talk()
  elseif self._curBehaviorState == PokemonEntity.BehaviorStateEnum.TALKING then
    self:StartIdle(PokemonEntity.BehaviorStateEnum.REST)
  end
end
def.method("table", "table").OnTalkFinished = function(self, param, context)
  warn("[PokemonEntity:OnTalkFinished] On Talk finished.")
  if self:GetBehaviorState() == PokemonEntity.BehaviorStateEnum.TALKING then
    self:StartIdle(PokemonEntity.BehaviorStateEnum.REST)
  end
end
def.method().OnHeroFindpathSucc = function(self)
  if self:GetBehaviorState() ~= PokemonEntity.BehaviorStateEnum.TALKING or self:GetLifeStage() == PokemonEntity.LifeStageEnum.EGG then
  end
end
def.method().OnHeroFindpathFail = function(self)
  if self:GetBehaviorState() == PokemonEntity.BehaviorStateEnum.TALKING then
    self:StartIdle(PokemonEntity.BehaviorStateEnum.REST)
  end
end
def.override("number").Update = function(self, dt)
  if self._ecmodel and not self._ecmodel:IsDestroyed() then
    self._ecmodel:Update(dt)
  end
  if self:GetLifeStage() == PokemonEntity.LifeStageEnum.COOLDOWN and not self:IsMateCDing() then
    if self._awardId > 0 then
      self:_SetLifeStage(PokemonEntity.LifeStageEnum.AWARD)
    else
      self:_SetLifeStage(PokemonEntity.LifeStageEnum.ADULT)
    end
  end
end
def.override("number", "table", "table").OnInfoChange = function(self, cfgid, loc, extra_info)
  if self.cfgid ~= cfgid then
    self._ecmodel:Destroy()
    self._ecmodel = nil
  end
  self.cfgid = cfgid
  self.loc = loc
  self:UnmarshalExtraInfo(extra_info)
  self:UpdatePokemonEntityInfo()
end
def.override("table", "table").OnExtraInfoChange = function(self, extra_info, remove_extra_info_keys)
  self:UnmarshalExtraInfo(extra_info)
  self:UpdatePokemonEntityInfo()
end
def.override("table").UnmarshalExtraInfo = function(self, extra_info)
  local ExtraInfoType = EntityBase.MapEntityExtraInfoType
  if extra_info.int_extra_infos[ExtraInfoType.MET_ANIMAL_STAGE] then
    self._pokemonStage = extra_info.int_extra_infos[ExtraInfoType.MET_ANIMAL_STAGE]
  end
  if self._pokemonStage == 0 then
    if extra_info.int_extra_infos[ExtraInfoType.MET_EMBRYO_CFG_ID] then
      self._eggCfgId = extra_info.int_extra_infos[ExtraInfoType.MET_EMBRYO_CFG_ID]
    end
    if extra_info.int_extra_infos[ExtraInfoType.MET_EMBRYO_HATCH_DAYS] then
      local oldFondleCount = self._hatchDays
      self._hatchDays = extra_info.int_extra_infos[ExtraInfoType.MET_EMBRYO_HATCH_DAYS]
      if oldFondleCount ~= self._hatchDays then
        Event.DispatchEvent(ModuleId.POKEMON, gmodule.notifyId.Pokemon.EGG_FONDLE_COUNT_CHANGE, {entity = self})
      end
    end
    if extra_info.string_extra_infos[ExtraInfoType.MET_ANIMAL_OWNER_NAME] then
      local ownerName = extra_info.string_extra_infos[ExtraInfoType.MET_ANIMAL_OWNER_NAME]
      self._ownerName = ownerName and _G.GetStringFromOcts(ownerName) or self._ownerName
    end
  else
    if extra_info.int_extra_infos[ExtraInfoType.MET_ANIMAL_CFG_ID] then
      self._pokemonId = extra_info.int_extra_infos[ExtraInfoType.MET_ANIMAL_CFG_ID]
    end
    if extra_info.int_extra_infos[ExtraInfoType.MET_ANIMAL_LAST_MATE_TIME] then
      self._lastMateTime = extra_info.int_extra_infos[ExtraInfoType.MET_ANIMAL_LAST_MATE_TIME]
    end
    if extra_info.int_extra_infos[ExtraInfoType.MET_ANIMAL_AWARD_CFG_ID] then
      self._awardId = extra_info.int_extra_infos[ExtraInfoType.MET_ANIMAL_AWARD_CFG_ID]
      warn("[PokemonEntity:UnmarshalExtraInfo] self._awardId:", self._awardId)
    end
    if extra_info.string_extra_infos[ExtraInfoType.MET_ANIMAL_NAME] then
      local pokemonName = extra_info.string_extra_infos[ExtraInfoType.MET_ANIMAL_NAME]
      self._pokemonName = pokemonName and _G.GetStringFromOcts(pokemonName) or self._pokemonName
    end
    if extra_info.string_extra_infos[ExtraInfoType.MET_ANIMAL_OWNER_NAME] then
      local ownerName = extra_info.string_extra_infos[ExtraInfoType.MET_ANIMAL_OWNER_NAME]
      self._ownerName = ownerName and _G.GetStringFromOcts(ownerName) or self._ownerName
    end
  end
  self:UpdatePokemonLifeStage()
end
def.method().UpdatePokemonEntityInfo = function(self)
  warn("[PokemonEntity:UpdatePokemonEntityInfo] self.instanceid:", tostring(self.instanceid))
  if self._ecmodel and not self._ecmodel:IsDestroyed() then
    self._ecmodel:SetName(self:GetName(), nil)
    return
  end
  local homelandInfo = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):GetCurHomelandInfo()
  local houseCfg = HomelandUtils.GetHouseCfg(homelandInfo.houseLevel)
  if self._pokemonStage == 0 then
    self:LoadEggModel(self.loc.x, self.loc.y, houseCfg.maidDir)
  else
    self:LoadAdultModel(self.loc.x, self.loc.y, houseCfg.maidDir)
  end
  self:UpdatePokemonEffect()
end
def.method("=>", "number").GetFondleCount = function(self)
  return self._hatchDays or 0
end
def.method("=>", "string").GetPokemonName = function(self)
  return self._pokemonName or ""
end
def.method("=>", "string").GetOwnerName = function(self)
  return self._ownerName or ""
end
def.method("string").Rename = function(self, name)
  self._pokemonName = name
  if self._ecmodel and not self._ecmodel:IsDestroyed() then
    self._ecmodel:SetName(self.name, nil)
  end
end
def.method("=>", "string").GetName = function(self)
  if self:GetLifeStage() == PokemonEntity.LifeStageEnum.EGG then
    return PokemonUtils.GetEggName(self._eggCfgId)
  else
    return self._pokemonName
  end
end
def.method("=>", "number").GetCfgId = function(self)
  if self:GetLifeStage() == PokemonEntity.LifeStageEnum.EGG then
    return self._eggCfgId
  else
    return self._pokemonId
  end
end
def.method("=>", "number").GetAwardId = function(self)
  if self:GetLifeStage() == PokemonEntity.LifeStageEnum.EGG then
    return 0
  else
    return self._awardId and self._awardId or 0
  end
end
def.method("number").StartIdle = function(self, state)
  local idleDuration = -1
  if state == PokemonEntity.BehaviorStateEnum.REST then
    idleDuration = constant.CAnimalConst.ANIMAL_REST_SECOND
  elseif state == PokemonEntity.BehaviorStateEnum.STANDBY then
    idleDuration = constant.CAnimalConst.CALL_TOGETHER_STAY_SECOND
  elseif state == PokemonEntity.BehaviorStateEnum.TALKING then
    idleDuration = constant.CAnimalConst.CALL_TOGETHER_STAY_SECOND
  else
    warn("[ERROR][PokemonEntity:StartIdle] WRONG Idle STATE:", state)
    return
  end
  self:_ClearIdleTimer()
  self:_SetBehaviorState(state)
  if self._ecmodel and self._ecmodel:IsMoving() then
    self._ecmodel:Stop()
  end
  if idleDuration > 0 then
    self._idleTimerId = GameUtil.AddGlobalTimer(idleDuration, true, function()
      self:_IdleEndCallback()
    end)
  end
end
def.method()._IdleEndCallback = function(self)
  self:_ClearIdleTimer()
  if self._curBehaviorState == PokemonEntity.BehaviorStateEnum.REST or self._curBehaviorState == PokemonEntity.BehaviorStateEnum.STANDBY then
    self:Stroll()
  elseif self._curBehaviorState == PokemonEntity.BehaviorStateEnum.TALKING then
    if self:IsTalking() then
      self:StartIdle(PokemonEntity.BehaviorStateEnum.TALKING)
    else
      self:StartIdle(PokemonEntity.BehaviorStateEnum.REST)
    end
  else
    warn("[ERROR][PokemonEntity:_IdleEndCallback] WRONG CURRENT STATE:", self._curBehaviorState)
    return
  end
end
def.method().Stroll = function(self)
  if self._ecmodel == nil or self._ecmodel:IsDestroyed() then
    warn("[ERROR][PokemonEntity:Stroll] Stroll Failed! self._ecmodel == nil or self._ecmodel:IsDestroyed().")
    return
  end
  local pt = MapScene.FindRandomValidPoint(gmodule.moduleMgr:GetModule(ModuleId.MAP).scene)
  if pt == nil then
    warn("[ERROR][PokemonEntity:Stroll] MapScene.FindRandomValidPoint nil.")
    self:StartIdle(PokemonEntity.BehaviorStateEnum.REST)
    return
  end
  self:_ClearIdleTimer()
  self:_SetBehaviorState(PokemonEntity.BehaviorStateEnum.STROLL)
  self:_MoveTo(pt:x(), pt:y(), PokemonEntity.BehaviorStateEnum.STROLL)
end
def.method()._MoveEndCallback = function(self)
  local state
  if self._curBehaviorState == PokemonEntity.BehaviorStateEnum.CONVENE then
    state = PokemonEntity.BehaviorStateEnum.STANDBY
  elseif self._curBehaviorState == PokemonEntity.BehaviorStateEnum.STROLL then
    state = PokemonEntity.BehaviorStateEnum.REST
  else
    warn("[ERROR][PokemonEntity:_MoveEndCallback] WRONG STATE moving state:", self._curBehaviorState)
    return
  end
  if state and state > 0 then
    self:StartIdle(state)
  else
    warn("[ERROR][PokemonEntity:_MoveEndCallback] state invalid:", state)
  end
end
def.method().Convene = function(self)
  local HomelandModule = Lplus.ForwardDeclare("HomelandModule")
  if not HomelandModule.Instance():IsInSelfHomeland() then
    warn("[PokemonEntity:Convene] Convene failed! not self homeland.")
    return
  end
  local convenePos = self:_GetConvenePos()
  self:_ClearIdleTimer()
  self:_SetBehaviorState(PokemonEntity.BehaviorStateEnum.CONVENE)
  self:_MoveTo(convenePos.x, convenePos.y, PokemonEntity.BehaviorStateEnum.CONVENE)
end
def.method().Talk = function(self)
  self:_ClearIdleTimer()
  self:StartIdle(PokemonEntity.BehaviorStateEnum.TALKING)
end
def.method("number")._SetBehaviorState = function(self, state)
  self._curBehaviorState = state
end
def.method("=>", "number").GetBehaviorState = function(self)
  return self._curBehaviorState
end
def.method().UpdatePokemonLifeStage = function(self)
  if 0 == self._pokemonStage then
    self:_SetLifeStage(PokemonEntity.LifeStageEnum.EGG)
  elseif 1 == self._pokemonStage then
    if self:IsMateCDing() then
      self:_SetLifeStage(PokemonEntity.LifeStageEnum.COOLDOWN)
    elseif 0 < self._awardId then
      self:_SetLifeStage(PokemonEntity.LifeStageEnum.AWARD)
    else
      self:_SetLifeStage(PokemonEntity.LifeStageEnum.ADULT)
    end
  else
    warn("[ERROR][PokemonEntity:UpdatePokemonLifeStage] WRONG STAGE:", self._pokemonStage)
  end
  if self._ecmodel and not self._ecmodel:IsDestroyed() then
    self:UpdatePokemonEffect()
  end
end
def.method("=>", "boolean").IsMateCDing = function(self)
  local cfgMateCD = PokemonUtils.GetPokemonMateCD(self._pokemonId)
  local mateInterval = _G.GetServerTime() - self._lastMateTime
  return cfgMateCD >= mateInterval
end
def.method("=>", "number").GetMateRestTime = function(self)
  local cfgMateCD = PokemonUtils.GetPokemonMateCD(self._pokemonId)
  local mateInterval = _G.GetServerTime() - self._lastMateTime
  return math.max(0, cfgMateCD - mateInterval)
end
def.method("=>", "number").GetLifeStage = function(self)
  return self._curLifeStage
end
def.method("number")._SetLifeStage = function(self, stage)
  if nil == PokemonData.Instance():GetPokemonInfo(self.instanceid) and (self._curLifeStage == PokemonEntity.LifeStageEnum.ADULT or stage == PokemonEntity.LifeStageEnum.ADULT) then
    warn("[PokemonEntity:_SetLifeStage] DispatchEvent POKEMON_MATE_INFO_CHANGE_OTHER, stage=", stage)
    Event.DispatchEvent(ModuleId.POKEMON, gmodule.notifyId.Pokemon.POKEMON_MATE_INFO_CHANGE_OTHER, {
      stage == PokemonEntity.LifeStageEnum.ADULT
    })
  end
  self._curLifeStage = stage
end
def.method("=>", "boolean").HasAward = function(self)
  return self._awardId > 0
end
def.method("=>", "boolean").CanMate = function(self)
  return self._curLifeStage == PokemonEntity.LifeStageEnum.ADULT
end
def.method("=>", "table").GetECModel = function(self)
  return self._ecmodel
end
def.method("=>", "table").GetPosition = function(self)
  return self._ecmodel and self._ecmodel:GetPos() or Vector.Vector2.zero
end
def.method("=>", "number").GetHeight = function(self)
  if self._ecmodel then
    local UIRoot = GUIRoot.GetUIRootObj()
    return self._ecmodel:GetBoxHeight() / UIRoot.localScale.y / CommonCamera.game3DCamera.orthographicSize
  else
    warn("[PokemonEntity:GetHeight] self._ecmodel nil, return 0!")
    return 0
  end
end
def.method("=>", "table").GetInteractivePanelPos = function(self)
  local pos = Vector.Vector2.zero
  if self._ecmodel == nil then
    return pos
  end
  local mapPos = self._ecmodel:GetPos()
  if mapPos == nil then
    return pos
  end
  local localPos = Vector.Vector3.new(mapPos.x, world_height - mapPos.y, 0)
  local cam2dpos = ECGame.Instance():Get2dCameraPos()
  local diff = localPos - cam2dpos
  local UIRoot = GUIRoot.GetUIRootObj()
  local boxHeight = self._ecmodel:GetBoxHeight()
  local offset = 60
  diff.y = diff.y + boxHeight / UIRoot.localScale.y / CommonCamera.game3DCamera.orthographicSize + offset
  pos = diff
  return pos
end
def.method("=>", "table")._GetConvenePos = function(self)
  local convenePos
  local heroPos = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetPos()
  if heroPos ~= nil then
    local selfPos = self:GetPosition()
    local vector = Vector.Vector2.new(selfPos.x - heroPos.x, selfPos.y - heroPos.y)
    vector:Normalize()
    vector = vector * constant.CAnimalConst.CALL_TOGETHER_CYCLE
    convenePos = {}
    convenePos.x = heroPos.x + vector.x
    convenePos.y = heroPos.y + vector.y
  else
    warn("[ERROR][PokemonEntity:_GetConvenePos] heroPos nil.")
  end
  return convenePos
end
def.method("number", "number", "number", "=>", "boolean")._MoveTo = function(self, x, y, state)
  local findpath = self:_FindPath(x, y, 0)
  if findpath == nil or #findpath == 0 then
    warn(string.format("[PokemonEntity:_MoveTo] findpath nil, set pokemon to (%d, %d) directly.", x, y))
    self._ecmodel:SetPos(x, y)
    return true
  end
  self._ecmodel:RunPath(findpath, self._ecmodel.runSpeed, function()
    self:_MoveEndCallback()
  end)
  return true
end
def.method("number", "number", "number", "=>", "table")._FindPath = function(self, x, y, distance)
  if self._ecmodel == nil then
    warn("[ERROR][PokemonEntity:_FindPath] self._ecmodel == nil, return nil!")
    return nil
  elseif self._ecmodel:IsDestroyed() then
    warn("[ERROR][PokemonEntity:_FindPath] self._ecmodel:IsDestroyed(), return nil!")
    return nil
  end
  local findpath = gmodule.moduleMgr:GetModule(ModuleId.MAP):FindPath(self._ecmodel.m_node2d.localPosition.x, self._ecmodel.m_node2d.localPosition.y, x, y, distance)
  if nil == findpath then
    warn(string.format("[ERROR][PokemonEntity:_FindPath] findpath nil from (%d,%d) to (%d,%d)!", self._ecmodel.m_node2d.localPosition.x, self._ecmodel.m_node2d.localPosition.y, x, y))
  end
  return findpath
end
def.method()._ClearIdleTimer = function(self)
  if self._idleTimerId > 0 then
    GameUtil.RemoveGlobalTimer(self._idleTimerId)
    self._idleTimerId = 0
  end
end
local getPanelNameFromResName = function(resName)
  local i, j, cap = resName:lower():find("/([%w_]+)%.prefab%.u3dext$")
  if cap then
    return cap
  end
  local i, j, cap = resName:lower():find("([^/]*)$")
  return cap or "noname"
end
def.method("=>", "boolean").IsTalking = function(self)
  if self._curBehaviorState == PokemonEntity.BehaviorStateEnum.TALKING then
    local PokemonMgr = require("Main.Pokemon.PokemonMgr")
    local NPCDlg = require("Main.npc.ui.NPCDlg")
    if NPCDlg.Instance():IsShow() and self == PokemonMgr.Instance():GetTarget() then
      return true
    end
    local HatchPokemonPanel = require("Main.Pokemon.ui.HatchPokemonPanel")
    if HatchPokemonPanel.Instance():IsShow() and self == PokemonMgr.Instance():GetTarget() then
      return true
    end
    local PokemonMateListPanel = require("Main.Pokemon.ui.PokemonMateListPanel")
    if PokemonMateListPanel.Instance():IsShow() and self == PokemonMgr.Instance():GetTarget() then
      return true
    end
    local ECGUIMan = require("GUI.ECGUIMan")
    local captchaConfirmDlg = ECGUIMan.Instance():FindPanelByName(getPanelNameFromResName(RESPATH.PREFAB_PET_FREE_PROTECTION_PANEL_RES))
    if captchaConfirmDlg and captchaConfirmDlg:IsShow() and self == PokemonMgr.Instance():GetTarget() then
      warn("[PokemonEntity:IsTalking] IsTalking=true! captchaConfirmDlg:IsShow().")
      return true
    end
    local CommonRenamePanel = require("GUI.CommonRenamePanel")
    if CommonRenamePanel.Instance():IsShow() and self == PokemonMgr.Instance():GetTarget() then
      return true
    end
    return false
  else
    return false
  end
end
def.method("number", "number", "number", "=>", "table").LoadEggModel = function(self, x, y, dir)
  if self._ecmodel then
    self._ecmodel:Destroy()
    self._ecmodel = nil
  end
  if 0 == self._pokemonStage then
    local eggCfg = PokemonData.Instance():GetEggCfg(self.cfgid)
    if nil == eggCfg then
      warn("[ERROR][PokemonEntity:LoadEggModel] eggCfg nil, self.instanceid:", tostring(self.instanceid))
      return nil
    end
    self._ecmodel = ECPlayer.new(self.instanceid, eggCfg.modelId, self:GetName(), _G.GetColorData(constant.CAnimalConst.NAME_COLOR_CFG_ID), RoleType.POKEMON)
    self._ecmodel.showOrnament = true
    self._ecmodel.m_bUncache = true
    self._ecmodel:SetLayer(ClientDef_Layer.NPC)
    local model_info = {}
    model_info.modelid = eggCfg.modelId
    model_info.extraMap = {}
    _G.LoadModel(self._ecmodel, model_info, x, y, dir, false, false)
    return self._ecmodel
  else
    warn("[ERROR][PokemonEntity:LoadEggModel] self._pokemonStage~=0! CAN NOT LOAD EGG MODEL.")
    return nil
  end
end
def.method("number", "number", "number", "=>", "table").LoadAdultModel = function(self, x, y, dir)
  if self._ecmodel then
    self._ecmodel:Destroy()
    self._ecmodel = nil
  end
  if 1 == self._pokemonStage then
    local npcId = PokemonUtils.GetPokemonNPCId(self.cfgid)
    local mapId = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapId()
    local npcdata = {
      insanceid = self.instanceid,
      x = self.loc.x,
      y = self.loc.y,
      dir = dir,
      npcId = npcId,
      name = self:GetName(),
      mapId = mapId,
      namecolor = constant.CAnimalConst.NAME_COLOR_CFG_ID,
      extraInfo = {}
    }
    local npc = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):CreateUserNpc(npcdata)
    npc.extraInfo.npc = npc
    npc.extraInfo.entityType = self.type
    npc.extraInfo.instanceId = self.instanceid
    if nil == PokemonData.Instance():GetPokemonInfo(self.instanceid) then
      local pokemonCfg = PokemonData.Instance():GetPokemonCfg(self.cfgid)
      if pokemonCfg then
        npc.extraInfo.customTalkTexts = {}
        local customTalk = string.format(textRes.Pokemon.OTHER_ROLE_POKEMON, self:GetOwnerName(), pokemonCfg.starType, pokemonCfg.name)
        table.insert(npc.extraInfo.customTalkTexts, customTalk)
      else
        warn("[ERROR][PokemonEntity:LoadAdultModel] pokemonCfg nil for cfgid:", self.cfgid)
      end
    end
    self._ecmodel = npc
    return self._ecmodel
  else
    warn("[ERROR][PokemonEntity:LoadAdultModel] self._pokemonStage~=1! CAN NOT LOAD POKEMON MODEL.")
    return nil
  end
end
def.method().UpdatePokemonEffect = function(self)
  if nil == self._ecmodel or self._ecmodel:IsDestroyed() then
    warn("[ERROR][PokemonEntity:UpdatePokemonEffect] self._ecmodel nil.")
    return
  end
  local effectId = 0
  if self._curLifeStage == PokemonEntity.LifeStageEnum.AWARD or self._curLifeStage == PokemonEntity.LifeStageEnum.COOLDOWN and self:HasAward() then
    effectId = constant.CAnimalConst.AWARD_ABLE_EFFECT_CFG_ID
  elseif self._curLifeStage == PokemonEntity.LifeStageEnum.ADULT then
    effectId = constant.CAnimalConst.MATE_ABLE_EFFECT_CFG_ID
  end
  if effectId == self._curEffectId then
    return
  end
  self:_RemovePokemonEffect()
  if effectId > 0 then
    warn("[PokemonEntity:UpdatePokemonEffect] add effect:", effectId)
    self._curEffectId = effectId
    self._ecmodel:AddTop3DEffect(effectId, 0.6)
  end
end
def.method()._RemovePokemonEffect = function(self)
  if self._curEffectId > 0 then
    warn("[PokemonEntity:_RemovePokemonEffect] remove effect:", self._curEffectId)
    self._ecmodel:RemoveTop3DEffect(self._curEffectId)
    self._curEffectId = 0
  end
end
return PokemonEntity.Commit()
