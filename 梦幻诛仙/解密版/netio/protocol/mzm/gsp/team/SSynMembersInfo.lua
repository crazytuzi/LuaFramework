local SSynMembersInfo = class("SSynMembersInfo")
SSynMembersInfo.TYPEID = 12588342
function SSynMembersInfo:ctor(members)
  self.id = 12588342
  self.members = members or {}
end
function SSynMembersInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.members))
  for _, v in ipairs(self.members) do
    v:marshal(os)
  end
end
function SSynMembersInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.team.RoleInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.members, v)
  end
end
function SSynMembersInfo:sizepolicy(size)
  return size <= 65535
end
return SSynMembersInfo
