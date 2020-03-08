local Lplus = require("Lplus")
local PetMarkMgr = Lplus.Class("PetMarkMgr")
local def = PetMarkMgr.define
local PetMarkDataMgr = require("Main.Pet.PetMark.PetMarkDataMgr")
local PetMarkUtils = require("Main.Pet.PetMark.PetMarkUtils")
def.field("boolean").isDrawLottry = false
def.field("boolean").hasNewItemNotify = false
local instance
def.static("=>", PetMarkMgr).Instance = function()
  if instance == nil then
    instance = PetMarkMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petmark.SSynPetMarkInfo", PetMarkMgr.OnSSynPetMarkInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petmark.SSynPetMarkUnequip", PetMarkMgr.OnSSynPetMarkUnequip)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petmark.SUnlockPetMarkSuccess", PetMarkMgr.OnSUnlockPetMarkSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petmark.SUnlockPetMarkFail", PetMarkMgr.OnSUnlockPetMarkFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petmark.SEquipPetMarkSuccess", PetMarkMgr.OnSEquipPetMarkSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petmark.SEquipPetMarkFail", PetMarkMgr.OnSEquipPetMarkFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petmark.SUnequipPetMarkSuccess", PetMarkMgr.OnSUnequipPetMarkSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petmark.SUnequipPetMarkFail", PetMarkMgr.OnSUnequipPetMarkFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petmark.SPetMarkUpgradeWithMarkSuccess", PetMarkMgr.OnSPetMarkUpgradeWithMarkSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petmark.SPetMarkUpgradeWithMarkFail", PetMarkMgr.OnSPetMarkUpgradeWithMarkFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petmark.SPetMarkUpgradeWithItemSuccess", PetMarkMgr.OnSPetMarkUpgradeWithItemSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petmark.SPetMarkUpgradeWithItemFail", PetMarkMgr.OnSPetMarkUpgradeWithItemFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petmark.SPetMarkUpgradeUseAllSuccess", PetMarkMgr.OnSPetMarkUpgradeUseAllSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petmark.SPetMarkUpgradeUseAllFail", PetMarkMgr.OnSPetMarkUpgradeUseAllFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petmark.SPetMarkDecomposeSuccess", PetMarkMgr.OnSPetMarkDecomposeSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petmark.SPetMarkDecomposeFail", PetMarkMgr.OnSPetMarkDecomposeFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petmark.SPetMarkItemDecomposeSuccess", PetMarkMgr.OnSPetMarkItemDecomposeSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petmark.SPetMarkItemDecomposeFail", PetMarkMgr.OnSPetMarkItemDecomposeFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petmark.SPetMarkDecomposeAllSuccess", PetMarkMgr.OnSPetMarkDecomposeAllSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petmark.SPetMarkDecomposeAllFail", PetMarkMgr.OnSPetMarkDecomposeAllFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petmark.SPetMarkLotteryDrawSuccess", PetMarkMgr.OnSPetMarkLotteryDrawSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petmark.SPetMarkLotteryDrawFail", PetMarkMgr.OnSPetMarkLotteryDrawFail)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Get_NewOne, PetMarkMgr.OnItemGetNewOne)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, PetMarkMgr.OnLeaveWorld)
end
def.static("table").OnSSynPetMarkInfo = function(p)
  PetMarkDataMgr.Instance():SetPetMarkMap(p.pet_mark_info_map)
  PetMarkDataMgr.Instance():SetPetMarkEquipMap(p.pet_mark_equip_map)
end
def.static("table").OnSSynPetMarkUnequip = function(p)
  PetMarkDataMgr.Instance():SetMarkEquipPet(p.pet_mark_id, nil)
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_MARK_EQUIP_PET_CHANGE, {
    petMarkId = p.pet_mark_id
  })
end
def.static("table").OnSUnlockPetMarkSuccess = function(p)
  Toast(textRes.Pet.PetMark[3])
  PetMarkDataMgr.Instance():SetPetMarkInfo(p.pet_mark_id, p.pet_mark_info)
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_MARK_UNLOCK_SUCCESS, {
    petMarkId = p.pet_mark_id
  })
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_MARK_LIST_UPDATE, nil)
end
def.static("table").OnSUnlockPetMarkFail = function(p)
  if textRes.Pet.PetMark.SUnlockPetMarkFail[p.error_code] then
    Toast(textRes.Pet.PetMark.SUnlockPetMarkFail[p.error_code])
  else
    Toast(string.format(textRes.Pet.PetMark.SUnlockPetMarkFail[0], p.error_code))
  end
