local MODULE_NAME = (...)
local Lplus = require("Lplus")
local PartnerYuanShenMgr = Lplus.Class(MODULE_NAME)
local def = PartnerYuanShenMgr.define
local PartnerInterface = require("Main.partner.PartnerInterface")
local MathHelper = require("Common.MathHelper")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
def.field("table").m_posInfos = nil
def.field("table").m_positionProperties = nil
def.field("table").m_concernedItems = nil
def.field("boolean").m_bLastNotify = false
def.field("table").m_upgradeSimpleCache = nil
def.field("table").m_upgradeNeedCache = nil
local instance
def.static("=>", PartnerYuanShenMgr).Instance = function()
  if instance == nil then
    instance = PartnerYuanShenMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.partneryuanshen.SSyncPartnerYuanshenInfo", PartnerYuanShenMgr.OnSSyncPartnerYuanshenInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.partneryuanshen.SAttachPartnerSuccess", PartnerYuanShenMgr.OnSAttachPartnerSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.partneryuanshen.SImproveSuccess", PartnerYuanShenMgr.OnSImproveSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.partneryuanshen.SImproveFail", PartnerYuanShenMgr.OnSImproveFail)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PartnerYuanShenMgr.OnItemChange, self)
  Event.RegisterEventWithContext(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, PartnerYuanShenMgr.OnFunctionOpenInit, self)
  Event.RegisterEventWithContext(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, PartnerYuanShenMgr.OnFunctionOpenChange, self)
  Event.RegisterEventWithContext(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, PartnerYuanShenMgr.OnHeroRoleLevelUp, self)
end
def.method("=>", "boolean").IsFeatureOpen = function(self)
  local heroProp = _G.GetHeroProp()
  local openLevel = _G.constant.CPartnerYuanshenConsts.OPEN_LEVEL
  if heroProp and openLevel > heroProp.level then
    return false
  end
  local featureType = Feature.TYPE_PARTNER_YUANSHEN
  local isOpen = _G.IsFeatureOpen(featureType)
  return isOpen
end
def.method("=>", "boolean").HasNotify = function(self)
  local function hasNotifyInner(...)
    if not self:IsFeatureOpen() then
      return false
    end
    if not LuaPlayerPrefs.HasRoleKey("KNOW_PARTNER_YUAN_SHEN_OPEN") then
      return true
    end
    if self:IsTopLevelYuanShenCanUpgrade10Times() then
      return true
    end
    return false
  end
  local bNotify = hasNotifyInner()
  self.m_bLastNotify = bNotify
  return bNotify
end
def.method("=>", "boolean").HasPreYuanShenCanBeUpgradeByItem = function(self)
  local posInfos = self:GetAllYuanShenPosInfos()
  for pos, v in pairs(posInfos) do
    if self:IsYuanShenEverUpgrade(pos) and self:IsYuanShenCanBeUpgradeByItem(pos, 1) then
      return true
    end
  end
  return false
end
def.method("number", "number", "=>", "boolean").IsYuanShenCanBeUpgradeByItem = function(self, position, upgradeLevel)
  local posInfo = self:GetAdvanceYuanShenPosInfo(position)
  if posInfo == nil then
    return false
  end
  if posInfo.level >= posInfo.maxLevel and posInfo.property == posInfo.maxProperty then
    return false
  end
  local needInfo = self:GetCurYuanshenUpgradeNeedEx(position, upgradeLevel)
  local itemFilterCfg = ItemUtils.GetItemFilterCfg(needInfo.itemSiftId)
  local haveNum, needNum = 0, needInfo.itemNum
  if itemFilterCfg then
    self.m_concernedItems = self.m_concernedItems or {}
    for i, v in ipairs(itemFilterCfg.siftCfgs) do
      local count = ItemModule.Instance():GetItemCountById(v.idvalue)
      haveNum = haveNum + count
      self.m_concernedItems[v.idvalue] = count
    end
  end
  if needNum > haveNum then
    return false
  end
  return true
end
def.method("number", "=>", "boolean").IsYuanShenEverUpgrade = function(self, position)
  local posInfo = self:GetYuanShenPosInfo(position)
  if posInfo.level == 1 and posInfo.property == 0 then
    return false
  end
  return true
