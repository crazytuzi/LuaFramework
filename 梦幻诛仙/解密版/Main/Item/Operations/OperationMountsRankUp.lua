local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local MathHelper = require("Common.MathHelper")
local OperationMountsRankUp = Lplus.Extend(OperationBase, "OperationMountsRankUp")
local def = OperationMountsRankUp.define
def.field("boolean").bind = false
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and (itemBase.itemType == ItemType.MOUNTS_RANK_UP_ITEM or itemBase.itemType == ItemType.MOUNTS_HIGH_RANK_UP_ITEM) then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local MountsModule = require("Main.Mounts.MountsModule")
  local checkResult = MountsModule.CheckMountsOperation()
  if checkResult then
    local MountsPanel = require("Main.Mounts.ui.MountsPanel")
    MountsPanel.Instance():ShowPanelWithTabId(MountsPanel.NodeId.BasicAttr)
  end
  return true
end
OperationMountsRankUp.Commit()
return OperationMountsRankUp
