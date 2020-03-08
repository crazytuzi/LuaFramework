local MODULE_NAME = (...)
local Lplus = require("Lplus")
local JewelProtocols = Lplus.Class("JewelProtocols")
local def = JewelProtocols.define
local instance
def.static("=>", JewelProtocols).Instance = function()
  if instance == nil then
    instance = JewelProtocols()
  end
  return instance
end
def.method().Init = function()
  local Cls = JewelProtocols
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.superequipment.SMountJewelSuccess", Cls.OnSMountJewelSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.superequipment.SUnMountJewelSuccess", Cls.OnSUnMountJewelSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.superequipment.SComposeJewelSuccess", Cls.OnSComposeJewelSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.superequipment.SUpdateJewelSuccess", Cls.OnSUpdateJewelSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.superequipment.SJewelError", Cls.OnSJewelError)
end
def.static("number", "number", "number", "number").CSendMountJewelReq = function(bagId, itemKey, slotIdx, itemId)
  local p = require("netio.protocol.mzm.gsp.superequipment.CMountJewel").new(bagId, itemKey, slotIdx, itemId)
  gmodule.network.sendProtocol(p)
end
def.static("number", "number", "number").CSendUnMountJewelReq = function(bagId, itemKey, slotIdx)
  local p = require("netio.protocol.mzm.gsp.superequipment.CUnMountJewel").new(bagId, itemKey, slotIdx)
  gmodule.network.sendProtocol(p)
end
def.static("number").CSendComposeJewel = function(itemId)
  local p = require("netio.protocol.mzm.gsp.superequipment.CComposeJewel").new(itemId)
  gmodule.network.sendProtocol(p)
end
def.static("number", "number", "number").CSendUpdateJewel = function(bagId, itemKey, slotIdx)
  local p = require("netio.protocol.mzm.gsp.superequipment.CUpdateJewel").new(bagId, itemKey, slotIdx)
  gmodule.network.sendProtocol(p)
end
def.static("number", "boolean").CSendAutoComposeAllJewel = function(itemId, bUseYB)
  local p = require("netio.protocol.mzm.gsp.superequipment.CComposeJewelAuto").new(itemId, bUseYB and 1 or 0)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSMountJewelSuccess = function(p)
  Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.JewelMountChange, {bMount = true})
end
def.static("table").OnSUnMountJewelSuccess = function(p)
  Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.JewelMountChange, {bMount = false})
end
def.static("table").OnSComposeJewelSuccess = function(p)
  Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.JEWEL_COMPOUND_SUCCESS, p.jewelCfgId2count)
end
def.static("table").OnSUpdateJewelSuccess = function(p)
  Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.JewelLevelChange, nil)
end
local SJewelError = require("netio.protocol.mzm.gsp.superequipment.SJewelError")
def.static("table").OnSJewelError = function(p)
  for desc, code in pairs(SJewelError) do
    if code == p.errorCode then
      warn(">>>>" .. desc)
    end
  end
  if p.errorCode == SJewelError.JEWEL_BAG_FULL then
    Toast(textRes.GodWeapon.Jewel[32])
  end
end
return JewelProtocols.Commit()
