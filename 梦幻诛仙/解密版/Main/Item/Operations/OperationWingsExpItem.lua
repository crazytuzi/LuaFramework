local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local MathHelper = require("Common.MathHelper")
local OperationWingsExpItem = Lplus.Extend(OperationBase, "OperationWingsExpItem")
local PersonalHelper = require("Main.Chat.PersonalHelper")
local def = OperationWingsExpItem.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.WingsItemBag and itemBase.itemType == ItemType.WING_EXP_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  Event.DispatchEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_EXP_ITEM_USED, {bagId = bagId, itemKey = itemKey})
  return false
end
def.override("number", "number", "userdata", "table", "=>", "boolean").OperateAll = function(self, bagId, itemKey, m_panel, context)
  if not require("Main.Wing.WingsInterface").InWingOpen() then
    Toast(textRes.Wing[25])
    return true
  end
  require("Main.Wing.WingsInterface").OpenWingPanel(1)
  return true
end
OperationWingsExpItem.Commit()
return OperationWingsExpItem
