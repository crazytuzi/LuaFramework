local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenFriendList = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenFriendList.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  require("Main.friend.ui.SocialDlg").ShowSocialDlg(2)
  return true
end
return OpenFriendList.Commit()
