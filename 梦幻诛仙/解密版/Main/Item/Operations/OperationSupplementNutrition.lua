local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local OperationSupplementNutrition = Lplus.Extend(OperationBase, "OperationSupplementNutrition")
local def = OperationSupplementNutrition.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.BAO_SHI_DU then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local NutritionMgr = require("Main.Buff.NutritionMgr")
  local result = NutritionMgr.Instance():ItemSupplementNutrition(itemKey)
  if result == NutritionMgr.CResult.NutritionReachMax then
    Toast(textRes.Buff[11])
  end
  return true
end
def.override("number", "number", "userdata", "table", "=>", "boolean").OperateAll = function(self, bagId, itemKey, m_panel, context)
  return false
end
OperationSupplementNutrition.Commit()
return OperationSupplementNutrition
