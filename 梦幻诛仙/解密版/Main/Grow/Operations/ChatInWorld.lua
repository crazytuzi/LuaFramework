local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local ChatInWorld = Lplus.Extend(Operation, CUR_CLASS_NAME)
local ChatMsgData = require("Main.Chat.ChatMsgData")
local def = ChatInWorld.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  require("Main.Chat.ui.ChannelChatPanel").ShowChannelChatPanel(ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.WORLD)
  return true
end
return ChatInWorld.Commit()
