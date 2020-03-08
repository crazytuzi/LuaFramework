local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationDrugInFight = Lplus.Extend(OperationBase, "OperationDrugInFight")
local def = OperationDrugInFight.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and (itemBase.itemType == ItemType.IN_FIGHT_DRUG or itemBase.itemType == ItemType.SUPER_IN_FIGHT_DRUG_ITEM) then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  Toast(textRes.Item[8311])
  return true
end
OperationDrugInFight.Commit()
return OperationDrugInFight
