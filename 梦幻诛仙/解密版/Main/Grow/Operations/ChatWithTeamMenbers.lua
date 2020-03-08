local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local ChatWithTeamMenbers = Lplus.Extend(Operation, CUR_CLASS_NAME)
local ChatMsgData = require("Main.Chat.ChatMsgData")
local def = ChatWithTeamMenbers.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  require("Main.Chat.ui.ChannelChatPanel").ShowChannelChatPanel(ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.TEAM)
  return true
end
return ChatWithTeamMenbers.Commit()
