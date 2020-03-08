local Lplus = require("Lplus")
local OperationMarketShareBase = require("Main.Item.Operations.OperationMarketShareBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local EquipUtils = require("Main.Equip.EquipUtils")
local ItemModule = require("Main.Item.ItemModule")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local ChatModule = require("Main.Chat.ChatModule")
local ChatConst = require("netio.protocol.mzm.gsp.chat.ChatConsts")
local OperationMarketShareGroup = Lplus.Extend(OperationMarketShareBase, "OperationMarketShareGroup")
local def = OperationMarketShareGroup.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  return true
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[9526]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local content = self:ConvertChannelContent(context)
  local GroupModule = require("Main.Group.GroupModule")
  local function onGroupBasicInfoLoaded(groupList)
    if #groupList == 0 then
      Toast(textRes.Group[34])
      return
    end
    local panel = require("Main.Group.ui.GroupSelectPanel").Instance()
    panel:ShowPanel(textRes.Group[36], 1, function(groupIds)
      if #groupIds == 0 then
        Toast(textRes.Group[37])
        return false
      end
      local lastGroupId
      for i, groupId in ipairs(groupIds) do
        lastGroupId = groupId
        ChatModule.Instance():SendGroupChatMsg(groupId, content, false)
      end
      ChatModule.Instance():ShowGroupChatPanel(lastGroupId)
    end)
  end
  GroupModule.Instance():LoadBasicGroupList(onGroupBasicInfoLoaded)
  return true
end
OperationMarketShareGroup.Commit()
return OperationMarketShareGroup