end
def.static("table").OnSEquipPetMarkSuccess = function(p)
  Toast(textRes.Pet.PetMark[5])
  local preEquipMarkId = PetMarkDataMgr.Instance():GetPetEquipMarkId(p.pet_id)
  PetMarkDataMgr.Instance():SetMarkEquipPet(p.pet_mark_id, p.pet_id)
  if preEquipMarkId ~= nil then
    PetMarkDataMgr.Instance():SetMarkEquipPet(preEquipMarkId, nil)
  end
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_MARK_EQUIP_PET_CHANGE, {
    petMarkId = p.pet_mark_id
  })
end
def.static("table").OnSEquipPetMarkFail = function(p)
  if textRes.Pet.PetMark.SEquipPetMarkFail[p.error_code] then
    Toast(textRes.Pet.PetMark.SEquipPetMarkFail[p.error_code])
  else
    Toast(string.format(textRes.Pet.PetMark.SEquipPetMarkFail[0], p.error_code))
  end
end
def.static("table").OnSUnequipPetMarkSuccess = function(p)
  Toast(textRes.Pet.PetMark[6])
  PetMarkDataMgr.Instance():SetMarkEquipPet(p.pet_mark_id, nil)
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_MARK_EQUIP_PET_CHANGE, {
    petMarkId = p.pet_mark_id
  })
end
def.static("table").OnSUnequipPetMarkFail = function(p)
  if textRes.Pet.PetMark.SUnequipPetMarkFail[p.error_code] then
    Toast(textRes.Pet.PetMark.SUnequipPetMarkFail[p.error_code])
  else
    Toast(string.format(textRes.Pet.PetMark.SUnequipPetMarkFail[0], p.error_code))
  end
end
def.static("table").OnSPetMarkUpgradeWithMarkSuccess = function(p)
  local mark = PetMarkDataMgr.Instance():GetPetMarkInfo(p.main_pet_mark_id)
  local preLevel = mark:GetLevel()
  mark:SetLevel(p.now_level)
  mark:SetExp(p.now_exp)
  PetMarkDataMgr.Instance():SetPetMarkInfo(p.cost_pet_mark_id, nil)
  for k, v in pairs(p.new_pet_mark_info_map) do
    PetMarkDataMgr.Instance():SetPetMarkInfo(k, v)
  end
  Toast(string.format(textRes.Pet.PetMark[12], p.add_exp))
  if preLevel < p.now_level then
    Toast(string.format(textRes.Pet.PetMark[13], p.now_level))
  end
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_MARK_LIST_UPDATE, nil)
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_MARK_INFO_CHANGE, {
    petMarkId = p.main_pet_mark_id
  })
end
def.static("table").OnSPetMarkUpgradeWithMarkFail = function(p)
  if textRes.Pet.PetMark.SPetMarkUpgradeWithMarkFail[p.error_code] then
    Toast(textRes.Pet.PetMark.SPetMarkUpgradeWithMarkFail[p.error_code])
  else
    Toast(string.format(textRes.Pet.PetMark.SPetMarkUpgradeWithMarkFail[0], p.error_code))
  end
end
def.static("table").OnSPetMarkUpgradeWithItemSuccess = function(p)
  local mark = PetMarkDataMgr.Instance():GetPetMarkInfo(p.main_pet_mark_id)
  local preLevel = mark:GetLevel()
  mark:SetLevel(p.now_level)
  mark:SetExp(p.now_exp)
  Toast(string.format(textRes.Pet.PetMark[12], p.add_exp))
  if preLevel < p.now_level then
    Toast(string.format(textRes.Pet.PetMark[13], p.now_level))
  end
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_MARK_INFO_CHANGE, {
    petMarkId = p.main_pet_mark_id
  })
