local CorpsMember = require("netio.protocol.mzm.gsp.corps.CorpsMember")
local SSynMemberInfo = class("SSynMemberInfo")
SSynMemberInfo.TYPEID = 12617489
function SSynMemberInfo:ctor(memberInfo)
  self.id = 12617489
  self.memberInfo = memberInfo or CorpsMember.new()
end
function SSynMemberInfo:marshal(os)
  self.memberInfo:marshal(os)
end
function SSynMemberInfo:unmarshal(os)
  self.memberInfo = CorpsMember.new()
  self.memberInfo:unmarshal(os)
end
function SSynMemberInfo:sizepolicy(size)
  return size <= 65535
end
return SSynMemberInfo
