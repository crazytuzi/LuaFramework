local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local MathHelper = require("Common.MathHelper")
local OperationWingsPassiveItems = Lplus.Extend(OperationBase, "OperationWingsPassiveItems")
local PersonalHelper = require("Main.Chat.PersonalHelper")
local def = OperationWingsPassiveItems.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and (itemBase.itemType == ItemType.WING_PROPERTY_RESET_ITEM or itemBase.itemType == ItemType.WING_SKILL_RESET_ITEM or itemBase.itemType == ItemType.WING_PHASE_UP_ITEM) then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if not require("Main.Wing.WingsInterface").InWingOpen() then
    Toast(textRes.Wing[25])
    return
  end
  require("Main.Wing.WingsInterface").OpenWingPanel(2)
  return true
end
OperationWingsPassiveItems.Commit()
return OperationWingsPassiveItems