end
def.static("table").OnSPetMarkUpgradeWithItemFail = function(p)
  if textRes.Pet.PetMark.SPetMarkUpgradeWithItemFail[p.error_code] then
    Toast(textRes.Pet.PetMark.SPetMarkUpgradeWithItemFail[p.error_code])
  else
    Toast(string.format(textRes.Pet.PetMark.SPetMarkUpgradeWithItemFail[0], p.error_code))
  end
end
def.static("table").OnSPetMarkUpgradeUseAllSuccess = function(p)
  local mark = PetMarkDataMgr.Instance():GetPetMarkInfo(p.main_pet_mark_id)
  local preLevel = mark:GetLevel()
  mark:SetLevel(p.now_level)
  mark:SetExp(p.now_exp)
  for k, v in pairs(p.cost_pet_mark_ids) do
    PetMarkDataMgr.Instance():SetPetMarkInfo(v, nil)
  end
  for k, v in pairs(p.new_pet_mark_info_map) do
    PetMarkDataMgr.Instance():SetPetMarkInfo(k, v)
  end
  Toast(string.format(textRes.Pet.PetMark[12], p.add_exp))
  if preLevel < p.now_level then
    Toast(string.format(textRes.Pet.PetMark[13], p.now_level))
  end
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_MARK_LIST_UPDATE, nil)
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_MARK_INFO_CHANGE, {
    petMarkId = p.main_pet_mark_id
  })
end
def.static("table").OnSPetMarkUpgradeUseAllFail = function(p)
  if textRes.Pet.PetMark.SPetMarkUpgradeUseAllFail[p.error_code] then
    Toast(textRes.Pet.PetMark.SPetMarkUpgradeUseAllFail[p.error_code])
  else
    Toast(string.format(textRes.Pet.PetMark.SPetMarkUpgradeUseAllFail[0], p.error_code))
  end
end
def.static("table").OnSPetMarkDecomposeSuccess = function(p)
  PetMarkDataMgr.Instance():SetPetMarkInfo(p.pet_mark_id, nil)
  local scoreTbl = {}
  for k, v in pairs(p.get_score_map) do
    local ItemUtils = require("Main.Item.ItemUtils")
    local tokenCfg = ItemUtils.GetTokenCfg(k)
    table.insert(scoreTbl, string.format(textRes.Pet.PetMark[24], tokenCfg.name, v))
  end
  local scoreStr = table.concat(scoreTbl, "\239\188\140")
  Toast(string.format(textRes.Pet.PetMark[23], scoreStr))
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_MARK_LIST_UPDATE, nil)
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_MARK_REMOVE, {
    petMarkId = p.pet_mark_id
  })
end
def.static("table").OnSPetMarkDecomposeFail = function(p)
  if textRes.Pet.PetMark.SPetMarkDecomposeFail[p.error_code] then
    Toast(textRes.Pet.PetMark.SPetMarkDecomposeFail[p.error_code])
  else
    Toast(string.format(textRes.Pet.PetMark.SPetMarkDecomposeFail[0], p.error_code))
  end
end
def.static("table").OnSPetMarkItemDecomposeSuccess = function(p)
  local scoreTbl = {}
  for k, v in pairs(p.get_score_map) do
    local ItemUtils = require("Main.Item.ItemUtils")
    local tokenCfg = ItemUtils.GetTokenCfg(k)
    table.insert(scoreTbl, string.format(textRes.Pet.PetMark[24], tokenCfg.name, v))
  end
  local scoreStr = table.concat(scoreTbl, "\239\188\140")
  Toast(string.format(textRes.Pet.PetMark[23], scoreStr))
end
def.static("table").OnSPetMarkItemDecomposeFail = function(p)
  if textRes.Pet.PetMark.SPetMarkItemDecomposeFail[p.error_code] then
    Toast(textRes.Pet.PetMark.SPetMarkItemDecomposeFail[p.error_code])
  else
    Toast(string.format(textRes.Pet.PetMark.SPetMarkItemDecomposeFail[0], p.error_code))
  end
