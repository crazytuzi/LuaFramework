local Lplus = require("Lplus")
local BreakOutUtils = require("Main.GodWeapon.BreakOut.BreakOutUtils")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local BreakOutProtocols = Lplus.Class("BreakOutProtocols")
local def = BreakOutProtocols.define
def.static().RegisterProtocols = function()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.superequipment.SImproveSuperEquipmentStageSuccess", BreakOutProtocols.OnSImproveStageSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.superequipment.SImproveSuperEquipmentStageFail", BreakOutProtocols.OnSImproveStageFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.superequipment.SImproveSuperEquipmentLevelSuccess", BreakOutProtocols.OnSImproveLevelSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.superequipment.SImproveSuperEquipmentLevelFail", BreakOutProtocols.OnSImproveLevelFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.superequipment.STransferSuperEquipmentFail", BreakOutProtocols.OnInheritGodWeaponFailed)
end
def.static("number", "number", "boolean", "userdata", "userdata").SendCImproveStage = function(bagId, grid, bUseYB, requiredYB, curCurrency)
  warn("[BreakOutProtocols:SendCImproveStage] Send CImproveSuperEquipmentStageReq!")
  local useYB = 0
  if bUseYB then
    useYB = 1
  end
  local p = require("netio.protocol.mzm.gsp.superequipment.CImproveSuperEquipmentStageReq").new(bagId, grid, useYB, requiredYB, curCurrency)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSImproveStageSuccess = function(p)
  warn("[BreakOutProtocols:OnSImproveStageSuccess] On SImproveSuperEquipmentStageSuccess!")
  local uuid = p.item_info and p.item_info.uuid or nil
  local itemid = p.item_info and p.item_info.id or 0
  local bImproved = 0 < p.improved
  Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.GOD_WEAPON_BREAK_OUT_SUCC, {
    uuid = uuid,
    itemid = itemid,
    bImproved = bImproved
  })
end
def.static("table").OnSImproveStageFailed = function(p)
  warn("[BreakOutProtocols:OnSImproveStageFailed] On SImproveSuperEquipmentStageFail! p.retcode:", p.retcode)
  local SImproveSuperEquipmentStageFail = require("netio.protocol.mzm.gsp.superequipment.SImproveSuperEquipmentStageFail")
  local errString
  if SImproveSuperEquipmentStageFail.NO_MATERIAL == p.retcode then
    errString = textRes.GodWeapon.BreakOut.STAGE_UP_FAIL_LACK_ITEMS
  elseif SImproveSuperEquipmentStageFail.INSUFFICIENT_YUANBAO == p.retcode then
  elseif SImproveSuperEquipmentStageFail.INSUFFICIENT_CURRENCY == p.retcode then
  elseif SImproveSuperEquipmentStageFail.YUANBAO_MISMATCH == p.retcode then
    errString = textRes.GodWeapon.BreakOut.STAGE_UP_FAIL_YB_MISMATCH
  elseif SImproveSuperEquipmentStageFail.CURRENCY_MISMATCH == p.retcode then
    errString = textRes.GodWeapon.BreakOut.STAGE_UP_FAIL_MONEY_MISMATCH
  else
    warn("[ERROR][BreakOutProtocols:OnSImproveStageFailed] unhandled p.retcode:", p.retcode)
  end
  if errString then
    warn("[BreakOutProtocols:OnSImproveStageFailed] err:", errString)
    Toast(errString)
  end
  Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.GOD_WEAPON_BREAK_OUT_FAIL, {
    reason = p.retcode
  })
end
def.static("number", "number", "boolean", "userdata", "userdata").SendCImproveLevel = function(bagId, grid, bUseYB, requiredYB, curYB)
  warn("[BreakOutProtocols:SendCImproveLevel] Send CImproveSuperEquipmentLevelReq!")
  local useYB = 0
  if bUseYB then
    useYB = 1
  end
  local p = require("netio.protocol.mzm.gsp.superequipment.CImproveSuperEquipmentLevelReq").new(bagId, grid, useYB, requiredYB, curYB)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSImproveLevelSuccess = function(p)
  warn("[BreakOutProtocols:OnSImproveLevelSuccess] On SImproveSuperEquipmentLevelSuccess!")
  local uuid = p.item_info and p.item_info.uuid or nil
  local itemid = p.item_info and p.item_info.id or 0
  local bImproved = 0 < p.improved
  Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.GOD_WEAPON_LEVEL_UP_SUCC, {
    uuid = uuid,
    itemid = itemid,
    bImproved = bImproved
  })
end
def.static("table").OnSImproveLevelFailed = function(p)
  warn("[BreakOutProtocols:OnSImproveLevelFailed] On SImproveSuperEquipmentLevelFail! p.retcode:", p.retcode)
  local SImproveSuperEquipmentLevelFail = require("netio.protocol.mzm.gsp.superequipment.SImproveSuperEquipmentLevelFail")
  local errString
  if SImproveSuperEquipmentLevelFail.NO_MATERIAL == p.retcode then
    errString = textRes.GodWeapon.BreakOut.LEVEL_UP_FAIL_LACK_ITEMS
  elseif SImproveSuperEquipmentLevelFail.INSUFFICIENT_YUANBAO == p.retcode then
  elseif SImproveSuperEquipmentLevelFail.INSUFFICIENT_CURRENCY == p.retcode then
  elseif SImproveSuperEquipmentLevelFail.YUANBAO_MISMATCH == p.retcode then
    errString = textRes.GodWeapon.BreakOut.LEVEL_UP_FAIL_YB_MISMATCH
  elseif SImproveSuperEquipmentLevelFail.CURRENCY_MISMATCH == p.retcode then
    errString = textRes.GodWeapon.BreakOut.LEVEL_UP_FAIL_MONEY_MISMATCH
  else
    warn("[ERROR][BreakOutProtocols:OnSImproveLevelFailed] unhandled p.retcode:", p.retcode)
  end
  if errString then
    warn("[BreakOutProtocols:OnSImproveLevelFailed] err:", errString)
    Toast(errString)
  end
  Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.GOD_WEAPON_LEVEL_UP_FAIL, {
    reason = p.retcode
  })
end
def.static("table").SendCInheritGodWeapon = function(uuids)
  warn("[BreakOutProtocols:SendCInheritGodWeapon] Send CTransferSuperEquipmentReq!")
  local p = require("netio.protocol.mzm.gsp.superequipment.CTransferSuperEquipmentReq").new(uuids)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnInheritGodWeaponFailed = function(p)
  warn("[BreakOutProtocols:OnInheritGodWeaponFailed] On STransferSuperEquipmentFail! p.retcode:", p.retcode)
  local STransferSuperEquipmentFail = require("netio.protocol.mzm.gsp.superequipment.STransferSuperEquipmentFail")
  local errString
  if STransferSuperEquipmentFail.STAGE_CONDITIONS_NOT_MEET == p.retcode then
    errString = textRes.GodWeapon.BreakOut.GODWEAPON_TRANS_FAIL_STAGE_NOT_MEET
  elseif STransferSuperEquipmentFail.LEVEL_CONDITIONS_NOT_MEET == p.retcode then
    errString = textRes.GodWeapon.BreakOut.GODWEAPON_TRANS_FAIL_LEVEL_NOT_MEET
  else
    warn("[ERROR][BreakOutProtocols:OnInheritGodWeaponFailed] unhandled p.retcode:", p.retcode)
  end
  if errString then
    warn("[BreakOutProtocols:OnInheritGodWeaponFailed] err:", errString)
    Toast(errString)
  end
end
BreakOutProtocols.Commit()
return BreakOutProtocols
