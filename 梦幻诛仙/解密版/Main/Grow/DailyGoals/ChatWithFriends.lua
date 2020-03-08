local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local BaseGoal = import(".BaseGoal")
local ChatWithFriends = Lplus.Extend(BaseGoal, CUR_CLASS_NAME)
local def = ChatWithFriends.define
def.override("=>", "boolean").Go = function(self)
  require("Main.friend.ui.SocialDlg").ShowSocialDlg(2)
  return true
end
return ChatWithFriends.Commit()
