local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemModule = require("Main.Item.ItemModule")
local OperationLingWu = Lplus.Extend(OperationBase, "OperationLingWu")
local def = OperationLingWu.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.PLAY_EXPRESSION_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if _G.PlayerIsInFight() then
    Toast(textRes.Item[100])
    return
  end
  local itemData = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if itemData == nil then
    return
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.item.CUsePlayExpressionItemReq").new(itemData.uuid[1]))
  Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Use_LingWu, nil)
  return true
end
OperationLingWu.Commit()
return OperationLingWu
