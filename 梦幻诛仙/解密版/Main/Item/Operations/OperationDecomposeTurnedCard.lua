local MODULE_NAME = (...)
local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local OperationDecomposeTurnedCard = Lplus.Extend(OperationBase, MODULE_NAME)
local def = OperationDecomposeTurnedCard.define
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemModule = require("Main.Item.ItemModule")
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and (itemBase.itemType == ItemType.CHANGE_MODEL_CARD_ITEM or itemBase.itemType == ItemType.CHANGE_MODEL_CARD_FRAGMENT) then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.TurnedCard[2]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return true
  end
  local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
  local function callback(id)
    if id == 1 then
      local p = require("netio.protocol.mzm.gsp.changemodelcard.CCardItemDecomposeReq").new({
        item.uuid[1]
      }, 1)
      gmodule.network.sendProtocol(p)
    end
  end
  if TurnedCardUtils.IsPurpleCardItem(item.id) then
    local CaptchaConfirmDlg = require("GUI.CaptchaConfirmDlg")
    CaptchaConfirmDlg.ShowConfirm(textRes.TurnedCard[32], "", textRes.TurnedCard[33], nil, callback, nil)
  else
    callback(1)
  end
  return true
end
return OperationDecomposeTurnedCard.Commit()
