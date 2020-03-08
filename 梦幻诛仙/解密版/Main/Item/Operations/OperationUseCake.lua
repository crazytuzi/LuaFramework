local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local MathHelper = require("Common.MathHelper")
local OperationUseCake = Lplus.Extend(OperationBase, "OperationUseCake")
local PersonalHelper = require("Main.Chat.PersonalHelper")
local def = OperationUseCake.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.CAKE_AWARD_ITEM then
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
  local item_id = item.id
  local item_uuid = item.uuid[1]
  require("Main.activity.BakeCake.BakeCakeMgr").Instance():ReqUseCakeItem(item_id, item_uuid)
  return true
end
OperationUseCake.Commit()
return OperationUseCake
