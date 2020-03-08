local Lplus = require("Lplus")
local CrossBattleInterface = require("Main.CrossBattle.CrossBattleInterface")
local CrossBattleActivityStage = require("netio.protocol.mzm.gsp.crossbattle.CrossBattleActivityStage")
local ItemUtils = require("Main.Item.ItemUtils")
local BreakOutData = require("Main.GodWeapon.BreakOut.data.BreakOutData")
local ItemColor = require("consts.mzm.gsp.item.confbean.Color")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local WearPos = require("consts.mzm.gsp.item.confbean.WearPos")
local EquipUtils = require("Main.Equip.EquipUtils")
local ItemModule = require("Main.Item.ItemModule")
local MallUtility = require("Main.Mall.MallUtility")
local SOccupationEnum = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
local ItemConsumeHelper = require("Main.Item.ItemConsumeHelper")
local SGenderEnum = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
local CurrencyFactory = require("Main.Currency.CurrencyFactory")
local BreakOutUtils = Lplus.Class("BreakOutUtils")
local def = BreakOutUtils.define
def.const("table").BREAKOUT_EQUIP_TYPES = {
  WearPos.WEAPON,
  WearPos.CLOTHES,
  WearPos.HAT,
  WearPos.BELT,
  WearPos.WRISTER,
  WearPos.SHOES
}
def.static("table", "=>", "boolean").IsItemSatisfyGodWeapon = function(itemInfo)
  if nil == itemInfo then
    warn("[ERROR][BreakOutUtils:IsItemSatisfyGodWeapon] itemInfo nil, return false!")
    return false
  end
  local itemBase = ItemUtils.GetItemBase(itemInfo.id)
  if nil == itemBase then
    warn("[ERROR][BreakOutUtils:IsItemSatisfyGodWeapon] return fasle, itemBase nil for itemid:", itemInfo.id)
    return false
  elseif itemBase.itemType ~= ItemType.EQUIP then
    return false
  end
  local equipBase = ItemUtils.GetEquipBase(itemInfo.id)
  if nil == equipBase then
    warn("[ERROR][BreakOutUtils:IsItemSatisfyGodWeapon] return fasle, equipBase nil for itemid:", itemInfo.id)
    return false
  elseif nil == _G.GetHeroProp() then
    warn("[ERROR][BreakOutUtils:IsItemSatisfyGodWeapon] return fasle, _G.GetHeroProp() nil.")
    return false
  elseif not BreakOutUtils.CheckEquipType(equipBase.wearpos) then
    return false
  elseif equipBase.menpai ~= SOccupationEnum.ALL and equipBase.menpai ~= _G.GetHeroProp().occupation then
    return false
  elseif equipBase.sex ~= SGenderEnum.ALL and equipBase.sex ~= _G.GetHeroProp().gender then
    return false
  end
  local godWeaponStage = itemInfo.extraMap[ItemXStoreType.SUPER_EQUIPMENT_STAGE]
  if godWeaponStage and godWeaponStage > 0 then
    return true
  end
  local result = false
  local stage1Cfg = BreakOutData.Instance():GetStageCfg(1)
  if stage1Cfg then
    result = true
    if result then
      result = itemBase.namecolor == ItemColor.ORANGE
      if false == result then
      end
    end
    if result then
      result = itemBase.useLevel >= stage1Cfg.requiredEquipmentLevel
      if false == result then
      end
    end
    if result then
      local strenLevel = itemInfo.extraMap[ItemXStoreType.STRENGTH_LEVEL]
      result = strenLevel and strenLevel >= stage1Cfg.requiredStrengthLevel
      if false == result then
      end
    end
  else
    warn("[ERROR][BreakOutUtils:IsItemSatisfyGodWeapon] stageCfg nil for stage 1!")
    result = false
  end
  return result
end
def.static("number", "=>", "boolean").CheckEquipType = function(type)
  for _, equipType in ipairs(BreakOutUtils.BREAKOUT_EQUIP_TYPES) do
    if equipType == type then
      return true
    end
  end
  return false
