local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local ChatWithGangMenbers = Lplus.Extend(Operation, CUR_CLASS_NAME)
local ChatMsgData = require("Main.Chat.ChatMsgData")
local def = ChatWithGangMenbers.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  if self:HasGang() then
    require("Main.Chat.ui.ChannelChatPanel").ShowChannelChatPanel(ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION)
  else
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_GANG_CLICK, nil)
  end
  return true
end
def.method("=>", "boolean").HasGang = function(self)
  return require("Main.Gang.GangModule").Instance():HasGang()
end
return ChatWithGangMenbers.Commit()
