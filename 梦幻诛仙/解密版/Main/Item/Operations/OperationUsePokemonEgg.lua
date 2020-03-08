local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationUsePokemonEgg = Lplus.Extend(OperationBase, "OperationUsePokemonEgg")
local def = OperationUsePokemonEgg.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local result = false
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.EMBRYO_ITEM then
    result = true
  end
  return result
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Use_Pokemon, {bagId = bagId, itemKey = itemKey})
  return true
end
OperationUsePokemonEgg.Commit()
return OperationUsePokemonEgg