end
def.static("table", "boolean", "=>", "boolean").CanEquipStageUp = function(equipInfo, bToast)
  local result = false
  local toast
  if BreakOutUtils.IsItemSatisfyGodWeapon(equipInfo) then
    result = true
    local godWeaponStage = equipInfo.extraMap[ItemXStoreType.SUPER_EQUIPMENT_STAGE]
    if not godWeaponStage or not godWeaponStage then
      godWeaponStage = 0
    end
    local nextStageCfg = BreakOutData.Instance():GetStageCfg(godWeaponStage + 1)
    if nextStageCfg then
      if result then
        if godWeaponStage > 0 then
          if godWeaponStage < 10 then
            local godWeaponLevel = equipInfo.extraMap[ItemXStoreType.SUPER_EQUIPMENT_LEVEL]
            if not godWeaponLevel or not godWeaponLevel then
              godWeaponLevel = 0
            end
            result = godWeaponLevel >= nextStageCfg.requiredLevel
            if not result then
              toast = string.format(textRes.GodWeapon.BreakOut.STAGE_UP_FAIL_LACK_LEVEL, nextStageCfg.requiredLevel)
            end
          else
            result = false
            toast = textRes.GodWeapon.BreakOut.STAGE_UP_FAIL_MAX
          end
        else
          result = true
        end
      end
      if result then
        local strenLevel = EquipUtils.GetEquipStrenLevel(equipInfo.bagId, equipInfo.key)
        result = strenLevel >= nextStageCfg.requiredStrengthLevel
        if not result then
          toast = string.format(textRes.GodWeapon.BreakOut.STAGE_UP_FAIL_LACK_STRENGTH, nextStageCfg.requiredStrengthLevel)
        end
      end
      if result then
        result = _G.GetHeroProp().level >= nextStageCfg.requiredRoleLevel
        if not result then
          toast = string.format(textRes.GodWeapon.BreakOut.STAGE_UP_FAIL_LACK_ROLE_LEVEL, nextStageCfg.requiredRoleLevel)
        end
      end
      if result then
        local serverLevelData = require("Main.Server.ServerModule").Instance():GetServerLevelInfo()
        local serverLevel = serverLevelData.level
        result = serverLevel >= nextStageCfg.requiredServerLevel
        if not result then
          toast = string.format(textRes.GodWeapon.BreakOut.STAGE_UP_FAIL_LACK_SERVER_LEVEL, nextStageCfg.requiredServerLevel)
        end
      end
    else
      result = false
      toast = textRes.GodWeapon.BreakOut.STAGE_UP_FAIL_MAX
    end
  else
    result = false
    toast = textRes.GodWeapon.BreakOut.STAGE_UP_NOT_SATISFIED
  end
  if toast and bToast then
    Toast(toast)
  end
  return result
end
def.static("table", "boolean", "=>", "boolean").CanEquipLevelUp = function(equipInfo, bToast)
  local result = false
  local toast
  if BreakOutUtils.IsItemSatisfyGodWeapon(equipInfo) then
    result = true
    local godWeaponLevel = equipInfo.extraMap[ItemXStoreType.SUPER_EQUIPMENT_LEVEL]
    if not godWeaponLevel or not godWeaponLevel then
      godWeaponLevel = 0
    end
    local equipBase = ItemUtils.GetEquipBase(equipInfo.id)
    local wearPos = equipBase and equipBase.wearpos or -1
    local nextLevelCfg = BreakOutData.Instance():GetLevelCfg(wearPos, godWeaponLevel + 1)
    if nextLevelCfg then
      if result then
        local godWeaponStage = equipInfo.extraMap[ItemXStoreType.SUPER_EQUIPMENT_STAGE]
        if not godWeaponStage or not godWeaponStage then
          godWeaponStage = 0
        end
        result = godWeaponStage >= nextLevelCfg.requiredStage
        if not result then
          toast = string.format(textRes.GodWeapon.BreakOut.LEVEL_UP_FAIL_LACK_STAGE, nextLevelCfg.requiredStage)
        end
      end
      if result then
        local strenLevel = EquipUtils.GetEquipStrenLevel(equipInfo.bagId, equipInfo.key)
        result = strenLevel >= nextLevelCfg.requiredStrengthLevel
        if not result then
          toast = string.format(textRes.GodWeapon.BreakOut.LEVEL_UP_FAIL_LACK_STRENGTH, nextLevelCfg.requiredStrengthLevel)
        end
      end
    else
      result = false
      toast = textRes.GodWeapon.BreakOut.LEVEL_UP_FAIL_MAX
    end
  else
    result = false
    toast = textRes.GodWeapon.BreakOut.LEVEL_UP_NOT_SATISFIED
  end
  if toast and bToast then
    Toast(toast)
  end
  return result
