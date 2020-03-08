local CorpsMemberExtroInfo = require("netio.protocol.mzm.gsp.corps.CorpsMemberExtroInfo")
local SSynMemberExtroInfo = class("SSynMemberExtroInfo")
SSynMemberExtroInfo.TYPEID = 12617495
function SSynMemberExtroInfo:ctor(member, extroInfo)
  self.id = 12617495
  self.member = member or nil
  self.extroInfo = extroInfo or CorpsMemberExtroInfo.new()
end
function SSynMemberExtroInfo:marshal(os)
  os:marshalInt64(self.member)
  self.extroInfo:marshal(os)
end
function SSynMemberExtroInfo:unmarshal(os)
  self.member = os:unmarshalInt64()
  self.extroInfo = CorpsMemberExtroInfo.new()
  self.extroInfo:unmarshal(os)
end
function SSynMemberExtroInfo:sizepolicy(size)
  return size <= 65535
end
return SSynMemberExtroInfo
