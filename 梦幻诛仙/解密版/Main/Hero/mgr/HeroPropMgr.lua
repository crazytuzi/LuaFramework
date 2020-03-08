local Lplus = require("Lplus")
local HeroPropMgr = Lplus.Class("HeroPropMgr")
local HeroProp = require("Main.Hero.data.HeroProp")
local HeroSecondProp = require("Main.Hero.data.HeroSecondProp")
local HeroExtraProp = require("Main.Hero.data.HeroExtraProp")
local HeroUtility = require("Main.Hero.HeroUtility")
local HeroEnergyMgr = require("Main.Hero.mgr.HeroEnergyMgr")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
local ECGame = Lplus.ForwardDeclare("ECGame")
local def = HeroPropMgr.define
def.const("number").MAX_EXP = 999999999
def.const("string").NEW_APPELLATION_KEY = "HERO_NEW_APPELLATION"
def.const("string").NEW_TITLE_KEY = "HERO_NEW_TITLE"
def.field(HeroProp).heroProp = nil
def.field(HeroProp).lastHeroProp = nil
def.field(HeroProp).retainProp = nil
def.field("string").newName = ""
def.field("number").schemeSwitchTimes = 0
def.field("number")._maxAnger = -1
def.field("boolean").isPropInited = false
def.field("boolean").hasNotify = false
def.field("boolean").hasNewAppellation = false
def.field("boolean").hasNewTitle = false
def.field("boolean").hasShituNotify = false
local instance
def.static("=>", HeroPropMgr).Instance = function()
  if instance == nil then
    instance = HeroPropMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_MODULE_RESET, HeroPropMgr.OnReset)
  Event.RegisterEvent(ModuleId.TITLE, gmodule.notifyId.title.OwnAppellationChanged, HeroPropMgr.OwnAppellationChanged)
  Event.RegisterEvent(ModuleId.TITLE, gmodule.notifyId.title.OwnTitleChanged, HeroPropMgr.OwnTitleChanged)
  Event.RegisterEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Red_Point_Info_Change, HeroPropMgr.OwnAvatarChange)
end
def.method("table").SetHeroProp = function(self, data)
  local prop = data
  self:SetLastHeroProp()
  if self.heroProp == nil then
    if self.retainProp == nil then
      self.heroProp = HeroProp()
    else
      self.heroProp = self.retainProp
    end
  end
  self.heroProp:RawSet(data)
  self.schemeSwitchTimes = data.todayActivityCount
  self.heroProp.nextLevelExp = HeroPropMgr.GetNextLevelExp(prop.level)
  ECGame.Instance():setRoleInfo(self.heroProp.id, self.heroProp.name, self.heroProp.level)
  if not self.isPropInited then
    self.isPropInited = true
    Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_PROP_INIT, nil)
  end
end
def.method().SetLastHeroProp = function(self)
  if self.heroProp == nil then
    self.lastHeroProp = self.heroProp
  else
    if self.lastHeroProp == nil then
      self.lastHeroProp = HeroProp()
    end
    self.lastHeroProp:Copy(self.heroProp)
  end
end
def.method("=>", "table").GetHeroProp = function(self)
  if self.heroProp == nil then
    return self.retainProp
  end
  return self.heroProp
end
def.static("number", "=>", "number").GetNextLevelExp = function(curLevel)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ROLE_LEVEL_UP_CFG, curLevel + 1)
  local nextexp
  if record ~= nil then
    nextexp = record:GetIntValue("needExp")
  else
    nextexp = HeroPropMgr.MAX_EXP
  end
  return nextexp
end
def.method("=>", "number").GetRoleMaxAnger = function(self)
  if self._maxAnger ~= -1 then
    return self._maxAnger
  end
  local maxAnger = HeroUtility.Instance():GetRoleCommonConsts("ANGER_LIMIT") or 0
  self._maxAnger = maxAnger
  return maxAnger
end
def.method("=>", "boolean").CanAssignProp = function(self)
  if self.heroProp == nil then
    return false
  end
  local HeroAssignPropMgr = Lplus.ForwardDeclare("HeroAssignPointMgr")
  local index = HeroAssignPropMgr.Instance():GetEnabledSchemeIndex()
  return HeroAssignPropMgr.Instance():GetUnusedPotentialPointAmount(index) > 0
end
def.method("=>", "boolean").NeedAssignProp = function(self)
  if self.heroProp == nil then
    return false
  end
  local HeroAssignPropMgr = Lplus.ForwardDeclare("HeroAssignPointMgr")
  local index = HeroAssignPropMgr.Instance():GetEnabledSchemeIndex()
  local scheme = HeroAssignPropMgr.Instance():GetAssignPointScheme(index)
  if scheme.isEnableAutoAssign then
    return false
  end
  return HeroAssignPropMgr.Instance():GetUnusedPotentialPointAmount(index) > 0