end
def.method("=>", "boolean").IsTopLevelYuanShenCanUpgrade10Times = function(self)
  local poses = self:GetTopLevelYuanShenPoses()
  local pos = next(poses)
  return self:IsYuanShenCanBeUpgradeByItem(pos, 10)
end
def.method("=>", "table").GetTopLevelYuanShenPoses = function(self)
  local posInfos = self:GetAllYuanShenPosInfos()
  local topLevelPosInfo
  local poses = {}
  for position, v in pairs(posInfos) do
    if topLevelPosInfo == nil or topLevelPosInfo.level < v.level or topLevelPosInfo.level == v.level and topLevelPosInfo.property < v.property then
      topLevelPosInfo = v
      poses = {position}
    elseif topLevelPosInfo.level == v.level and topLevelPosInfo.property == v.property then
      table.insert(poses, position)
    end
  end
  return poses
end
def.method("number", "=>", "boolean").IsYuanShenHasNotify = function(self, position)
  if not self:IsTopLevelYuanShen(position) then
    return false
  end
  if not self:IsYuanShenCanBeUpgradeByItem(position, 10) then
    return false
  end
  return true
end
def.method("number", "=>", "boolean").IsTopLevelYuanShen = function(self, position)
  local poses = self:GetTopLevelYuanShenPoses()
  for i, pos in ipairs(poses) do
    if pos == position then
      return true
    end
  end
  return false
end
def.method().MarkYuanShenOpenAsKnow = function(self)
  if LuaPlayerPrefs.HasRoleKey("PARTNER_YUAN_SHEN_OP_RECORD") then
    return
  end
  LuaPlayerPrefs.SetRoleInt("KNOW_PARTNER_YUAN_SHEN_OPEN", 1)
  LuaPlayerPrefs.Save()
  Event.DispatchEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_NotifyChange, nil)
end
def.method().CheckNotify = function(self)
  local bLastNotify = self.m_bLastNotify
  local bNotify = self:HasNotify()
  if bLastNotify ~= bNotify then
    Event.DispatchEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_NotifyChange, nil)
  end
end
def.method("=>", "table").GetAllYuanShens = function(self)
  local posInfos = self:GetAllYuanShenPosInfos()
  local yuanShens = {}
  for position, v in pairs(posInfos) do
    local yuanShenInfo = {}
    yuanShenInfo.position = position
    yuanShenInfo.level = v.level - 1
    yuanShenInfo.partnerId = v.partnerId
    local upgradeCfg = self:GetYuanShenUpgradeSimpleCfg(position)
    local propertyNum = upgradeCfg.propertyNum
    if v.property == propertyNum then
      yuanShenInfo.level = yuanShenInfo.level + 1
    end
    yuanShenInfo.fightValue = self:CalcYuanShengFightValue(position)
    yuanShens[position] = yuanShenInfo
  end
  return yuanShens
end
def.method("=>", "table").GetYuanShenPartners = function(self)
  local partnerInterface = PartnerInterface.Instance()
  local partnerCfgsList = partnerInterface:GetPartnerCfgsList()
  local partners = {}
  for i, v in ipairs(partnerCfgsList) do
    if partnerInterface:HasThePartner(v.id) then
      table.insert(partners, clone(v))
    end
  end
  return partners
end
def.method("number", "=>", "number").GetPartnerIdByYuanShen = function(self, position)
  local posInfos = self:GetAllYuanShenPosInfos()
  local posInfo = posInfos[position]
  if posInfo == nil then
    return 0
  end
  return posInfo.partnerId
end
def.method("number", "=>", "number").GetYuanShenByPartnerId = function(self, partnerId)
  local posInfos = self:GetAllYuanShenPosInfos()
  for k, v in pairs(posInfos) do
    if v.partnerId == partnerId then
      return v.position
    end
  end
  return 0