end
def.static("table").OnSPetMarkDecomposeAllSuccess = function(p)
  for k, v in pairs(p.cost_pet_mark_ids) do
    PetMarkDataMgr.Instance():SetPetMarkInfo(v, nil)
    Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_MARK_REMOVE, {
      petMarkId = p.pet_mark_id
    })
  end
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_MARK_LIST_UPDATE, nil)
  local scoreTbl = {}
  for k, v in pairs(p.get_score_map) do
    local ItemUtils = require("Main.Item.ItemUtils")
    local tokenCfg = ItemUtils.GetTokenCfg(k)
    table.insert(scoreTbl, string.format(textRes.Pet.PetMark[24], tokenCfg.name, v))
  end
  local scoreStr = table.concat(scoreTbl, "\239\188\140")
  Toast(string.format(textRes.Pet.PetMark[23], scoreStr))
end
def.static("table").OnSPetMarkDecomposeAllFail = function(p)
  if textRes.Pet.PetMark.SPetMarkDecomposeAllFail[p.error_code] then
    Toast(textRes.Pet.PetMark.SPetMarkDecomposeAllFail[p.error_code])
  else
    Toast(string.format(textRes.Pet.PetMark.SPetMarkDecomposeAllFail[0], p.error_code))
  end
end
def.static("table").OnSPetMarkLotteryDrawSuccess = function(p)
  local items = p.new_pet_mark_item_infos
  require("Main.Pet.PetMark.ui.PetMarkLotteryAwardPanel").Instance():ShowAwards(p.lottery_type, items)
end
def.static("table").OnSPetMarkLotteryDrawFail = function(p)
  if textRes.Pet.PetMark.SPetMarkLotteryDrawFail[p.error_code] then
    Toast(textRes.Pet.PetMark.SPetMarkLotteryDrawFail[p.error_code])
  else
    Toast(string.format(textRes.Pet.PetMark.SPetMarkLotteryDrawFail[0], p.error_code))
  end
end
def.static("table", "table").OnItemGetNewOne = function(params, context)
  local ItemModule = require("Main.Item.ItemModule")
  local bagId = params.bagId
  if bagId == ItemModule.PET_MARK_BAG then
    instance:SetHasNewPetMarkItemNotify(true)
  end
end
def.static("table", "table").OnLeaveWorld = function(params, context)
  instance.isDrawLottry = false
  instance.hasNewItemNotify = false
end
def.method("=>", "boolean").IsOpen = function(self)
  if not self:IsReachFunctionLevel() then
    return false
  end
  if not self:IsFeatureOpen() then
    return false
  end
  return true
end
def.method("=>", "boolean").CheckIsOpenAndToast = function(self)
  if not self:IsReachFunctionLevel() then
    Toast(string.format(textRes.Pet.PetMark[2], constant.CPetMarkConstants.OPEN_LEVEL))
    return false
  end
  if not self:IsFeatureOpen() then
    Toast(textRes.Pet.PetMark[1])
    return false
  end
  return true
end
def.method("=>", "boolean").IsReachFunctionLevel = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if not heroProp then
    return false
  end
  return heroProp.level >= constant.CPetMarkConstants.OPEN_LEVEL
end
def.method("=>", "boolean").IsFeatureOpen = function(self)
  if _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_PET_MARK) then
    return true
  end
  return false
end
def.method("number").UnlockPetMark = function(self, itemKey)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if not self:CheckIsOpenAndToast() then
    return
  end
  if self:IsFullPetMark() then
    Toast(textRes.Pet.PetMark[33])
    return
  end
  local ItemModule = require("Main.Item.ItemModule")
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.PET_MARK_BAG, itemKey)
  if item == nil then
    Toast(textRes.Pet.PetMark[14])
    return
  end
  local markItemCfg = PetMarkUtils.GetPetMarkItemCfg(item.id)
  if markItemCfg == nil then
    Toast(textRes.Pet.PetMark[15])
    return
  end
  local markCfg = PetMarkUtils.GetPetMarkCfg(markItemCfg.petMarkCfgId)
  local PetMarkType = require("consts.mzm.gsp.petmark.confbean.PetMarkType")
  if markCfg.type == PetMarkType.TYPE_GENERAL then
    Toast(textRes.Pet.PetMark[15])
    return
  end
  local p = require("netio.protocol.mzm.gsp.petmark.CUnlockPetMarkReq").new(item.uuid[1])
  gmodule.network.sendProtocol(p)
