local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local MathHelper = require("Common.MathHelper")
local OperationUnlockAvatarFrameItem = Lplus.Extend(OperationBase, "OperationUnlockAvatarFrameItem")
local def = OperationUnlockAvatarFrameItem.define
def.field("boolean").bind = false
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.AVATAR_FRAME_ITEM then
    if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_AVATAR_FRAME) then
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
  if curLevel < constant.CAvatarFrameConsts.OPEN_LEVEL then
    Toast(string.format(textRes.Avatar[15], constant.CAvatarFrameConsts.OPEN_LEVEL))
    return false
  end
  local AvatarFrameMgr = require("Main.Avatar.AvatarFrameMgr")
  local frameItemCfg = AvatarFrameMgr.GetAvatarFrameItemCfg(item.id)
  if frameItemCfg then
    local cfg = AvatarFrameMgr.GetAvatarFrameCfg(frameItemCfg.avatarFrameId)
    local myOccupation = heroProp.occupation or 0
    local myGender = heroProp.gender or 0
    if (cfg.factionLimit == 0 or cfg.factionLimit == myOccupation) and (cfg.genderLimit == 0 or cfg.genderLimit == myGender) then
      local AvatarPanel = require("Main.Avatar.ui.AvatarPanel")
      AvatarPanel.Instance():ShowPanelToAvatarFrame(frameItemCfg.avatarFrameId)
      return true
    end
    Toast(textRes.Avatar[106])
    return false
  end
  return true
end
OperationUnlockAvatarFrameItem.Commit()
return OperationUnlockAvatarFrameItem
