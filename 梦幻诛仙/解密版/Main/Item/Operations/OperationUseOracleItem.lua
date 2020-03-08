local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OracleData = require("Main.Oracle.data.OracleData")
local OperationUseOracleItem = Lplus.Extend(OperationBase, "OperationUseOracleItem")
local def = OperationUseOracleItem.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local result = false
  if source == ItemTipsMgr.Source.Bag and OracleData.Instance():IsOracleItem(itemBase.itemid) then
    result = true
  end
  return result
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  warn("[OperationUseOracleItem:Operate] Use single Oracle Item.")
  Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Use_Oracle, {
    bagId = bagId,
    itemKey = itemKey,
    bUseAll = 0
  })
  return true
end
OperationUseOracleItem.Commit()
return OperationUseOracleItem