end
def.method("userdata", "userdata").EquipPetMark = function(self, markId, petId)
  if not self:CheckIsOpenAndToast() then
    return
  end
  local p = require("netio.protocol.mzm.gsp.petmark.CEquipPetMarkReq").new(markId, petId)
  gmodule.network.sendProtocol(p)
end
def.method("userdata").UnequipPetMark = function(self, markId)
  if not self:CheckIsOpenAndToast() then
    return
  end
  local p = require("netio.protocol.mzm.gsp.petmark.CUnequipPetMarkReq").new(markId)
  gmodule.network.sendProtocol(p)
end
def.method("userdata", "userdata").PetMarkUpgradeWithMark = function(self, mainMarkId, subMarkId)
  if not self:CheckIsOpenAndToast() then
    return
  end
  local p = require("netio.protocol.mzm.gsp.petmark.CPetMarkUpgradeWithMarkReq").new(mainMarkId, subMarkId)
  gmodule.network.sendProtocol(p)
end
def.method("userdata", "number", "boolean").PetMarkUpgradeWithItem = function(self, mainMarkId, itemId, useAll)
  if not self:CheckIsOpenAndToast() then
    return
  end
  if useAll then
    local p = require("netio.protocol.mzm.gsp.petmark.CPetMarkUpgradeWithItemReq").new(mainMarkId, itemId, 1)
    gmodule.network.sendProtocol(p)
  else
    local p = require("netio.protocol.mzm.gsp.petmark.CPetMarkUpgradeWithItemReq").new(mainMarkId, itemId, 0)
    gmodule.network.sendProtocol(p)
  end
end
def.method("userdata").PetMarkUpgradeUseAll = function(self, mainMarkId)
  if not self:CheckIsOpenAndToast() then
    return
  end
  local p = require("netio.protocol.mzm.gsp.petmark.CPetMarkUpgradeUseAllReq").new(mainMarkId)
  gmodule.network.sendProtocol(p)
end
def.method("userdata").DecomposeMark = function(self, markId)
  if not self:CheckIsOpenAndToast() then
    return
  end
  local p = require("netio.protocol.mzm.gsp.petmark.CPetMarkDecomposeReq").new(markId)
  gmodule.network.sendProtocol(p)
end
def.method("number", "boolean").DecomposeMarkItem = function(self, itemId, useAll)
  if not self:CheckIsOpenAndToast() then
    return
  end
  if useAll then
    local p = require("netio.protocol.mzm.gsp.petmark.CPetMarkItemDecomposeReq").new(itemId, 1)
    gmodule.network.sendProtocol(p)
  else
    local p = require("netio.protocol.mzm.gsp.petmark.CPetMarkItemDecomposeReq").new(itemId, 0)
    gmodule.network.sendProtocol(p)
  end
end
def.method("table", "number").DecomposeAllMarkAndItem = function(self, qualities, level)
  if not self:CheckIsOpenAndToast() then
    return
  end
  local p = require("netio.protocol.mzm.gsp.petmark.CPetMarkDecomposeAllReq").new(qualities, level)
  gmodule.network.sendProtocol(p)
end
def.method().DrawLotteryCommonOne = function(self)
  if not self:CheckIsOpenAndToast() then
    return
  end
  self:PlayEffectToDrawLottery(constant.CPetMarkConstants.LOTTERY_EFFECT_ID1, constant.CPetMarkConstants.LOTTERY_ANIMATION_DURATION1, function()
    local CPetMarkLotteryDrawReq = require("netio.protocol.mzm.gsp.petmark.CPetMarkLotteryDrawReq")
    local p = CPetMarkLotteryDrawReq.new(CPetMarkLotteryDrawReq.LOTTERY_TYPE1, CPetMarkLotteryDrawReq.ONE_LOTTERY)
    gmodule.network.sendProtocol(p)
  end)
end
def.method().DrawLotteryCommonTen = function(self)
  if not self:CheckIsOpenAndToast() then
    return
  end
  self:PlayEffectToDrawLottery(constant.CPetMarkConstants.LOTTERY_EFFECT_ID1, constant.CPetMarkConstants.LOTTERY_ANIMATION_DURATION1, function()
    local CPetMarkLotteryDrawReq = require("netio.protocol.mzm.gsp.petmark.CPetMarkLotteryDrawReq")
    local p = CPetMarkLotteryDrawReq.new(CPetMarkLotteryDrawReq.LOTTERY_TYPE1, CPetMarkLotteryDrawReq.TEN_LOTTERY)
    gmodule.network.sendProtocol(p)
  end)
