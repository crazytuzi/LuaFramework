local Lplus = require("Lplus")
local OperationMarketShareBase = require("Main.Item.Operations.OperationMarketShareBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local EquipUtils = require("Main.Equip.EquipUtils")
local ItemModule = require("Main.Item.ItemModule")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local ChatModule = require("Main.Chat.ChatModule")
local ChatConst = require("netio.protocol.mzm.gsp.chat.ChatConsts")
local OperationMarketShareGang = Lplus.Extend(OperationMarketShareBase, "OperationMarketShareGang")
local def = OperationMarketShareGang.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  return true
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[9523]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local content = self:ConvertChannelContent(context)
  ChatModule.Instance():SendChannelMsg(content, ChatConst.CHANNEL_FACTION, false)
  return true
end
OperationMarketShareGang.Commit()
return OperationMarketShareGang
