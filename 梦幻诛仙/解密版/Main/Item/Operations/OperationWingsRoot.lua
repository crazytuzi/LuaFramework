local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local MathHelper = require("Common.MathHelper")
local OperationWingsRoot = Lplus.Extend(OperationBase, "OperationWingsRoot")
local PersonalHelper = require("Main.Chat.PersonalHelper")
local def = OperationWingsRoot.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.WING_ROOT_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local curRoleLevel = require("Main.Hero.Interface"):GetBasicHeroProp().level
  local needRoleLevel = constant.WingConsts.MIN_ROLE_LEVLE_FOR_WING
  if curRoleLevel < needRoleLevel then
    Toast(string.format(textRes.Wing[24], needRoleLevel))
    return true
  end
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return
  end
  local p = require("netio.protocol.mzm.gsp.item.CUseWingRootItem").new(item.uuid[1])
  gmodule.network.sendProtocol(p)
  return true
end
OperationWingsRoot.Commit()
return OperationWingsRoot
