local Lplus = require("Lplus")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTips = require("Main.Item.ui.ItemTips")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local WearPos = require("consts.mzm.gsp.item.confbean.WearPos")
local PetUtility = require("Main.Pet.PetUtility")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = Lplus.Class("ItemTipsMgr")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local def = ItemTipsMgr.define
local _instance
def.static("=>", ItemTipsMgr).Instance = function()
  if _instance == nil then
    _instance = ItemTipsMgr()
    _instance:InitOperations()
  end
  return _instance
end
def.const("table").Source = {
  Bag = 1,
  Equip = 2,
  Storage = 3,
  StorageBag = 4,
  Other = 5,
  PetItemBag = 6,
  PetItemEquip = 7,
  Access = 8,
  ChatSelf = 9,
  ChatOther = 10,
  Commerce = 11,
  Task = 12,
  PetBasicNode = 13,
  WingsItemBag = 14,
  RecycleLeft = 15,
  RecycleRight = 16,
  FabaoExp = 17,
  TradingArcade = 18,
  TradingArcadeSell = 19,
  FurnitureBag = 20,
  ChildrenItemBag = 21,
  ChildrenPanel = 22,
  ChildrenBag = 23,
  EquipMake = 24,
  JewelBag = 25,
  FabaoBag = 26,
  SpaceDecoPanel = 27,
  TurnedCardBag = 28,
  ManorBag = 29,
  EnergyPanel = 30,
  BrillianceBag = 31,
  ItemLocker = 32,
  ItemLockerPanel = 33,
  DestinyBag = 34,
  DestinyGrid = 35
}
def.const("table").Position = {
  Left = {x = -184, y = 186},
  Right = {x = 184, y = 186},
  Center = {x = 92, y = 186}
}
def.const("table").Color = {
  [1] = "ffffff",
  [2] = "01b35b",
  [3] = "009fd6",
  [4] = "ea01fd",
  [5] = "fe7200",
  [8] = "fe7200",
  ["Title"] = "00ff2a",
  ["Content"] = "00e4ff",
  ["Attr"] = "ffe492",
  ["Yellow"] = "ffe492",
  ["Gold"] = "ffff00",
  ["White"] = "ffffff",
  ["Red"] = "ff0000",
  ["Green"] = "00ff00",
  ["Pink"] = "fda6a6"
}
def.field("table")._bottomOperations = nil
def.field("table")._topOperation = nil
def.field("table")._itemCompare = nil
def.method().InitOperations = function(self)
  self._bottomOperations = {
    require("Main.Item.Operations.OperationUseCake"),
    require("Main.Item.Operations.OperationGiveCake"),
    require("Main.Item.Operations.OperationMooncakeIngredients"),
    require("Main.Item.Operations.OperationUseSpaceDecoration"),
    require("Main.Item.Operations.OperationImprovePartnerYuanShen"),
    require("Main.Item.Operations.OperationChildEquip"),
    require("Main.Item.Operations.OperationChildUnlockSkillItem"),
    require("Main.Item.Operations.OperationChildEquipLevelUp"),
    require("Main.Item.Operations.OperationChildEquipRandomBtn"),
    require("Main.Item.Operations.OperationChildPropItem"),
    require("Main.Item.Operations.OperationChildSkillLevelUpItem"),
    require("Main.Item.Operations.OperationChildEquipUpgrade"),
    require("Main.Item.Operations.OperationChildEquipRandom"),
    require("Main.Item.Operations.OperationChildGrowthItem"),
    require("Main.Item.Operations.OperationChildCharacterItem"),
    require("Main.Item.Operations.OperationUseChildSpecialSkillBook"),
    require("Main.Item.Operations.OperationCompensateYouthChild"),
    require("Main.Item.Operations.OperationBaoKuExchangeItem"),
    require("Main.Item.Operations.OperationLingWu"),
    require("Main.Item.Operations.OperationMagicMark"),
    require("Main.Item.Operations.OperationUseFurnitureItem"),
    require("Main.Item.Operations.OperationEmplaceFurniture"),
    require("Main.Item.Operations.OperationPreviewFurniture"),
    require("Main.Item.Operations.OperationSellFurniture"),
    require("Main.Item.Operations.OperationFurnitureAccess"),
    require("Main.Item.Operations.OperationWingsRoot"),
    require("Main.Item.Operations.OperationWingsExpItem"),
    require("Main.Item.Operations.OperationWingsViewItem"),
    require("Main.Item.Operations.OperationWingsDyeItems"),
    require("Main.Item.Operations.OperationUseLottery"),
    require("Main.Item.Operations.OperationSwitchToPetPanel"),
    require("Main.Item.Operations.OperationSwitchToWingsPanel"),
    require("Main.Item.Operations.OperationUseMoShouFragment"),
    require("Main.Item.Operations.OperationUseShenShouFragment"),
    require("Main.Item.Operations.OperationPetReplaceEquipment"),
    require("Main.Item.Operations.OperationPetEquip"),
    require("Main.Item.Operations.OperationCompositePetEquipment"),
    require("Main.Item.Operations.OperationRefreshPetEquipment"),
    require("Main.Item.Operations.OperationPetAmuletRefresh"),
    require("Main.Item.Operations.OperationPetExp"),
    require("Main.Item.Operations.OperationPetExpandBag"),
    require("Main.Item.Operations.OperationPetUse"),
    require("Main.Item.Operations.OperationPetResetProp"),
    require("Main.Item.Operations.OperationPetUseSkillBook"),
    require("Main.Item.Operations.OperationPetMarkItemUse"),
    require("Main.Item.Operations.OperationUsePetBabyBag"),
    require("Main.Item.Operations.OperationUseDrugOut"),
    require("Main.Item.Operations.OperationRoleExp"),
    require("Main.Item.Operations.OperationRoleResetProp"),
    require("Main.Item.Operations.OperationBaotuUse"),
    require("Main.Item.Operations.OperationYaoCai"),
    require("Main.Item.Operations.OperationXiuLianExp"),
    require("Main.Item.Operations.OperationSupplementNutrition"),
    require("Main.Item.Operations.OperationEquip"),
    require("Main.Item.Operations.OperationEquipBless"),
    require("Main.Item.Operations.OperationUnequip"),
    require("Main.Item.Operations.OperationMoshouStone"),
    require("Main.Item.Operations.OperationEquipSkillResetItem"),
    require("Main.Item.Operations.OperationUseTrumpet"),
    require("Main.Item.Operations.OperationAxes"),
    require("Main.Item.Operations.OperationExchangeFabaoSpirit"),
    require("Main.Item.Operations.OperationImproveLQ"),
    require("Main.Item.Operations.OperationUseJewel"),
    require("Main.Item.Operations.OperationJewelLvUp"),
    require("Main.Item.Operations.OperationUseWuShi"),
    require("Main.Item.Operations.OperationGodWeaponLevelUp"),
    require("Main.Item.Operations.OperationGodWeaponStageUp"),
    require("Main.Item.Operations.OperationUseWuShiFrags"),
    require("Main.Item.Operations.OperationUseRevengeCard"),
    require("Main.Item.Operations.OperationOccupation"),
    require("Main.Item.Operations.OperationChatBubble"),
    require("Main.Item.Operations.OperationMonkeyRunItemUse"),
    require("Main.Item.Operations.OperationUseTurnedCard"),
    require("Main.Item.Operations.OperationUseAircraftItem"),
    require("Main.Item.Operations.OperationUseAircraftDyeItem"),
    require("Main.Item.Operations.OperationShapeShiftItem"),
    require("Main.Item.Operations.OperationUseFormationItem"),
    require("Main.Item.Operations.OperationUseFormationFragment"),
    require("Main.Item.Operations.OperationHangChristmasStockItem"),
    require("Main.Item.Operations.OperationGotoHangChristmasStockItem"),
    require("Main.Item.Operations.OperationDrawPassItem"),
    require("Main.Item.Operations.OperationWearOnFabao"),
    require("Main.Item.Operations.OperationFabaoOff"),
    require("Main.Item.Operations.OperationDrugInFight"),
    require("Main.Item.Operations.OperationFixEquip"),
    require("Main.Item.Operations.OperationCompound"),
    require("Main.Item.Operations.OperationCommonExchange"),
    require("Main.Item.Operations.OperationFumo"),
    require("Main.Item.Operations.OperationExtendBag"),
    require("Main.Item.Operations.OperationFile"),
    require("Main.Item.Operations.OperationVigor"),
    require("Main.Item.Operations.OperationRefreshWing"),
    require("Main.Item.Operations.OperationFireWork"),
    require("Main.Item.Operations.OperationRideItem"),
    require("Main.Item.Operations.OperationQiling"),
    require("Main.Item.Operations.OperationQilingMatrial"),
    require("Main.Item.Operations.OperationEquipEffectReset"),
    require("Main.Item.Operations.OperationMatrial"),
    require("Main.Item.Operations.OperationFuHun"),
    require("Main.Item.Operations.OperationDoublePoint"),
    require("Main.Item.Operations.OperationZhenFaShu"),
    require("Main.Item.Operations.OperationPartnerItemUse"),
    require("Main.Item.Operations.OperationUseMoneyBag"),
    require("Main.Item.Operations.OperationGift"),
    require("Main.Item.Operations.OperationSelectableGift"),
    require("Main.Item.Operations.OperationChainGift"),
    require("Main.Item.Operations.OperationFivePrecious"),
    require("Main.Item.Operations.OperationRoleRename"),
    require("Main.Item.Operations.OperationRideDye"),
    require("Main.Item.Operations.OperationLongJingUse"),
    require("Main.Item.Operations.OperationFlower"),
    require("Main.Item.Operations.OperationFabaoCombine"),
    require("Main.Item.Operations.OperationRoleDyeItemUse"),
    require("Main.Item.Operations.OperationFabaoWashItem"),
    require("Main.Item.Operations.OperationFabaoExpItem"),
    require("Main.Item.Operations.OperationFabaoYuanLingItem"),
    require("Main.Item.Operations.OperationLockHunItemUse"),
    require("Main.Item.Operations.OperationRefreshHunItemUse"),
    require("Main.Item.Operations.OperationWeddingCandie"),
    require("Main.Item.Operations.OperationFireWork"),
    require("Main.Item.Operations.OperationFabaoExpItemUse"),
    require("Main.Item.Operations.OperationJanDanSuipian"),
    require("Main.Item.Operations.OperationFashionUse"),
    require("Main.Item.Operations.OperationXianLvShenYuanUse"),
    require("Main.Item.Operations.OperationMountsStarUp"),
    require("Main.Item.Operations.OperationMountsResetSkill"),
    require("Main.Item.Operations.OperationMountsRankUp"),
    require("Main.Item.Operations.OperationMountsUnlockProtect"),
    require("Main.Item.Operations.OperationCat"),
    require("Main.Item.Operations.OperationUseSnowItem"),
    require("Main.Item.Operations.OperationUsePetExtraModel"),
    require("Main.Item.Operations.OperationChildrenFashion"),
    require("Main.Item.Operations.OperationBreakEquip"),
    require("Main.Item.Operations.OperationUseFoolsDayChest"),
    require("Main.Item.Operations.OperationGivingFoolsDayChest"),
    require("Main.Item.Operations.OperationYZXGItem"),
    require("Main.Item.Operations.OperationUnlockAvatarItem"),
    require("Main.Item.Operations.OperationUseWishItem"),
    require("Main.Item.Operations.OperationUseOracleItem"),
    require("Main.Item.Operations.OperationGreetingCard"),
    require("Main.Item.Operations.OperationLunhuiDrawCard"),
    require("Main.Item.Operations.OperationUnlockAvatarFrameItem"),
    require("Main.Item.Operations.OperationActiveTaskItem"),
    require("Main.Item.Operations.OperationUsePokemonEgg"),
    require("Main.Item.Operations.OperationSweep"),
    require("Main.Item.Operations.OperationSweepFloor"),
    require("Main.Item.Operations.OperationUsePetSoulItem"),
    require("Main.Item.Operations.OperationSell"),
    require("Main.Item.Operations.OperationSellAllToCommerce"),
    require("Main.Item.Operations.OperationSellToCommerce"),
    require("Main.Item.Operations.OperationSellToTradingArcade"),
    require("Main.Item.Operations.OperationPitch"),
    require("Main.Item.Operations.OperationDiscard"),
    require("Main.Item.Operations.OperationMoveToStorage"),
    require("Main.Item.Operations.OperationMoveToBag"),
    require("Main.Item.Operations.OperationFabaoGrow"),
    require("Main.Item.Operations.OperationUseAllItem"),
    require("Main.Item.Operations.OperationCompoundAll"),
    require("Main.Item.Operations.OperationSplit"),
    require("Main.Item.Operations.OperationSplitAll"),
    require("Main.Item.Operations.OperationDecomposeTurnedCard"),
    require("Main.Item.Operations.OperationBatchDecomposeTurnedCard")
  }
  self._topOperation = {
    require("Main.Item.Operations.OperationEquipDetail"),
    require("Main.Item.Operations.OperationWingFabaoDetail"),
    require("Main.Item.Operations.OperationViewItemsFitting"),
    require("Main.Item.Operations.OperationMarketItem")
  }
end
def.method("string", "number", "string", "string", "number", "number", "number", "number", "number", "=>", ItemTips).ShowCustomTip = function(self, title, iconId, type, desc, sourceX, sourceY, sourceW, sourceH, prefer)
  local pos = {
    auto = true,
    sourceX = sourceX,
    sourceY = sourceY,
    sourceW = sourceW,
    sourceH = sourceH,
    prefer = prefer
  }
  local lv = -1
  local Html = string.format("<p align=left valign=middle><font size=22 color=#%s>%s</font></p>", ItemTipsMgr.Color.White, desc)
  local buttomOperations = {}
  local isEquiped = false
  return ItemTips.ShowTip(pos, title, iconId, isEquiped, 0, lv, type, Html, nil, buttomOperations, 0, 0, "", nil, 0)
end
def.method("number", "number", "number", "number", "number", "number", "number", "number", "boolean", "boolean", "=>", ItemTips).ShowWingItemTip = function(self, itemId, level, phase, sourceX, sourceY, sourceW, sourceH, prefer, fixPos, isMine)
  local itemBase = ItemUtils.GetItemBase(itemId)
  local pos
  if fixPos then
    pos = ItemTipsMgr.Position.Right
  else
    pos = {
      auto = true,
      sourceX = sourceX,
      sourceY = sourceY,
      sourceW = sourceW,
      sourceH = sourceH,
      prefer = prefer
    }
  end
  local itemName = self:GetName(nil, itemBase)
  local iconId = itemBase.icon
  local lv = -1
  local equipType = itemBase.itemTypeName
  local description = self:GetWingDescription(itemBase, level, phase)
  local buttomOperations = {}
  if isMine then
    local OpenWingOperation = require("Main.Item.Operations.OperationOpenWingUI")
    local ope = OpenWingOperation()
    buttomOperations = {ope}
  end
  local isEquiped = false
  return ItemTips.ShowTip(pos, itemName, iconId, isEquiped, 0, lv, equipType, description, nil, buttomOperations, 0, 0, "", nil, 0)
end
def.method("table", "number", "number", "boolean", "number", "number", "number", "number", "number", "boolean", "=>", ItemTips).ShowLongJingSpecialTips = function(self, item, fabaoType, longjingPos, onlyShow, sourceX, sourceY, sourceW, sourceH, prefer, fixPos)
  local pos
  if fixPos then
    pos = ItemTipsMgr.Position.Right
  else
    pos = {
      auto = true,
      sourceX = sourceX,
      sourceY = sourceY,
      sourceW = sourceW,
      sourceH = sourceH,
      prefer = prefer
    }
  end
  local longjingId = item.id
  local itemBase = ItemUtils.GetItemBase(longjingId)
  local longjingBase = ItemUtils.GetLongJingItem(longjingId)
  local itemName = self:GetName(nil, itemBase)
  local iconId = itemBase.icon
  local level = longjingBase.lv
  local itemType = itemBase.itemTypeName
  local isEquiped = false
  local UnmountLongjingOpe = require("Main.Item.Operations.OperationUnmountLongjing")
  local LevelUpLongjingOpe = require("Main.Item.Operations.OperationLevelUpLongjing")
  local operations = {}
  if not onlyShow then
    local Ope = UnmountLongjingOpe()
    if Ope:CanDispaly(0, {longjingPos = longjingPos, fabaoType = fabaoType}, itemBase) then
      table.insert(operations, Ope)
    end
    Ope = LevelUpLongjingOpe()
    if Ope:CanDispaly(0, {longjingPos = longjingPos, fabaoType = fabaoType}, itemBase) then
      table.insert(operations, Ope)
    end
  end
  local description = self:GetDescription(item, itemBase) or " "
  return ItemTips.ShowTip(pos, itemName, iconId, isEquiped, 0, level, itemType, description, nil, operations, 0, 0, "", nil, 0)
end
def.method("table", "table", "number", "number", "number", "number", "number", "number", "boolean", "=>", ItemTips).ShowFabaoWearTips = function(self, itemInfo, itemBase, source, sourceX, sourceY, sourceW, sourceH, prefer, fixPos)
  local pos
  if fixPos then
    pos = ItemTipsMgr.Position.Right
  else
    pos = {
      auto = true,
      sourceX = sourceX,
      sourceY = sourceY,
      sourceW = sourceW,
      sourceH = sourceH,
      prefer = prefer
    }
  end
  local itemName = self:GetName(nil, itemBase)
  local iconId = itemBase.icon
  local level = itemInfo.extraMap[ItemXStoreType.FABAO_CUR_LV]
  local itemType = itemBase.itemTypeName
  local isEquiped = true
  local bottomOperations = {}
  local ope
  local OperationFabaoDetail = require("Main.Item.Operations.OperationWingFabaoDetail")
  local OperationWearOffFabao = require("Main.Item.Operations.OperationWearOffFabao")
  ope = OperationWearOffFabao()
  if ope:CanDispaly(source, itemInfo, itemBase) then
    table.insert(bottomOperations, ope)
  end
  local topOperation
  ope = OperationFabaoDetail()
  if ope:CanDispaly(source, itemInfo, itemBase) then
    topOperation = ope
  end
  local description = self:GetDescription(itemInfo, itemBase)
  return ItemTips.ShowTip(pos, itemName, iconId, isEquiped, 0, level, itemType, description, topOperation, bottomOperations, 0, 0, "", {
    itemId = itemBase.itemid
  }, 0)
