local Lplus = require("Lplus")
local RoleOperateHelper = Lplus.Class("RoleOperateHelper")
local FriendUtils = Lplus.ForwardDeclare("FriendUtils")
local FriendCommonDlgManager = require("Main.friend.FriendCommonDlgManager")
local def = RoleOperateHelper.define
local instance
def.static("table").ShowRoleOPPanel = function(roleInfo)
  FriendCommonDlgManager.ShowFriendCommonDlg(roleInfo, 54, 218)
end
return RoleOperateHelper.Commit()
