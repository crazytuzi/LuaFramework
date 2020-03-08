local Lplus = require("Lplus")
local LoginModule = require("Main.Login.LoginModule")
local PokemonData = require("Main.Pokemon.data.PokemonData")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local HomelandModule = Lplus.ForwardDeclare("HomelandModule")
local PokemonModule = Lplus.ForwardDeclare("PokemonModule")
local MapEntityType = require("netio.protocol.mzm.gsp.map.MapEntityType")
local HatchPokemonPanel = require("Main.Pokemon.ui.HatchPokemonPanel")
local PokemonEntity = require("Main.Map.entity.PokemonEntity")
local PokemonProtocols = require("Main.Pokemon.PokemonProtocols")
local PokemonUtils = require("Main.Pokemon.PokemonUtils")
local PokemonMgr = Lplus.Class("PokemonMgr")
local def = PokemonMgr.define
local instance
def.static("=>", PokemonMgr).Instance = function()
  if instance == nil then
    instance = PokemonMgr()
  end
  return instance
end
def.const("number").TALK_DISTANCE = 150
def.field("table")._targetPokemonEntity = nil
def.field("userdata")._mateEffect = nil
def.field("number")._effectTimerID = 0
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, PokemonMgr._OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, PokemonMgr._OnLeaveWorld)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, PokemonMgr._OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Use_Pokemon, PokemonMgr._OnUseEgg)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LEAVE_COURTYARD, PokemonMgr._OnLeaveCourtyard)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_ROLE, PokemonMgr._OnClearTarget)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_MONSTER, PokemonMgr._OnClearTarget)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_PET, PokemonMgr._OnClearTarget)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_DOUDOU, PokemonMgr._OnClearTarget)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_CHILD, PokemonMgr._OnClearTarget)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_NPC, PokemonMgr._OnClickNPC)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_POKEMON, PokemonMgr._OnClickPokemon)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_FINDPATH_FINISHED, PokemonMgr._OnHeroFindpathFinished)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_CLICKMAP_FINDPATH, PokemonMgr.OnClickMapFindpath)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_FINDPATH_CANCELED, PokemonMgr.OnFindpathCanceled)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.FIND_PATH_FAILED, PokemonMgr.OnFindPathFailed)
  Event.RegisterEvent(ModuleId.POKEMON, gmodule.notifyId.Pokemon.MATE_PANEL_SHOW, PokemonMgr._OnMatePanelShow)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, PokemonMgr._OnNPCService)
end
def.static("table", "table")._OnEnterWorld = function(param, context)
  PokemonData.Instance():OnEnterWorld(param, context)
  if not param or param.enterType ~= LoginModule.EnterWorldType.RECONNECT then
  end
end
def.static("table", "table")._OnLeaveWorld = function(param, context)
  PokemonData.Instance():OnLeaveWorld(param, context)
  PokemonMgr.Instance():_DestroyMateEffect()
  PokemonMgr.Instance():_ClearEffectTimer()
  if not param or param.reason == LoginModule.LeaveWorldReason.RECONNECT then
  end
end
def.static("table", "table")._OnFunctionOpenChange = function(param, context)
  if param.feature == ModuleFunSwitchInfo.TYPE_ZOO and false == param.open then
    if HatchPokemonPanel.Instance():IsShow() then
      HatchPokemonPanel.Instance():DestroyPanel()
    end
    local MyPokemonPanel = require("Main.Pokemon.ui.MyPokemonPanel")
    if MyPokemonPanel.Instance():IsShow() then
      MyPokemonPanel.Instance():DestroyPanel()
    end
    local PokemonMateListPanel = require("Main.Pokemon.ui.PokemonMateListPanel")
    if PokemonMateListPanel.Instance():IsShow() then
      PokemonMateListPanel.Instance():DestroyPanel()
    end
  else
  end
end
def.static("table", "table")._OnUseEgg = function(param, context)
  warn("[PokemonMgr:_OnUseEgg] on event Item_Use_Pokemon.")
  if not PokemonModule.Instance():IsOpen(true) then
    return
  end
  if not HomelandModule.Instance():HaveHome() then
    Toast(textRes.Pokemon.HAVE_NO_HOMELAND)
    return
  end
  local ItemModule = require("Main.Item.ItemModule")
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(param.bagId, param.itemKey)
  if item == nil then
    warn("[PokemonMgr:_OnUseOracleItem] egg itemInfo not found in bag!param.bagId, param.itemKey:", param.bagId, param.itemKey)
    return
  end
  PokemonProtocols.SendCUseEmbryoItem(item.uuid[1])
