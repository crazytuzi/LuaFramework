local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local FabaoSpiritModule = Lplus.Extend(ModuleBase, "FabaoSpiritModule")
local instance
local def = FabaoSpiritModule.define
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local FabaoSpiritUtils = require("Main.FabaoSpirit.FabaoSpiritUtils")
local Protocols = require("Main.FabaoSpirit.FabaoSpiritProtocols")
def.field("boolean")._bActiceRedPt = false
def.field("boolean")._bFeatureOpen = false
def.field("table")._ownedLQInfos = nil
def.field("table")._tblLQLvUp = nil
def.field("number")._equipLQClassId = 0
def.static("=>", FabaoSpiritModule).Instance = function()
  if instance == nil then
    instance = FabaoSpiritModule()
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  Protocols.Init()
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, FabaoSpiritModule.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, FabaoSpiritModule.OnFeatureInit)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, FabaoSpiritModule.OnHeroLvUp)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, FabaoSpiritModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.FABAO_DISPLAY_CHANGE, FabaoSpiritModule.OnDisplayFabaoChange)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, FabaoSpiritModule.OnItemChange)
end
def.static("=>", "boolean").CheckLQRedNotice = function()
  local self = FabaoSpiritModule.Instance()
  return self._bActiceRedPt
end
def.static("=>", "boolean").CheckFeatureOpen = function()
  local self = FabaoSpiritModule.Instance()
  return self._bFeatureOpen
end
def.static("boolean").SetRetPtActive = function(bActive)
  local self = FabaoSpiritModule.Instance()
  self._bActiceRedPt = bActive
  Event.DispatchEvent(ModuleId.FABAO_SPIRIT, gmodule.notifyId.FabaoSpirit.NoticeChange, nil)
end
def.static("=>", "boolean").IsFeatureOpen = function()
  local featureOpenModule = FeatureOpenListModule.Instance()
  local bFeatureOpen = featureOpenModule:CheckFeatureOpen(Feature.TYPE_FABAOLINGQI)
  return bFeatureOpen
end
def.static("=>", "table").GetOwnedLQInfos = function()
  if FabaoSpiritModule.Instance()._ownedLQInfos == nil then
    FabaoSpiritModule.Instance()._ownedLQInfos = {}
  end
  return FabaoSpiritModule.Instance()._ownedLQInfos
end
def.static("=>", "table").GetOwnedLQInfosList = function()
  local retData = {}
  local ownedLQInfos = FabaoSpiritModule.Instance()._ownedLQInfos
  if ownedLQInfos == nil then
    warn("===> empty")
    return retData
  end
  for clsId, tblInfo in pairs(ownedLQInfos) do
    local data = {}
    data.class_id = clsId
    data.expire_time = tblInfo.expire_time or 0
    data.level = tblInfo.level
    data.upgrade_exp = tblInfo.upgrade_exp or 0
    data.properties = tblInfo.properties
    data.tgNew = tblInfo.tgNew
    table.insert(retData, data)
  end
  return retData
end
def.static("number", "boolean").SetTagNew = function(clsId, bNew)
  local tblOwnedLQInfos = FabaoSpiritModule.GetOwnedLQInfos()
  if tblOwnedLQInfos[clsId] ~= nil then
    tblOwnedLQInfos[clsId].tgNew = bNew
  end
end
def.static("=>", "number").CountOwnedLQ = function()
  local count = 0
  for clsId, _ in pairs(FabaoSpiritModule.Instance()._ownedLQInfos or {}) do
    count = count + 1
  end
  return count
end
def.static("=>", "number").GetEquipedLQClsId = function()
  local self = FabaoSpiritModule.Instance()
  return self._equipLQClassId
end
def.static("number").SetEquipedLQClsId = function(clsId)
  local self = FabaoSpiritModule.Instance()
  self._equipLQClassId = clsId
end
def.static("number").FillProperties = function(clsId)
  local LQInfo = FabaoSpiritModule.Instance()._ownedLQInfos[clsId]
  local LQClsCfg = FabaoSpiritUtils.GetLQClsCfgByClsId(clsId)
  local lv = 1
  if #LQClsCfg.arrCfgId ~= 1 then
    lv = LQInfo.level
  end
  local propCfg = FabaoSpiritUtils.GetFabaoLQPropCfgById(LQClsCfg.arrCfgId[lv])
  for i = 1, #propCfg.arrPropValues do
    local prop = propCfg.arrPropValues[i]
    LQInfo.properties[prop.propType] = prop.initVal
  end
end
def.static("number").RmvLQByClsId = function(clsId)
  FabaoSpiritModule.Instance()._ownedLQInfos[clsId] = nil
  Event.DispatchEvent(ModuleId.FABAO_SPIRIT, gmodule.notifyId.FabaoSpirit.OwndLQChange, nil)
