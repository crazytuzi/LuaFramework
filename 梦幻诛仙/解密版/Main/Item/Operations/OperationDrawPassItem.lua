local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local MathHelper = require("Common.MathHelper")
local OperationDrawPassItem = Lplus.Extend(OperationBase, "OperationDrawPassItem")
local PersonalHelper = require("Main.Chat.PersonalHelper")
local def = OperationDrawPassItem.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.DRAW_CARNIVAL_ACTIVITY_DRAW_PASS_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local item = gmodule.moduleMgr:GetModule(ModuleId.ITEM):GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return true
  end
  local DragonBaoKuMgr = require("Main.activity.DragonBaoKu.DragonBaoKuMgr")
  if DragonBaoKuMgr.Instance():isOpen() then
    require("Main.activity.DragonBaoKu.ui.DragonBaoKuPanel").Instance():ShowPanelByItem(item.id)
  else
    Toast(textRes.activity.DragonBaoKu[11])
  end
  return true
end
OperationDrawPassItem.Commit()
return OperationDrawPassItem
