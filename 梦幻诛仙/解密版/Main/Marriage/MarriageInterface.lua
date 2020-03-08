local Lplus = require("Lplus")
local MarriageInterface = Lplus.Class("MarriageInterface")
local MarriageModule = require("Main.Marriage.MarriageModule")
local def = MarriageInterface.define
def.static("=>", "boolean").IsMarried = function()
  local mateInfo = MarriageModule.Instance().mateInfo
  if mateInfo then
    return true
  else
    return false
  end
end
def.static("=>", "boolean").IsDivorcing = function()
  local forceDivorceRoleId = MarriageModule.Instance().forceDivorceRoleId
  if forceDivorceRoleId then
    return forceDivorceRoleId == GetMyRoleID()
  else
    return false
  end
end
def.static("=>", "table").GetMateInfo = function()
  return MarriageModule.Instance().mateInfo
end
def.static("=>", "table").GetMarriageSkills = function()
  return MarriageModule.Instance():GetMarriageSkills()
end
def.static("string", "string").SendRedPacket = function(roleIdStr, roleName)
  local roleId = Int64.new(string.sub(roleIdStr, 11))
  MarriageModule.Instance():SendRedPacket(roleId, roleName)
end
def.static("string").JoinWedding = function(roleIdStr)
  local roleId = Int64.new(string.sub(roleIdStr, 9))
  MarriageModule.Instance():C2SJoinWedding(roleId)
end
def.static().ShowCoupleSkill = function()
  MarriageModule.Instance():ShowCoupleSkill()
end
return MarriageInterface.Commit()
