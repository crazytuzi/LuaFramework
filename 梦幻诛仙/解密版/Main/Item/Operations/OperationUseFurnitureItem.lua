local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationUseFurnitureItem = Lplus.Extend(OperationBase, "OperationUseFurnitureItem")
local def = OperationUseFurnitureItem.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if itemBase.itemType == ItemType.FURNITURE_ITEM and source == ItemTipsMgr.Source.Bag then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local item = gmodule.moduleMgr:GetModule(ModuleId.ITEM):GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return true
  end
  local homelandModule = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND)
  if not homelandModule:IsFeatureOpen() then
    Toast(textRes.Homeland[52])
    return true
  end
  if not homelandModule:HaveHome() then
    Toast(textRes.Homeland[60])
    homelandModule:GotoCreateHomelandNPC()
  else
    require("Main.Homeland.HomelandProtocol").CUseFurnitureItemReq(item.uuid[1])
  end
  return true
end
OperationUseFurnitureItem.Commit()
return OperationUseFurnitureItem
