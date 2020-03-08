local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local MathHelper = require("Common.MathHelper")
local OperationRefreshWing = Lplus.Extend(OperationBase, "OperationRefreshWing")
local def = OperationRefreshWing.define
def.field("boolean").bind = false
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.WING_XILIAN_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local key, item = ItemModule.Instance():SelectOneItemByItemType(ItemModule.EQUIPBAG, ItemType.WING_ITEM)
  if key <= 0 then
    Toast(textRes.Item[8333])
    return true
  end
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return
  end
  local itemBase = require("Main.Item.ItemUtils").GetItemBase(item.id)
  CommonConfirmDlg.ShowConfirm(textRes.Item[8325], textRes.Item[8326], function(selection, tag)
    if selection == 1 then
      local wingXilian = require("netio.protocol.mzm.gsp.item.CUseWingXilianItem").new(item.uuid[1])
      gmodule.network.sendProtocol(wingXilian)
    end
  end, nil)
  return true
end
OperationRefreshWing.Commit()
return OperationRefreshWing
