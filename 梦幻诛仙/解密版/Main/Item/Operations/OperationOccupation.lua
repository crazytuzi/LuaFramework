local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local MathHelper = require("Common.MathHelper")
local OperationOccupation = Lplus.Extend(OperationBase, "OperationOccupation")
local def = OperationOccupation.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.ACTIVATE_NEW_OCCUP_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  require("GUI.ECGUIMan").Instance():DestroyUIAtLevel(1)
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
    constant.CMultiOccupConsts.npc
  })
  Toast(textRes.MultiOccupation[21])
  return true
end
OperationOccupation.Commit()
return OperationOccupation
