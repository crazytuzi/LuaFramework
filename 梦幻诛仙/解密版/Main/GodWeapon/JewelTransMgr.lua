local Lplus = require("Lplus")
local JewelTransMgr = Lplus.Class("JewelTransMgr")
local instance
local def = JewelTransMgr.define
local Cls = JewelTransMgr
local JewelUtils = require("Main.GodWeapon.Jewel.JewelUtils")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local txtConst = textRes.GodWeapon.Jewel
local const = constant.SuperEquipmentJewelConstants
def.static("=>", JewelTransMgr).Instance = function()
  if instance == nil then
    instance = JewelTransMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.superequipment.SJewelTransferCountRsp", Cls.OnSQueryTransCount)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.superequipment.SJewelTransferPriceRsp", Cls.OnSQueryJewelsPrice)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.superequipment.SJewelTransferRsp", Cls.OnSTransSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.superequipment.SJewelTransferError", Cls.OnSTransFailed)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, Cls.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, Cls.OnFeatureInit)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, Cls.OnNpcService)
end
def.static("=>", "boolean").IsFeatureOpen = function()
  local bFeatureOpen = FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_SUPER_EQUIPMENT_JEWEL_TRANSFER)
  return bFeatureOpen
end
def.static("number", "=>", "table").GetJewelWithLv = function(lv)
  local allJewels = require("Main.GodWeapon.JewelMgr").Instance():GetJewelItems()
  local retData = {}
  for i = 1, #allJewels do
    local item = allJewels[i]
    local jewelBasic = JewelUtils.GetJewelItemByItemId(item.id, false)
    if lv <= jewelBasic.level then
      table.insert(retData, {item = item, basicCfg = jewelBasic})
    end
  end
  return retData
end
def.static("table", "table").OnNpcService = function(p, c)
  local srvcId, npcId = p[1], p[2]
  if npcId ~= const.TRANSFER_NPC_ID or srvcId ~= const.TRANSFER_NPC_SERVICE then
    return
  end
  if not Cls.IsFeatureOpen() then
    return
  end
  Cls.SendQueryTransCountReq()
end
def.static("table", "table").OnFeatureInit = function(p, c)
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {
    npcid = const.TRANSFER_NPC_ID,
    show = Cls.IsFeatureOpen()
  })
end
def.static("table", "table").OnFeatureOpenChange = function(p, c)
  if p.feature == Feature.TYPE_SUPER_EQUIPMENT_JEWEL_TRANSFER then
    Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {
      npcid = const.TRANSFER_NPC_ID,
      show = Cls.IsFeatureOpen()
    })
  end
end
def.static().SendQueryTransCountReq = function()
  local p = require("netio.protocol.mzm.gsp.superequipment.CJewelTransferCountReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").CQueryJewelsPrice = function(jewels)
  local p = require("netio.protocol.mzm.gsp.superequipment.CJewelTransferPriceReq").new(jewels)
  gmodule.network.sendProtocol(p)
end
def.static("number", "number", "number").Send2TransJewelReq = function(bagId, itemKey, dstItemId)
  local p = require("netio.protocol.mzm.gsp.superequipment.CJewelTransferReq").new(bagId, itemKey, dstItemId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSQueryTransCount = function(p)
  if p.count < 1 then
    Toast(txtConst[52]:format(const.MAX_TRANSFER_COUNT))
    return
  end
  Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.GET_TRANSFORM_COUNT, p)
  require("Main.GodWeapon.ui.UIJewelTransform").Instance():ShowPanel(p.count)
end
def.static("table").OnSQueryJewelsPrice = function(p)
  Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.GET_JEWELS_PRICE, p)
end
def.static("table").OnSTransSuccess = function(p)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(p.fromJewelBagId, p.fromJewelGridNo)
  if item ~= nil then
    local srcItemBase = ItemUtils.GetItemBase(item.id)
    local dstItemBase = ItemUtils.GetItemBase(p.toJewelCfgId)
    if srcItemBase ~= nil and dstItemBase ~= nil then
      local HtmlHelper = require("Main.Chat.HtmlHelper")
      local sourceColor = HtmlHelper.NameColor[srcItemBase.namecolor] or "fe7200"
      local targetColor = HtmlHelper.NameColor[dstItemBase.namecolor] or "fe7200"
      Toast(string.format(txtConst[55], sourceColor, srcItemBase.name, targetColor, dstItemBase.name))
    end
  end
  Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.TRANS_JEWEL_SUCCESS, p)
end
def.static("table").OnSTransFailed = function(p)
  local ERRORCODE = require("netio.protocol.mzm.gsp.superequipment.SJewelTransferError")
  if p.errorCode == ERRORCODE.TRANSFER_COUNT_ERROR then
    warn(">>>>Transform jewel number error")
  elseif p.errorCode == ERRORCODE.JEWEL_LEVEL_ERROR then
    warn(">>>>Jewel level error")
  elseif p.errorCode == ERRORCODE.GOLD_TO_MAX then
    warn(">>>>Too much gold")
  elseif p.errorCode == ERRORCODE.GOLD_NOT_ENOUGH then
  end
  Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.TRANS_JEWEL_FAILED, p)
end
return JewelTransMgr.Commit()