end
def.method("number", "=>", "table").GetYuanShenProperties = function(self, position)
  local posInfos = self:GetAllYuanShenPosInfos()
  local posInfo = posInfos[position]
  if posInfo == nil then
    return {}
  end
  if self.m_positionProperties and self.m_positionProperties[position] then
    return self.m_positionProperties[position]
  end
  local properties = {}
  local upgradeCfg = PartnerInterface.GetPartnerYuanShenUpgradeCfg(position)
  local sampleImprove = upgradeCfg.levelImproves[1]
  local propertyNum = #sampleImprove.propertyTypes
  local function setPropertyInfo(i, propertyInfo, levelImprove, level)
    if levelImprove then
      propertyInfo.type = levelImprove.propertyTypes[i]
      propertyInfo.ratio = levelImprove.propertyRatios[i] / 100
      propertyInfo.colorId = levelImprove.frameColor
    else
      propertyInfo.type = sampleImprove.propertyTypes[i]
      propertyInfo.ratio = 0
      propertyInfo.colorId = 0
    end
    propertyInfo.index = i
    propertyInfo.level = level
  end
  local posLevel = posInfo.level
  local levelImprove = upgradeCfg.levelImproves[posLevel]
  for i = 1, posInfo.property do
    local propertyInfo = {}
    setPropertyInfo(i, propertyInfo, levelImprove, posLevel)
    table.insert(properties, propertyInfo)
  end
  posLevel = posInfo.level - 1
  levelImprove = upgradeCfg.levelImproves[posLevel]
  for i = posInfo.property + 1, propertyNum do
    local propertyInfo = {}
    setPropertyInfo(i, propertyInfo, levelImprove, posLevel)
    table.insert(properties, propertyInfo)
  end
  self.m_positionProperties = self.m_positionProperties or {}
  self.m_positionProperties[position] = properties
  return properties
end
def.method("number", "=>", "table").GetYuanShenPropertiesByPartnerId = function(self, partnerId)
  if not self:IsFeatureOpen() then
    return {}
  end
  local position = self:GetYuanShenByPartnerId(partnerId)
  if position == 0 then
    return {}
  end
  return self:GetYuanShenProperties(position)
end
def.method("=>", "table").GetAllYuanShenPosInfos = function(self)
  if self.m_posInfos == nil then
    self.m_posInfos = {}
    local allPositions = PartnerInterface.GetAllYuanShenPositions()
    for i, pos in ipairs(allPositions) do
      self.m_posInfos[pos] = {
        position = pos,
        level = 1,
        property = 0,
        partnerId = 0
      }
    end
  end
  return self.m_posInfos
end
def.method("number", "=>", "table").GetYuanShenPosInfo = function(self, position)
  local posInfos = self:GetAllYuanShenPosInfos()
  return posInfos[position]
end
def.method("number", "=>", "table").GetAdvanceYuanShenPosInfo = function(self, position)
  local posInfo = self:GetYuanShenPosInfo(position)
  if posInfo == nil then
    return nil
  end
  if posInfo.maxLevel == nil then
    local upgradeCfg = self:GetYuanShenUpgradeSimpleCfg(position)
    local propertyNum = upgradeCfg.propertyNum
    local maxLevel = upgradeCfg.maxLevel
    posInfo.maxLevel = maxLevel
    posInfo.maxProperty = propertyNum
  end
  return posInfo
end
def.method("number", "=>", "table").GetYuanShenPosDisplayInfo = function(self, position)
  local posInfo = self:GetYuanShenPosInfo(position)
  local upgradeCfg = self:GetYuanShenUpgradeSimpleCfg(position)
  local propertyNum = upgradeCfg.propertyNum
  local displayInfo = {}
  displayInfo.partnerId = posInfo.partnerId
  displayInfo.property = posInfo.property
  displayInfo.level = posInfo.level - 1
  if posInfo.property == propertyNum then
    displayInfo.level = displayInfo.level + 1
    displayInfo.property = 0
  end
  return displayInfo
end
def.method("number", "=>", "table").GetCurYuanshenUpgradeNeed = function(self, position)
  return self:GetCurYuanshenUpgradeNeedEx(position, 1)
