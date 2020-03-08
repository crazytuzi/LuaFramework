local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationUseDrugOut = Lplus.Extend(OperationBase, "OperationUseDrugOut")
local def = OperationUseDrugOut.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.OUT_FIGHT_DRUG then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local useDrugOut = require("netio.protocol.mzm.gsp.role.CUseDrug").new(itemKey, bagId)
  gmodule.network.sendProtocol(useDrugOut)
  return true
end
OperationUseDrugOut.Commit()
return OperationUseDrugOut
