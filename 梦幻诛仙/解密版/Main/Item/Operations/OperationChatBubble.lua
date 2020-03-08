local MODULE_NAME = (...)
local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local OperationChatBubble = Lplus.Extend(OperationBase, "OperationChatBubble")
local def = OperationChatBubble.define
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local ChatBubbleMgr = require("Main.Chat.ChatBubble.ChatBubbleMgr")
local const = constant.ChatBubbleConsts
local txtConst = textRes.Chat.ChatBubble
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  if itemBase.itemType ~= ItemType.CHAT_BUBBLE_ITEM or not ChatBubbleMgr.IsFeatureOpen() then
    return false
  end
  return true
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if _G.GetHeroProp().level < const.minRoleLevel then
    Toast(txtConst[2]:format(const.minRoleLevel))
  else
    local item = require("Main.Item.ItemModule").Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
    if item then
      local bubbleCfgId = require("Main.Chat.ChatBubble.ChatBubbleUtils").GetCfgIdByItemId(item.id)
      require("Main.Avatar.ui.AvatarPanel").Instance():ShowPanelToBubbleNode(bubbleCfgId)
    end
  end
  return true
end
return OperationChatBubble.Commit()
