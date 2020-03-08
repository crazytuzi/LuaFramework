local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationUsePetSoulItem = Lplus.Extend(OperationBase, "OperationUsePetSoulItem")
local def = OperationUsePetSoulItem.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local result = false
  if source == ItemTipsMgr.Source.Bag and (itemBase.itemType == ItemType.PET_SOUL_LEVEL_UP_COMMOM_ITEM or itemBase.itemType == ItemType.PET_SOUL_LEVEL_UP_SENIOR_ITEM or itemBase.itemType == ItemType.PET_SOUL_RANDOM_PROP_ITEM or itemBase.itemType == ItemType.PET_SOUL_EXCHANGE_COMMOM_ITEM) then
    local PetSoulMgr = require("Main.Pet.soul.PetSoulMgr")
    if not PetSoulMgr.Instance():IsOpen(false) then
      result = false
    else
      result = true
    end
  end
  return result
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Use_Pet_Soul, {bagId = bagId, itemKey = itemKey})
  return true
end
OperationUsePetSoulItem.Commit()
return OperationUsePetSoulItem
