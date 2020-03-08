local MODULE_NAME = (...)
local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local OperationHangChristmasStockItem = Lplus.Extend(OperationBase, "OperationHangChristmasStockItem")
local def = OperationHangChristmasStockItem.define
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  if source == ItemTipsMgr.Source.Other and item.id == constant.CChristmasStockingConsts.CONSUME_ITEM_ID then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[13301]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if context == nil then
    return
  end
  local roleId = context.roleId
  local pos = context.pos
  require("Main.activity.ChristmasTree.ChristmasTreeMgr").Instance():HangStockOnCurrentTree(roleId, pos)
  return true
end
return OperationHangChristmasStockItem.Commit()
