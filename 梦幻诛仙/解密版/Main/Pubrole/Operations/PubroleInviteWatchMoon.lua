local Lplus = require("Lplus")
local PubroleOperationBase = require("Main.Pubrole.Operations.PubroleOperationBase")
local PubroleInviteWatchMoon = Lplus.Extend(PubroleOperationBase, "PubroleInviteWatchMoon")
local RoleDeleteStatus = require("netio.protocol.mzm.gsp.RoleDeleteStatus")
local GangData = require("Main.Gang.data.GangData")
local GangUtility = require("Main.Gang.GangUtility")
local FriendCommonDlgManager = Lplus.ForwardDeclare("FriendCommonDlgManager")
local def = PubroleInviteWatchMoon.define
def.override("table", "=>", "boolean").CanDispaly = function(self, roleInfo)
  local heroMember = GangData.Instance():GetMemberInfoByRoleId(_G.GetMyRoleID())
  if heroMember ~= nil then
    local actCfg = require("Main.activity.ActivityInterface").GetActivityCfgById(constant.CWatchmoonConsts.ACTIVITY_ID)
    if heroMember.level >= actCfg.levelMin then
      local memberInfo = GangData.Instance():GetMemberInfoByRoleId(roleInfo.roleId)
      if memberInfo then
        if memberInfo.level >= actCfg.levelMin then
          return true
        else
          return false
        end
      else
        return false
      end
    else
      return false
    end
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.WatchMoon[20]
end
def.override("table", "=>", "boolean").Operate = function(self, roleInfo)
  require("Main.activity.WatchMoon.WatchMoonMgr").Instance():SendWatchMoonRequest(roleInfo.roleId)
  return true
end
PubroleInviteWatchMoon.Commit()
return PubroleInviteWatchMoon