end
def.static("table", "function").GetEquipStageUpYB = function(equipInfo, callback)
  local nextStageCfg = equipInfo and BreakOutData.Instance():GetStageCfg(equipInfo.godWeaponStage + 1) or nil
  local costItemList = nextStageCfg and nextStageCfg.costItems or {}
  local consumedItemMap = equipInfo and equipInfo.stageUpCostMap or {}
  return BreakOutUtils.GetLackItemsCostYB(costItemList, consumedItemMap, callback)
end
def.static("table", "function").GetEquipLevelUpYB = function(equipInfo, callback)
  local nextLevelCfg = equipInfo and BreakOutData.Instance():GetLevelCfg(equipInfo.wearPos, equipInfo.godWeaponLevel + 1) or nil
  local costItemList = nextLevelCfg and nextLevelCfg.costItems or {}
  local consumedItemMap = equipInfo and equipInfo.levelUpCostMap or {}
  return BreakOutUtils.GetLackItemsCostYB(costItemList, consumedItemMap, callback)
end
def.static("table", "table", "function").GetLackItemsCostYB = function(costItemList, consumedItemMap, callback)
  local costYBMap = {}
  if costItemList and #costItemList > 0 then
    local costYB = 0
    for index, item in ipairs(costItemList) do
      ItemConsumeHelper.Instance():GetItemYuanBaoPrice(item.id, function(price)
        costYBMap[item.id] = price
        local bTotal = true
        local totalCostYB = 0
        for index, item in ipairs(costItemList) do
          if nil == costYBMap[item.id] then
            bTotal = false
            break
          else
            local haveCount = ItemModule.Instance():GetItemCountById(item.id)
            local curConsumeNum = consumedItemMap and consumedItemMap[item.id] or 0
            local lackCount = math.max(0, item.num - haveCount - curConsumeNum)
            totalCostYB = totalCostYB + costYBMap[item.id] * lackCount
          end
        end
        if bTotal and callback then
          callback(totalCostYB)
        end
      end)
    end
  else
    warn("[BreakOutUtils:GetLackItemsCostYB] costItemList nil or #costItemList==0, set cost 0!")
    if callback then
      callback(0)
    end
  end
end
def.static("table", "=>", "boolean").IsEquipReadyForLevelUp = function(equipInfo)
  if BreakOutUtils.ShallEquipStageUp(equipInfo) then
    return false
  end
  if not BreakOutUtils.CanEquipLevelUp(equipInfo, false) then
    return false
  end
  local godWeaponLevel = equipInfo.extraMap[ItemXStoreType.SUPER_EQUIPMENT_LEVEL]
  if not godWeaponLevel or not godWeaponLevel then
    godWeaponLevel = 0
  end
  local nextLevelCfg = BreakOutData.Instance():GetLevelCfg(equipInfo.wearPos, godWeaponLevel + 1)
  if nil == nextLevelCfg then
    return false
  end
  local costItemList = nextLevelCfg.costItems
  local consumedItemMap = equipInfo.levelUpCostMap
  local checkResult = BreakOutUtils.CheckCostItems(costItemList, consumedItemMap)
  if checkResult == 1 then
    return true
  else
    return false
  end
end
def.static("table", "=>", "boolean").IsEquipReadyForStageUp = function(equipInfo)
  if not BreakOutUtils.ShallEquipStageUp(equipInfo) then
    return false
  end
  if not BreakOutUtils.CanEquipStageUp(equipInfo, false) then
    return false
  end
  local godWeaponStage = equipInfo.extraMap[ItemXStoreType.SUPER_EQUIPMENT_STAGE]
  if not godWeaponStage or not godWeaponStage then
    godWeaponStage = 0
  end
  local nextStageCfg = BreakOutData.Instance():GetStageCfg(godWeaponStage + 1)
  if nil == nextStageCfg then
    return false
  end
  local costItemList = nextStageCfg.costItems
  local consumedItemMap = equipInfo.stageUpCostMap
  local checkResult = BreakOutUtils.CheckCostItems(costItemList, consumedItemMap)
  if checkResult == 1 then
    return true
  else
    return false
  end