end
def.static("table", "table")._OnLeaveCourtyard = function(param, context)
  instance:_ClearTarget()
end
def.method().PlayMateEffect = function(self)
  local effectParent = require("Main.MainUI.ui.MainUIPanel").Instance().m_panel
  if effectParent then
    if nil == self._mateEffect then
      local effectCfg = GetEffectRes(constant.CAnimalConst.MATE_SUCCESS_EFFECT)
      self._mateEffect = require("Fx.GUIFxMan").Instance():PlayAsChild(effectParent, effectCfg and effectCfg.path, 0, 0, -1, false)
    end
    if self._mateEffect then
      self:_ClearEffectTimer()
      local effectDuration = 3
      self._effectTimerID = GameUtil.AddGlobalTimer(effectDuration, true, function()
        self:_DestroyMateEffect()
      end)
    end
  else
    warn("[PokemonMgr:_PlayMateEffect] effectParent nil, play failed.")
  end
end
def.method()._DestroyMateEffect = function(self)
  if self._mateEffect then
    self._mateEffect:Destroy()
    self._mateEffect = nil
  end
end
def.method()._ClearEffectTimer = function(self)
  if self._effectTimerID > 0 then
    GameUtil.RemoveGlobalTimer(self._effectTimerID)
    self._effectTimerID = 0
  end
end
def.method("=>", "boolean").CanAnyEntityMate = function(self)
  local result = false
  local entites = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapEntitiesByType(MapEntityType.MET_ANIMAL)
  if entites then
    for k, pokemonEntity in pairs(entites) do
      if pokemonEntity:CanMate() then
        result = true
        break
      end
    end
  end
  warn("[PokemonMgr:CanAnyEntityMate] return:", result)
  return result
end
def.method("=>", "table").GetEntityInfoList = function(self)
  local pokemonList = {}
  local entites = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapEntitiesByType(MapEntityType.MET_ANIMAL)
  if entites then
    for k, pokemonEntity in pairs(entites) do
      local pokemonInfo = {}
      if pokemonEntity:GetLifeStage() == PokemonEntity.LifeStageEnum.EGG then
        pokemonInfo.stage = 0
        pokemonInfo.eggCfgId = pokemonEntity:GetCfgId()
        pokemonInfo.uuid = pokemonEntity.instanceid
      else
        pokemonInfo.stage = 1
        pokemonInfo.adultCfgId = pokemonEntity:GetCfgId()
        pokemonInfo.name = pokemonEntity:GetName()
        pokemonInfo.awardId = pokemonEntity:GetAwardId()
        pokemonInfo.uuid = pokemonEntity.instanceid
        pokemonInfo.canMate = pokemonEntity:CanMate()
      end
      table.insert(pokemonList, pokemonInfo)
    end
  end
  return pokemonList
end
def.static("table", "table")._OnClearTarget = function(param, context)
  if gmodule.moduleMgr:GetModule(ModuleId.HERO).isInHomeland then
    warn("[PokemonMgr:_OnClearTarget] On clear target.")
    instance:_ClearTarget()
  end
end
def.static("table", "table")._OnClickNPC = function(param, context)
  local npcID = param[1]
  local extraInfo = param[2]
  local entityType = extraInfo and extraInfo.entityType
  if entityType and entityType == MapEntityType.MET_ANIMAL then
    warn("[PokemonMgr:_OnClickNPC] pokemon NPC clicked, instanceId:", tostring(extraInfo.instanceId))
    local instanceId = extraInfo.instanceId
    local entity = instanceId and gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapEntity(MapEntityType.MET_ANIMAL, instanceId)
    PokemonMgr._DoClickPokemon(instanceId, entity)
  else
    instance:_ClearTarget()
  end
end
def.static("table", "table")._OnClickPokemon = function(param, context)
  warn("[PokemonMgr:_OnClickPokemon] pokemon EGG clicked, instanceId:", tostring(param[1]))
  local instanceId = param[1]
  local entity = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapEntity(MapEntityType.MET_ANIMAL, instanceId)
  PokemonMgr._DoClickPokemon(instanceId, entity)
