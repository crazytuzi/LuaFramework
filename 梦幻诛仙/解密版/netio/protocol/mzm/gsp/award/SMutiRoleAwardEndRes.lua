local SMutiRoleAwardEndRes = class("SMutiRoleAwardEndRes")
SMutiRoleAwardEndRes.TYPEID = 12583437
function SMutiRoleAwardEndRes:ctor(awardUUid, index2Award)
  self.id = 12583437
  self.awardUUid = awardUUid or nil
  self.index2Award = index2Award or {}
end
function SMutiRoleAwardEndRes:marshal(os)
  os:marshalInt64(self.awardUUid)
  local _size_ = 0
  for _, _ in pairs(self.index2Award) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.index2Award) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SMutiRoleAwardEndRes:unmarshal(os)
  self.awardUUid = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.award.MultiRoleAwardBean")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.index2Award[k] = v
  end
end
function SMutiRoleAwardEndRes:sizepolicy(size)
  return size <= 65535
end
return SMutiRoleAwardEndRes
