local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationMoveToStorage = Lplus.Extend(OperationBase, "OperationMoveToStorage")
local def = OperationMoveToStorage.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  if source == ItemTipsMgr.Source.StorageBag then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8105]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local ItemModule = require("Main.Item.ItemModule")
  local storageId = ItemModule.Instance():GetCurrentStorage()
  if storageId <= 0 then
    return true
  end
  ItemModule.MoveItemToStorage(itemKey, storageId)
  return true
end
OperationMoveToStorage.Commit()
return OperationMoveToStorage