end
def.static("userdata", "table")._DoClickPokemon = function(instanceId, entity)
  instance:_ClearTarget()
  instance:_SetTarget(entity)
  PokemonMgr._OnTalkStarted(instanceId)
  if entity and entity:GetLifeStage() == PokemonEntity.LifeStageEnum.EGG then
    local clickDist = PokemonMgr._GetHero2EntityDist()
    if clickDist <= PokemonMgr.TALK_DISTANCE then
      HatchPokemonPanel.ShowDlg(entity)
    else
      local entityPos = entity:GetPosition()
      local HeroModule = require("Main.Hero.HeroModule")
      HeroModule.Instance():MoveTo(0, entityPos.x, entityPos.y, 0, 5, MoveType.RUN, nil)
    end
  else
    if nil == entity then
      warn("[ERROR][PokemonMgr:_DoClickPokemon] entity nil for instanceId:", tostring(instanceId))
    else
    end
  end
end
def.static("=>", "number")._GetHero2EntityDist = function()
  if instance._targetPokemonEntity then
    local entityPos = instance._targetPokemonEntity:GetPosition()
    local myRole = require("Main.Hero.HeroModule").Instance().myRole
    local heroPos = myRole:GetPos()
    local MathHelper = require("Common.MathHelper")
    return MathHelper.Distance(heroPos.x, heroPos.y, entityPos.x, entityPos.y)
  else
    warn("[ERROR][PokemonMgr:_GetHero2EntityDist] instance._targetPokemonEntity nil. return math.huge.")
    return math.huge
  end
end
def.static("table", "table")._OnHeroFindpathFinished = function(param, context)
  if instance._targetPokemonEntity then
    warn("[PokemonMgr:_OnHeroFindpathFinished] Hero Findpath to pokemon Finished.")
    instance:OnFindpathEnd(true)
  end
end
def.static("table", "table").OnFindPathFailed = function(param, context)
  if instance._targetPokemonEntity then
    warn("[PokemonMgr:OnFindPathFailed] Hero Findpath to pokemon Failed.")
    local distance = PokemonMgr._GetHero2EntityDist()
    if distance <= PokemonMgr.TALK_DISTANCE then
      warn(string.format("[PokemonMgr:OnFindPathFailed] distance[%d]<=PokemonMgr.TALK_DISTANCE[%d], handle as findpath succ.", distance, PokemonMgr.TALK_DISTANCE))
      instance:OnFindpathEnd(true)
    else
      warn(string.format("[PokemonMgr:OnFindPathFailed] distance[%d]>PokemonMgr.TALK_DISTANCE[%d], handle as findpath failed.", distance, PokemonMgr.TALK_DISTANCE))
      instance:OnFindpathEnd(false)
    end
  end
end
def.static("table", "table").OnClickMapFindpath = function(param, context)
  if instance._targetPokemonEntity then
    warn("[PokemonMgr:OnClickMapFindpath] Findpath end on click map.")
    instance:OnFindpathEnd(false)
  end
end
def.static("table", "table").OnFindpathCanceled = function(param, context)
  if instance._targetPokemonEntity then
    warn("[PokemonMgr:OnFindpathCanceled] Hero Findpath to pokemon canceled.")
    instance:OnFindpathEnd(false)
  end
end
def.method("boolean").OnFindpathEnd = function(self, bSucc)
  if self._targetPokemonEntity then
    if bSucc then
      if self._targetPokemonEntity:GetLifeStage() == PokemonEntity.LifeStageEnum.EGG then
        self._targetPokemonEntity:OnHeroFindpathSucc()
        HatchPokemonPanel.ShowDlg(self._targetPokemonEntity)
      end
    else
      self._targetPokemonEntity:OnHeroFindpathFail()
      self:_ClearTarget()
    end
  else
    warn("[PokemonMgr:OnFindpathEnd] self._targetPokemonEntity nil.")
  end
end
def.static("table", "table")._OnMatePanelShow = function(param, context)
  warn("[PokemonMgr:_OnMatePanelShow] On PokemonMateListPanel Show.")
  local entity = param and param.entity or nil
  PokemonMgr._OnTalkStarted(entity and entity.instanceid or nil)
end
def.static("userdata")._OnTalkStarted = function(instanceId)
  if instanceId then
    local entites = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapEntitiesByType(MapEntityType.MET_ANIMAL)
    if entites == nil then
      warn("[PokemonMgr:_OnTalkStarted] not pokemon in view.")
      return
    end
    for k, pokemonEntity in pairs(entites) do
      pokemonEntity:OnTalkStart(instanceId)
    end
  else
    warn("[ERROR][PokemonMgr:_OnTalkStarted] instanceId nil.")
  end
