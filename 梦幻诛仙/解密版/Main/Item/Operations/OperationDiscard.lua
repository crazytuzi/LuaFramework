local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemModule = require("Main.Item.ItemModule")
local OperationDiscard = Lplus.Extend(OperationBase, "OperationDiscard")
local def = OperationDiscard.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  if source == ItemTipsMgr.Source.Bag and itemBase.canSellAndThrow and itemBase.isProprietary then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8112]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return true
  end
  local itemBase = require("Main.Item.ItemUtils").GetItemBase(item.id)
  CommonConfirmDlg.ShowConfirm(textRes.Item[8315], string.format(textRes.Item[8316], ItemTipsMgr.Color[itemBase.namecolor], itemBase.name), function(selection, tag)
    if selection == 1 then
      local abandonItem = require("netio.protocol.mzm.gsp.item.CAbandonItemReq").new(bagId, item.uuid[1], item.number)
      gmodule.network.sendProtocol(abandonItem)
    end
  end, nil)
  return true
end
OperationDiscard.Commit()
return OperationDiscard