end
def.method("number", "boolean", "number", "number", "number", "number", "number", "boolean", "=>", ItemTips).ShowFabaoSpecialTip = function(self, fabaoId, forceCannotCompose, sourceX, sourceY, sourceW, sourceH, prefer, fixPos)
  local itemBase = ItemUtils.GetItemBase(fabaoId)
  local fabaoBase = ItemUtils.GetFabaoItem(fabaoId)
  local pos
  if fixPos then
    pos = ItemTipsMgr.Position.Left
  else
    pos = {
      auto = true,
      sourceX = sourceX,
      sourceY = sourceY,
      sourceW = sourceW,
      sourceH = sourceH,
      prefer = prefer
    }
  end
  local itemName = self:GetName(nil, itemBase)
  local iconId = itemBase.icon
  local FabaoUtils = require("Main.Fabao.FabaoUtils")
  local level = FabaoUtils.GetMaxFabaoLevelByClassId(fabaoBase.classId)
  local itemType = itemBase.itemTypeName
  local description = self:GetFabaoSpecialDescription(itemBase, fabaoBase)
  local bottomOperations = {}
  if not forceCannotCompose then
    local OperationFabaoCompose = require("Main.Item.Operations.OperationFabaoCompose")
    local ope = OperationFabaoCompose()
    if ope:CanDispaly(0, fabaoBase, itemBase) then
      table.insert(bottomOperations, ope)
    end
  end
  local isEquiped = false
  return ItemTips.ShowTip(pos, itemName, iconId, isEquiped, 0, level, itemType, description, nil, bottomOperations, 0, 0, "", nil, 0)
end
def.method("table", "table", "number", "number", "number", "number", "number", "number", "boolean", "=>", ItemTips).ShowFabaoLQWearTips = function(self, itemInfo, itemBase, source, sourceX, sourceY, sourceW, sourceH, prefer, fixPos)
  local pos
  if fixPos then
    pos = ItemTipsMgr.Position.Right
  else
    pos = {
      auto = true,
      sourceX = sourceX,
      sourceY = sourceY,
      sourceW = sourceW,
      sourceH = sourceH,
      prefer = prefer
    }
  end
  local itemName = self:GetName(nil, itemBase)
  local iconId = itemBase.icon
  local level = itemInfo.level
  local itemType = itemBase.itemTypeName
  local isEquiped = true
  if itemInfo.bIsEquip ~= nil then
    isEquiped = itemInfo.bIsEquip
  end
  local bottomOperations = {}
  local topOperation
  local description = self:GetDescription({
    id = itemBase.itemid,
    extraMap = {},
    properties = itemInfo.properties
  }, itemBase)
  return ItemTips.ShowTip(pos, itemName, iconId, isEquiped, 0, level, itemType, description, topOperation, bottomOperations, 0, 0, "", {
    itemId = itemBase.itemid
  }, 0)
end
def.method("table", "number", "number", "number", "number", "number", "boolean", "=>", ItemTips).ShowJewelSpecialTips = function(self, item, sourceX, sourceY, sourceW, sourceH, prefer, fixPos)
  local itemId = item.id
  local itemBase = ItemUtils.GetItemBase(item.id)
  local pos
  if fixPos then
    pos = ItemTipsMgr.Position.Left
  else
    pos = {
      auto = true,
      sourceX = sourceX,
      sourceY = sourceY,
      sourceW = sourceW,
      sourceH = sourceH,
      prefer = prefer
    }
  end
  local itemName = self:GetName(nil, itemBase)
  local iconId = itemBase.icon
  local itemType = itemBase.itemTypeName
  local JewelUtils = require("Main.GodWeapon.Jewel.JewelUtils")
  local jewelBase = JewelUtils.GetJewelItemByItemId(itemId, false)
  local description = self:GetDescription(item, itemBase)
  local bottomOperations = {}
  local OperationJewelLvUp = require("Main.Item.Operations.OperationJewelLvUp")
  local OperationSell = require("Main.Item.Operations.OperationSell")
  local ope
  ope = OperationJewelLvUp()
  if ope:CanDispaly(ItemTipsMgr.Source.Bag, item, itemBase) then
    table.insert(bottomOperations, ope)
  end
  ope = OperationSell()
  if ope:CanDispaly(ItemTipsMgr.Source.Bag, item, itemBase) then
    table.insert(bottomOperations, ope)
  end
  local isEquiped = false
  local level = jewelBase.level
  return ItemTips.ShowTip(pos, itemName, iconId, isEquiped, 0, level, itemType, description, nil, bottomOperations, ItemModule.GOD_WEAPON_JEWEL_BAG, item.itemKey, "", nil, 0)
end
def.method("table", "boolean", "number", "number", "number", "number", "number", "boolean", "=>", ItemTips).ShowGodWeaponJewelTips = function(self, item, bToMount, sourceX, sourceY, sourceW, sourceH, prefer, fixPos)
  local itemId = item.id
  local itemBase = ItemUtils.GetItemBase(itemId)
  local pos
  if fixPos then
    pos = ItemTipsMgr.Position.Left
  else
    pos = {
      auto = true,
      sourceX = sourceX,
      sourceY = sourceY,
      sourceW = sourceW,
      sourceH = sourceH,
      prefer = prefer
    }
  end
  local itemName = self:GetName(nil, itemBase)
  local iconId = itemBase.icon
  local itemType = itemBase.itemTypeName
  local JewelUtils = require("Main.GodWeapon.Jewel.JewelUtils")
  local jewelBase = JewelUtils.GetJewelItemByItemId(itemId, false)
  local description = self:GetDescription(item, itemBase)
  local bottomOperations = {}
  local OperationJewelLvUp = require("Main.Item.Operations.OperationGodweaponJewelLvUp")
  local OperationMount = require("Main.Item.Operations.OperationJewelMount")
  local OperationJewelUnmount = require("Main.Item.Operations.OperationJewelUnmount")
  local ope
  ope = OperationJewelLvUp()
  if ope:CanDispaly(0, item, itemBase) then
    table.insert(bottomOperations, ope)
  end
  ope = OperationMount()
  if bToMount and ope:CanDispaly(ItemTipsMgr.Source.Bag, nil, itemBase) then
    table.insert(bottomOperations, ope)
  end
  ope = OperationJewelUnmount()
  if not bToMount and ope:CanDispaly(ItemTipsMgr.Source.Bag, item, itemBase) then
    table.insert(bottomOperations, ope)
  end
  local isEquiped = not bToMount
  local level = jewelBase.level
  return ItemTips.ShowTip(pos, itemName, iconId, isEquiped, 0, level, itemType, description, nil, bottomOperations, item.bagId, item.itemKey, "", nil, 0)
end
def.method("number", "number", "number", "number", "number", "string", "boolean", "=>", ItemTips).ShowJewelPropTips = function(self, jewelId, srcX, srcY, srcW, srcH, pnlName, bEquiped)
  local pos = {
    auto = true,
    sourceX = srcX,
    sourceY = srcY,
    sourceW = srcW,
    sourceH = srcH,
    prefer = 0
  }
  local itemBase = ItemUtils.GetItemBase(jewelId)
  if itemBase == nil then
    return
  end
  local itemName = self:GetName(nil, itemBase)
  local iconId = itemBase.icon
  local itemType = itemBase.itemTypeName
  local JewelUtils = require("Main.GodWeapon.Jewel.JewelUtils")
  local description = ""
  local jewelBase = JewelUtils.GetJewelItemByItemId(jewelId, false)
  local arrProps = jewelBase.arrProps
  local strTable = {}
  for i = 1, #arrProps do
    local propType = arrProps[i].propType
    local propVal = arrProps[i].propVal
    if propType and 0 ~= propType and propVal then
      local attrName = JewelUtils.GetProName(propType)
      table.insert(strTable, string.format("<font size=20 color=#%s>%s</font>", ItemTipsMgr.Color.Content, textRes.Item[8409]:format(attrName, propVal)))
      table.insert(strTable, "<br/>")
    end
  end
  description = table.concat(strTable)
  local bottomOperations = {}
  local isEquiped = not bToMount
  local level = jewelBase.level
  local tips = ItemTips.ShowTip(pos, itemName, iconId, isEquiped, 0, level, itemType, description, nil, bottomOperations, 0, 0, pnlName, {itemId = jewelId}, 0)
  return tips
end
def.method("number", "number", "number", "number", "number", "number", "boolean", "boolean", "=>", ItemTips).ShowTaskItemTip = function(self, itemId, sourceX, sourceY, sourceW, sourceH, prefer, fixPos, needUse)
  local itemBase = ItemUtils.GetItemBase(itemId)
  local pos
  if fixPos then
    pos = ItemTipsMgr.Position.Left
  else
    pos = {
      auto = true,
      sourceX = sourceX,
      sourceY = sourceY,
      sourceW = sourceW,
      sourceH = sourceH,
      prefer = prefer
    }
  end
  local itemName = self:GetName(nil, itemBase)
  local iconId = itemBase.icon
  local lv = self:GetLevel(itemBase, nil)
  local equipType = itemBase.itemTypeName
  local description = self:GetSimpleDescription(itemBase)
  local buttomOperations = {}
  if needUse then
    local TaskOperation = require("Main.Item.Operations.OperationTaskItemUse")
    local task = TaskOperation()
    buttomOperations = {task}
  end
  local isEquiped = false
  return ItemTips.ShowTip(pos, itemName, iconId, isEquiped, 0, lv, equipType, description, nil, buttomOperations, 0, 0, "", nil, 0)
end
def.method("number", "=>", ItemTips).ShowFashionItemTip = function(self, itemId)
  local itemBase = ItemUtils.GetItemBase(itemId)
  local pos = ItemTipsMgr.Position.Center
  local itemName = self:GetName(nil, itemBase)
  local iconId = itemBase.icon
  local lv = self:GetLevel(itemBase, nil)
  local equipType = itemBase.itemTypeName
  local description = self:GetSimpleDescription(itemBase)
  local OperationAccess = require("Main.Item.Operations.OperationAccess")
  local OperationViewItemsFitting = require("Main.Item.Operations.OperationViewItemsFitting")
  local opAcess = OperationAccess()
  local opView = OperationViewItemsFitting()
  local buttomOperations = {}
  if opAcess:CanDispaly(ItemTipsMgr.Source.Access, nil, itemBase) then
    opAcess.itemId = itemBase.itemid
    table.insert(buttomOperations, opAcess)
  end
  local topOperations
  if opView:CanDispaly(ItemTipsMgr.Source.ChatOther, nil, itemBase) then
    topOperations = opView
  end
  local isEquiped = false
  return ItemTips.ShowTip(pos, itemName, iconId, isEquiped, 0, lv, equipType, description, topOperations, buttomOperations, 0, 0, "", nil, 0)
end
def.method("number", "boolean", "=>", ItemTips).ShowAircraftTip = function(self, itemId, isMine)
  local AircraftData = require("Main.Aircraft.data.AircraftData")
  local itemCfg = AircraftData.Instance():GetAircraftItemCfg(itemId)
  if nil == itemCfg then
    warn("[ERROR][ItemTipsMgr:ShowAircraftTip] aircraftItemCfg nil for itemId:", itemId)
    return
  end
  local aircraftCfg = AircraftData.Instance():GetAircraftCfg(itemCfg.aircraftId)
  if nil == aircraftCfg then
    warn("[ERROR][ItemTipsMgr:ShowAircraftTip] aircraftCfg nil for aircraftId:", itemCfg.aircraftId)
    return
  end
  local itemBase = ItemUtils.GetItemBase(itemId)
  local pos = ItemTipsMgr.Position.Center
  local itemName = self:GetName(nil, itemBase)
  local iconId = itemBase.icon
  local lv = self:GetLevel(itemBase, nil)
  local equipType = textRes.Aircraft.AIRCRAFT_TYPE
  local description = self:GetAircraftDescription(itemBase, aircraftCfg)
  local OperationAccess = require("Main.Item.Operations.OperationAccess")
  local OperationViewItemsFitting = require("Main.Item.Operations.OperationViewItemsFitting")
  local opAcess = OperationAccess()
  local opView = OperationViewItemsFitting()
  local topOperations
  local buttomOperations = {}
  if isMine then
    local OperationOpenAircraftUI = require("Main.Item.Operations.OperationOpenAircraftUI")
    local ope = OperationOpenAircraftUI()
    buttomOperations = {ope}
  end
  local isEquiped = false
  local extInfo = {}
  extInfo.itemId = itemId
  return ItemTips.ShowTip(pos, itemName, iconId, isEquiped, 0, lv, equipType, description, topOperations, buttomOperations, 0, 0, "", extInfo, 0)
end
def.method("number", "number", "number", "number", "number", "number", "boolean", "=>", ItemTips).ShowItemFilterTips = function(self, id, sourceX, sourceY, sourceW, sourceH, prefer, needSource)
  local itemFilter = ItemUtils.GetItemFilterCfg(id)
  local pos = {
    auto = true,
    sourceX = sourceX,
    sourceY = sourceY,
    sourceW = sourceW,
    sourceH = sourceH,
    prefer = prefer
  }
  local itemName = itemFilter.name
  local iconId = itemFilter.icon
  local lv = itemFilter.level
  local equipType = itemFilter.type
  local description = self:GetFilterItemDescription(itemFilter)
  local buttomOperations = {}
  if needSource then
    local OperationSiftAccess = require("Main.Item.Operations.OperationSiftAccess")
    local access = OperationSiftAccess()
    access._siftID = id
    buttomOperations = {access}
  end
  local isEquiped = false
  return ItemTips.ShowTip(pos, itemName, iconId, isEquiped, 0, lv, equipType, description, nil, buttomOperations, 0, 0, "", nil, 0)
end
def.method("number", "number", "number", "number", "number", "number", "string", "boolean", "=>", ItemTips).ShowItemFilterTipsEX = function(self, id, sourceX, sourceY, sourceW, sourceH, prefer, extraInfo, needSource)
  local itemFilter = ItemUtils.GetItemFilterCfg(id)
  local pos = {
    auto = true,
    sourceX = sourceX,
    sourceY = sourceY,
    sourceW = sourceW,
    sourceH = sourceH,
    prefer = prefer
  }
  local itemName = itemFilter.name
  local iconId = itemFilter.icon
  local lv = -1
  local equipType = itemFilter.type
  local description = self:GetFilterItemDescriptionEX(itemFilter, extraInfo)
  local buttomOperations = {}
  if needSource then
    local OperationSiftAccess = require("Main.Item.Operations.OperationSiftAccess")
    local access = OperationSiftAccess()
    access._siftID = id
    buttomOperations = {access}
  end
  local isEquiped = false
  return ItemTips.ShowTip(pos, itemName, iconId, isEquiped, 0, lv, equipType, description, nil, buttomOperations, 0, 0, "", nil, 0)
end
def.method("number", "userdata", "number", "boolean", "=>", ItemTips).ShowBasicTipsWithGO = function(self, itemId, go, prefer, needSource)
  if not go then
    return nil
  end
  local position = go.position
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = go:GetComponent("UIWidget")
  if not widget then
    warn("There is no widget component in :", go.name)
    return nil
  end
  return self:ShowBasicTips(itemId, screenPos.x, screenPos.y, widget.width, widget.height, prefer, needSource)
end
def.method("number", "number", "number", "number", "number", "number", "boolean", "=>", ItemTips).ShowBasicTips = function(self, itemId, sourceX, sourceY, sourceW, sourceH, prefer, needSource)
  local pos = {
    auto = true,
    sourceX = sourceX,
    sourceY = sourceY,
    sourceW = sourceW,
    sourceH = sourceH,
    prefer = prefer
  }
  return self:ShowBasicTipsWithPos(itemId, pos, needSource)
end
def.method("number", "table", "boolean", "=>", ItemTips).ShowBasicTipsWithPos = function(self, itemId, pos, needSource)
  local itemBase = ItemUtils.GetItemBase(itemId)
  if not itemBase then
    warn("Missing the itemBaseInfo :", itemId)
    return nil
  end
  local itemName = self:GetName(nil, itemBase)
  local iconId = itemBase.icon
  local lv = self:GetLevel(itemBase, nil)
  local equipType = itemBase.itemTypeName
  local description = self:GetSimpleDescription(itemBase)
  local buttomOperations = {}
  if needSource then
    local AccessOperation = require("Main.Item.Operations.OperationAccess")
    local access = AccessOperation()
    access.itemId = itemId
    buttomOperations = {access}
  end
  local isEquiped = false
  local extraInfo = {}
  extraInfo.itemId = itemId
  return ItemTips.ShowTip(pos, itemName, iconId, isEquiped, 0, lv, equipType, description, nil, buttomOperations, 0, 0, "", extraInfo, 0)
end
def.method("table", "number", "number", "number", "number", "number", "boolean").ShowMutilItemBasicTips = function(self, itemIds, sourceX, sourceY, sourceW, sourceH, prefer, needSource)
  local pos = {
    auto = true,
    sourceX = sourceX,
    sourceY = sourceY,
    sourceW = sourceW,
    sourceH = sourceH,
    prefer = prefer
  }
  self:ShowMutilItemBasicTipsEx(itemIds, pos, needSource)
end
def.method("table", "table", "boolean").ShowMutilItemBasicTipsEx = function(self, itemIds, pos, needSource)
  if not itemIds[1] then
    return
  end
  local curIndex = 1
  local function ShowNextTips(next)
    curIndex = curIndex + next
    local arrowState = 0
    local itemId = itemIds[curIndex]
    if itemId == nil then
      return
    end
    if curIndex <= 1 and curIndex >= #itemIds then
      arrowState = ItemTips.ArrowState.None
    elseif curIndex <= 1 and curIndex < #itemIds then
      arrowState = ItemTips.ArrowState.Right
    elseif curIndex > 1 and curIndex >= #itemIds then
      arrowState = ItemTips.ArrowState.Left
    else
      arrowState = ItemTips.ArrowState.Both
    end
    local itemBase = ItemUtils.GetItemBase(itemId)
    local itemName = self:GetName(nil, itemBase)
    local iconId = itemBase.icon
    local lv = self:GetLevel(itemBase, nil)
    local equipType = itemBase.itemTypeName
    local description = self:GetSimpleDescription(itemBase)
    local buttomOperations = {}
    if needSource then
      local AccessOperation = require("Main.Item.Operations.OperationAccess")
      local access = AccessOperation()
      access.itemId = itemId
      buttomOperations = {access}
    end
    local isEquiped = false
    local extraInfo = {}
    extraInfo.itemId = itemId
    ItemTips.ShowTipWithArrow(pos, itemName, iconId, isEquiped, 0, lv, equipType, description, nil, buttomOperations, 0, 0, "", arrowState, ShowNextTips, extraInfo)
  end
  ShowNextTips(0)