end
def.method("number", "number", "=>", "table").GetCurYuanshenUpgradeNeedEx = function(self, position, upgradeLevel)
  self.m_upgradeNeedCache = self.m_upgradeNeedCache or {}
  self.m_upgradeNeedCache[position] = self.m_upgradeNeedCache[position] or {}
  local posUpgradeCache = self.m_upgradeNeedCache[position]
  local posInfo = self:GetYuanShenPosInfo(position)
  if posUpgradeCache.level ~= posInfo.level or posUpgradeCache.property ~= posInfo.property then
    posUpgradeCache.needInfos = {}
  end
  if posUpgradeCache.needInfos[upgradeLevel] == nil then
    local upgradeCfg = PartnerInterface.GetPartnerYuanShenUpgradeCfg(position)
    local sampleImprove = upgradeCfg.levelImproves[1]
    upgradeCfg.propertyNum = #sampleImprove.propertyTypes
    local posLevel = posInfo.level
    local propertyNum = upgradeCfg.propertyNum
    local needInfo
    for i = 1, upgradeLevel do
      local propertyIndex = posInfo.property + i - 1
      local level = posLevel + math.floor(propertyIndex / propertyNum)
      local levelImprove = upgradeCfg.levelImproves[level]
      if levelImprove == nil then
        break
      end
      if needInfo == nil then
        needInfo = {}
        needInfo.itemSiftId = levelImprove.improveRequiredItemSiftId
        needInfo.itemNum = levelImprove.improveRequiredItemNum
        needInfo.upgradeLevel = 1
      else
        needInfo.itemNum = needInfo.itemNum + levelImprove.improveRequiredItemNum
        needInfo.upgradeLevel = needInfo.upgradeLevel + 1
      end
    end
    posUpgradeCache.level = posInfo.level
    posUpgradeCache.property = posInfo.property
    posUpgradeCache.needInfos[upgradeLevel] = needInfo or false
  end
  return posUpgradeCache.needInfos[upgradeLevel] or nil
end
def.method("number", "=>", "boolean").IsYuanShenReachMaxLevel = function(self, position)
  local posInfo = self:GetAdvanceYuanShenPosInfo(position)
  if posInfo.level >= posInfo.maxLevel and posInfo.property == posInfo.maxProperty then
    return true
  end
  return false
end
def.method("number", "=>", "number").CalcYuanShengFightValue = function(self, position)
  local totalLevel = 0
  local properties = self:GetYuanShenProperties(position)
  for i, v in ipairs(properties) do
    totalLevel = totalLevel + v.level
  end
  local FIGHT_SCORE_FACTOR = _G.constant.CPartnerYuanshenConsts.FIGHT_SCORE_FACTOR
  local fightValue = MathHelper.Floor(FIGHT_SCORE_FACTOR * totalLevel / 10000)
  return fightValue
end
def.method("table", "number", "=>", "table").UpgradeYuanShenLevel = function(self, posInfo, propertyLevel)
  local advancePosInfo = self:GetAdvanceYuanShenPosInfo(posInfo.position)
  posInfo.property = posInfo.property + propertyLevel
  local carryLevel = math.floor((posInfo.property - 1) / advancePosInfo.maxProperty)
  posInfo.level = posInfo.level + carryLevel
  posInfo.property = (posInfo.property - 1) % advancePosInfo.maxProperty + 1
  if posInfo.level > advancePosInfo.maxLevel then
    posInfo.level = advancePosInfo.maxLevel
    posInfo.property = advancePosInfo.maxProperty
  end
  return posInfo
end
def.method("number", "=>", "table").GetYuanShenUpgradeSimpleCfg = function(self, position)
  if self.m_upgradeSimpleCache == nil then
    self.m_upgradeSimpleCache = {}
  end
  local upgradeCfg = self.m_upgradeSimpleCache[position]
  if upgradeCfg == nil then
    upgradeCfg = PartnerInterface.GetPartnerYuanShenUpgradeCfg(position)
    if upgradeCfg == nil then
      return nil
    end
    local sampleImprove = upgradeCfg.levelImproves[1]
    upgradeCfg.propertyNum = #sampleImprove.propertyTypes
    upgradeCfg.maxLevel = #upgradeCfg.levelImproves
    upgradeCfg.levelImproves = nil
    self.m_upgradeSimpleCache[position] = upgradeCfg
  end
  return upgradeCfg
end
def.method().ClearCache = function(self)
  self.m_upgradeSimpleCache = nil
  self.m_upgradeNeedCache = nil
end
def.method().Reset = function(self)
  self:ClearCache()
  self.m_posInfos = nil
  self.m_positionProperties = nil
  self.m_concernedItems = nil
  self.m_bLastNotify = false
end
def.method("number", "number").SetYuanShenPartner = function(self, position, partnerId)
  local p = require("netio.protocol.mzm.gsp.partneryuanshen.CAttachPartnerReq").new(position, partnerId)
  gmodule.network.sendProtocol(p)