end
def.method().DrawLotteryHighOne = function(self)
  if not self:CheckIsOpenAndToast() then
    return
  end
  self:PlayEffectToDrawLottery(constant.CPetMarkConstants.LOTTERY_EFFECT_ID2, constant.CPetMarkConstants.LOTTERY_ANIMATION_DURATION2, function()
    local CPetMarkLotteryDrawReq = require("netio.protocol.mzm.gsp.petmark.CPetMarkLotteryDrawReq")
    local p = CPetMarkLotteryDrawReq.new(CPetMarkLotteryDrawReq.LOTTERY_TYPE2, CPetMarkLotteryDrawReq.ONE_LOTTERY)
    gmodule.network.sendProtocol(p)
  end)
end
def.method().DrawLotteryHighTen = function(self)
  if not self:CheckIsOpenAndToast() then
    return
  end
  self:PlayEffectToDrawLottery(constant.CPetMarkConstants.LOTTERY_EFFECT_ID2, constant.CPetMarkConstants.LOTTERY_ANIMATION_DURATION2, function()
    local CPetMarkLotteryDrawReq = require("netio.protocol.mzm.gsp.petmark.CPetMarkLotteryDrawReq")
    local p = CPetMarkLotteryDrawReq.new(CPetMarkLotteryDrawReq.LOTTERY_TYPE2, CPetMarkLotteryDrawReq.TEN_LOTTERY)
    gmodule.network.sendProtocol(p)
  end)
end
def.method().DrawLotteryAward = function(self)
  local CPetMarkLotteryDrawFinishReq = require("netio.protocol.mzm.gsp.petmark.CPetMarkLotteryDrawFinishReq")
  local p = CPetMarkLotteryDrawFinishReq.new()
  gmodule.network.sendProtocol(p)
end
def.method("number", "number", "function").PlayEffectToDrawLottery = function(self, effectId, duration, callback)
  if self.isDrawLottry then
    Toast(textRes.Pet.PetMark[39])
    return
  end
  self.isDrawLottry = true
  local effres = _G.GetEffectRes(effectId)
  if effres == nil then
    warn("PetMark draw lottery effect is nil :" .. effectId)
  else
    require("Fx.GUIFxMan").Instance():Play(effres.path, "PetMarkDrawLottery", 0, 0, duration, false)
  end
  if callback then
    GameUtil.AddGlobalTimer(math.max(0, duration - 0.5), true, function()
      if _G.IsEnteredWorld() then
        callback()
        self.isDrawLottry = false
      end
    end)
  end
end
def.method("userdata", "=>", "table").GetPetEquipedMark = function(self, petId)
  local markId = PetMarkDataMgr.Instance():GetPetEquipMarkId(petId)
  if markId == nil then
    return nil
  end
  local mark = PetMarkDataMgr.Instance():GetPetMarkInfo(markId)
  return mark
end
def.method("userdata", "=>", "number").GetPetEquipMarkModelId = function(self, petId)
  local mark = self:GetPetEquipedMark(petId)
  if mark == nil then
    return 0
  else
    local markCfg = require("Main.Pet.PetMark.PetMarkUtils").GetPetMarkCfg(mark:GetPetMarkCfgId())
    if markCfg == nil then
      return 0
    else
      return markCfg.modelId
    end
  end
end
def.method("=>", "boolean").IsFullPetMark = function(self)
  local curNum = PetMarkDataMgr.Instance():GetCurrentPetMarkCount()
  return curNum >= constant.CPetMarkConstants.PET_MARK_MAX_CARRY_NUM
end
def.method("=>", "boolean").HasNewPetMarkItemNotify = function(self)
  return self.hasNewItemNotify
end
def.method("boolean").SetHasNewPetMarkItemNotify = function(self, b)
  self.hasNewItemNotify = b
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_MARK_NEW_ITEM_NOTIFY_CHANGE, nil)
end
PetMarkMgr.Commit()
return PetMarkMgr