end
def.method("number", "number", "number", "number", "number", "number", "boolean", "string", "=>", ItemTips).ShowBasicTipsRename = function(self, itemId, sourceX, sourceY, sourceW, sourceH, prefer, needSource, rename)
  local itemBase = ItemUtils.GetItemBase(itemId)
  local pos = {
    auto = true,
    sourceX = sourceX,
    sourceY = sourceY,
    sourceW = sourceW,
    sourceH = sourceH,
    prefer = prefer
  }
  local itemName = self:GetName(nil, itemBase)
  local iconId = itemBase.icon
  local lv = self:GetLevel(itemBase, nil)
  local equipType = itemBase.itemTypeName
  local description = self:GetSimpleDescription(itemBase)
  local buttomOperations = {}
  if needSource then
    local AccessOperation = require("Main.Item.Operations.OperationAccess")
    local access = AccessOperation()
    access.itemId = itemId
    buttomOperations = {access}
  end
  local isEquiped = false
  return ItemTips.ShowTip(pos, itemName, iconId, isEquiped, 0, lv, equipType, description, nil, buttomOperations, 0, 0, rename, nil, 0)
end
def.method("number", "number", "number", "number", "number", "number", "boolean", "string", "=>", ItemTips).ShowBasicTipsAddDesc = function(self, itemId, sourceX, sourceY, sourceW, sourceH, prefer, needSource, additionalDesc)
  local itemBase = ItemUtils.GetItemBase(itemId)
  local pos = {
    auto = true,
    sourceX = sourceX,
    sourceY = sourceY,
    sourceW = sourceW,
    sourceH = sourceH,
    prefer = prefer
  }
  local itemName = self:GetName(nil, itemBase)
  local iconId = itemBase.icon
  local lv = self:GetLevel(itemBase, nil)
  local equipType = itemBase.itemTypeName
  local description = self:GetSimpleDescription(itemBase)
  local buttomOperations = {}
  if needSource then
    local AccessOperation = require("Main.Item.Operations.OperationAccess")
    local access = AccessOperation()
    access.itemId = itemId
    buttomOperations = {access}
  end
  local isEquiped = false
  if additionalDesc ~= "" then
    description = description .. additionalDesc
  end
  return ItemTips.ShowTip(pos, itemName, iconId, isEquiped, 0, lv, equipType, description, nil, buttomOperations, 0, 0, "", nil, 0)
end
def.method("number", "number", "number", "number", "number", "number", "boolean", "string", "=>", ItemTips).ShowBasicTipsEX = function(self, itemId, sourceX, sourceY, sourceW, sourceH, prefer, needSource, extraInfo)
  local itemBase = ItemUtils.GetItemBase(itemId)
  local pos = {
    auto = true,
    sourceX = sourceX,
    sourceY = sourceY,
    sourceW = sourceW,
    sourceH = sourceH,
    prefer = prefer
  }
  local itemName = self:GetName(nil, itemBase)
  local iconId = itemBase.icon
  local lv = self:GetLevel(itemBase, nil)
  local equipType = itemBase.itemTypeName
  local description = self:GetSimpleDescriptionEX(itemBase, extraInfo)
  local buttomOperations = {}
  if needSource then
    local AccessOperation = require("Main.Item.Operations.OperationAccess")
    local access = AccessOperation()
    access.itemId = itemId
    buttomOperations = {access}
  end
  local isEquiped = false
  return ItemTips.ShowTip(pos, itemName, iconId, isEquiped, 0, lv, equipType, description, nil, buttomOperations, 0, 0, "", nil, 0)
end
def.method("table", "number", "number", "number", "userdata", "number", "=>", ItemTips).ShowTipsEx = function(self, item, bagId, itemKey, source, container, prefer)
  local screenPos = WorldPosToScreen(container.position.x, container.position.y)
  local uiWight = container:GetComponent("UIWidget")
  if not uiWight then
    return nil
  end
  return self:ShowTips(item, bagId, itemKey, source, screenPos.x, screenPos.y, uiWight.width, uiWight.height, prefer)
end
def.method("table", "number", "number", "number", "number", "number", "number", "number", "number", "=>", ItemTips).ShowTips = function(self, item, bagId, itemKey, source, sourceX, sourceY, sourceW, sourceH, prefer)
  local itemBase = ItemUtils.GetItemBase(item.id)
  local tip
  local godWeaponStage = item.extraMap[ItemXStoreType.SUPER_EQUIPMENT_STAGE]
  if not godWeaponStage or not godWeaponStage then
    godWeaponStage = 0
  end
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.EQUIP then
    local equipBase = ItemUtils.GetEquipBase(itemBase.itemid)
    local comparekey, itemCompare = ItemModule.Instance():GetItemByPosition(ItemModule.EQUIPBAG, equipBase.wearpos)
    if comparekey ~= -1 then
      self._itemCompare = itemCompare
      tip = self:_showTips(ItemTipsMgr.Position.Right, ItemTipsMgr.Source.Bag, item, itemBase, false, bagId, itemKey, "", godWeaponStage)
      self._itemCompare = item
      local itemCompareBase = ItemUtils.GetItemBase(itemCompare.id)
      local godWeaponStage2 = itemCompare.extraMap[ItemXStoreType.SUPER_EQUIPMENT_STAGE]
      if not godWeaponStage2 or not godWeaponStage2 then
        godWeaponStage2 = 0
      end
      self:_showTips(ItemTipsMgr.Position.Left, ItemTipsMgr.Source.Other, itemCompare, itemCompareBase, true, ItemModule.EQUIPBAG, comparekey, "Compare", godWeaponStage2)
      self._itemCompare = nil
    else
      tip = self:_showTips(ItemTipsMgr.Position.Left, source, item, itemBase, false, bagId, itemKey, "", godWeaponStage)
    end
  elseif source == ItemTipsMgr.Source.ChatOther and itemBase.itemType == ItemType.EQUIP then
    local equipBase = ItemUtils.GetEquipBase(itemBase.itemid)
    local comparekey, itemCompare = ItemModule.Instance():GetItemByPosition(ItemModule.EQUIPBAG, equipBase.wearpos)
    if comparekey ~= -1 then
      self._itemCompare = itemCompare
      tip = self:_showTips(ItemTipsMgr.Position.Right, ItemTipsMgr.Source.Other, item, itemBase, false, 0, 0, "", godWeaponStage)
      self._itemCompare = item
      local itemCompareBase = ItemUtils.GetItemBase(itemCompare.id)
      self:_showTips(ItemTipsMgr.Position.Left, ItemTipsMgr.Source.Other, itemCompare, itemCompareBase, true, ItemModule.EQUIPBAG, comparekey, "Compare", godWeaponStage)
      self._itemCompare = nil
    else
      tip = self:_showTips(ItemTipsMgr.Position.Center, source, item, itemBase, false, 0, 0, "", godWeaponStage)
    end
  elseif source == ItemTipsMgr.Source.FabaoBag and itemBase.itemType == ItemType.FABAO_ITEM then
    local FabaoData = require("Main.Fabao.data.FabaoData")
    local fabaoItemInfo = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
    local fabaoBase = ItemUtils.GetFabaoItem(fabaoItemInfo.id)
    local wearFabao = FabaoData.Instance():GetFabaoByType(fabaoBase.fabaoType)
    if wearFabao then
      self._itemCompare = wearFabao
      tip = self:_showTips(ItemTipsMgr.Position.Right, ItemTipsMgr.Source.FabaoBag, item, itemBase, false, bagId, itemKey, "", godWeaponStage)
      self._itemCompare = nil
      local itemCompareBase = ItemUtils.GetItemBase(wearFabao.id)
      self:_showTips(ItemTipsMgr.Position.Left, ItemTipsMgr.Source.Other, wearFabao, itemCompareBase, true, 0, 0, "Compare", godWeaponStage)
    else
      tip = self:_showTips(ItemTipsMgr.Position.Left, source, item, itemBase, false, bagId, itemKey, "", godWeaponStage)
    end
  elseif source == ItemTipsMgr.Source.ChatOther and itemBase.itemType == ItemType.FABAO_ITEM then
    local displayFabao = require("Main.Fabao.data.FabaoData").Instance():GetCurDisplayFabao()
    if displayFabao and 0 ~= displayFabao.fabaoType and displayFabao.fabaoData then
      local itemCompare = displayFabao.fabaoData
      self._itemCompare = itemCompare
      tip = self:_showTips(ItemTipsMgr.Position.Right, ItemTipsMgr.Source.Other, item, itemBase, false, 0, 0, "", godWeaponStage)
      self._itemCompare = nil
      local itemCompareBase = ItemUtils.GetItemBase(itemCompare.id)
      self:_showTips(ItemTipsMgr.Position.Left, ItemTipsMgr.Source.Other, itemCompare, itemCompareBase, true, 0, 0, "Compare", godWeaponStage)
    else
      tip = self:_showTips(ItemTipsMgr.Position.Center, source, item, itemBase, false, 0, 0, "", godWeaponStage)
    end
  elseif source == ItemTipsMgr.Source.TradingArcade and itemBase.itemType == ItemType.EQUIP then
    local equipBase = ItemUtils.GetEquipBase(itemBase.itemid)
    local comparekey, itemCompare = ItemModule.Instance():GetItemByPosition(ItemModule.EQUIPBAG, equipBase.wearpos)
    if comparekey ~= -1 then
      local itemCompareBase = ItemUtils.GetItemBase(itemCompare.id)
      self:_showTips(ItemTipsMgr.Position.Left, ItemTipsMgr.Source.Other, itemCompare, itemCompareBase, true, 0, 0, "Compare", godWeaponStage)
      self._itemCompare = itemCompare
      tip = self:_showTips(ItemTipsMgr.Position.Right, source, item, itemBase, false, bagId, itemKey, "", godWeaponStage)
      self._itemCompare = nil
    else
      tip = self:_showTips(ItemTipsMgr.Position.Center, source, item, itemBase, false, bagId, itemKey, "", godWeaponStage)
    end
  elseif source == ItemTipsMgr.Source.EquipMake and itemBase.itemType == ItemType.EQUIP then
    local equipBase = ItemUtils.GetEquipBase(itemBase.itemid)
    local comparekey, itemCompare = ItemModule.Instance():GetItemByPosition(ItemModule.EQUIPBAG, equipBase.wearpos)
    if comparekey ~= -1 then
      self._itemCompare = itemCompare
      local pos = {
        x = sourceX - 80,
        y = sourceY
      }
      local pos1 = {
        x = sourceX - 440,
        y = sourceY
      }
      tip = self:_showTips(pos, ItemTipsMgr.Source.Bag, item, itemBase, false, bagId, itemKey, "", godWeaponStage)
      self._itemCompare = item
      local itemCompareBase = ItemUtils.GetItemBase(itemCompare.id)
      self:_showTips(pos1, ItemTipsMgr.Source.Other, itemCompare, itemCompareBase, true, ItemModule.EQUIPBAG, comparekey, "Compare", godWeaponStage)
      self._itemCompare = nil
    else
      tip = self:_showTips(ItemTipsMgr.Position.Left, ItemTipsMgr.Source.Bag, item, itemBase, false, bagId, itemKey, "", godWeaponStage)
    end
  else
    local pos
    if source == ItemTipsMgr.Source.Bag or source == ItemTipsMgr.Source.StorageBag or source == ItemTipsMgr.Source.RecycleRight then
      pos = ItemTipsMgr.Position.Left
    elseif source == ItemTipsMgr.Source.Equip or source == ItemTipsMgr.Source.Storage or source == ItemTipsMgr.Source.RecycleLeft then
      pos = ItemTipsMgr.Position.Right
    elseif source == ItemTipsMgr.Source.ChatOther or source == ItemTipsMgr.Source.ChatSelf then
      pos = ItemTipsMgr.Position.Center
    elseif source == ItemTipsMgr.Source.TradingArcade then
      pos = ItemTipsMgr.Position.Center
    else
      pos = {
        auto = true,
        sourceX = sourceX,
        sourceY = sourceY,
        sourceW = sourceW,
        sourceH = sourceH,
        prefer = prefer
      }
    end
    tip = self:_showTips(pos, source, item, itemBase, source == ItemTipsMgr.Source.Equip, bagId, itemKey, "", godWeaponStage)
  end
  return tip
end
def.method("table", "number", "table", "table", "boolean", "number", "number", "string", "number", "=>", ItemTips)._showTips = function(self, pos, source, item, itemBase, isEquip, bagId, itemKey, rename, godWeaponStage)
  local itemName = self:GetName(item, itemBase)
  local iconId = itemBase.icon
  local itemState = self:GetState(item, itemBase)
  local lv = self:GetLevel(itemBase, item)
  local equipType = itemBase.itemTypeName
  local topOperation
  local description = self:GetDescription(item, itemBase)
  local buttomOperations = {}
  if source ~= ItemTipsMgr.Source.EasyUse and bagId ~= 0 then
    buttomOperations = self:GetBottomOperation(source, item, itemBase)
    topOperation = self:GetTopOperation(source, item, itemBase)
  end
  if source == ItemTipsMgr.Source.ChatOther then
    topOperation = self:GetTopOperation(source, item, itemBase)
    if topOperation ~= nil and topOperation:GetOperationName() == textRes.Item[9500] then
      local AccessOperation = require("Main.Item.Operations.OperationAccess")
      local access = AccessOperation()
      access.itemId = itemBase.itemid
      buttomOperations = {access}
    end
  elseif source == ItemTipsMgr.Source.TradingArcade or source == ItemTipsMgr.Source.TradingArcadeSell then
    topOperation = self:GetTopOperation(source, item, itemBase)
  end
  if itemBase.itemType == ItemType.GIFT_BAG_ITEM then
    description = ItemTipsMgr.GetGiftDescription(item.id)
  end
  local extInfo
  if itemBase.itemType == ItemType.EQUIP and (source == ItemTipsMgr.Source.Bag or source == ItemTipsMgr.Source.Other) and self._itemCompare then
    local compareItemBase = ItemUtils.GetItemBase(self._itemCompare.id)
    local myLevel = itemBase.useLevel
    local compareLevel = compareItemBase.useLevel
    extInfo = {}
    extInfo.myLevel = myLevel
    extInfo.compareLevel = compareLevel
  end
  if nil == extInfo then
    extInfo = {}
  end
  extInfo.itemId = item.id
  local itemTips = ItemTips.ShowTip(pos, itemName, iconId, isEquip, itemState, lv, equipType, description, topOperation, buttomOperations, bagId, itemKey, rename, extInfo, godWeaponStage)
  ItemTipsMgr.PostTipsContentHandler(item, itemBase, itemTips)
  return itemTips
end
local G_tblPostHandlers = {}
def.static("number", "function").RegisterPostTipsHandler = function(itemType, func)
  if itemType == nil then
    return
  end
  G_tblPostHandlers[itemType] = func
end
def.static("table", "table", "table").PostTipsContentHandler = function(item, itemBase, itemTips)
  local func = G_tblPostHandlers[itemBase.itemType]
  if func ~= nil then
    func(item, itemBase, itemTips)
  end
end
def.static("number", "=>", "table").GetGiftAwardCfgTbl = function(itemId)
  local itemCfg = ItemUtils.GetGiftBasicCfg(itemId)
  local awardId = itemCfg.awardId
  local mySchool = require("Main.Hero.Interface").GetHeroProp().occupation
  local myGender = require("Main.Hero.Interface").GetHeroProp().gender
  local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  local awardOcupSexKey = string.format("%d_%d_%d", awardId, mySchool, myGender)
  local awardAllAllKey = string.format("%d_%d_%d", awardId, occupation.ALL, gender.ALL)
  local awardOcpAllKey = string.format("%d_%d_%d", awardId, mySchool, gender.ALL)
  local awardAllSexKey = string.format("%d_%d_%d", awardId, occupation.ALL, myGender)
  local awardCfg = ItemUtils.GetGiftAwardCfg(awardOcupSexKey)
  if awardCfg == nil then
    awardCfg = ItemUtils.GetGiftAwardCfg(awardAllAllKey)
    if awardCfg == nil then
      awardCfg = ItemUtils.GetGiftAwardCfg(awardOcpAllKey)
      if awardCfg == nil then
        awardCfg = ItemUtils.GetGiftAwardCfg(awardAllSexKey)
      end
    end
  end
  return awardCfg
end
def.static("number", "=>", "string").GetGiftDescription = function(itemId)
  local awardCfg = ItemTipsMgr.GetGiftAwardCfgTbl(itemId)
  local strTable = {}
  if awardCfg == nil then
    return table.concat(strTable)
  end
  local itemBase = ItemUtils.GetItemBase(itemId)
  table.insert(strTable, string.format("<p align=left valign=middle><font size=22 color=#%s>", "ffffff"))
  table.insert(strTable, itemBase.desc)
  table.insert(strTable, "<br/>")
  table.insert(strTable, ItemTipsMgr.GetAwardDesc(awardCfg, false))
  table.insert(strTable, "</font></p>")
  return table.concat(strTable)
