local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local OperationUsePetBabyBag = Lplus.Extend(OperationBase, "OperationUsePetBabyBag")
local def = OperationUsePetBabyBag.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.BABY_BAG then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if self:CannotUseInFight() then
    return false
  end
  local PetMgr = require("Main.Pet.mgr.PetMgr")
  PetMgr.Instance():UsePetBabyBag(itemKey)
  return false
end
OperationUsePetBabyBag.Commit()
return OperationUsePetBabyBag
