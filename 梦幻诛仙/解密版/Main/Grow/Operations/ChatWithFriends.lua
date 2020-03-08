local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local ChatWithFriends = Lplus.Extend(Operation, CUR_CLASS_NAME)
local ChatMsgData = require("Main.Chat.ChatMsgData")
local def = ChatWithFriends.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  local SocialDlg = require("Main.friend.ui.SocialDlg")
  SocialDlg.ShowSocialDlg(SocialDlg.NodeId.Friend)
  return true
end
return ChatWithFriends.Commit()