end
def.static("table", "boolean", "=>", "string").GetAwardDesc = function(awardCfg, isBBCode)
  local strTable = {}
  local AllMoneyType = require("consts.mzm.gsp.item.confbean.AllMoneyType")
  if awardCfg.moneyList ~= nil then
    for k, v in pairs(awardCfg.moneyList) do
      if v.bigType == AllMoneyType.TYPE_MONEY then
        local cfgInfo = ItemUtils.GetMoneyCfg(v.littleType)
        local iconStr = string.format("<img src='%s:%s' width=22 height=22>", RESPATH.COMMONATLAS, cfgInfo.icon)
        table.insert(strTable, iconStr)
        local numStr = string.format(" X %d", v.num)
        table.insert(strTable, numStr)
        table.insert(strTable, "<br/>")
      elseif v.bigType == AllMoneyType.TYPE_TOKEN then
        local cfgInfo = ItemUtils.GetTokenCfg(v.littleType)
        local iconStr = string.format("<img src='%s:%s' width=22 height=22>", RESPATH.COMMONATLAS, cfgInfo.icon)
        table.insert(strTable, iconStr)
        local numStr = string.format(" X %d", v.num)
        table.insert(strTable, numStr)
        table.insert(strTable, "<br/>")
      end
    end
  end
  if awardCfg.expList ~= nil then
    for k, v in pairs(awardCfg.expList) do
    end
  end
  if awardCfg.itemList ~= nil then
    for k, v in pairs(awardCfg.itemList) do
      local itemBase = ItemUtils.GetItemBase(v.itemId)
      local color = HtmlHelper.NameColor[itemBase.namecolor]
      local str
      if isBBCode then
        str = string.format("[%s]%s[-] X %d", color, itemBase.name, v.num)
      else
        str = string.format("<font color=#%s>%s</font> X %d", color, itemBase.name, v.num)
      end
      table.insert(strTable, str)
      table.insert(strTable, "<br/>")
    end
  end
  local TitleInterface = require("Main.title.TitleInterface")
  if awardCfg.appellationId ~= 0 then
    local appellationCfg = TitleInterface.GetAppellationCfg(awardCfg.appellationId)
    local appellationStr = string.format(textRes.Item[129], appellationCfg.appellationName)
    table.insert(strTable, appellationStr)
    table.insert(strTable, "<br/>")
  end
  if awardCfg.titleId ~= 0 then
    local titleCfg = TitleInterface.GetTitleCfg(awardCfg.titleId)
    local titleStr = string.format(textRes.Item[130], titleCfg.titleName)
    table.insert(strTable, titleStr)
    table.insert(strTable, "<br/>")
  end
  return table.concat(strTable)
end
def.method("table", "table", "=>", "string").GetName = function(self, item, itemBase)
  local EquipUtils = require("Main.Equip.EquipUtils")
  local dynamicColor = 1
  if item and itemBase and itemBase.itemType == ItemType.CHILDREN_EQUIP_ITEM then
    local phase = item.extraMap[ItemXStoreType.CHILDREN_EQUIP_STAGE]
    local equip_phase_cfg = require("Main.Children.ChildrenUtils").GetChildEquipPhaseCfg(1, phase)
    dynamicColor = equip_phase_cfg and equip_phase_cfg.color or itemBase.namecolor
  else
    dynamicColor = EquipUtils.GetEquipDynamicColor(item, nil, itemBase)
  end
  local color = ItemTipsMgr.Color[dynamicColor]
  return GUIUtils.DyeText(ItemUtils.GetItemName(item, itemBase), color)
end
def.method("table", "table", "=>", "number").GetState = function(self, item, itemBase)
  local state = ""
  local MathHelper = require("Common.MathHelper")
  local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
  local zhuanYou = itemBase.isProprietary
  if zhuanYou then
    state = ItemTips.ItemState.Proprietary
  elseif MathHelper.BitAnd(item.flag, ItemInfo.BIND) ~= 0 then
    state = ItemTips.ItemState.Bind
  elseif ItemUtils.IsRarity(item.id) then
    state = ItemTips.ItemState.Rarity
  else
    state = ItemTips.ItemState.None
  end
  return state
end
def.method("table", "table", "=>", "number").GetLevel = function(self, itemBase, item)
  local lv = -1
  if itemBase.itemType == ItemType.MADE_MATERIAL then
    local EquipUtils = require("Main.Equip.EquipUtils")
    local matCfg = EquipUtils.GetEquipMakeMaterialInfo(itemBase.itemid)
    lv = matCfg.materialLevel
  elseif itemBase.itemType == ItemType.EQUIP then
    lv = itemBase.useLevel
  elseif itemBase.itemType == ItemType.PET_EQUIP then
    local petEquipCfg = PetUtility.GetPetEquipmentCfg(itemBase.itemid)
    lv = petEquipCfg.equipLevel
  elseif itemBase.itemType == ItemType.FABAO_ITEM then
    if item ~= nil then
      lv = item.extraMap[ItemXStoreType.FABAO_CUR_LV]
      lv = lv or -1
    end
  elseif itemBase.itemType == ItemType.FABAO_LONGJING_ITEM then
    local longjing = ItemUtils.GetLongJingItem(itemBase.itemid)
    lv = longjing.lv
  elseif itemBase.itemType == ItemType.CHILDREN_EQUIP_ITEM then
    lv = item.extraMap[ItemXStoreType.CHILDREN_EQUIP_LEVEL]
  elseif itemBase.itemType == ItemType.SUPER_EQUIPMENT_JEWEL_ITEM then
    local JewelUtils = require("Main.GodWeapon.Jewel.JewelUtils")
    local jewelBase = JewelUtils.GetJewelItemByItemId(itemBase.itemid, false)
    if jewelBase ~= nil then
      lv = jewelBase.level
    end
  end
  return lv
end
def.method("number", "table", "table", "=>", OperationBase).GetTopOperation = function(self, source, item, itemBase)
  for k, v in ipairs(self._topOperation) do
    local ope = v()
    if ope:CanDispaly(source, item, itemBase) then
      return ope
    end
  end
  return nil
end
def.method("number", "table", "table", "=>", "table").GetBottomOperation = function(self, source, item, itemBase)
  local opes = {}
  for k, v in ipairs(self._bottomOperations) do
    local ope = v()
    if ope:CanDispaly(source, item, itemBase) then
      table.insert(opes, ope)
    end
  end
  return opes
end
def.method("number", "table", "table", "=>", OperationBase).GetFirstOperation = function(self, source, item, itemBase)
  for k, v in ipairs(self._bottomOperations) do
    local ope = v()
    if ope:CanDispaly(source, item, itemBase) then
      return ope
    end
  end
  return nil
end
def.method("table", "=>", "string").GetFilterItemDescription = function(self, filterBase)
  local filterEffect = filterBase.effect
  local effectStr = ""
  if filterEffect and filterEffect ~= "" then
    effectStr = string.format("<font color=#%s>%s</font>%s<br/>", ItemTipsMgr.Color.Content, textRes.Item[8312], filterEffect)
  end
  local Html = string.format("<p align=left valign=middle><font size=22 color=#%s>%s%s</font></p>", ItemTipsMgr.Color.White, effectStr, filterBase.desc)
  return Html
end
def.method("table", "number", "number", "=>", "string").GetWingDescription = function(self, itemBase, level, phase)
  local strTable = {}
  local lvStr = string.format(textRes.Item[8215], level)
  local phStr = string.format(textRes.Item[8214], phase)
  table.insert(strTable, lvStr)
  table.insert(strTable, "<br/>")
  table.insert(strTable, phStr)
  table.insert(strTable, "<br/>")
  local Html = string.format("<p align=left valign=middle><font size=22 color=#%s>%s%s</font></p>", ItemTipsMgr.Color.White, table.concat(strTable), itemBase.desc)
  return Html
end
def.method("table", "table", "=>", "string").GetAircraftDescription = function(self, itemBase, aircraftCfg)
  local strTable = {}
  table.insert(strTable, itemBase.desc)
  table.insert(strTable, "<br/>")
  table.insert(strTable, "<br/>")
  table.insert(strTable, textRes.Item[13101])
  table.insert(strTable, "<br/>")
  if aircraftCfg and aircraftCfg.props and #aircraftCfg.props > 0 then
    local propCount = #aircraftCfg.props
    local AircraftUtils = require("Main.Aircraft.AircraftUtils")
    for i = 1, propCount do
      local prop = aircraftCfg.props[i]
      table.insert(strTable, AircraftUtils.GetAttrString(prop.propType, prop.propValue))
      if i ~= propCount then
        table.insert(strTable, "<br/>")
      end
    end
  else
    table.insert(strTable, textRes.Aircraft.AIRCRAFT_ATTR_NONE)
  end
  local Html = string.format("<p align=left valign=middle><font size=22 color=#%s>%s</font></p>", ItemTipsMgr.Color.White, table.concat(strTable))
  return Html
end
def.method("table", "string", "=>", "string").GetFilterItemDescriptionEX = function(self, filterBase, extraInfo)
  local filterEffect = filterBase.effect
  local effectStr = ""
  if filterEffect and filterEffect ~= "" then
    effectStr = string.format("<font color=#%s>%s</font>%s<br/>", ItemTipsMgr.Color.Content, textRes.Item[8312], filterEffect)
  end
  local Html = string.format("<p align=left valign=middle><font size=22 color=#%s>%s%s<br/>%s</font></p>", ItemTipsMgr.Color.White, effectStr, filterBase.desc, extraInfo)
  return Html
end
def.method("table", "=>", "string").GetSimpleDescription = function(self, itemBase)
  local itemId = itemBase.itemid
  local typeDesc = ""
  if itemBase.itemType == ItemType.MAGIC_MATERIAL then
    typeDesc = self:GetFumoItemBasicDescription(itemId)
  elseif itemBase.itemType == ItemType.IN_FIGHT_DRUG or itemBase.itemType == ItemType.SUPER_IN_FIGHT_DRUG_ITEM then
    typeDesc = self:GetInFightItemBasicDescription(itemId)
  elseif itemBase.itemType == ItemType.DRUG_ITEM then
    typeDesc = self:GetYaoCaiBasicDescription(itemId)
  elseif itemBase.itemType == ItemType.PET_LIFE_ITEM then
    typeDesc = self:GetPetAgeItemBasicDescription(itemId)
  elseif itemBase.itemType == ItemType.BAO_SHI_DU then
    typeDesc = self:GetRoleFullBasicDescription(itemId)
  elseif itemBase.itemType == ItemType.FABAO_LONGJING_ITEM then
    typeDesc = self:GetLongJingBasicDescription(itemId)
  elseif itemBase.itemType == ItemType.WING_EXP_ITEM then
    typeDesc = self:GetWingExpItemBasicDescription(itemId)
  elseif itemBase.itemType == ItemType.FLOWER_ITEM then
    typeDesc = self:GetFlowerBasicDescription(itemId)
  elseif itemBase.itemType == ItemType.FABAO_EXP_ITEM then
    typeDesc = self:GetFabaoExpBasicDescription(itemId)
  elseif itemBase.itemType == ItemType.XIULIAN_EXP_ITEM then
    typeDesc = self:GetXiuLianExpBasicDescription(itemId)
  elseif itemBase.itemType == ItemType.FASHION_DRESS_ITEM then
    typeDesc = self:GetFashionDressItemBasicDescription(itemId)
  elseif itemBase.itemType == ItemType.PET_DECORATE_ITEM then
    typeDesc = self:GetPetDecorateDescription(nil, itemBase)
  elseif itemBase.itemType == ItemType.FURNITURE_ITEM then
    typeDesc = self:GetFurnitureDescription(nil, itemBase)
  elseif itemBase.itemType == ItemType.CHILDREN_EQUIP_NORMAL_LEVEL_UP_ITEM or itemBase.itemType == ItemType.CHILDREN_EQUIP_HIGH_LEVEL_UP_ITEM then
    typeDesc = self:GetChildEquipLevelUpItemSimpleDesc(itemId)
  elseif itemBase.itemType == ItemType.CHILDREN_CHARATER_ITEM then
    typeDesc = self:GetChildCharacterSimpleDesc(itemId)
  elseif itemBase.itemType == ItemType.CHILDREN_GROWTH_ITEM then
    typeDesc = self:GetChildGrowthSimpleDesc(itemId)
  elseif itemBase.itemType == ItemType.SUPER_EQUIPMENT_JEWEL_ITEM then
    typeDesc = self:GetGodWeaponJewelSimpleDesc(itemId)
  elseif itemBase.itemType == ItemType.CHAINED_GIFT_BAG_ITEM then
    typeDesc = self:GetSimpleChainGiftItemDesc(item, itemBase)
  elseif itemBase.itemType == ItemType.EQUIPMENT_BLESSING_ITEM then
    typeDesc = self:GetEquipBlessItemDesc(item, itemBase)
  elseif itemBase.itemType == ItemType.CHANGE_MODEL_CARD_ITEM then
    typeDesc = self:GetTurnedCardBasicDescription(itemId)
  elseif itemBase.itemType == ItemType.CHANGE_MODEL_CARD_FRAGMENT then
    typeDesc = self:GetTurnedCardFragmentBasicDescription(itemId)
  elseif itemBase.itemType == ItemType.PET_MARK_ITEM then
    typeDesc = self:GetPetMarkItemDescription(item, itemBase)
  end
  local Html = string.format("<p align=left valign=middle><font size=22 color=#%s>%s%s</font></p>", ItemTipsMgr.Color.White, typeDesc, itemBase.desc)
  return Html
end
def.method("table", "string", "=>", "string").GetSimpleDescriptionEX = function(self, itemBase, extraInfo)
  local Html = string.format("<p align=left valign=middle><font size=22 color=#%s>%s<br/>%s</font></p>", ItemTipsMgr.Color.White, itemBase.desc, extraInfo)
  return Html
end
def.method("table", "table", "=>", "string").GetDescription = function(self, item, itemBase)
  local priceDesc = self:GetPriceDesc(item, itemBase)
  local frozenTimeDesc = self:GetFrozenTimeDesc(item, itemBase)
  local commonDesc = itemBase.desc
  local typeDesc = ""
  local compoundDesc = ""
  local splitDesc = ""
  local timeDesc = ""
  if itemBase.itemType == ItemType.EQUIP then
    typeDesc = self:GetEquipDescription(item, itemBase)
  elseif itemBase.itemType == ItemType.ITEMTYPE_BAOTU then
    typeDesc = self:GetBaoTuDescription(item, itemBase)
  elseif itemBase.itemType == ItemType.PET_EQUIP then
    typeDesc = self:GetPetEquipDescription(item, itemBase)
  elseif itemBase.itemType == ItemType.MAGIC_MATERIAL then
    typeDesc = self:GetFumoItemDescription(item, itemBase)
  elseif itemBase.itemType == ItemType.IN_FIGHT_DRUG or itemBase.itemType == ItemType.SUPER_IN_FIGHT_DRUG_ITEM then
    typeDesc = self:GetInFightItemDescription(item, itemBase)
  elseif itemBase.itemType == ItemType.DRUG_ITEM then
    typeDesc = self:GetYaoCaiDescription(item, itemBase)
  elseif itemBase.itemType == ItemType.FABAO_ITEM then
    typeDesc = self:GetFabaoDescription(item, itemBase)
  elseif itemBase.itemType == ItemType.FABAO_ARTIFACT_ITEM then
    typeDesc = self:GetFabaoSpiritDescription(item, itemBase)
  elseif itemBase.itemType == ItemType.BABY_BAG then
    typeDesc = self:GetPetBagDescription(item, itemBase)
  elseif itemBase.itemType == ItemType.PET_LIFE_ITEM then
    typeDesc = self:GetPetAgeItemDescription(item, itemBase)
  elseif itemBase.itemType == ItemType.BAO_SHI_DU then
    typeDesc = self:GetRoleFullDescription(item, itemBase)
  elseif itemBase.itemType == ItemType.FABAO_LONGJING_ITEM then
    typeDesc = self:GetLongJingDescription(item, itemBase)
  elseif itemBase.itemType == ItemType.WING_EXP_ITEM then
    typeDesc = self:GetWingExpItemDescription(item, itemBase)
  elseif itemBase.itemType == ItemType.FLOWER_ITEM then
    typeDesc = self:GetFlowerDescription(item, itemBase)
  elseif itemBase.itemType == ItemType.FABAO_EXP_ITEM then
    typeDesc = self:GetFabaoExpDescription(item, itemBase)
  elseif itemBase.itemType == ItemType.XIULIAN_EXP_ITEM then
    typeDesc = self:GetXiuLianExpDescription(item, itemBase)
  elseif itemBase.itemType == ItemType.FASHION_DRESS_ITEM then
    typeDesc = self:GetFashionDressItemDescription(item, itemBase)
  elseif itemBase.itemType == ItemType.PET_DECORATE_ITEM then
    typeDesc = self:GetPetDecorateDescription(item, itemBase)
  elseif itemBase.itemType == ItemType.FURNITURE_ITEM then
    typeDesc = self:GetFurnitureDescription(item, itemBase)
  elseif itemBase.itemType == ItemType.CHILDREN_EQUIP_NORMAL_LEVEL_UP_ITEM or itemBase.itemType == ItemType.CHILDREN_EQUIP_HIGH_LEVEL_UP_ITEM then
    typeDesc = self:GetChildEquipLevelUpItemDesc(item, itemBase)
  elseif itemBase.itemType == ItemType.CHILDREN_EQUIP_ITEM then
    typeDesc = self:GetChildEquipDescription(item, itemBase)
  elseif itemBase.itemType == ItemType.CHILDREN_CHARATER_ITEM then
    typeDesc = self:GetChildCharacterItemDesc(item, itemBase)
  elseif itemBase.itemType == ItemType.CHILDREN_GROWTH_ITEM then
    typeDesc = self:GetChildGrowthItemDesc(item, itemBase)
  elseif itemBase.itemType == ItemType.EXP_BOTTLE_ITEM then
    typeDesc = self:GetExpBottleItemDesc(item, itemBase)
  elseif itemBase.itemType == ItemType.DOUBLE_ITEM then
    typeDesc = self:GetDoubleItemDesc(item, itemBase)
  elseif itemBase.itemType == ItemType.SUPER_EQUIPMENT_JEWEL_ITEM then
    typeDesc = self:GetGodWeaponJewelDesc(item, itemBase)
  elseif itemBase.itemType == ItemType.PK_REVENGE_ITEM then
    typeDesc = self:GetRevengeCardDesc(item, itemBase)
  elseif itemBase.itemType == ItemType.CHAINED_GIFT_BAG_ITEM then
    typeDesc = self:GetChainGiftItemDesc(item, itemBase)
  elseif itemBase.itemType == ItemType.INDIANA_LOTTERY_ITEM then
    typeDesc = self:GetDuoBaoItemDesc(item, itemBase)
  elseif itemBase.itemType == ItemType.EQUIPMENT_BLESSING_ITEM then
    typeDesc = self:GetEquipBlessItemDesc(item, itemBase)
  elseif itemBase.itemType == ItemType.CHAT_BUBBLE_ITEM then
    typeDesc = self:GetChatBubbleDesc(item, itemBase)
  elseif itemBase.itemType == ItemType.CHANGE_MODEL_CARD_ITEM then
    typeDesc = self:GetTurnedCardDescription(item, itemBase)
  elseif itemBase.itemType == ItemType.CHANGE_MODEL_CARD_FRAGMENT then
    typeDesc = self:GetTurnedCardFragmentDescription(item, itemBase)
  elseif itemBase.itemType == ItemType.CAKE_AWARD_ITEM then
    typeDesc = self:GetCakeDesc(item, itemBase)
  elseif itemBase.itemType == ItemType.PET_MARK_ITEM then
    typeDesc = self:GetPetMarkItemDescription(item, itemBase)
  end
  compoundDesc = self:GetCompoundDesc(item, itemBase)
  splitDesc = self:GetSplitDesc(item, itemBase)
  timeDesc = self:GetTimeEffectDesciption(item, itemBase)
  local Html = string.format("<p align=left valign=middle><font size=22 color=#%s>%s%s%s%s%s%s%s</font></p>", ItemTipsMgr.Color.White, priceDesc, frozenTimeDesc, typeDesc, commonDesc, compoundDesc, splitDesc, timeDesc)
  return Html
