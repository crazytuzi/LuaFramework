local MODULE_NAME = (...)
local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local OperationBatchDecomposeTurnedCard = Lplus.Extend(OperationBase, MODULE_NAME)
local def = OperationBatchDecomposeTurnedCard.define
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and (itemBase.itemType == ItemType.CHANGE_MODEL_CARD_ITEM or itemBase.itemType == ItemType.CHANGE_MODEL_CARD_FRAGMENT) then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.TurnedCard[3]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local TurnedCardDecomposePanel = require("Main.TurnedCard.ui.TurnedCardDecomposePanel")
  TurnedCardDecomposePanel.Instance():ShowPanel()
  return true
end
return OperationBatchDecomposeTurnedCard.Commit()
