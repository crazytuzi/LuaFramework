local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationMountsUnlockProtect = Lplus.Extend(OperationBase, "OperationMountsUnlockProtect")
local MountsUtils = require("Main.Mounts.MountsUtils")
local def = OperationMountsUnlockProtect.define
def.field("boolean").bind = false
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and MountsUtils.IsMountsProtectPetsUnlockItemType(itemBase.itemType) then
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
    MountsPanel.Instance():ShowPanelWithTabId(MountsPanel.NodeId.Guard)
    Toast(textRes.Mounts[134])
  end
  return true
end
OperationMountsUnlockProtect.Commit()
return OperationMountsUnlockProtect