end
def.method("number", "=>", "number").GetRoleMaxEnergy = function(self, curLevel)
  return HeroEnergyMgr.Instance():GetRoleMaxEnergy(curLevel)
end
def.method("=>", "boolean").IsEnergyFull = function(self)
  local energy = self.heroProp.energy
  local maxEnergy = self.heroProp:GetMaxEnergy()
  return energy >= maxEnergy
end
def.method("=>", "boolean").IsEnergyNearlyFull = function(self)
  local energy = self.heroProp.energy
  local maxEnergy = self.heroProp:GetMaxEnergy()
  local rate = HeroEnergyMgr.Instance():GetEnergyNearlyFullRate()
  if energy < maxEnergy and energy >= maxEnergy * rate then
    return true
  end
  return false
end
def.method("=>", "boolean").IsEnergyStorageFull = function(self)
  local energy = self.heroProp.energy
  local maxEnergy = self.heroProp:GetMaxEnergy()
  local rate = HeroEnergyMgr.Instance():GetEnergyMaxAmountRate()
  local storageLimit = require("Common.MathHelper").Floor(maxEnergy * rate)
  if energy >= storageLimit then
    return true
  end
  return false
end
def.method("=>", "boolean").HasNotify = function(self)
  if self:HasNewAppellation() then
    self.hasNotify = true
  elseif self:HasNewTitle() then
    self.hasNotify = true
  elseif self:IsEnergyFull() then
    self.hasNotify = true
  elseif self:HasShituNotify() then
    self.hasNotify = true
  else
    local avatarInterface = require("Main.Avatar.AvatarInterface").Instance()
    if avatarInterface:isAvatarNotify() then
      self.hasNotify = true
    else
      local TurnedCardInterface = require("Main.TurnedCard.TurnedCardInterface")
      if TurnedCardInterface.Instance():isShowTurnedCardRedPoint() then
        self.hasNotify = true
      else
        self.hasNotify = false
      end
    end
  end
  return self.hasNotify
end
def.method().CheckNotify = function(self)
  local last = self.hasNotify
  Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_PROP_NOTIFY_UPDATE, {
    last = last,
    cur = self.hasNotify
  })
end
def.method("=>", "boolean").HasNewAppellation = function(self)
  return self.hasNewAppellation
end
def.method("number").SetNewAppellation = function(self, id)
  if id > 0 then
    self.hasNewAppellation = true
  else
    self.hasNewAppellation = false
  end
  self:CheckNotify()
end
def.method("=>", "boolean").HasNewTitle = function(self)
  return self.hasNewTitle
end
def.method("number").SetNewTitle = function(self, id)
  if id > 0 then
    self.hasNewTitle = true
  else
    self.hasNewTitle = false
  end
  self:CheckNotify()
end
def.method("=>", "boolean").HasShituNotify = function(self)
  return self.hasShituNotify
end
def.method().SetShituNotify = function(self)
  local shituUIMgr = require("Main.Shitu.ShituUIMgr").Instance()
  if shituUIMgr:HasNotify() then
    self.hasShituNotify = true
  else
    self.hasShituNotify = false
  end
  self:CheckNotify()
end
def.method("string", "table").Rename = function(self, newName, extraParams)
  self.newName = newName
  local itemId = HeroUtility.Instance():GetRoleCommonConsts("RENAME_ITEM_TYPE_ID")
  local ItemModule = require("Main.Item.ItemModule")
  local yuanBaoAmount = ItemModule.Instance():GetAllYuanBao()
  local renameItemNum = ItemModule.Instance():GetItemCountById(itemId)
  local intIsUseYuanBao = extraParams.isYuanBaoBuZu == true and 1 or 0
  self:C2S_Rename(self.newName, {
    [1] = yuanBaoAmount,
    [2] = Int64.new(renameItemNum)
  }, intIsUseYuanBao)
end
def.method("string").UpdateHeroName = function(self, newName)
  if self.newName == "" then
    return
  end
  self.heroProp.name = self.newName
  gmodule.moduleMgr:GetModule(ModuleId.LOGIN):SaveLoginInfo()
  Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.SYNC_HERO_PROP, nil)
end
def.method().QueryPropChangeEvent = function(self)
  if self.lastHeroProp == nil then
    return
  end
  self:QueryLevelUpEvent()
  self:QuerySecondPropChangeEvent()
  self:QueryFightValueChangeEvent()