end
def.method("table", "table", "=>", "string").GetCompoundDesc = function(self, item, itemBase)
  local itemId = itemBase.itemid
  local compoundCfg = ItemUtils.GetItemCompounCfg(itemId)
  if compoundCfg == nil then
    return ""
  end
  local EquipUtils = require("Main.Equip.EquipUtils")
  local makeNeedItem = EquipUtils.GetMakeItemTable(compoundCfg.makeCfgId)
  local strTable = {}
  table.insert(strTable, "<br/>")
  table.insert(strTable, string.format("<font color=#%s>%s</font>", ItemTipsMgr.Color.Title, textRes.Item[8301]))
  table.insert(strTable, "<br/>")
  if makeNeedItem.goldNum > 0 then
    table.insert(strTable, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")
    table.insert(strTable, string.format("<img src='%s:%s' width=22 height=22>", RESPATH.COMMONATLAS, "Icon_Gold"))
    table.insert(strTable, "\195\151" .. makeNeedItem.goldNum)
    table.insert(strTable, "<br/>")
  end
  if 0 < makeNeedItem.silverNum then
    table.insert(strTable, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")
    table.insert(strTable, string.format("<img src='%s:%s' width=22 height=22>", RESPATH.COMMONATLAS, "Icon_Sliver"))
    table.insert(strTable, "\195\151" .. makeNeedItem.silverNum)
    table.insert(strTable, "<br/>")
  end
  if 0 < makeNeedItem.vigorNum then
    table.insert(strTable, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")
    table.insert(strTable, textRes.Item[8303])
    table.insert(strTable, "\195\151" .. makeNeedItem.vigorNum)
    table.insert(strTable, "<br/>")
  end
  for k, v in ipairs(makeNeedItem.makeNeedItem) do
    local needitemId = v.itemId
    local needItemBase = ItemUtils.GetItemBase(needitemId)
    local name = needItemBase.name
    local num = v.itemNum
    table.insert(strTable, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")
    table.insert(strTable, string.format("<a href='item' id=item_%d><font color=#%s>[%s]</font></a>", needitemId, ItemTipsMgr.Color[needItemBase.namecolor], name))
    table.insert(strTable, "\195\151" .. num)
    table.insert(strTable, "<br/>")
  end
  table.insert(strTable, textRes.Item[8302])
  table.insert(strTable, string.format("<font color=#%s>%s</font>", ItemTipsMgr.Color.Title, compoundCfg.showname))
  return table.concat(strTable)
end
def.method("table", "table", "=>", "string").GetSplitDesc = function(self, item, itemBase)
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_ITEM_SPLIT) then
    return ""
  end
  local itemId = itemBase.itemid
  local splitCfg = ItemUtils.GetItemSplitCfg(itemId)
  if splitCfg == nil then
    return ""
  end
  local strTable = {}
  table.insert(strTable, "<br/>")
  table.insert(strTable, string.format("<font color=#%s>%s</font>", ItemTipsMgr.Color.Title, textRes.Item[12104]))
  table.insert(strTable, "<br/>")
  if splitCfg.requiredGold > 0 then
    table.insert(strTable, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")
    table.insert(strTable, string.format("<img src='%s:%s' width=22 height=22>", RESPATH.COMMONATLAS, "Icon_Gold"))
    table.insert(strTable, "\195\151" .. splitCfg.requiredGold)
    table.insert(strTable, "<br/>")
  end
  if 0 < splitCfg.requiredSilver then
    table.insert(strTable, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")
    table.insert(strTable, string.format("<img src='%s:%s' width=22 height=22>", RESPATH.COMMONATLAS, "Icon_Sliver"))
    table.insert(strTable, "\195\151" .. splitCfg.requiredSilver)
    table.insert(strTable, "<br/>")
  end
  if 0 < splitCfg.requiredSilver then
    table.insert(strTable, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")
    table.insert(strTable, textRes.Item[8303])
    table.insert(strTable, "\195\151" .. splitCfg.requiredVigor)
    table.insert(strTable, "<br/>")
  end
  local needitemId = splitCfg.itemId
  local needItemBase = ItemUtils.GetItemBase(needitemId)
  local name = needItemBase.name
  local num = 1
  table.insert(strTable, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")
  table.insert(strTable, string.format("<a href='item' id=item_%d><font color=#%s>[%s]</font></a>", needitemId, ItemTipsMgr.Color[needItemBase.namecolor], name))
  table.insert(strTable, "\195\151" .. num)
  table.insert(strTable, "<br/>")
  table.insert(strTable, string.format("<font color=#%s>%s</font>", ItemTipsMgr.Color.White, HtmlHelper.ConvertBBCodeColorToHtml(splitCfg.description)))
  return table.concat(strTable)
end
def.method("table", "table", "=>", "string").GetTimeEffectDesciption = function(self, item, itemBase)
  local itemId = itemBase.itemid
  local timeEffectCfg = ItemUtils.GetTimeEffectItemCfg(itemId)
  if timeEffectCfg == nil then
    return ""
  end
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local ItemTimeType = require("consts.mzm.gsp.item.confbean.ItemTimeType")
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  local strTable = {}
  table.insert(strTable, "<br/>")
  local timeDesc = ""
  if timeEffectCfg.itemTimeType == ItemTimeType.FIX_LIMIT_TIME then
    local startTimePointCfg = TimeCfgUtils.GetCommonTimePointCfg(timeEffectCfg.beginEffectTime)
    local endTimePointCfg = TimeCfgUtils.GetCommonTimePointCfg(timeEffectCfg.endEffectTime)
    if startTimePointCfg ~= nil and endTimePointCfg == nil then
      timeDesc = string.format(textRes.Item[8378], startTimePointCfg.year % 2000, startTimePointCfg.month, startTimePointCfg.day)
    elseif startTimePointCfg == nil and endTimePointCfg ~= nil then
      timeDesc = string.format(textRes.Item[8379], endTimePointCfg.year % 2000, endTimePointCfg.month, endTimePointCfg.day)
    elseif startTimePointCfg ~= nil and endTimePointCfg ~= nil then
      timeDesc = string.format(textRes.Item[8380], startTimePointCfg.year % 2000, startTimePointCfg.month, startTimePointCfg.day, endTimePointCfg.year % 2000, endTimePointCfg.month, endTimePointCfg.day)
    end
  elseif timeEffectCfg.itemTimeType == ItemTimeType.GET_EFFECT_TIME then
    local endSec = item.extraMap[ItemXStoreType.TIME_ITEM_END_TIME]
    local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
    local t = AbsoluteTimer.GetServerTimeTable(endSec)
    timeDesc = string.format(textRes.Item[8381], t.year % 2000, t.month, t.day, t.hour, t.min)
  elseif timeEffectCfg.itemTimeType == ItemTimeType.USER_DEFINED_END_TIME then
    local endSec = item.extraMap[ItemXStoreType.TIME_ITEM_END_TIME]
    if endSec == nil then
      timeDesc = textRes.Item[8411]
    else
      local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
      local t = AbsoluteTimer.GetServerTimeTable(endSec)
      timeDesc = string.format(textRes.Item[8381], t.year % 2000, t.month, t.day, t.hour, t.min)
    end
  end
  table.insert(strTable, string.format("<font color=#%s>%s</font>", ItemTipsMgr.Color.Content, timeDesc))
  return table.concat(strTable)
end
def.method("table", "table", "=>", "string").GetPriceDesc = function(self, item, itemBase)
  local strTable = {}
  local ItemSourceEnum = require("netio.protocol.mzm.gsp.item.ItemSourceEnum")
  if item.extraMap[ItemXStoreType.ITEM_SOURCE] == ItemSourceEnum.SHANGHUI then
    table.insert(strTable, textRes.Item[125])
    table.insert(strTable, item.extraMap[ItemXStoreType.SHANGHUI_PRICE])
    table.insert(strTable, string.format("&nbsp;&nbsp;<img src='%s:%s' width=22 height=22><br/>", RESPATH.COMMONATLAS, "Icon_Gold"))
  end
  return table.concat(strTable)
end
def.method("table", "table", "=>", "string").GetFrozenTimeDesc = function(self, item, itemBase)
  local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
  local unfreezeTime = TradingArcadeUtils.GetItemUnfreezeTime(item)
  local curTime = _G.GetServerTime()
  local remainSeconds = unfreezeTime - curTime
  if remainSeconds <= 0 then
    return ""
  end
  local timeText = _G.SeondsToTimeText(remainSeconds)
  local strTable = {}
  local text = string.format(textRes.TradingArcade[32], timeText)
  table.insert(strTable, string.format("<font color=#%s>%s</font></br>", ItemTipsMgr.Color.Red, text))
  return table.concat(strTable)
end
def.method("table", "table", "=>", "string").GetEquipDurable = function(self, item, itemBase)
  local equipBase = ItemUtils.GetEquipBase(itemBase.itemid)
  local equipFullDurable = equipBase.usePoint
  local equipDurable = item.extraMap[ItemXStoreType.USE_POINT_VALUE]
  local color = ItemTipsMgr.Color.Green
  if equipDurable < 50 then
    color = ItemTipsMgr.Color.Red
  end
  local durableStr = textRes.Item[8107] .. string.format("<font color=#%s>%d/%d</font>", color, equipDurable, equipFullDurable)
  return durableStr
end
def.method("table", "table", "=>", "string").GetEquipDescription = function(self, item, itemBase)
  local equipModule = require("Main.Equip.EquipModule")
  local EquipUtils = require("Main.Equip.EquipUtils")
  local itemBaseCompare, equipBaseCompare
  if self._itemCompare ~= nil then
    itemBaseCompare = ItemUtils.GetItemBase(self._itemCompare.id)
    equipBaseCompare = ItemUtils.GetEquipBase(self._itemCompare.id)
  end
  local description = ""
  local equipBase = ItemUtils.GetEquipBase(itemBase.itemid)
  local strTable = {}
  local godWeaponStage = item.extraMap[ItemXStoreType.SUPER_EQUIPMENT_STAGE]
  if godWeaponStage and godWeaponStage > 0 then
    local ColorEnum = require("consts.mzm.gsp.item.confbean.Color")
    local godWeaponLevel = item.extraMap[ItemXStoreType.SUPER_EQUIPMENT_LEVEL]
    if not godWeaponLevel or not godWeaponLevel then
      godWeaponLevel = 0
    end
    table.insert(strTable, string.format("<font color=#%s>", ItemTipsMgr.Color[ColorEnum.ORANGE]))
    table.insert(strTable, string.format(textRes.Item[12201], godWeaponStage, godWeaponLevel))
    table.insert(strTable, "</font>")
    table.insert(strTable, "<br/>")
  end
  local MathHelper = require("Common.MathHelper")
  local curBlessLevel = item.extraMap[ItemXStoreType.EQUIPMENT_BLESS_LEVEL] or 0
  local curExp = item.extraMap[ItemXStoreType.EQUIPMENT_BLESS_EXP] or 0
  local attrBless = 0
  if curBlessLevel ~= 0 or curExp ~= 0 then
    local ColorEnum = require("consts.mzm.gsp.item.confbean.Color")
    table.insert(strTable, string.format("<font color=#%s>", ItemTipsMgr.Color[ColorEnum.ORANGE]))
    table.insert(strTable, string.format(textRes.Item[12202], curBlessLevel))
    table.insert(strTable, "</font>")
    table.insert(strTable, "<br/>")
    local EquipUtils = require("Main.Equip.EquipUtils")
    local curBlessCfg = EquipUtils.GetEquipBlessCfgByLevelAndPos(equipBase.wearpos, curBlessLevel)
    if curBlessCfg then
      attrBless = curBlessCfg.propertyBuff
    end
  end
  if equipBase.menpai ~= 0 or equipBase.sex ~= 0 then
    local mySchool = require("Main.Hero.Interface").GetHeroProp().occupation
    local myGender = require("Main.Hero.Interface").GetHeroProp().gender
    local color = ItemTipsMgr.Color.White
    if equipBase.menpai ~= 0 and equipBase.menpai ~= mySchool or equipBase.sex ~= 0 and equipBase.sex ~= myGender then
      color = ItemTipsMgr.Color.Red
    end
    table.insert(strTable, string.format("<font color=#%s>", color))
    table.insert(strTable, textRes.Item[8021])
    if equipBase.menpai ~= 0 then
      local schoolName = GetOccupationName(equipBase.menpai)
      local color = equipBase.menpai == mySchool and ItemTipsMgr.Color.White or ItemTipsMgr.Color.Red
      table.insert(strTable, string.format("%s&nbsp;", schoolName))
    end
    if equipBase.sex ~= 0 then
      local myGender = require("Main.Hero.Interface").GetHeroProp().gender
      local color = equipBase.sex == myGender and ItemTipsMgr.Color.White or ItemTipsMgr.Color.Red
      table.insert(strTable, string.format("%s", textRes.Item[8010 + equipBase.sex]))
    end
    table.insert(strTable, "</font>")
    table.insert(strTable, "<br/>")
  end
  table.insert(strTable, self:GetEquipDurable(item, itemBase))
  table.insert(strTable, "<br/>")
  local baseAttrScore = EquipUtils.CalcEpuipBaseAttrScore(item, itemBase, equipBase)
  local qilinScore = EquipUtils.GetQiLingScore(item)
  local godWeaponBreakOutScore = EquipUtils.CalcGodWeaponBreakOutScore(item, equipBase)
  local xihunScore = EquipUtils.CalcEpuipXihunScore(item)
  local skillScore = EquipUtils.CalcEpuipSkillScore(item)
  local godWeaponJewelScore = EquipUtils.CalcGodWeaponJewelScore(item)
  local totalScore = baseAttrScore + qilinScore + godWeaponBreakOutScore + xihunScore + skillScore + godWeaponJewelScore
  table.insert(strTable, textRes.Item[8406])
  table.insert(strTable, string.format("<font color=#%s>%d%s</font>", ItemTipsMgr.Color.Gold, totalScore, textRes.Item[127]))
  if self._itemCompare ~= nil then
    local compareScore = EquipUtils.GetEquipTotalScore(self._itemCompare, itemBaseCompare, equipBaseCompare)
    local arrow = self:GetCompareArrow(totalScore, compareScore)
    table.insert(strTable, arrow)
  end
  table.insert(strTable, "<br/>")
  local strenLevel = item.extraMap[ItemXStoreType.STRENGTH_LEVEL]
  table.insert(strTable, string.format("<font color=#%s>%s</font>", ItemTipsMgr.Color.Attr, textRes.Item[8009]))
  if strenLevel > 0 then
    table.insert(strTable, string.format("<font color=#%s>&nbsp;+%d</font>", ItemTipsMgr.Color.Attr, strenLevel))
  end
  table.insert(strTable, "&nbsp;" .. textRes.Item[8407])
  table.insert(strTable, string.format("<font color=#%s>%d</font>", ItemTipsMgr.Color.Gold, EquipUtils.CalcEpuipBaseAttrScore(item, itemBase, equipBase)))
  if strenLevel > 0 then
    table.insert(strTable, string.format("<font color=#%s>(+%d)</font>", ItemTipsMgr.Color.Gold, qilinScore))
  end
  table.insert(strTable, "<br/>")
  local linColor = ItemTipsMgr.Color[itemBase.namecolor]
  local strenAValue, strenBValue = EquipUtils.GetEquipStrenIncrease(equipBase.qilinTypeid, strenLevel)
  local attriAName = equipModule.GetAttriName(equipBase.attrA)
  local attriAValue = equipModule.GetAttriValue(itemBase.itemid, ItemXStoreType.ATTRI_A, item.extraMap[ItemXStoreType.ATTRI_A])
  attriAValue = attriAValue + MathHelper.Round(attriAValue * attrBless)
  if attriAName ~= "" then
    table.insert(strTable, string.format("<font color=#%s>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;%s +%d</font>", linColor, attriAName, attriAValue))
  end
  if self._itemCompare ~= nil and attriAName ~= "" then
    local strenAValueCompare, strenBValueCompare = EquipUtils.GetEquipStrenIncrease(equipBaseCompare.qilinTypeid, self._itemCompare.extraMap[ItemXStoreType.STRENGTH_LEVEL])
    local attriAValueCompare = equipModule.GetAttriValue(itemBaseCompare.itemid, ItemXStoreType.ATTRI_A, self._itemCompare.extraMap[ItemXStoreType.ATTRI_A])
    local arrow = self:GetCompareArrow(attriAValue, attriAValueCompare)
    table.insert(strTable, arrow)
  end
  if strenLevel > 0 and "" ~= attriAName then
    table.insert(strTable, string.format("<font color=#%s>&nbsp;(+%d)</font>", ItemTipsMgr.Color.Green, strenAValue))
  end
  table.insert(strTable, "<br/>")
  local attriBName = equipModule.GetAttriName(equipBase.attrB)
  local attriBValue = equipModule.GetAttriValue(itemBase.itemid, ItemXStoreType.ATTRI_B, item.extraMap[ItemXStoreType.ATTRI_B])
  attriBValue = attriBValue + MathHelper.Round(attriBValue * attrBless)
  if "" ~= attriBName then
    table.insert(strTable, string.format("<font color=#%s>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;%s +%d</font>", linColor, attriBName, attriBValue))
  end
  if self._itemCompare ~= nil and "" ~= attriBName then
    local strenBValueCompare, strenBValueCompare = EquipUtils.GetEquipStrenIncrease(equipBaseCompare.qilinTypeid, self._itemCompare.extraMap[ItemXStoreType.STRENGTH_LEVEL])
    local attriBValueCompare = equipModule.GetAttriValue(itemBaseCompare.itemid, ItemXStoreType.ATTRI_B, self._itemCompare.extraMap[ItemXStoreType.ATTRI_B])
    local arrow = self:GetCompareArrow(attriBValue, attriBValueCompare)
    table.insert(strTable, arrow)
  end
  if strenLevel > 0 and "" ~= attriBName then
    table.insert(strTable, string.format("<font color=#%s>&nbsp;(+%d)</font>", ItemTipsMgr.Color.Green, strenBValue))
  end
  table.insert(strTable, "<br/>")
  local godWeaponLevel = item.extraMap[ItemXStoreType.SUPER_EQUIPMENT_LEVEL]
  if godWeaponStage and godWeaponStage > 0 and godWeaponLevel and godWeaponLevel > 0 then
    local BreakOutUtils = require("Main.GodWeapon.BreakOut.BreakOutUtils")
    table.insert(strTable, string.format("<font color=#%s>%s</font>", ItemTipsMgr.Color.Attr, textRes.Item[8405]))
    table.insert(strTable, "&nbsp;" .. textRes.Item[8407])
    table.insert(strTable, string.format("<font color=#%s>%d</font>", ItemTipsMgr.Color.Gold, godWeaponBreakOutScore))
    table.insert(strTable, "<br/>")
    local linColor = ItemTipsMgr.Color.Pink
    local attriAName = equipModule.GetAttriName(equipBase.attrA)
    local attriAValue = BreakOutUtils.GetGodWeaponAttr(item, equipBase.attrA, equipBase)
    if attriAName ~= "" then
      table.insert(strTable, string.format("<font color=#%s>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;%s +%d</font>", linColor, attriAName, attriAValue))
    end
    if self._itemCompare ~= nil and attriAName ~= "" then
      local attriAValueCompare = BreakOutUtils.GetGodWeaponAttr(self._itemCompare, self._itemCompare.extraMap[ItemXStoreType.ATTRI_A], nil)
      local arrow = self:GetCompareArrow(attriAValue, attriAValueCompare)
      table.insert(strTable, arrow)
    end
    table.insert(strTable, "<br/>")
    local attriBName = equipModule.GetAttriName(equipBase.attrB)
    local attriBValue = BreakOutUtils.GetGodWeaponAttr(item, equipBase.attrB, equipBase)
    if attriBName ~= "" then
      table.insert(strTable, string.format("<font color=#%s>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;%s +%d</font>", linColor, attriBName, attriBValue))
    end
    if self._itemCompare ~= nil and attriBName ~= "" then
      local attriBValueCompare = BreakOutUtils.GetGodWeaponAttr(self._itemCompare, self._itemCompare.extraMap[ItemXStoreType.ATTRI_B], nil)
      local arrow = self:GetCompareArrow(attriBValue, attriBValueCompare)
      table.insert(strTable, arrow)
    end
    table.insert(strTable, "<br/>")
  end
  local exproCount = #item.exproList
  if exproCount > 0 then
    local emptyCount = EquipUtils.GetEmptyHumCount(item.exproList)
    local nameStr = string.format("%s %d/%d", textRes.Item[8010], exproCount - emptyCount, exproCount)
    table.insert(strTable, string.format("<font color=#%s>%s</font>", ItemTipsMgr.Color.Attr, nameStr))
    table.insert(strTable, "&nbsp;" .. textRes.Item[8407])
    table.insert(strTable, string.format("<font color=#%s>%d</font>", ItemTipsMgr.Color.Gold, xihunScore))
    table.insert(strTable, "<br/>")
    for i = 1, exproCount do
      if 0 == item.exproList[i].proType or 0 == item.exproList[i] then
        table.insert(strTable, string.format("<font color=#%s>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;%s</font>", ItemTipsMgr.Color[1], textRes.Item[9507]))
        table.insert(strTable, "<br/>")
      else
        local exproName = equipModule.GetProRandomName(item.exproList[i].proType)
        local exproValue, realVal, floatValue = equipModule.GetProRealValue(item.exproList[i].proType, item.exproList[i].proValue)
        local pro = equipModule.GetProTypeID(item.exproList[i].proType)
        local propType = equipModule.GetProTypeID(item.exproList[i].proType)
        local color = EquipUtils.GetHunColor(itemBase.itemid, propType, floatValue)
        if color <= 0 then
          color = EquipUtils.GetColor(item.exproList[i].proValue)
        else
        end
        table.insert(strTable, string.format("<font color=#%s>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;%s + %s</font>", ItemTipsMgr.Color[color], exproName, exproValue))
        table.insert(strTable, "<br/>")
      end
    end
  end
  local skillId = item.extraMap[ItemXStoreType.EQUIP_SKILL]
  if skillId then
    table.insert(strTable, string.format("<font color=#%s>%s</font>", ItemTipsMgr.Color.Attr, textRes.Item[8369]))
    local skillCfg = require("Main.Skill.SkillUtility").GetSkillCfg(skillId)
    if skillCfg then
      local skillName = skillCfg.name
      table.insert(strTable, "&nbsp;" .. textRes.Item[8407])
      table.insert(strTable, string.format("<font color=#%s>%d</font>", ItemTipsMgr.Color.Gold, skillScore))
      table.insert(strTable, "<br/>")
      table.insert(strTable, string.format("<a href='equipskill' id=se_%d><font color=#%s>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[%s]</font></a><br/>", skillId, ItemTipsMgr.Color.Content, skillName))
    end
  else
    local namecolor = itemBase.namecolor
    local ColorEnum = require("consts.mzm.gsp.item.confbean.Color")
    if namecolor == ColorEnum.ORANGE then
      table.insert(strTable, string.format("<font color=#%s>%s</font>", ItemTipsMgr.Color.Attr, textRes.Item[8369]))
      table.insert(strTable, "<br/>")
      table.insert(strTable, string.format("<font color=#ffffff>&nbsp;&nbsp;%s</font>", textRes.Item[9502]))
      table.insert(strTable, "<br/>")
    end
  end
  local fumoCount = #item.fumoProList
  if fumoCount > 0 then
    table.insert(strTable, string.format("<font color=#%s>%s</font>", ItemTipsMgr.Color.Attr, textRes.Item[8022]))
    table.insert(strTable, "<br/>")
    for i = 1, fumoCount do
      local fumoPro = item.fumoProList[i]
      local name = equipModule.GetAttriName(fumoPro.proType)
      local leftSecond = Int64.ToNumber(fumoPro.timeout) - GetServerTime()
      if leftSecond > 0 then
        table.insert(strTable, string.format("<font color=#%s>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;%s+%s</font>", ItemTipsMgr.Color.White, name, fumoPro.addValue))
        table.insert(strTable, string.format("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[<gameobj width=88 height=22 id=time prefab='%s' componentname='NGUITimeCountDownComponent' param='%d'>]", RESPATH.PREFAB_HTML_COUNTDOWN, leftSecond))
        table.insert(strTable, "<br/>")
      end
    end
  end
  local JewelMgr = require("Main.GodWeapon.JewelMgr")
  local opendSlotNum = JewelMgr.GetData():GetEquipOpenedSlotNum(godWeaponStage and godWeaponStage or 1)
  if godWeaponStage and godWeaponStage > 0 and opendSlotNum > 0 then
    local jewelMap = item.jewelMap
    local bHasJewel = false
    table.insert(strTable, string.format("<font color=#%s>%s</font>", ItemTipsMgr.Color.Attr, textRes.Item[8403]))
    if godWeaponJewelScore > 0 then
      table.insert(strTable, "&nbsp;" .. textRes.Item[8407])
      table.insert(strTable, string.format("<font color=#%s>%d</font>", ItemTipsMgr.Color.Gold, godWeaponJewelScore))
    end
    table.insert(strTable, "<br/>")
    if jewelMap ~= nil then
      local JewelUtils = require("Main.GodWeapon.Jewel.JewelUtils")
      local arrJewels = {}
      for i = 1, opendSlotNum do
        local v = jewelMap[i]
        if v ~= nil then
          bHasJewel = true
          local jewelItemId = v.jewelCfgId
          local jewelBasic = JewelUtils.GetJewelItemByItemId(jewelItemId, false)
          local itemBase = ItemUtils.GetItemBase(jewelItemId)
          local propColor = ItemTipsMgr.Color[itemBase.namecolor] or ItemTipsMgr.Color.Content
          table.insert(strTable, string.format("<a href='jewelprops' id=jewel_%d><font color=#%s>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[%s]</font></a>", jewelItemId, propColor, itemBase.name))
        else
          table.insert(strTable, string.format("<font color=#%s>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;%s</font>", ItemTipsMgr.Color.Content, textRes.Item[8408]))
        end
        if i ~= opendSlotNum then
          table.insert(strTable, "<br/>")
        end
      end
    end
  end
  table.insert(strTable, "<br/>")
  description = table.concat(strTable)
  return description
end
def.method("number", "number", "=>", "string").GetCompareArrow = function(self, a, b)
  local mark = ""
  if b < a then
    mark = string.format("&nbsp;&nbsp;<img src='%s:%s' width=14 height=22>", RESPATH.COMMONATLAS, "Img_Up")
  elseif a < b then
    mark = string.format("&nbsp;&nbsp;<img src='%s:%s' width=14 height=22>", RESPATH.COMMONATLAS, "Img_Down")
  else
    mark = string.format("&nbsp;&nbsp;<img src='%s:%s' width=24 height=15>", RESPATH.COMMONATLAS, "Img_Balance")
  end
  return mark
end
def.method("table", "table", "=>", "string").GetBaoTuDescription = function(self, item, itemBase)
  local strTable = {}
  local mapId = item.extraMap[ItemXStoreType.BAO_TU_MAPID]
  local x = item.extraMap[ItemXStoreType.BAO_TU_X]
  local y = item.extraMap[ItemXStoreType.BAO_TU_Y]
  local displayX = math.floor(x / 16 + 0.5)
  local displayY = math.floor(y / 16 + 0.5)
  local mapCfg = require("Main.Map.Interface").GetMapCfg(mapId)
  table.insert(strTable, string.format("<font color=#%s>", ItemTipsMgr.Color.Yellow))
  table.insert(strTable, textRes.Item[8018])
  table.insert(strTable, mapCfg.mapName)
  table.insert(strTable, "<br/>")
  table.insert(strTable, textRes.Item[8017])
  table.insert(strTable, string.format("[%d,%d]", displayX, displayY))
  table.insert(strTable, "<br/>")
  table.insert(strTable, "</font>")
  return table.concat(strTable)
end
def.method("table", "table", "=>", "string").GetPetEquipDescription = function(self, item, itemBase)
  local strTable = {}
  local equipModule = require("Main.Equip.EquipModule")
  local SkillUtils = require("Main.Skill.SkillUtility")
  local attrA = item.extraMap[ItemXStoreType.PET_EQUIP_ATTRI_A_TYPE]
  if attrA ~= nil then
    local attrAValue = item.extraMap[ItemXStoreType.PET_EQUIP_ATTRI_A]
    local attrAName = equipModule.GetAttriName(attrA)
    table.insert(strTable, string.format("%s + %d", attrAName, attrAValue))
    table.insert(strTable, "<br/>")
  end
  local attrB = item.extraMap[ItemXStoreType.PET_EQUIP_ATTRI_B_TYPE]
  if attrB ~= nil then
    local attrBValue = item.extraMap[ItemXStoreType.PET_EQUIP_ATTRI_B]
    local attrBName = equipModule.GetAttriName(attrB)
    table.insert(strTable, string.format("%s + %d", attrBName, attrBValue))
    table.insert(strTable, "<br/>")
  end
  local skillA = item.extraMap[ItemXStoreType.PET_EQUIP_SKILL_ID_1]
  if skillA ~= nil then
    local skillAName = PetUtility.Instance():GetPetSkillCfg(skillA).name
    table.insert(strTable, string.format("<a href='petskill' id=sp_%d><font color=#%s>[%s]</font></a>", skillA, ItemTipsMgr.Color.Yellow, skillAName))
    table.insert(strTable, "<br/>")
  end
  local skillB = item.extraMap[ItemXStoreType.PET_EQUIP_SKILL_ID_2]
  if skillB ~= nil then
    local skillBName = PetUtility.Instance():GetPetSkillCfg(skillB).name
    table.insert(strTable, string.format("<a href='petskill' id=sp_%d><font color=#%s>[%s]</font></a>", skillB, ItemTipsMgr.Color.Yellow, skillBName))
    table.insert(strTable, "<br/>")
  end
  return table.concat(strTable)
end
def.method("table", "table", "=>", "string").GetFumoItemDescription = function(self, item, itemBase)
  return self:GetFumoItemBasicDescription(item.id)
end
def.method("number", "=>", "string").GetFumoItemBasicDescription = function(self, itemId)
  local fumoCfg = require("Main.Skill.LivingSkillUtility").GetEnchantingPropInfo(itemId)
  return string.format("<font color=#%s>%s\239\188\154%d %s</font></br>", ItemTipsMgr.Color.Content, textRes.Item[8308], fumoCfg.drugPro, textRes.Item[8309])
end
def.method("table", "table", "=>", "string").GetPetAgeItemDescription = function(self, item, itemBase)
  return self:GetPetAgeItemBasicDescription(item.id)
end
def.method("number", "=>", "string").GetPetAgeItemBasicDescription = function(self, itemId)
  local cfg = ItemUtils.GetPetLifeCfg(itemId)
  local quality = ""
  if cfg.drugPro <= 0 then
    quality = string.format("<font color=#%s>%s\239\188\154%s</font></br>", ItemTipsMgr.Color.Content, textRes.Item[8308], textRes.Item[8121])
  else
    quality = string.format("<font color=#%s>%s\239\188\154%d %s</font></br>", ItemTipsMgr.Color.Content, textRes.Item[8308], cfg.drugPro, textRes.Item[8309])
  end
  local effect = string.format("<font color=#%s>%s%s </font></br>", ItemTipsMgr.Color.Content, textRes.Item[8312], cfg.itemdesc)
  return quality .. effect
end
def.method("table", "table", "=>", "string").GetRoleFullDescription = function(self, item, itemBase)
  return self:GetRoleFullBasicDescription(item.id)
end
def.method("number", "=>", "string").GetRoleFullBasicDescription = function(self, itemId)
  local cfg = require("Main.Skill.LivingSkillUtility").GetBaoShiDuItemInfo(itemId)
  local quality = ""
  if cfg.drugPro <= 0 then
    quality = string.format("<font color=#%s>%s\239\188\154%s</font></br>", ItemTipsMgr.Color.Content, textRes.Item[8308], textRes.Item[8121])
  else
    quality = string.format("<font color=#%s>%s\239\188\154%d %s</font></br>", ItemTipsMgr.Color.Content, textRes.Item[8308], cfg.drugPro, textRes.Item[8309])
  end
  local effect = string.format("<font color=#%s>%s%s </font></br>", ItemTipsMgr.Color.Content, textRes.Item[8312], cfg.itemdesc)
  return quality .. effect
end
def.method("table", "table", "=>", "string").GetInFightItemDescription = function(self, item, itemBase)
  return self:GetInFightItemBasicDescription(item.id)
end
def.method("number", "=>", "string").GetInFightItemBasicDescription = function(self, itemId)
  local inFightDrugCfg = require("Main.Skill.LivingSkillUtility").GetInFightDrugItemInfo(itemId)
  local quality = ""
  if inFightDrugCfg.drugPro <= 0 then
    quality = string.format("<font color=#%s>%s\239\188\154%s</font></br>", ItemTipsMgr.Color.Content, textRes.Item[8308], textRes.Item[8121])
  else
    quality = string.format("<font color=#%s>%s\239\188\154%d %s</font></br>", ItemTipsMgr.Color.Content, textRes.Item[8308], inFightDrugCfg.drugPro, textRes.Item[8309])
  end
  local effect = string.format("<font color=#%s>%s%s</font></br>", ItemTipsMgr.Color.Content, textRes.Item[8312], inFightDrugCfg.itemdesc)
  return quality .. effect
end
def.method("table", "table", "=>", "string").GetYaoCaiDescription = function(self, item, itemBase)
  return self:GetYaoCaiBasicDescription(item.id)
end
def.method("number", "=>", "string").GetYaoCaiBasicDescription = function(self, itemId)
  local yaocaiCfg = require("Main.Skill.LivingSkillUtility").GetYaoCaiInfo(itemId)
  return string.format("<font color=#%s>%s%s</font></br>", ItemTipsMgr.Color.Content, textRes.Item[8312], yaocaiCfg.itemdesc)
end
def.method("table", "table", "=>", "string").GetWingExpItemDescription = function(self, item, itemBase)
  return self:GetWingExpItemBasicDescription(item.id)
end
def.method("number", "=>", "string").GetWingExpItemBasicDescription = function(self, itemId)
  local wingExpItemCfg = require("Main.Wings.WingsUtility").GetWingExpItemCfg(itemId)
  return string.format("<font color=#%s>%s</font></br>", ItemTipsMgr.Color.Content, string.format(textRes.Wing[26], wingExpItemCfg.exp))
end
def.method("table", "table", "=>", "string").GetChildEquipLevelUpItemDesc = function(self, item, itemBase)
  return self:GetChildEquipLevelUpItemSimpleDesc(item.id)
end
def.method("number", "=>", "string").GetChildEquipLevelUpItemSimpleDesc = function(self, itemId)
  local exp = require("Main.Children.ChildrenUtils").GetChildEquipLevelUpItemCfg(itemId)
  return string.format("<font color=#%s>%s</font></br>", ItemTipsMgr.Color.Content, string.format(textRes.Children[3059], exp))
end
def.method("table", "table", "=>", "string").GetChildEquipDescription = function(self, item, itemBase)
  local strTable = {}
  local level = item.extraMap[ItemXStoreType.CHILDREN_EQUIP_LEVEL]
  local phase = item.extraMap[ItemXStoreType.CHILDREN_EQUIP_STAGE]
  local cur_prop = item.extraMap[ItemXStoreType.CHILDREN_EQUIP_PROP_A]
  if cur_prop then
    local ChildrenUtils = require("Main.Children.ChildrenUtils")
    local itemCfg = ChildrenUtils.GetChildEquipItem(item.id)
    local level_cfg = ChildrenUtils.GetChildEquipLevelCfg(itemCfg.levelTypeid, level)
    local prop_value
    for i = 1, #level_cfg.propList do
      if level_cfg.propList[i].key == cur_prop then
        prop_value = level_cfg.propList[i].value
        break
      end
    end
    local propstr = tostring(prop_value)
    if cur_prop == PropertyType.PHY_CRT_VALUE or cur_prop == PropertyType.MAG_CRT_VALUE then
      propstr = string.format("%.1f%%", prop_value / 100)
    end
    table.insert(strTable, string.format("<font color=#%s>%s + %s</font>", ItemTipsMgr.Color.Content, textRes.Children.FightPropertyName[cur_prop], propstr))
    table.insert(strTable, "<br/>")
  end
  return table.concat(strTable)
end
def.method("table", "table", "=>", "string").GetChildCharacterItemDesc = function(self, item, itemBase)
  return self:GetChildCharacterSimpleDesc(item.id)
end
def.method("number", "=>", "string").GetChildCharacterSimpleDesc = function(self, itemId)
  local exp = require("Main.Children.ChildrenUtils").GetChildCharacterItemCfg(itemId)
  return string.format("<font color=#%s>%s</font></br>", ItemTipsMgr.Color.Content, string.format(textRes.Children[3060], exp))
end
def.method("table", "table", "=>", "string").GetChildGrowthItemDesc = function(self, item, itemBase)
  return self:GetChildGrowthSimpleDesc(item.id)
end
def.method("number", "=>", "string").GetChildGrowthSimpleDesc = function(self, itemId)
  local cfg = require("Main.Children.ChildrenUtils").GetChildGrowthItemCfg(itemId)
  local desc = ""
  if cfg.min == cfg.max then
    desc = string.format("<font color=#%s>%s</font></br>", ItemTipsMgr.Color.Content, string.format(textRes.Children[3061], tostring(cfg.min / 10000)))
  else
    desc = string.format("<font color=#%s>%s</font></br>", ItemTipsMgr.Color.Content, string.format(textRes.Children[3062], tostring(cfg.min / 10000), tostring(cfg.max / 10000)))
  end
  if not cfg.useCount then
    desc = desc .. string.format("<font color=#%s>%s</font></br>", ItemTipsMgr.Color.Content, textRes.Children[3063])
  end
  return desc
end
def.method("table", "table", "=>", "string").GetFabaoDescription = function(self, item, itemBase)
  local strTable = {}
  local FabaoUtils = require("Main.Fabao.FabaoUtils")
  local fabaoBase = ItemUtils.GetFabaoItem(itemBase.itemid)
  local attrId = fabaoBase.attrId
  local fabaoLevel = item.extraMap[ItemXStoreType.FABAO_CUR_LV]
  local fabaoSkillId = item.extraMap[ItemXStoreType.FABAO_OWN_SKILL_ID]
  local fabaoScore = FabaoUtils.GetFabaoScore(attrId, fabaoLevel, fabaoSkillId)
  table.insert(strTable, string.format("<font color=#%s>%s %d%s<font>", ItemTipsMgr.Color.Gold, textRes.Item[126], fabaoScore, textRes.Item[127]))
  table.insert(strTable, "<br/>")
  local attrIndex = 45 + fabaoBase.fabaoType
  table.insert(strTable, string.format("<font color=#%s>%s %s</font>", ItemTipsMgr.Color.Attr, textRes.Fabao[77], textRes.Fabao[attrIndex] or textRes.Fabao[46]))
  table.insert(strTable, "<br/>")
  table.insert(strTable, string.format("<font color=#%s>%s</font>", ItemTipsMgr.Color.Attr, textRes.Item[8211]))
  table.insert(strTable, "<br/>")
  local fabaoLevel = item.extraMap[ItemXStoreType.FABAO_CUR_LV]
  local proCfg = FabaoUtils.GetFabaoAttrTypeAndValue(fabaoBase.attrId, fabaoLevel)
  if proCfg then
    for k, proInfo in pairs(proCfg) do
      if 0 ~= proInfo.proType then
        local proType = proInfo.proType
        local proValue = proInfo.proValue
        local proColor = proInfo.proColor
        local proName = FabaoUtils.GetFabaoProName(proType)
        local proRealValue = proValue
        local color = ItemTipsMgr.Color[proColor]
        if nil == color then
          color = ItemTipsMgr.Color.Attr
        end
        table.insert(strTable, string.format("<font color=#%s>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;%s  + %d</font>", color, proName, proRealValue))
        table.insert(strTable, "<br/>")
      end
    end
  end
  local proInstruction = fabaoBase.proInstruction or ""
  table.insert(strTable, string.format("<font color=#%s>%s</font>", ItemTipsMgr.Color.Content, proInstruction))
  table.insert(strTable, "<br/>")
  table.insert(strTable, string.format("<font color=#%s>%s</font>", ItemTipsMgr.Color.Attr, textRes.Item[8213]))
  local fabaoSkillId = item.extraMap[ItemXStoreType.FABAO_OWN_SKILL_ID]
  table.insert(strTable, "<br/>")
  if fabaoSkillId and 0 ~= fabaoSkillId then
    local skillCfg = require("Main.Skill.SkillUtility").GetSkillCfg(fabaoSkillId)
    table.insert(strTable, string.format("<a href='fabaoSkill' id=se_%d><font color=#%s>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[%s]</font></a><br/>", fabaoSkillId, ItemTipsMgr.Color.Content, skillCfg.name))
  end
  table.insert(strTable, "<br/>")
  return table.concat(strTable)
end
def.method("table", "table", "=>", "string").GetFabaoSpecialDescription = function(self, itemBase, fabaoBase)
  local strTable = {}
  local FabaoUtils = require("Main.Fabao.FabaoUtils")
  local attrIndex = 45 + fabaoBase.fabaoType
  table.insert(strTable, string.format("<font color=#%s>%s %s</font>", ItemTipsMgr.Color.Attr, textRes.Fabao[77], textRes.Fabao[attrIndex] or textRes.Fabao[46]))
  table.insert(strTable, "<br/>")
  table.insert(strTable, string.format("<font color=#%s> %s</font>", ItemTipsMgr.Color.Title, textRes.Item[8211]))
  table.insert(strTable, "<br/>")
  local EquipModule = require("Main.Equip.EquipModule")
  local proLevel = FabaoUtils.GetMaxFabaoLevelByClassId(fabaoBase.classId)
  local proCfg = FabaoUtils.GetFabaoAttrTypeAndValue(fabaoBase.attrId, proLevel)
  for k, proInfo in pairs(proCfg) do
    if 0 ~= proInfo.proType then
      local proType = proInfo.proType
      local proValue = proInfo.proValue
      local proColor = proInfo.proColor
      local proName = FabaoUtils.GetFabaoProName(proType)
      local proRealValue = proValue
      local color = ItemTipsMgr.Color[proColor]
      if nil == color then
        color = ItemTipsMgr.Color.Attr
      end
      table.insert(strTable, string.format("<font color=#%s>&nbsp;&nbsp;%s  + %d</font>", color, proName, proRealValue))
      table.insert(strTable, "<br/>")
    end
  end
  local proInstruction = fabaoBase.proInstruction
  table.insert(strTable, string.format("<font color=#%s>&nbsp;&nbsp;%s </font>", ItemTipsMgr.Color.Content, proInstruction))
  table.insert(strTable, "<br/>")
  table.insert(strTable, string.format("<font color=#%s>%s</font>", ItemTipsMgr.Color.Title, textRes.Item[8213]))
  table.insert(strTable, "<br/>")
  local rankId = fabaoBase.rankId
  local rankSkillLibId, _ = FabaoUtils.GetFabaoSkillLidId(rankId)
  local FabaoSkillcfg = FabaoUtils.GetAllFabaoSkill(rankSkillLibId)
  if FabaoSkillcfg then
    local count = 1
    for _, skillId in pairs(FabaoSkillcfg) do
      local skillCfg = require("Main.Skill.SkillUtility").GetSkillCfg(skillId)
      table.insert(strTable, string.format("<a href='fabaoSkill' id=se_%d><font color=#%s>&nbsp;&nbsp;[%s]</font></a>", skillId, ItemTipsMgr.Color.Yellow, skillCfg.name))
      if 2 == count then
        table.insert(strTable, "<br/>")
        count = 1
      else
        table.insert(strTable, string.format("<font color=#%s>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font>", ItemTipsMgr.Color.White))
        count = count + 1
      end
    end
  end
  table.insert(strTable, "<br/>")
  table.insert(strTable, "<br/>")
  local canCompose = fabaoBase.canCompose
  if canCompose then
    table.insert(strTable, string.format("<font color=#%s>&nbsp;&nbsp;%s</font>", ItemTipsMgr.Color.Yellow, textRes.Fabao[119]))
  else
    table.insert(strTable, string.format("<font color=#%s>&nbsp;&nbsp;%s</font>", ItemTipsMgr.Color.Yellow, textRes.Fabao[74]))
    table.insert(strTable, "<br/>")
    table.insert(strTable, string.format("<font color=#%s>&nbsp;&nbsp;%s</font>", ItemTipsMgr.Color.Yellow, textRes.Fabao[73]))
  end
  table.insert(strTable, "<br/>")
  local Html = string.format("<p align=left valign=middle><font size=22 color=#%s>%s%s</font></p>", ItemTipsMgr.Color.White, table.concat(strTable), itemBase.desc)
  return Html
end
def.method("table", "table", "=>", "string").GetLongJingDescription = function(self, item, itemBase)
  return self:GetLongJingBasicDescription(item.id)
end
def.method("number", "=>", "string").GetLongJingBasicDescription = function(self, itemId)
  local EquipModule = require("Main.Equip.EquipModule")
  local longjingCfg = ItemUtils.GetLongJingItem(itemId)
  local attrIds = longjingCfg.attrIds
  local attrValues = longjingCfg.attrValues
  local strTable = {}
  local attrNum = #attrIds
  for i = 1, attrNum do
    local attrId = attrIds[i]
    local attrValue = attrValues[i]
    if attrId and 0 ~= attrId and attrValue then
      local attrName = require("Main.Fabao.FabaoUtils").GetFabaoProName(attrId)
      table.insert(strTable, string.format("<font color=#%s>%s: +%d</font></br>", ItemTipsMgr.Color.Content, attrName, attrValue))
    end
  end
  return table.concat(strTable)
end
def.method("table", "table", "=>", "string").GetFabaoSpiritDescription = function(self, item, itemBase)
  local FabaoSpiritInterface = require("Main.FabaoSpirit.FabaoSpiritInterface")
  local FabaoSpiritModule = require("Main.FabaoSpirit.FabaoSpiritModule")
  local FabaoSpiritUtils = require("Main.FabaoSpirit.FabaoSpiritUtils")
  local strTable = {}
  local LQClsBasicCfgInfo = FabaoSpiritInterface.GetClsCfgByItemId(item.id)
  table.insert(strTable, string.format("<font color=#%s>%s %d%s<font>", ItemTipsMgr.Color.Gold, textRes.Item[8003], LQClsBasicCfgInfo.LQBasicCfg.level, textRes.Item[128]))
  table.insert(strTable, "<br/>")
  table.insert(strTable, string.format("<font color=#%s>%s</font>", ItemTipsMgr.Color.Attr, textRes.Item[8211]))
  table.insert(strTable, "<br/>")
  local LQPropCfg = FabaoSpiritUtils.GetFabaoLQPropCfgById(LQClsBasicCfgInfo.LQBasicCfg.id)
  if LQPropCfg ~= nil then
    local arrProp = LQPropCfg.arrPropValues
    local tmpProps = {}
    if item ~= nil and item.properties ~= nil then
      for prop, val in pairs(item.properties) do
        table.insert(tmpProps, {propType = prop, initVal = val})
      end
    end
    if #tmpProps > 0 then
      arrProp = tmpProps
    end
    for i = 1, #arrProp do
      local propCfg = arrProp[i]
      local proName = FabaoSpiritUtils.GetFabaoSpiritProName(propCfg.propType)
      if propCfg.propType ~= 0 then
        local color = ItemTipsMgr.Color[itemBase.namecolor] or ItemTipsMgr.Color.Attr
        local proRealValue = propCfg.initVal
        table.insert(strTable, string.format("<font color=#%s>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;%s  + %d</font>", color, proName, proRealValue))
        table.insert(strTable, "<br/>")
      end
    end
  else
    warn("LQ has no property.")
  end
  table.insert(strTable, string.format("<font color=#%s>%s</font>", ItemTipsMgr.Color.Attr, textRes.Item[8213]))
  table.insert(strTable, "<br/>")
  local skillId = LQClsBasicCfgInfo.LQBasicCfg.skillId
  if skillId and skillId ~= 0 then
    local skillCfg = require("Main.Skill.SkillUtility").GetSkillCfg(skillId)
    table.insert(strTable, string.format("<a href='fabaoSkill' id=se_%d><font color=#%s>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[%s]</font></a><br/>", skillId, ItemTipsMgr.Color.Content, skillCfg.name))
  else
    table.insert(strTable, string.format("<font color=#%s>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;%s</font></a><br/>", ItemTipsMgr.Color.Content, textRes.Item[8121]))
  end
  table.insert(strTable, "<br/>")
  return table.concat(strTable)
end
def.method("table", "table", "=>", "string").GetPetBagDescription = function(self, item, itemBase)
  local strTable = {}
  local SkillUtils = require("Main.Skill.SkillUtility")
  local petBagCfg = ItemUtils.GetPetBagCfg(item.id)
  if petBagCfg == nil then
    return ""
  end
  local PetQualityType = require("netio.protocol.mzm.gsp.pet.PetAptConsts")
  local petCfg = PetUtility.Instance():GetPetCfg(petBagCfg.petId)
  table.insert(strTable, textRes.Item[8203])
  table.insert(strTable, string.format("%.3f~%.3f", petCfg.growMinValue, petCfg.growMaxValue))
  table.insert(strTable, "<br/>")
  local function GetQualityTuple(qualityType)
    return petCfg:GetMinQuality(qualityType) or 0, petCfg:GetMaxQuality(qualityType) or 0
  end
  table.insert(strTable, textRes.Item[9000])
  table.insert(strTable, string.format("%d~%d", GetQualityTuple(PetQualityType.HP_APT)))
  table.insert(strTable, "<br/>")
  table.insert(strTable, textRes.Item[9001])
  table.insert(strTable, string.format("%d~%d", GetQualityTuple(PetQualityType.PHYATK_APT)))
  table.insert(strTable, "<br/>")
  table.insert(strTable, textRes.Item[9002])
  table.insert(strTable, string.format("%d~%d", GetQualityTuple(PetQualityType.MAGATK_APT)))
  table.insert(strTable, "<br/>")
  table.insert(strTable, textRes.Item[9003])
  table.insert(strTable, string.format("%d~%d", GetQualityTuple(PetQualityType.PHYDEF_APT)))
  table.insert(strTable, "<br/>")
  table.insert(strTable, textRes.Item[9004])
  table.insert(strTable, string.format("%d~%d", GetQualityTuple(PetQualityType.MAGDEF_APT)))
  table.insert(strTable, "<br/>")
  table.insert(strTable, textRes.Item[9005])
  table.insert(strTable, string.format("%d~%d", GetQualityTuple(PetQualityType.SPEED_APT)))
  table.insert(strTable, "<br/>")
  local skillRandomCfg = SkillUtils.GetMonsterSkillCfg(petCfg.skillPropTabId)
  if skillRandomCfg and #skillRandomCfg > 0 then
    table.insert(strTable, textRes.Item[8209])
    table.insert(strTable, "<br/>")
    for i = 1, #skillRandomCfg do
      local skillId = skillRandomCfg[i]
      local skillName = PetUtility.Instance():GetPetSkillCfg(skillId).name
      table.insert(strTable, string.format("<a href='petskill' id=sp_%d><font color=#%s>[%s]</font></a><br/>", skillId, ItemTipsMgr.Color.Yellow, skillName))
    end
  end
  return table.concat(strTable)
end
def.method("table", "table", "=>", "string").GetFlowerDescription = function(self, item, itemBase)
  return self:GetFlowerBasicDescription(item.id)
end
def.method("number", "=>", "string").GetFlowerBasicDescription = function(self, itemId)
  local flowerCfg = ItemUtils.GetFlowerItemCfg(itemId)
  return string.format("<font color=#%s>%s</font></br>", ItemTipsMgr.Color.Content, string.format(textRes.Item[10007], flowerCfg.addIntimacyNum))
end
def.method("table", "table", "=>", "string").GetFabaoExpDescription = function(self, item, itemBase)
  return self:GetFabaoExpBasicDescription(item.id)
end
def.method("number", "=>", "string").GetFabaoExpBasicDescription = function(self, itemId)
  local fabaoCfg = ItemUtils.GetFabaoExpItem(itemId)
  return string.format("<font color=#%s>%s</font></br>", ItemTipsMgr.Color.Content, string.format(textRes.Item[10009], fabaoCfg.exp))
end
def.method("table", "table", "=>", "string").GetXiuLianExpDescription = function(self, item, itemBase)
  return self:GetXiuLianExpBasicDescription(item.id)
end
def.method("number", "=>", "string").GetXiuLianExpBasicDescription = function(self, itemId)
  local xiulianCfg = ItemUtils.GetXiuLianExpCfg(itemId)
  return string.format("<font color=#%s>%s</font></br>", ItemTipsMgr.Color.Content, string.format(textRes.Item[10008], xiulianCfg.addExpNum))
end
def.method("table", "table", "=>", "string").GetFashionDressItemDescription = function(self, item, itemBase)
  return self:GetFashionDressItemBasicDescription(item.id)
end
def.method("number", "=>", "string").GetFashionDressItemBasicDescription = function(self, itemId)
  local fashionItem = require("Main.Fashion.FashionUtils").GetFashionItemByUnlockItemId(itemId)
  local desc = ""
  if fashionItem then
    local skillEffects = fashionItem.effects
    local effectDesc = {}
    for i = 1, #skillEffects do
      local skillId = skillEffects[i]
      local skillCfg = require("Main.Skill.SkillUtility").GetSkillCfg(skillId)
      if skillCfg ~= nil then
        table.insert(effectDesc, string.format("<font color=#%s><a href='fashionskill' id=fashionskill_%d>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[%s]</a></font></br>", ItemTipsMgr.Color.Green, skillId, skillCfg.name))
      end
    end
    if #effectDesc > 0 then
      desc = string.format("<font color=#%s>%s</font></br>%s", ItemTipsMgr.Color.Yellow, textRes.Item[10010], table.concat(effectDesc, ""))
    end
    local skillProperties = fashionItem.properties
    local propertyDesc = {}
    for i = 1, #skillProperties do
      local skillId = skillProperties[i]
      local skillCfg = require("Main.Skill.SkillUtility").GetSkillCfg(skillId)
      if skillCfg ~= nil then
        table.insert(propertyDesc, string.format("<font color=#%s>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;%s</font></br>", ItemTipsMgr.Color.Green, skillCfg.description))
      end
    end
    if #propertyDesc > 0 then
      desc = string.format("%s<font color=#%s>%s</font></br>%s", desc, ItemTipsMgr.Color.Yellow, textRes.Item[10011], table.concat(propertyDesc, ""))
    end
  end
  return desc
end
def.method("table", "table", "=>", "string").GetPetDecorateDescription = function(self, item, itemBase)
  local petdecorateCfg = PetUtility.GetPetDecorateItemCfg(itemBase.itemid)
  if petdecorateCfg then
    local petCatchLevel = petdecorateCfg.petCatchLevel
    local title = textRes.Pet[168]
    local desc = ""
    if itemBase.name == textRes.Pet[169] then
      desc = textRes.Pet[166]
    elseif itemBase.name == textRes.Pet[170] then
      desc = textRes.Pet[167]
    else
      desc = string.format(textRes.Pet[165], petCatchLevel)
    end
    return string.format("<font color=#%s>%s %s</font></br>", ItemTipsMgr.Color.Content, title, desc)
  else
    return ""
  end
end
def.method("table", "table", "=>", "string").GetFurnitureDescription = function(self, item, itemBase)
  local furnitureCfg = ItemUtils.GetFurnitureCfg(itemBase.itemid)
  if furnitureCfg == nil then
    return ""
  end
  local FurnitureAreaEnum = require("consts.mzm.gsp.item.confbean.FurnitureAreaEnum")
  local strTable = {}
  local addFengShuiValue = furnitureCfg.addFengShuiValue
  local addBeautifulValue = furnitureCfg.addBeautifulValue
  local area = furnitureCfg.area
  if area == FurnitureAreaEnum.ROOM and addFengShuiValue > 0 then
    local desc = string.format(textRes.Item[10020], addFengShuiValue)
    desc = string.format("<font color=#%s>%s</font>", ItemTipsMgr.Color.Content, desc)
    table.insert(strTable, desc)
  elseif area == FurnitureAreaEnum.COURT_YARD and addBeautifulValue > 0 then
    local desc = string.format(textRes.Item[10021], addBeautifulValue)
    desc = string.format("<font color=#%s>%s</font>", ItemTipsMgr.Color.Content, desc)
    table.insert(strTable, desc)
  end
  table.insert(strTable, "<br/>")
  return table.concat(strTable, "")
end
def.method("table", "table", "=>", "string").GetExpBottleItemDesc = function(self, item, itemBase)
  local curExp = item.extraMap[ItemXStoreType.LEFT_BOTTLE_EXP_VALUE]
  local totalExp = item.extraMap[ItemXStoreType.TOTAL_BOTTLE_EXP_VALUE]
  if curExp == nil or totalExp == nil then
    return ""
  end
  return string.format("<font color=#%s>%s</font></br>", ItemTipsMgr.Color.Content, string.format(textRes.Item[8375], curExp, totalExp))
end
def.method("table", "table", "=>", "string").GetDoubleItemDesc = function(self, item, itemBase)
  local curTimes = item.extraMap[ItemXStoreType.LEFT_DOUBLE_ITEM_USE_TIMES]
  local itemCfg = ItemUtils.GetDoubleItemCfg(itemBase.itemid)
  if curTimes == nil or itemCfg == nil then
    return ""
  end
  return string.format("<font color=#%s>%s</font></br>", ItemTipsMgr.Color.Content, string.format(textRes.Item[8377], curTimes, itemCfg.totalTimes))
end
def.method("table", "table", "=>", "string").GetGodWeaponJewelDesc = function(self, item, itemBase)
  local strTable = {}
  local JewelUtils = require("Main.GodWeapon.Jewel.JewelUtils")
  local jewelCfg = JewelUtils.GetJewelItemByItemId(item.id, false)
  if jewelCfg ~= nil then
    local color = ItemTipsMgr.Color.Content
    item.level = jewelCfg.level
    for i = 1, #jewelCfg.arrProps do
      local prop = jewelCfg.arrProps[i]
      if prop.propType > 0 then
        local propName = JewelUtils.GetProName(prop.propType)
        local proRealValue = prop.propVal
        table.insert(strTable, string.format("<font color=#%s>%s  + %d</font>", color, propName, proRealValue))
        table.insert(strTable, "<br/>")
      end
    end
  else
    table.insert(strTable, string.format("<font color=#%s>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;%s</font></a>", ItemTipsMgr.Color.Content, textRes.Item[8121]))
    table.insert(strTable, "<br/>")
  end
  return table.concat(strTable)
end
def.method("number", "=>", "string").GetGodWeaponJewelSimpleDesc = function(self, itemId)
  local JewelUtils = require("Main.GodWeapon.Jewel.JewelUtils")
  local jewelBasicCfg = JewelUtils.GetJewelItemByItemId(itemId, false)
  local arrProps = jewelBasicCfg and jewelBasicCfg.arrProps or {}
  local strTable = {}
  local attrNum = #arrProps
  for i = 1, attrNum do
    local propType = arrProps[i].propType
    local propVal = arrProps[i].propVal
    if propType and 0 ~= propType and propVal then
      local attrName = JewelUtils.GetProName(propType)
      table.insert(strTable, string.format("<font color=#%s>%s: +%d</font>", ItemTipsMgr.Color.Content, attrName, propVal))
      table.insert(strTable, "<br/>")
    end
  end
  return table.concat(strTable)
end
def.method("table", "table", "=>", "string").GetRevengeCardDesc = function(self, item, itemBase)
  local strTable = {}
  local txtConst = textRes.PlayerPK.PK
  local iCanUseTimes = item.extraMap[ItemXStoreType.PK_REVENGE_ITEM_AVAILABLE_TIMES]
  if iCanUseTimes == nil then
    local itemCfg = require("Main.PlayerPK.PK.PKInterface").GetRevengeItemCfgById(item.id)
    iCanUseTimes = itemCfg and itemCfg.maxQueryTime or 0
  end
  local roleId = require("Main.PlayerPK.PKMgr").GetRoleIdFromItem(item)
  table.insert(strTable, string.format(txtConst[24], iCanUseTimes))
  table.insert(strTable, "<br/>")
  if roleId == nil then
    table.insert(strTable, string.format(txtConst[25], txtConst[46]))
  else
    table.insert(strTable, txtConst[25])
    table.insert(strTable, "<br/>")
    table.insert(strTable, txtConst[62])
  end
  table.insert(strTable, "<br/>")
  return table.concat(strTable)
end
def.method("table", "table", "=>", "string").GetSimpleChainGiftItemDesc = function(self, item, itemBase)
  local chainGiftCfg = ItemUtils.GetChainGiftBagCfg(itemBase.itemid)
  if chainGiftCfg == nil then
    return ""
  end
  local totalGiftNum = #chainGiftCfg.chainGifts
  for i = 1, #chainGiftCfg.chainGifts do
    if chainGiftCfg.chainGifts[i] == itemBase.itemid then
      totalGiftNum = totalGiftNum - i + 1
      break
    end
  end
  return string.format("<font color=#%s>%s</font></br>", ItemTipsMgr.Color.Content, string.format(textRes.Item[12001], totalGiftNum))
end
def.method("table", "table", "=>", "string").GetChainGiftItemDesc = function(self, item, itemBase)
  local chainGiftCfg = ItemUtils.GetChainGiftBagCfg(itemBase.itemid)
  if chainGiftCfg == nil then
    return ""
  end
  local timeStr = ""
  local endTime = item.extraMap[ItemXStoreType.CHAINED_GIFT_BAG_USE_TIME] or 0
  local curTime = _G.GetServerTime()
  if endTime - curTime > 0 then
    local leftTimeStr = _G.SeondsToTimeText(endTime - curTime)
    timeStr = string.format("<font color=#%s>%s</font></br>", ItemTipsMgr.Color.Content, string.format(textRes.Item[12003], leftTimeStr))
  else
    timeStr = string.format("<font color=#%s>%s</font></br>", ItemTipsMgr.Color.Content, textRes.Item[12006])
  end
  local totalGiftNum = #chainGiftCfg.chainGifts
  local leftGiftNum = 0
  for i = 1, #chainGiftCfg.chainGifts do
    if chainGiftCfg.chainGifts[i] == itemBase.itemid then
      leftGiftNum = totalGiftNum - i + 1
      break
    end
  end
  local numStr = string.format("<font color=#%s>%s</font></br>", ItemTipsMgr.Color.Content, string.format(textRes.Item[12002], leftGiftNum, totalGiftNum))
  return timeStr .. numStr
end
def.method("table", "table", "=>", "string").GetDuoBaoItemDesc = function(self, item, itemBase)
  local activityId = item.extraMap[ItemXStoreType.INDIANA_ACTIVITY_CFG_ID]
  local turnId = item.extraMap[ItemXStoreType.INDIANA_ACTIVITY_TURN]
  local sortId = item.extraMap[ItemXStoreType.INDIANA_SORT_ID]
  local code = item.extraMap[ItemXStoreType.INDIANA_NUMBER]
  local codeStr = ""
  if activityId and turnId and sortId and code then
    local YiYuanDuoBaoUtils = require("Main.YiYuanDuoBao.YiYuanDuoBaoUtils")
    local turnCfg = YiYuanDuoBaoUtils.GetTurnCfg(activityId, turnId)
    if turnCfg then
      local awardCfg = turnCfg.awards[sortId]
      if awardCfg then
        local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
        local diaplay_turn = turnCfg.diaplay_turn
        local beginTimeTbl = AbsoluteTimer.GetServerTimeTable(turnCfg.begin_timestamp)
        local endTimeTbl = AbsoluteTimer.GetServerTimeTable(turnCfg.end_timestamp)
        local awardItems = ItemUtils.GetAwardItems(awardCfg.fix_award_id)
        if awardItems and awardItems[1] then
          local itemBase = ItemUtils.GetItemBase(awardItems[1].itemId)
          if itemBase then
            codeStr = string.format(textRes.YiYuanDuoBao[21], beginTimeTbl.month, beginTimeTbl.day, diaplay_turn, itemBase.name, endTimeTbl.month, endTimeTbl.day, endTimeTbl.hour, endTimeTbl.min, YiYuanDuoBaoUtils.ConvertToDisplayNumber(code, YiYuanDuoBaoUtils.CalcOffset(turnId, sortId)))
          end
        end
      end
    end
  end
  return string.format("<font color=#%s>%s</font></br>", ItemTipsMgr.Color.Content, codeStr)
end
def.method("table", "table", "=>", "string").GetEquipBlessItemDesc = function(self, item, itemBase)
  local equipBlessItemCfg = ItemUtils.GetEquipBlessItemCfg(itemBase.itemid)
  if equipBlessItemCfg == nil then
    return ""
  end
  return string.format("<font color=#%s>%s</font></br>", ItemTipsMgr.Color.Content, string.format(textRes.Item[12200], equipBlessItemCfg.minBlessValue, equipBlessItemCfg.maxBlessValue))
end
def.method("table", "table", "=>", "string").GetChatBubbleDesc = function(self, item, itemBase)
  local ChatBubbleUtils = require("Main.Chat.ChatBubble.ChatBubbleUtils")
  local bubbleCfgId = ChatBubbleUtils.GetCfgIdByItemId(itemBase.itemid) or 0
  local bubbleCfg = ChatBubbleUtils.GetBubbleCfgById(bubbleCfgId)
  if bubbleCfg == nil then
    return ""
  end
  local sec = bubbleCfg.duration * 3600
  local timeStr = ""
  local txtConst = textRes.Chat.ChatBubble
  if sec < 1 then
    timeStr = txtConst[10]
  elseif sec > 86400 then
    local day = math.floor(sec / 86400)
    local hour = math.floor(sec % 86400 / 3600)
    timeStr = txtConst[3]:format(day, txtConst[4], hour, txtConst[5])
  elseif sec > 3600 then
    local hour = math.floor(sec / 3600)
    local min = math.floor(sec % 3600 / 60)
    timeStr = txtConst[3]:format(hour, txtConst[5], min, txtConst[6])
  else
    local min = math.floor(sec / 60)
    local sec = math.floor(sec % 60)
    timeStr = txtConst[3]:format(min, txtConst[6], sec, txtConst[7])
  end
  timeStr = txtConst[21] .. timeStr
  return string.format("<font color=#%s>%s</font></br>", ItemTipsMgr.Color.Content, timeStr)
end
def.method("table", "table", "=>", "string").GetTurnedCardDescription = function(self, item, itemBase)
  return self:GetTurnedCardBasicDescription(item.id)
end
def.method("number", "=>", "string").GetTurnedCardBasicDescription = function(self, itemId)
  local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
  local cardItemCfg = TurnedCardUtils.GetChangeModelCardItemCfg(itemId)
  if cardItemCfg then
    local cardCfg = TurnedCardUtils.GetChangeModelCardCfg(cardItemCfg.cardCfgId)
    local classCfg = TurnedCardUtils.GetCardClassCfg(cardCfg.classType)
    local cardLevelCfg = TurnedCardUtils.GetCardLevelCfg(cardItemCfg.cardCfgId)
    local curLevelCfg = cardLevelCfg.cardLevels[cardItemCfg.cardLevel]
    local attrStr = ""
    if curLevelCfg then
      local attrStrs = {}
      local ProValueType = require("consts.mzm.gsp.common.confbean.ProValueType")
      for i, v in ipairs(curLevelCfg.propertys) do
        local propertyCfg = _G.GetCommonPropNameCfg(v.propType)
        if propertyCfg then
          local str
          if propertyCfg.valueType == ProValueType.TEN_THOUSAND_RATE then
            str = propertyCfg.propName .. "+" .. v.value / 100 .. "%"
          else
            str = propertyCfg.propName .. "+" .. v.value
          end
          table.insert(attrStrs, str)
        end
      end
      attrStr = table.concat(attrStrs, "\239\188\140")
    end
    return string.format("<font color=#%s>%s</br></br>%s</font></br>", ItemTipsMgr.Color.Content, string.format(textRes.TurnedCard[31], classCfg.className), attrStr)
  end
end
def.method("table", "table", "=>", "string").GetTurnedCardFragmentDescription = function(self, item, itemBase)
  return self:GetTurnedCardFragmentBasicDescription(item.id)
end
def.method("number", "=>", "string").GetTurnedCardFragmentBasicDescription = function(self, itemId)
  local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
  local cardFragmentCfg = TurnedCardUtils.GetChangeModelCardFragmentCfg(itemId)
  if cardFragmentCfg then
    local cardCfg = TurnedCardUtils.GetChangeModelCardCfg(cardFragmentCfg.cardCfgId)
    local classCfg = TurnedCardUtils.GetCardClassCfg(cardCfg.classType)
    return string.format("<font color=#%s>%s</font></br>", ItemTipsMgr.Color.Content, string.format(textRes.TurnedCard[31], classCfg.className))
  end
end
def.method("table", "table", "=>", "string").GetCakeDesc = function(self, item, itemBase)
  local bakerInfo = textRes.Item[13201]
  return string.format("<font color=#%s>%s</font></br>", ItemTipsMgr.Color.Content, bakerInfo)
end
def.method("table", "table", "=>", "string").GetPetMarkItemDescription = function(self, item, itemBase)
  local PetMarkUtils = require("Main.Pet.PetMark.PetMarkUtils")
  local markItemCfg = PetMarkUtils.GetPetMarkItemCfg(itemBase.itemid)
  if markItemCfg == nil then
    return ""
  end
  local petMarkLevelCfg = PetMarkUtils.GetPetMarkLevelCfgByLevel(markItemCfg.petMarkCfgId, markItemCfg.level)
  if petMarkLevelCfg == nil then
    return ""
  end
  local propDesc = ""
  if #petMarkLevelCfg.propList > 0 then
    local strTable = {}
    for i = 1, #petMarkLevelCfg.propList do
      local propertyCfg = _G.GetCommonPropNameCfg(petMarkLevelCfg.propList[i].propType)
      local propName = propertyCfg and propertyCfg.propName or ""
      local propValue = _G.PropValueToText(petMarkLevelCfg.propList[i].propValue, propertyCfg.valueType)
      table.insert(strTable, string.format("&nbsp;&nbsp;&nbsp;&nbsp;%s %s", propName, propValue))
    end
    propDesc = string.format("<font color=#%s>%s</font></br>", ItemTipsMgr.Color.Yellow, textRes.Item[10011]) .. string.format("<font color=#%s>%s</font></br>", ItemTipsMgr.Color.Content, table.concat(strTable, "</br>"))
  end
  local skillDesc = ""
  local skillId = petMarkLevelCfg.passiveSkillId
  if skillId ~= 0 then
    local strTable = {}
    local skillCfg = require("Main.Skill.SkillUtility").GetSkillCfg(skillId)
    if skillCfg then
      local skillName = skillCfg.name
      table.insert(strTable, string.format("<font color=#%s>%s</font></br>", ItemTipsMgr.Color.Yellow, textRes.Item[8209]))
      table.insert(strTable, string.format("<a href='equipskill' id=se_%d><font color=#%s>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[%s]</font></a><br/>", skillId, ItemTipsMgr.Color.Content, skillName))
    end
    skillDesc = table.concat(strTable, "")
  end
  return propDesc .. skillDesc
end
ItemTipsMgr.Commit()
return ItemTipsMgr
