local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local MathHelper = require("Common.MathHelper")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local OperationSellToTradingArcade = Lplus.Extend(OperationBase, "OperationSellToTradingArcade")
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
require("Main.module.ModuleId")
local def = OperationSellToTradingArcade.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local notBinded = not ItemUtils.IsItemBind(item)
  if source == ItemTipsMgr.Source.Bag and itemBase.canSellAndThrow and notBinded and itemBase.isProprietary == false and ItemUtils.IsRarity(item.id) then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8131]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if TradingArcadeUtils.CheckOpen() == false then
    return true
  end
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if nil == item then
    return true
  end
  if TradingArcadeUtils.IsItemFrozen(item) then
    Toast(textRes.TradingArcade[33])
    return true
  end
  local tbl = {
    itemKey = itemKey,
    itemId = item.id
  }
  Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Sell_To_TradingArcade, tbl)
  return true
end
OperationSellToTradingArcade.Commit()
return OperationSellToTradingArcade