end
def.method().QueryLevelUpEvent = function(self)
  if self.heroProp.level > self.lastHeroProp.level then
    TraceHelper.trace("LevelAchieved", {
      price = self.heroProp.level,
      level = self.heroProp.level
    })
    printInfo(string.format("Level up %d --> %d", self.lastHeroProp.level, self.heroProp.level))
    Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, {
      lastLevel = self.lastHeroProp.level,
      level = self.heroProp.level
    })
  elseif self.heroProp.exp ~= self.lastHeroProp.exp then
    Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_EXP_CHANGED, {
      lastExp = self.lastHeroProp.exp,
      exp = self.heroProp.exp
    })
  end
end
def.method().QuerySecondPropChangeEvent = function(self)
  local changedProp = self:GetChangedSecondProp()
  if changedProp.secondProp:IsZero() then
    return
  end
  local filteredProp = self:FilterChangedProp(changedProp)
  Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_SECOND_PROP_CHANGED, filteredProp)
end
def.method().QueryFightValueChangeEvent = function(self)
  if self.heroProp.fightValue ~= self.lastHeroProp.fightValue then
    Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_FIGHT_VALUE_CHANGED, {
      lastFightValue = self.lastHeroProp.fightValue,
      fightValue = self.heroProp.fightValue
    })
  end
end
def.method("=>", "table").GetChangedSecondProp = function(self)
  local changedProp = {
    secondProp = HeroSecondProp()
  }
  changedProp.secondProp:Add(self.heroProp.secondProp)
  changedProp.secondProp:Sub(self.lastHeroProp.secondProp)
  local sealHit = self.heroProp.propMap[PropertyType.SEAL_HIT]
  local lastSealHit = self.lastHeroProp.propMap[PropertyType.SEAL_HIT]
  changedProp.sealHit = sealHit - lastSealHit
  return changedProp
end
def.method("table", "=>", "table").FilterChangedProp = function(self, changedProp)
  local filteredProp = {}
  local increasedProp = {}
  local decreasedProp = {}
  for i, attrName in ipairs(HeroSecondProp.attrNameList) do
    if attrName ~= "maxMp" then
      local value = changedProp.secondProp[attrName]
      if value > 0 then
        table.insert(increasedProp, {key = attrName, value = value})
      elseif value < 0 then
        table.insert(decreasedProp, {key = attrName, value = value})
      end
    end
  end
  local pair = {
    key = "sealHit",
    value = changedProp.sealHit
  }
  if 0 < changedProp.sealHit then
    table.insert(increasedProp, pair)
  elseif 0 > changedProp.sealHit then
    table.insert(increasedProp, pair)
  end
  filteredProp.increasedProp = increasedProp
  filteredProp.decreasedProp = decreasedProp
  return filteredProp
end
def.method("number").SetHeroEnergy = function(self, energy)
  if self.heroProp == nil then
    return
  end
  local lastEnergy = self.heroProp.energy
  if self.lastHeroProp then
    self.lastHeroProp.energy = lastEnergy
  end
  self.heroProp.energy = energy
  if lastEnergy ~= energy then
    Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_CHANGED, {energy, lastEnergy})
    self:CheckNotify()
  end
  if lastEnergy > self.heroProp.energy then
    return
  end
  local maxEnergy = self.heroProp:GetMaxEnergy()
  if energy >= maxEnergy then
    Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_IS_FULL, nil)
  elseif self:IsEnergyNearlyFull() then
    Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_NEARLY_FULL, nil)
  end
end
def.method("string", "table", "number").C2S_Rename = function(self, newName, roleState, isUseYuanBao)
  print("netio.protocol.mzm.gsp.role.CRenameReq", newName, roleState[1], roleState[2], isUseYuanBao)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.role.CRenameReq").new(newName, isUseYuanBao, roleState))
end
def.static("table", "table").OnReset = function(params, context)
  local self = instance
  self.retainProp = self.heroProp
  self.heroProp = nil
  self.lastHeroProp = nil
  self.isPropInited = false
  if _G.leaveWorldReason ~= _G.LeaveWorldReason.RECONNECT then
    self.retainProp = nil
    self.hasNewAppellation = false
    self.hasNewTitle = false
  end
end
def.static("table", "table").OwnAppellationChanged = function(params, context)
  local id = params[1] or 0
  instance:SetNewAppellation(id)
  warn("~~~~~~~OwnAppellationChanged", id)
end
def.static("table", "table").OwnTitleChanged = function(params, context)
  local id = params[1] or 0
  instance:SetNewTitle(id)
  warn("~~~~~~~OwnTitleChanged", id)
end
def.static("table", "table").OwnAvatarChange = function(p1, p2)
  if instance then
    instance:CheckNotify()
  end
end
HeroPropMgr.Commit()
return HeroPropMgr
