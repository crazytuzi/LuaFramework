local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemModule = require("Main.Item.ItemModule")
local ItemData = require("Main.Item.ItemData")
local FashionUtils = require("Main.Fashion.FashionUtils")
local OperationFashionUse = Lplus.Extend(OperationBase, "OperationFashionUse")
local def = OperationFashionUse.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.FASHION_DRESS_ITEM then
    local itemId = item.id
    local fashionItem = FashionUtils.GetFashionItemByUnlockItemId(itemId)
    if fashionItem ~= nil then
      return true
    else
      return false
    end
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local param = {}
  param.itemKey = itemKey
  Event.DispatchEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.UseFationItem, param)
  return false
end
OperationFashionUse.Commit()
return OperationFashionUse
