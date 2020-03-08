local MODULE_NAME = (...)
local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local OperationUseTurnedCard = Lplus.Extend(OperationBase, MODULE_NAME)
local def = OperationUseTurnedCard.define
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemModule = require("Main.Item.ItemModule")
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.CHANGE_MODEL_CARD_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.TurnedCard[1]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return true
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.changemodelcard.CUnlockCardReq").new(item.uuid[1]))
  warn(">>>>>>CUnlockCardReq:", bagId, item.uuid[1], item.number)
  if 1 < item.number then
    return false
  end
  return true
end
return OperationUseTurnedCard.Commit()
