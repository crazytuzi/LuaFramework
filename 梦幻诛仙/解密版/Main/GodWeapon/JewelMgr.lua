local Lplus = require("Lplus")
local JewelMgr = Lplus.Class("JewelMgr")
local def = JewelMgr.define
local instance
local JewelProtocols = require("Main.GodWeapon.Jewel.JewelProtocols")
local JewelData = require("Main.GodWeapon.Jewel.data.JewelData")
local JewelUtils = require("Main.GodWeapon.Jewel.JewelUtils")
local ItemModule = require("Main.Item.ItemModule")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
def.field(JewelData)._data = nil
def.field("number")._iRedDotState = 0
def.const("number").COMPOUND_NEED_NUM = 2
def.static("=>", JewelMgr).Instance = function(self)
  if instance == nil then
    instance = JewelMgr()
    instance._data = JewelData()
  end
  return instance
end
def.method().Init = function(self)
  local Cls = JewelMgr
  JewelProtocols.Instance():Init()
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, JewelMgr.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, JewelMgr.OnFeatureInit)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, JewelMgr.OnLeaveWorld)
end
def.method("=>", "table").GetJewelItems = function(self)
  return self._data:GetAllItems()
end
def.static("=>", "boolean").IsFeatureOpen = function()
  local featureOpenModule = FeatureOpenListModule.Instance()
  local bFeatureOpen = featureOpenModule:CheckFeatureOpen(Feature.TYPE_SUPER_EQUIPMENT_JEWEL)
  return bFeatureOpen
end
def.static("=>", "boolean").IsJewelBagFeatureOpen = function()
  local featureOpenModule = FeatureOpenListModule.Instance()
  local bFeatureOpen = featureOpenModule:CheckFeatureOpen(Feature.TYPE_SUPER_EQUIPMENT_JEWEL_BAG)
  return bFeatureOpen
end
def.static("=>", "boolean").IsAutoCompoundFeatureOpen = function()
  local featureOpenModule = FeatureOpenListModule.Instance()
  local bFeatureOpen = featureOpenModule:CheckFeatureOpen(Feature.TYPE_SUPER_EQUIPMENT_JEWEL_AUTO_COMPOSE)
  return bFeatureOpen
end
def.static("=>", JewelData).GetData = function()
  local self = JewelMgr.Instance()
  return self._data
end
def.static("number", "=>", "userdata").GetMoneyNumByType = function(mtype)
  if mtype == MoneyType.YUANBAO then
    return ItemModule.Instance():GetAllYuanBao() or Int64.new(0)
  else
    if mtype == MoneyType.SILVER then
      mtype = ItemModule.MONEY_TYPE_SILVER
    elseif mtype == MoneyType.GOLD then
      mtype = ItemModule.MONEY_TYPE_GOLD
    elseif mtype == MoneyType.GOLD_INGOT then
      mtype = ItemModule.MONEY_TYPE_GOLD_INGOT
    end
    return ItemModule.Instance():GetMoney(mtype) or Int64.new(0)
  end
end
def.static("number", "boolean").GotoBuyMoney = function(mtype, bconfirm)
  if mtype == MoneyType.YUANBAO then
    _G.GotoBuyYuanbao()
  elseif mtype == MoneyType.GOLD then
    _G.GoToBuyGold(bconfirm)
  elseif mtype == MoneyType.SILVER then
    _G.GoToBuySilver(bconfirm)
  elseif mtype == MoneyType.GOLD_INGOT then
    _G.GoToBuyGoldIngot(bconfirm)
  end
end
def.static("table", "=>", "boolean", "table").CanToCompound = function(jewelBasic)
  local ownItemsCount = 0
  if 0 < jewelBasic.nxtLvNeedItemId then
    ownItemsCount = ItemModule.Instance():GetItemCountById(jewelBasic.nxtLvNeedItemId)
  end
  local moneyType = jewelBasic.nxtLvNeedMoneyType
  local moneyNum = jewelBasic.nxtLvNeedMoneyNum
  local itemNum = jewelBasic.nxtLvNeedItemNum
  local ownMoney = JewelMgr.GetMoneyNumByType(moneyType)
  if Int64.lt(ownMoney, moneyNum) then
    return false, {moneyType = moneyType}
  end
  if ownItemsCount < itemNum then
    return false, {
      itemId = jewelBasic.nxtLvNeedItemId
    }
  end
  return true, nil
end
def.static("=>", "boolean").IsShowRedDot = function()
  local self = JewelMgr.Instance()
  self:_chckRedDot()
  return self._iRedDotState == 1
end
def.method("=>", "boolean")._chckRedDot = function(self)
  local preState = self._iRedDotState
  local equipList = JewelMgr.GetData():GetHeroGodWeapons()
  for _, equipInfo in ipairs(equipList) do
    if JewelMgr.CheckEquipJewelReddot(equipInfo) then
      self._iRedDotState = 1
      return true
    end
  end
  self._iRedDotState = 0
  return false
end
def.static("table", "=>", "boolean").CheckEquipJewelReddot = function(equipInfo)
  if equipInfo == nil then
    return false
  end
  local stageCfg = require("Main.GodWeapon.BreakOut.data.BreakOutData").Instance():GetStageCfg(equipInfo.godWeaponStage)
  local bHas2EmbedSlot = false
  for i = 1, stageCfg.gemSlotNum do
    if equipInfo.jewelMap[i] ~= nil then
      local bCanLvUp, _ = JewelMgr.CanJewelLvUp(equipInfo, i)
      if bCanLvUp then
        return true
      end
    else
      bHas2EmbedSlot = true
    end
  end
  if bHas2EmbedSlot then
    local numJewleToEmbed = #(JewelMgr.GetData():GetBagJewelsByEquipType(equipInfo.wearPos) or {})
    return numJewleToEmbed > 0
  end
  return false
