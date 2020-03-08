local Lplus = require("Lplus")
local CorpsInterface = Lplus.Class("CorpsInterface")
local CorpsModule = require("Main.Corps.CorpsModule")
local def = CorpsInterface.define
def.static("=>", "boolean").HasCorps = function()
  return CorpsModule.Instance():GetData() ~= nil
end
def.static("=>", "boolean").IsCorpsLeader = function()
  local data = CorpsModule.Instance():GetData()
  if data then
    return data:IsLeader(GetMyRoleID())
  else
    return false
  end
end
def.static("userdata", "number").InviteToCorps = function(roleId, lv)
  CorpsModule.Instance():InviteToCorps(roleId, lv)
end
def.static("=>", "table").GetCorpsBriefData = function()
  local data = CorpsModule.Instance():GetData()
  if data then
    return {
      corpsId = data:GetCorpsId(),
      name = data:GetName(),
      declaration = data:GetDeclaration(),
      badgeId = data:GetBadgeId(),
      createTime = data:GetCreateTime()
    }
  else
    return nil
  end
end
def.static("=>", "table").GetCorpsMembersData = function()
  return CorpsModule.Instance():GetMembersData()
end
def.static("=>", "number").GetCorpsMembersCount = function()
  local data = CorpsModule.Instance():GetData()
  if data then
    return data:GetMemberCount()
  else
    return 0
  end
end
def.static("userdata", "=>", "table").GetCorpsMemberInfo = function(roleId)
  local data = CorpsModule.Instance():GetData()
  if data then
    return data:GetMemberInfoByRoleId(roleId)
  else
    return nil
  end
end
def.static().OpenCorpsManage = function()
  CorpsModule.Instance():OpenCorpsManage()
end
def.static("userdata").CheckCorpsInfo = function(corpsId)
  CorpsModule.Instance():RequestCorpsOtherInfo(corpsId, function(data)
    require("Main.Corps.ui.CorpsCheckDlg").ShowCorpsCheck(data)
  end)
end
def.static("userdata", "function").RequestCorpsDetail = function(corpsId, cb)
  CorpsModule.Instance():RequestCorpsDetailInfo(corpsId, cb)
end
def.static("userdata", "function").RequestCorpsBrief = function(corpsId, cb)
  CorpsModule.Instance():RequestCorpsBriefInfo(corpsId, cb)
end
def.static("=>", "boolean").IsOpen = function()
  return CorpsModule.Instance():IsOpen()
end
def.static("number", "=>", "string").MultiFightValueToString = function(fightValue)
  local fightValueStr
  if fightValue % 1 > 0 then
    fightValueStr = string.format("%.1f", fightValue)
  else
    fightValueStr = tostring(fightValue)
  end
  return fightValueStr
end
def.static("function").RegisterKickHandler = function(func)
  CorpsModule.Instance():RegisterKickHandler(func)
end
def.static("function").RegisterQuitHandler = function(func)
  CorpsModule.Instance():RegisterQuitHandler(func)
end
def.static("function").RegisterInviteHandler = function(func)
  CorpsModule.Instance():RegisterInviteHandler(func)
end
return CorpsInterface.Commit()
