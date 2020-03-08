local MultiRoleAwardBean = require("netio.protocol.mzm.gsp.award.MultiRoleAwardBean")
local STakeSelectAwardRes = class("STakeSelectAwardRes")
STakeSelectAwardRes.TYPEID = 12583434
function STakeSelectAwardRes:ctor(awardUUid, index, roleid, awardBean)
  self.id = 12583434
  self.awardUUid = awardUUid or nil
  self.index = index or nil
  self.roleid = roleid or nil
  self.awardBean = awardBean or MultiRoleAwardBean.new()
end
function STakeSelectAwardRes:marshal(os)
  os:marshalInt64(self.awardUUid)
  os:marshalInt32(self.index)
  os:marshalInt64(self.roleid)
  self.awardBean:marshal(os)
end
function STakeSelectAwardRes:unmarshal(os)
  self.awardUUid = os:unmarshalInt64()
  self.index = os:unmarshalInt32()
  self.roleid = os:unmarshalInt64()
  self.awardBean = MultiRoleAwardBean.new()
  self.awardBean:unmarshal(os)
end
function STakeSelectAwardRes:sizepolicy(size)
  return size <= 65535
end
return STakeSelectAwardRes