end
def.static("table", "table", "=>", "number").CheckCostItems = function(costItemList, consumedItemMap)
  local result = 0
  if costItemList and #costItemList > 0 then
    for index, item in ipairs(costItemList) do
      local haveCount = ItemModule.Instance():GetItemCountById(item.id)
      local curConsumeNum = consumedItemMap and consumedItemMap[item.id] or 0
      local lackCount = math.max(0, item.num - curConsumeNum)
      if lackCount > 0 then
        if haveCount < lackCount then
          result = -1
          break
        else
          result = 1
        end
      end
    end
  end
  return result
end
def.static("table", "=>", "boolean").ShallEquipStageUp = function(equipInfo)
  if nil == equipInfo then
    warn("[ERROR][BreakOutUtils:ShallEquipStageUp] return false! equipInfo nil.")
    return false
  end
  local godWeaponStage = equipInfo.extraMap[ItemXStoreType.SUPER_EQUIPMENT_STAGE]
  if not godWeaponStage or not godWeaponStage then
    godWeaponStage = 0
  end
  if godWeaponStage <= 0 then
    return true
  elseif godWeaponStage >= 10 then
    return false
  end
  local godWeaponLevel = equipInfo.extraMap[ItemXStoreType.SUPER_EQUIPMENT_LEVEL]
  if not godWeaponLevel or not godWeaponLevel then
    godWeaponLevel = 0
  end
  local stageMaxLevel = BreakOutData.Instance():GetStageMaxLevel(godWeaponStage)
  if godWeaponLevel < stageMaxLevel then
    return false
  else
    return true
  end
end
def.static("table", "number", "table", "=>", "number").GetGodWeaponAttr = function(itemInfo, attrType, equipBase)
  local result = 0
  local godWeaponLevel = itemInfo and itemInfo.extraMap[ItemXStoreType.SUPER_EQUIPMENT_LEVEL] or 0
  if godWeaponLevel > 0 then
    if nil == equipBase then
      equipBase = ItemUtils.GetEquipBase(itemInfo.id)
    end
    if equipBase then
      local curLevelCfg = BreakOutData.Instance():GetLevelCfg(equipBase.wearpos, godWeaponLevel)
      result = curLevelCfg and curLevelCfg.improveCfgs[attrType] or 0
      if not result or not result then
        result = 0
      end
    end
  end
  return result
end
def.static("table", "=>", "boolean").ReachGodWeaponLimit = function(equipInfo)
  if nil == equipInfo then
    warn("[ERROR][BreakOutUtils:ReachGodWeaponLimit] return true! equipInfo nil.")
    return true
  end
  local godWeaponStage = equipInfo.extraMap[ItemXStoreType.SUPER_EQUIPMENT_STAGE]
  if not godWeaponStage or not godWeaponStage then
    godWeaponStage = 0
  end
  if godWeaponStage > 10 then
    return true
  elseif godWeaponStage < 10 then
    return false
  else
    local godWeaponLevel = equipInfo.extraMap[ItemXStoreType.SUPER_EQUIPMENT_LEVEL]
    if not godWeaponLevel or not godWeaponLevel then
      godWeaponLevel = 0
    end
    local stageMaxLevel = BreakOutData.Instance():GetStageMaxLevel(godWeaponStage)
    if godWeaponLevel < stageMaxLevel then
      return false
    else
      return true
    end
  end
end
def.static("number", "boolean").GoToBuyCurrency = function(moneyType, bConfirm)
  local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
  warn("[BreakOutUtils:GoToBuyCurrency] GoToBuyCurrency, moneyType:", moneyType)
  if MoneyType.YUANBAO == moneyType then
    if bConfirm then
      _G.GotoBuyYuanbao()
    else
      local MallPanel = require("Main.Mall.ui.MallPanel")
      require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Pay, 0, 0)
    end
  elseif MoneyType.GOLD == moneyType then
    _G.GoToBuyGold(bConfirm)
  elseif MoneyType.SILVER == moneyType then
    _G.GoToBuySilver(bConfirm)
  elseif MoneyType.GOLD_INGOT == moneyType then
    _G.GoToBuyGoldIngot(bConfirm)
  else
    warn("[ERROR][BreakOutUtils:GoToBuyCurrency] unhandled moneyType:", moneyType)
  end
end
BreakOutUtils.Commit()
return BreakOutUtils
