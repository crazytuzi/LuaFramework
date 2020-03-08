local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local MathHelper = require("Common.MathHelper")
local OperationGiveCake = Lplus.Extend(OperationBase, "OperationGiveCake")
local PersonalHelper = require("Main.Chat.PersonalHelper")
local def = OperationGiveCake.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.CAKE_AWARD_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8136]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local item = gmodule.moduleMgr:GetModule(ModuleId.ITEM):GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return true
  end
  local list = require("Main.friend.FriendData").Instance():GetFriendList()
  if #list < 1 then
    Toast(textRes.Item[146])
    return true
  end
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnPresent, {2, nil})
  return true
end
OperationGiveCake.Commit()
return OperationGiveCake
