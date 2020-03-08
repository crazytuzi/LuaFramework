local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local MathHelper = require("Common.MathHelper")
local OperationWingsViewItem = Lplus.Extend(OperationBase, "OperationWingsViewItem")
local PersonalHelper = require("Main.Chat.PersonalHelper")
local def = OperationWingsViewItem.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.WING_VIEW_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if not require("Main.Wing.WingInterface").InWingOpen() then
    Toast(textRes.Wing[25])
    return true
  end
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return
  end
  local ItemSwitchInfo = require("netio.protocol.mzm.gsp.idip.ItemSwitchInfo")
  local IDIPInterface = require("Main.IDIP.IDIPInterface")
  local outlookId = require("Main.Item.ItemUtils").MapItemId2WingViewId(item.id)
  local bOpen = IDIPInterface.IsItemIDIPOpen(ItemSwitchInfo.WING, outlookId)
  if not bOpen then
    Toast(textRes.Wing[51])
    return true
  end
  local p = require("netio.protocol.mzm.gsp.item.CUseWingViewItem").new(item.uuid[1])
  gmodule.network.sendProtocol(p)
  return true
end
OperationWingsViewItem.Commit()
return OperationWingsViewItem