end
def.static("table", "table")._OnTalkFinished = function(param, context)
  warn("[PokemonMgr:_OnTalkFinished] On talk finished.")
  instance:_ClearTarget()
  local entites = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapEntitiesByType(MapEntityType.MET_ANIMAL)
  if entites == nil then
    warn("[PokemonMgr:_OnTalkFinished] not pokemon in view.")
    return
  end
  for k, pokemonEntity in pairs(entites) do
    pokemonEntity:OnTalkFinished(param, context)
  end
end
def.method().ConveneAllPokemon = function(self)
  local pokemonList = PokemonData.Instance():GetPokemonList()
  if pokemonList and #pokemonList > 0 then
    Toast(textRes.Pokemon.CONVENE_SUCC)
    for _, info in ipairs(pokemonList) do
      local pokemonEntity = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapEntity(MapEntityType.MET_ANIMAL, info.uuid)
      if pokemonEntity then
        pokemonEntity:OnConvene()
      else
        warn("[ERROR][PokemonMgr:ConveneAllPokemon] pokemonEntity nil for uuid:", tostring(info.uuid))
      end
    end
  else
    Toast(textRes.Pokemon.CONVENE_FAIL_NONE)
  end
end
def.static("table", "table")._OnNPCService = function(param, context)
  local serviceId = param[1]
  local npcId = param[2]
  local extraInfo = param[3]
  local pokemonEntity = extraInfo and gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapEntity(MapEntityType.MET_ANIMAL, extraInfo.instanceId)
  if pokemonEntity then
    if serviceId == constant.CAnimalConst.CHANGE_NAME_NPC_SERVICE_CFG_ID then
      PokemonMgr._OnNPCServiceRename(pokemonEntity)
    elseif serviceId == constant.CAnimalConst.FREE_NPC_SERVICE_CFG_ID then
      PokemonMgr._OnNPCServiceFree(pokemonEntity)
    elseif serviceId == constant.CAnimalConst.GET_AWARD_NPC_SERVICE_CFG_ID then
      PokemonMgr._OnNPCServiceAward(pokemonEntity)
    elseif serviceId == constant.CAnimalConst.MATE_NPC_SERVICE_CFG_ID then
      PokemonMgr._OnNPCServiceMate(pokemonEntity)
    elseif serviceId == constant.CAnimalConst.GET_MATE_INFO_SERVICE_CFG_ID then
      PokemonMgr._OnNPCServiceDetail(pokemonEntity)
    else
      if serviceId == constant.CAnimalConst.GET_REST_NPC_SERVICE_CFG_ID then
        PokemonMgr._OnNPCServiceRestTime(pokemonEntity)
      else
      end
    end
  else
  end
end
def.static("table")._OnNPCServiceRename = function(pokemonEntity)
  if not PokemonData.Instance():GetPokemonInfo(pokemonEntity.instanceid) then
    Toast(textRes.Pokemon.ERROR_RENAME_NOT_OWN_POKEMON)
  else
    PokemonMgr._OnTalkStarted(pokemonEntity.instanceid)
    local CommonRenamePanel = require("GUI.CommonRenamePanel").Instance()
    CommonRenamePanel:ShowPanel(textRes.Pokemon.ERROR_RENAME_TITLE, true, function(name, module)
      return PokemonMgr._RenamePanelCallback(pokemonEntity.instanceid, name)
    end, self)
  end
end
def.static("userdata", "string", "=>", "boolean")._RenamePanelCallback = function(uuid, name)
  if not PokemonMgr._ValidEnteredName(name) then
    return true
  elseif SensitiveWordsFilter.ContainsSensitiveWord(name) then
    Toast(textRes.Pokemon.ERROR_RENAME_SENSITIVE)
    return true
  elseif SensitiveWordsFilter.ContainsSensitiveWord(name, "Name") then
    Toast(textRes.Pokemon.ERROR_RENAME_UNUSABLE)
    return true
  elseif name == "" then
    Toast(textRes.Pokemon.ERROR_RENAME_EMPTY)
    return true
  else
    PokemonProtocols.SendCAnimalRename(uuid, name)
    return false
  end
end
def.static("string", "=>", "boolean")._ValidEnteredName = function(enteredName)
  local NameValidator = require("Main.Common.NameValidator")
  local isValid, reason, _ = NameValidator.Instance():IsValid(enteredName)
  if isValid then
    return true
  else
    if reason == NameValidator.InvalidReason.TooShort then
      Toast(textRes.Pokemon.ERROR_RENAME_MIN_LEN)
    elseif reason == NameValidator.InvalidReason.TooLong then
      Toast(textRes.Pokemon.ERROR_RENAME_MAX_LEN)
    elseif reason == NameValidator.InvalidReason.NotInSection then
      Toast(textRes.Pokemon.ERROR_RENAME_INVALID)
    end
    return false
  end