end
local BreakOutData = require("Main.GodWeapon.BreakOut.data.BreakOutData")
def.static("table", "number", "=>", "boolean").CanJewelLvUp = function(equipInfo, slotIdx)
  local stageCfg = BreakOutData.Instance():GetStageCfg(equipInfo and equipInfo.godWeaponStage or 1)
  local jewelId = 0
  if equipInfo ~= nil then
    jewelId = equipInfo.jewelMap[slotIdx] and equipInfo.jewelMap[slotIdx].jewelCfgId or 0
    local jewelBasic = JewelUtils.GetJewelItemByItemId(jewelId, false)
    local bCanLvUp, _ = JewelMgr.CanJewelLvUpEx(jewelId)
    return bCanLvUp and jewelBasic.level < stageCfg.maxGemLevel
  end
  return false
end
def.static("number", "=>", "boolean", "table").CanJewelLvUpEx = function(jewelCfgId)
  local mapCostItems = {}
  mapCostItems.jewels = {}
  mapCostItems.items = {}
  mapCostItems.moneys = {}
  mapCostItems.itemNotEnough = false
  mapCostItems.moneyNotEnough = false
  mapCostItems.jewelNotEnough = false
  local bCanLvUp = JewelMgr.CaculateCostItems(jewelCfgId, 1, mapCostItems)
  return bCanLvUp, mapCostItems
end
def.static("number", "number", "table", "=>", "boolean").CaculateCostItems = function(jewelCfgId, needNum, mapCostItems)
  local owndJewelNum = ItemModule.Instance():GetItemCountById(jewelCfgId)
  local jewelBasicCfg = JewelUtils.GetJewelItemByItemId(jewelCfgId, false)
  if jewelBasicCfg == nil then
    return false
  end
  if needNum <= owndJewelNum then
    return JewelMgr._getCostItems(jewelBasicCfg, mapCostItems, needNum, owndJewelNum)
  else
    local mergeFromItemId = JewelUtils.GetCompoundFromCfgId(jewelCfgId)
    if mergeFromItemId == 0 then
      mapCostItems.jewelNotEnough = true
      return false
    end
    local needJewelNum = (needNum - owndJewelNum) * JewelMgr.COMPOUND_NEED_NUM
    if JewelMgr.CaculateCostItems(mergeFromItemId, needJewelNum, mapCostItems) then
      return JewelMgr._getCostItems(jewelBasicCfg, mapCostItems, needNum, owndJewelNum)
    end
  end
  return false
end
def.static("table", "table", "number", "number", "=>", "boolean")._getCostItems = function(jewelBasicCfg, mapCostItems, needNum, owndItemNum)
  local jewels = mapCostItems.jewels
  local jewelId = jewelBasicCfg.itemId
  local iCompoundNum = math.floor(needNum / JewelMgr.COMPOUND_NEED_NUM)
  if iCompoundNum < 1 then
    iCompoundNum = 1
  end
  local costJewelNum = math.min(needNum, owndItemNum)
  jewels[jewelId] = jewels[jewelId] and jewels[jewelId] + costJewelNum or costJewelNum
  if jewelBasicCfg.nxtLvNeedItemId > 0 then
    local needItemId = jewelBasicCfg.nxtLvNeedItemId
    local needItemNum = jewelBasicCfg.nxtLvNeedItemNum * iCompoundNum
    local owndItemNum = ItemModule.Instance():GetItemCountById(needItemId)
    local mapItems = mapCostItems.items
    mapItems[needItemId] = mapItems[needItemId] and mapItems[needItemId] + needItemNum or needItemNum
    if owndItemNum < mapItems[needItemId] then
      mapCostItems.itemNotEnough = true
      return false
    end
  end
  local moneyType, needMoneyNum = jewelBasicCfg.nxtLvNeedMoneyType, jewelBasicCfg.nxtLvNeedMoneyNum * iCompoundNum
  local owndMoney = JewelMgr.GetMoneyNumByType(moneyType)
  local mapMoney = mapCostItems.moneys
  mapMoney[moneyType] = mapMoney[moneyType] and mapMoney[moneyType] + needMoneyNum or needMoneyNum
  if Int64.lt(owndMoney, mapMoney[moneyType]) then
    mapCostItems.moneyNotEnough = true
    return false
  end
  return true
end
def.static("table", "table").OnFeatureOpenChange = function(p, c)
  if p.feature == Feature.TYPE_SUPER_EQUIPMENT_JEWEL then
    Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.JewelFeatureChange, nil)
    Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.GOD_WEAPON_FEATURE_CHANGE, nil)
  elseif p.feature == Feature.TYPE_SUPER_EQUIPMENT_JEWEL_BAG then
    Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.JEWEL_BAG_FEATURE_CHG, nil)
  elseif p.feature == Feature.TYPE_SUPER_EQUIPMENT_JEWEL_AUTO_COMPOSE then
    Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.JEWEL_AUTOCOMPOUND_FEATURE_CHG, nil)
  end
end
def.static("table", "table").OnFeatureInit = function(p, c)
end
def.static("table", "table").OnJewelBagChange = function(p, c)
  local items = ItemModule.Instance():GetItemsByBagId(ItemModule.GOD_WEAPON_JEWEL_BAG)
  local self = JewelMgr.Instance()
  self._data:SetBagItems(items)
  if self:_chckRedDot() then
    Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.JEWEL_REDNOTICE_CHANGE, nil)
  end
end
def.static("table", "table").OnLeaveWorld = function(p, c)
  local self = JewelMgr.Instance()
  self._data = JewelData()
end
return JewelMgr.Commit()
