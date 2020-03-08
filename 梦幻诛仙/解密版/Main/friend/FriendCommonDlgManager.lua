local Lplus = require("Lplus")
local FriendCommonDlgManager = Lplus.Class("FriendCommonDlgManager")
local CommonRoleOperateMenu = require("GUI.CommonRoleOperateMenu")
local FriendModule = Lplus.ForwardDeclare("FriendModule")
local FriendUtils = Lplus.ForwardDeclare("FriendUtils")
local ChatModule = Lplus.ForwardDeclare("ChatModule")
local def = FriendCommonDlgManager.define
local instance
def.const("number").FRIEND_ADD_OR_DELETE = 1
def.const("number").CHAT = 2
def.const("number").TEAM_INVITE_OR_IN = 3
def.field("userdata")._strangerId = nil
def.field("boolean")._bComplete = false
def.field("table")._commonInfo = nil
def.const("table").StateConst = {
  Null = 0,
  GangChat = 1,
  NewerChat = 2,
  WorldChat = 3,
  SceneChat = 4,
  OtherChat = 5
}
def.static("=>", FriendCommonDlgManager).Instance = function()
  if nil == instance then
    instance = FriendCommonDlgManager()
  end
  return instance
end
def.static().Clear = function()
  FriendCommonDlgManager.Instance()._strangerId = nil
  FriendCommonDlgManager.Instance()._commonInfo = nil
  FriendCommonDlgManager.Instance()._bComplete = true
end
def.static("userdata", "number").ApplyShowFriendCommonDlg = function(roleId, state)
  if roleId == FriendCommonDlgManager.Instance()._strangerId and false == FriendCommonDlgManager.Instance()._bComplete then
    return
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.role.CGetRoleInfoReq").new(roleId))
  FriendCommonDlgManager.Instance()._commonInfo = {}
  FriendCommonDlgManager.Instance()._commonInfo.roleId = roleId
  FriendCommonDlgManager.Instance()._bComplete = false
  FriendCommonDlgManager.Instance()._strangerId = roleId
  FriendCommonDlgManager.Instance()._commonInfo.state = state
end
def.static("table").SetRoleInfo = function(p)
  if nil ~= FriendCommonDlgManager.Instance()._commonInfo and false == FriendCommonDlgManager.Instance()._bComplete then
    FriendCommonDlgManager.Instance()._commonInfo.occupationId = p.occupationId
    FriendCommonDlgManager.Instance()._commonInfo.level = p.level
    FriendCommonDlgManager.Instance()._commonInfo.name = p.name
    FriendCommonDlgManager.Instance()._commonInfo.teamId = p.teamId
    FriendCommonDlgManager.Instance()._commonInfo.gangId = p.gangId
    FriendCommonDlgManager.Instance()._commonInfo.gangName = p.gangName
    FriendCommonDlgManager.Instance()._commonInfo.onlineStatus = p.onlineStatus
    FriendCommonDlgManager.Instance()._commonInfo.gender = p.gender
    FriendCommonDlgManager.Instance()._commonInfo.teamMemberNum = p.teamMemberNum
    FriendCommonDlgManager.Instance()._commonInfo.friendSetting = p.friendSetting
    FriendCommonDlgManager.Instance()._commonInfo.deleteState = p.deleteState
    p.bNeedAt = FriendCommonDlgManager._NeedAt()
    FriendCommonDlgManager.ShowFriendCommonDlg(p, 154, 304)
  end
  FriendCommonDlgManager.Instance()._strangerId = nil
  FriendCommonDlgManager.Instance()._commonInfo = nil
  FriendCommonDlgManager.Instance()._bComplete = true
end
def.static("table", "number", "number").ShowFriendCommonDlg = function(info, x, y)
  require("Main.Pubrole.PubroleTipsMgr").Instance():ShowTipXY(info, x, y, nil)
end
def.static("=>", "boolean")._NeedAt = function()
  local StateConst = FriendCommonDlgManager.StateConst
  local curState = FriendCommonDlgManager.Instance()._commonInfo.state
  if curState == StateConst.GangChat or curState == StateConst.NewerChat or curState == StateConst.WorldChat or curState == StateConst.SceneChat or curState == StateConst.OtherChat then
    return true
  else
    return false
  end
end
FriendCommonDlgManager.Commit()
return FriendCommonDlgManager
