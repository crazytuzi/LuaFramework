local SSendMatchMembers = class("SSendMatchMembers")
SSendMatchMembers.TYPEID = 12593680
function SSendMatchMembers:ctor(leadersInfo, leadersNum, rolesNum)
  self.id = 12593680
  self.leadersInfo = leadersInfo or {}
  self.leadersNum = leadersNum or nil
  self.rolesNum = rolesNum or nil
end
function SSendMatchMembers:marshal(os)
  os:marshalCompactUInt32(table.getn(self.leadersInfo))
  for _, v in ipairs(self.leadersInfo) do
    v:marshal(os)
  end
  os:marshalInt32(self.leadersNum)
  os:marshalInt32(self.rolesNum)
end
function SSendMatchMembers:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.teamplatform.TeamInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.leadersInfo, v)
  end
  self.leadersNum = os:unmarshalInt32()
  self.rolesNum = os:unmarshalInt32()
end
function SSendMatchMembers:sizepolicy(size)
  return size <= 65535
end
return SSendMatchMembers
