local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local MathHelper = require("Common.MathHelper")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local CommercePitchUtils = require("Main.CommerceAndPitch.CommercePitchUtils")
local OperationPitch = Lplus.Extend(OperationBase, "OperationPitch")
local ItemModule = require("Main.Item.ItemModule")
require("Main.module.ModuleId")
local def = OperationPitch.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  if source == ItemTipsMgr.Source.Bag and itemBase.canSellAndThrow and itemBase.isProprietary == false and MathHelper.BitAnd(item.flag, ItemInfo.BIND) == 0 and CommercePitchUtils.CanItemPitchToSell(item.id, item) then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8113]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  local tbl = {
    itemKey = itemKey,
    itemId = item.id
  }
  Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Sell_To_Pitch, tbl)
  return true
end
OperationPitch.Commit()
return OperationPitch
