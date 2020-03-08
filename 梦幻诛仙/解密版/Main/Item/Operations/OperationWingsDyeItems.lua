local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local MathHelper = require("Common.MathHelper")
local OperationWingsDyeItems = Lplus.Extend(OperationBase, "OperationWingsDyeItems")
local PersonalHelper = require("Main.Chat.PersonalHelper")
local def = OperationWingsDyeItems.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.WING_DYE_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local WingInterface = require("Main.Wing.WingInterface")
  if not WingInterface.InWingOpen() then
    Toast(textRes.Wing[25])
    return true
  end
  local curWingId = WingInterface.GetCurWingId()
  if curWingId > 0 then
    WingInterface.ShowWingDye(curWingId)
  else
    WingInterface.OpenWingPanel(2)
  end
  return true
end
OperationWingsDyeItems.Commit()
return OperationWingsDyeItems
