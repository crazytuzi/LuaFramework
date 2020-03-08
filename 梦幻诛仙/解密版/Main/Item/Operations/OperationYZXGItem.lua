local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local RunningXuanGongData = require("Main.Soaring.data.RunningXuanGongData")
local OperationYZXGItem = Lplus.Extend(OperationBase, "OperationYZXGItem")
local def = OperationYZXGItem.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemid == RunningXuanGongData.Instance():GetItemId() then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  Event.DispatchEvent(ModuleId.SOARING, gmodule.notifyId.Soaring.YZXG_USE_ITEM, {bagId = bagId, itemKey = itemKey})
  return true
end
OperationYZXGItem.Commit()
return OperationYZXGItem
