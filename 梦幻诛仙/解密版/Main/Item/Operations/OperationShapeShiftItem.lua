local MODULE_NAME = (...)
local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local OperationShapeShiftItem = Lplus.Extend(OperationBase, MODULE_NAME)
local def = OperationShapeShiftItem.define
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.SHAPE_SHIFT_ITEM then
    if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_SHAPE_SHIFT_ITEM) then
      return false
    end
    local shapeShiftItemCfg = ItemUtils.GetShapeShiftItemCfg(itemBase.itemid)
    local myLevel = _G.GetHeroProp().level
    if myLevel >= itemBase.useLevel and myLevel <= shapeShiftItemCfg.useLevelMax then
      return true
    else
      return false
    end
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.TurnedCard[1]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return true
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.item.CUseShapeShiftItem").new(item.uuid[1]))
  return true
end
return OperationShapeShiftItem.Commit()