end
def.method("number").UnsetYuanShenPartner = function(self, position)
  local p = require("netio.protocol.mzm.gsp.partneryuanshen.CAttachPartnerReq").new(position, 0)
  gmodule.network.sendProtocol(p)
end
def.method("number", "number").UpgradeYuanShenWithItem = function(self, position, level)
  local p = require("netio.protocol.mzm.gsp.partneryuanshen.CImproveWithItemReq").new(position, level)
  gmodule.network.sendProtocol(p)
end
def.method("number", "number").UpgradeYuanShenWithYuanBao = function(self, position, level)
  local ItemModule = require("Main.Item.ItemModule")
  local current_yuanbao = ItemModule.Instance():GetAllYuanBao()
  local p = require("netio.protocol.mzm.gsp.partneryuanshen.CImproveWithYuanbaoReq").new(position, current_yuanbao, level)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSSyncPartnerYuanshenInfo = function(p)
  local self = instance
  self.m_posInfos = self:GetAllYuanShenPosInfos()
  for pos, v in pairs(p.position_info_map) do
    self.m_posInfos[pos] = {
      position = pos,
      level = v.level,
      property = v.property,
      partnerId = v.attached_partner_id
    }
  end
  self.m_positionProperties = nil
  self:CheckNotify()
end
def.static("table").OnSAttachPartnerSuccess = function(p)
  local self = instance
  local posInfo = self:GetYuanShenPosInfo(p.position)
  local lastPartnerId = posInfo.partnerId
  posInfo.partnerId = p.partner_id
  Event.DispatchEvent(ModuleId.PARTNER, gmodule.notifyId.partner.YuanShenPartnerChange, {
    position = p.position,
    partnerId = p.partner_id
  })
  local positionCfg = PartnerInterface.GetPartnerYuanShenPositionCfg(p.position)
  local positionName = positionCfg and positionCfg.name
  if posInfo.partnerId ~= 0 then
    local partnerCfg = PartnerInterface.Instance():GetPartnerCfgById(posInfo.partnerId)
    local text = textRes.Partner.YuanShen[5]:format(partnerCfg.name, positionName)
    Toast(text)
  else
    local partnerCfg = PartnerInterface.Instance():GetPartnerCfgById(lastPartnerId)
    local text = textRes.Partner.YuanShen[6]:format(partnerCfg.name, positionName)
    Toast(text)
  end
end
def.static("table").OnSImproveSuccess = function(p)
  local self = instance
  local posInfo = self:GetYuanShenPosInfo(p.position)
  local lastPosInfo = clone(posInfo)
  posInfo.level = p.level
  posInfo.property = p.property
  if self.m_positionProperties then
    self.m_positionProperties[p.position] = nil
  end
  Event.DispatchEvent(ModuleId.PARTNER, gmodule.notifyId.partner.YuanShenUpgradeSuccess, {lastPosInfo = lastPosInfo, posInfo = posInfo})
end
def.static("table").OnSImproveFail = function(p)
  Event.DispatchEvent(ModuleId.PARTNER, gmodule.notifyId.partner.YuanShenUpgradeFail, nil)
  local text = textRes.Partner.YuanShen.SImproveFail[p.retcode]
  if text == nil then
    text = textRes.Partner.YuanShen.SImproveFail.UNKNOW:format(p.retcode)
  end
  Toast(text)
end
def.method("table").OnItemChange = function(self, params)
  if self.m_concernedItems == nil then
    return
  end
  for itemId, lastNum in pairs(self.m_concernedItems) do
    local count = ItemModule.Instance():GetItemCountById(itemId)
    if count ~= lastNum then
      self:CheckNotify()
      break
    end
  end
end
def.method("table").OnFunctionOpenInit = function(self, params)
  self:CheckNotify()
end
def.method("table").OnFunctionOpenChange = function(self, params)
  if params and params.feature == Feature.TYPE_PARTNER_YUANSHEN then
    self:CheckNotify()
  end
end
def.method("table").OnHeroRoleLevelUp = function(self, params)
  local openLevel = _G.constant.CPartnerYuanshenConsts.OPEN_LEVEL
  local lastLevel = params.lastLevel
  local level = params.level
  if openLevel > lastLevel and openLevel <= level then
    self:CheckNotify()
  end
end
return PartnerYuanShenMgr.Commit()
