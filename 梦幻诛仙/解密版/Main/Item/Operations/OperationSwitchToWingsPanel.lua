local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local MathHelper = require("Common.MathHelper")
local OperationSwitchToWingsPanel = Lplus.Extend(OperationBase, "OperationSwitchToWingsPanel")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local WingsUtility = require("Main.Wings.WingsUtility")
local def = OperationSwitchToWingsPanel.define
def.const("table").ItemTypeSwitchToNode = {
  [ItemType.WING_EXP_ITEM] = 1,
  [ItemType.WING_PROPERTY_RESET_ITEM] = 2,
  [ItemType.WING_SKILL_RESET_ITEM] = 2,
  [ItemType.WING_PHASE_UP_ITEM] = 1
}
def.field("number").tab = 1
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  if source == ItemTipsMgr.Source.Bag and self:NeedToSwitchToWingsPanel(itemBase.itemType) then
    self.tab = OperationSwitchToWingsPanel.ItemTypeSwitchToNode[itemBase.itemType]
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
  require("Main.Wing.WingInterface").OpenWingPanel(self.tab)
  return true
end
def.method("number", "=>", "boolean").NeedToSwitchToWingsPanel = function(self, itemType)
  return OperationSwitchToWingsPanel.ItemTypeSwitchToNode[itemType] ~= nil
end
OperationSwitchToWingsPanel.Commit()
return OperationSwitchToWingsPanel
