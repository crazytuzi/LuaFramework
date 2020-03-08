local Lplus = require("Lplus")
local PubroleOperationBase = require("Main.Pubrole.Operations.PubroleOperationBase")
local PubroleNoTalkInGang = Lplus.Extend(PubroleOperationBase, "PubroleNoTalkInGang")
local FriendModule = Lplus.ForwardDeclare("FriendModule")
local RoleDeleteStatus = require("netio.protocol.mzm.gsp.RoleDeleteStatus")
local GangData = require("Main.Gang.data.GangData")
local GangUtility = require("Main.Gang.GangUtility")
local FriendCommonDlgManager = Lplus.ForwardDeclare("FriendCommonDlgManager")
local def = PubroleNoTalkInGang.define
def.override("table", "=>", "boolean").CanDispaly = function(self, roleInfo)
  local heroMember = GangData.Instance():GetMemberInfoByRoleId(_G.GetMyRoleID())
  if heroMember ~= nil and roleInfo.state == FriendCommonDlgManager.StateConst.GangChat then
    local tbl = GangUtility.GetAuthority(heroMember.duty)
    local memberInfo = GangData.Instance():GetMemberInfoByRoleId(roleInfo.roleId)
    if tbl.isCanForbidden then
      if memberInfo.forbiddenTalk == 0 and roleInfo.deleteState == RoleDeleteStatus.STATE_NORMAL then
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
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Friend[43]
end
def.override("table", "=>", "boolean").Operate = function(self, roleInfo)
  local costVigor = GangUtility.GetGangConsts("FORBIDDEN_TALK_COST_VIGOR")
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if costVigor > heroProp.energy then
    Toast(string.format(textRes.Gang[82], costVigor))
    return true
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CForbiddenTalkReq").new(roleInfo.roleId))
  return true
end
PubroleNoTalkInGang.Commit()
return PubroleNoTalkInGang