end
def.static("number", "=>", "table").GetOwndLQInfoByItemId = function(itemId)
  local LQItemCfg = FabaoSpiritUtils.GetItemCfgByItemId(itemId)
  if LQItemCfg == nil then
    return nil
  end
  local LQBasicCfg = FabaoSpiritUtils.GetFabaoLQCfg(LQItemCfg.LQCfgId)
  local ownedLQInfos = FabaoSpiritModule.GetOwnedLQInfos()
  local retData = {}
  retData.LQInfo = ownedLQInfos[LQBasicCfg.classId]
  if retData.LQInfo == nil then
    return nil
  end
  retData.LQInfo.class_id = LQBasicCfg.classId
  retData.itemCfg = LQItemCfg
  return retData
end
def.static("table", "table").OnFeatureOpenChange = function(p, c)
  if p.feature == Feature.TYPE_FABAOLINGQI then
    FabaoSpiritModule._doCheckFeatureOpen()
    Event.DispatchEvent(ModuleId.FABAO_SPIRIT, gmodule.notifyId.FabaoSpirit.FeatureChange, nil)
  end
end
def.static("table", "table").OnFeatureInit = function(p, c)
  FabaoSpiritModule.Instance()._bFeatureOpen = true
  FabaoSpiritModule._doCheckFeatureOpen()
end
def.static("table", "table").OnHeroLvUp = function(p, c)
  FabaoSpiritModule._doCheckFeatureOpen()
end
def.static()._doCheckFeatureOpen = function()
  local heroLv = require("Main.Hero.HeroModule").Instance():GetHeroProp().level
  local self = FabaoSpiritModule.Instance()
  local bPreFeatureOpen = FabaoSpiritModule.CheckFeatureOpen()
  if heroLv >= constant.CFabaoArtifactConsts.OPEN_LEVEL and FabaoSpiritModule.IsFeatureOpen() then
    self._bFeatureOpen = true
    FabaoSpiritModule.GetCanLvUpLQs()
  else
    self._bFeatureOpen = false
  end
  if not bPreFeatureOpen and self._bFeatureOpen then
    FabaoSpiritModule.SetRetPtActive(true)
  end
  Event.DispatchEvent(ModuleId.FABAO_SPIRIT, gmodule.notifyId.FabaoSpirit.FeatureChange, nil)
end
def.static("table", "table").OnLeaveWorld = function(p, c)
  local self = FabaoSpiritModule.Instance()
  self._ownedLQInfos = nil
  FabaoSpiritModule.SetEquipedLQClsId(0)
  self._bActiceRedPt = false
end
def.static("table", "table").OnDisplayFabaoChange = function(p, c)
  local self = FabaoSpiritModule.Instance()
  if p.fabaoType ~= 0 then
    FabaoSpiritModule.SetEquipedLQClsId(0)
  end
end
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local ItemModule = require("Main.Item.ItemModule")
def.static("table", "table").OnItemChange = function(p, c)
  FabaoSpiritModule.GetCanLvUpLQs()
end
def.static().GetCanLvUpLQs = function(self)
  local fabaoSpiritModule = FabaoSpiritModule.Instance()
  fabaoSpiritModule._tblLQLvUp = {}
  local items = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, ItemType.FABAO_ARTIFACT_ITEM)
  local ownedLQInfos = FabaoSpiritModule.GetOwnedLQInfos()
  for _, item in pairs(items) do
    local itemCfg = FabaoSpiritUtils.GetItemCfgByItemId(item.id)
    if itemCfg ~= nil then
      local LQBasicCfg = FabaoSpiritUtils.GetFabaoLQCfg(itemCfg.LQCfgId)
      local LQClsCfg = FabaoSpiritUtils.GetLQClsCfgByClsId(LQBasicCfg.classId)
      fabaoSpiritModule._tblLQLvUp = fabaoSpiritModule._tblLQLvUp or {}
      local clsId = LQBasicCfg.classId
      local ownLQInfo = ownedLQInfos[clsId]
      if ownLQInfo ~= nil and ownLQInfo.expire_time == 0 and LQClsCfg.arrCfgId[ownLQInfo.level + 1] ~= nil then
        fabaoSpiritModule._tblLQLvUp[clsId] = true
        if not FabaoSpiritModule.CheckLQRedNotice() then
          FabaoSpiritModule.SetRetPtActive(true)
        end
      end
    end
  end
  local bShowRedPt = false
  for clsId, _ in pairs(fabaoSpiritModule._tblLQLvUp) do
    bShowRedPt = true
    break
  end
  if not bShowRedPt then
    FabaoSpiritModule.SetRetPtActive(bShowRedPt)
  end
end
def.static("number", "=>", "boolean").CanFabaoSpiritLevelUp = function(clsId)
  local ownedLQInfos = FabaoSpiritModule.GetOwnedLQInfos()
  local ownLQInfo = ownedLQInfos[clsId]
  if ownLQInfo == nil or ownLQInfo.expire_time ~= 0 then
    return false
  end
  local talCanLvUpLQ = FabaoSpiritModule.Instance()._tblLQLvUp
  if talCanLvUpLQ == nil or talCanLvUpLQ[clsId] == nil then
    return false
  end
  return true
end
return FabaoSpiritModule.Commit()
