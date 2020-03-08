local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local MathHelper = require("Common.MathHelper")
local OperationUnlockAvatarItem = Lplus.Extend(OperationBase, "OperationUnlockAvatarItem")
local def = OperationUnlockAvatarItem.define
def.field("boolean").bind = false
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.UNLOCK_AVATAR_ITEM then
    if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_AVATAR) then
      return false
    end
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return false
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local curLevel = 0
  if heroProp then
    curLevel = heroProp.level
  end
  if curLevel < constant.CAvatarConsts.OPEN_LEVEL then
    Toast(string.format(textRes.Avatar[15], constant.CAvatarConsts.OPEN_LEVEL))
    return false
  end
  local AvatarInterface = require("Main.Avatar.AvatarInterface")
  local avatarItemCfg = AvatarInterface.GetAvatarUnlockCfg(item.id)
  if avatarItemCfg == nil then
    return true
  end
  local avatarId = avatarItemCfg.avatarId
  local avatarInterface = AvatarInterface.Instance()
  if avatarInterface:isUnlockAvatarId(avatarId) then
    local info = avatarInterface:getUnlockAvatarInfo(avatarId)
    if info and info.expire_time:eq(Int64.new(0)) then
      Toast(textRes.Avatar[25])
      return true
    end
  end
  local ownNum = avatarInterface:getUnlockItemIdNum(avatarId)
  if ownNum > 0 then
    local AvatarItemUsePanel = require("Main.Avatar.ui.AvatarItemUsePanel")
    AvatarItemUsePanel.Instance():ShowPanel(avatarId)
  else
    Toast(textRes.Avatar[24])
  end
  return true
end
OperationUnlockAvatarItem.Commit()
return OperationUnlockAvatarItem