end
def.static("table")._OnNPCServiceFree = function(pokemonEntity)
  if not PokemonData.Instance():GetPokemonInfo(pokemonEntity.instanceid) then
    Toast(textRes.Pokemon.ERROR_FREE_NOT_OWN_POKEMON)
  else
    PokemonMgr._OnTalkStarted(pokemonEntity.instanceid)
    local avatar = {}
    avatar.iconId = PokemonUtils.GetPokemonHeadByInst(pokemonEntity.instanceid)
    avatar.line1 = PokemonUtils.GetPokemonNameByInst(pokemonEntity.instanceid)
    avatar.line2 = string.format(textRes.Pokemon.POKEMON_STAR, PokemonUtils.GetPokemonStarByInst(pokemonEntity.instanceid))
    local CaptchaConfirmDlg = require("GUI.CaptchaConfirmDlg")
    CaptchaConfirmDlg.ShowConfirm(textRes.Pokemon.FREE_DESC, "", textRes.Pokemon.FREE_CONFIRM, avatar, function(s)
      if s == 1 then
        PokemonProtocols.SendCAnimalFree(pokemonEntity.instanceid)
      end
    end, nil)
  end
end
def.static("table")._OnNPCServiceAward = function(pokemonEntity)
  if not PokemonData.Instance():GetPokemonInfo(pokemonEntity.instanceid) then
    Toast(textRes.Pokemon.ERROR_AWARD_NOT_OWN_POKEMON)
  elseif pokemonEntity:HasAward() then
    PokemonProtocols.SendCGetAward(pokemonEntity.instanceid)
  else
    Toast(textRes.Pokemon.ERROR_AWARD_NOT_EXIST)
  end
end
def.static("table")._OnNPCServiceMate = function(pokemonEntity)
  if PokemonData.Instance():GetPokemonInfo(pokemonEntity.instanceid) then
    Toast(textRes.Pokemon.ERROR_MATE_OWN_POKEMON)
  elseif pokemonEntity:GetLifeStage() == PokemonEntity.LifeStageEnum.ADULT then
    local PokemonMateListPanel = require("Main.Pokemon.ui.PokemonMateListPanel")
    PokemonMateListPanel.ShowPanel(pokemonEntity)
  else
    Toast(textRes.Pokemon.POKEMON_MATE_FAIL_CD)
  end
end
def.static("table")._OnNPCServiceDetail = function(pokemonEntity)
  if pokemonEntity:GetLifeStage() ~= PokemonEntity.LifeStageEnum.EGG then
    local pokemonInfo = PokemonData.Instance():GetPokemonInfo(pokemonEntity.instanceid)
    if pokemonInfo then
      PokemonProtocols.SendCGetAnimalMates(pokemonEntity.instanceid)
    else
      Toast(textRes.Pokemon.ERROR_DETAIL_NOT_OWN_POKEMON)
    end
  else
    Toast(textRes.Pokemon.ERROR_DETAIL_EGG)
  end
end
def.static("table")._OnNPCServiceRestTime = function(pokemonEntity)
  if pokemonEntity:GetLifeStage() == PokemonEntity.LifeStageEnum.COOLDOWN then
    local restTime = pokemonEntity:GetMateRestTime()
    local toastStr = string.format(textRes.Pokemon.POKEMON_REST_TIME, PokemonUtils.GetRestTimeString(restTime))
    Toast(toastStr)
  else
    Toast(textRes.Pokemon.POKEMON_RESTTIME_WRONG_LIFG_STAGE)
  end
end
def.method("=>", "table").GetTarget = function(self)
  return self._targetPokemonEntity
end
def.method("table")._SetTarget = function(self, targetEntity)
  if targetEntity and targetEntity.type == MapEntityType.MET_ANIMAL then
    self._targetPokemonEntity = targetEntity
  elseif nil == targetEntity then
    warn("[ERROR][PokemonMgr:_SetTarget] _SetTarget failed! targetEntity nil.")
  else
    warn("[ERROR][PokemonMgr:_SetTarget] targetEntity.type ~= MapEntityType.MET_ANIMAL! targetEntity.type:", targetEntity.type)
  end
end
def.method()._ClearTarget = function(self)
  self._targetPokemonEntity = nil
end
PokemonMgr.Commit()
return PokemonMgr
