local SSyncRoleBuffList = class("SSyncRoleBuffList")
SSyncRoleBuffList.TYPEID = 12583169
function SSyncRoleBuffList:ctor(buffList)
  self.id = 12583169
  self.buffList = buffList or {}
end
function SSyncRoleBuffList:marshal(os)
  os:marshalCompactUInt32(table.getn(self.buffList))
  for _, v in ipairs(self.buffList) do
    v:marshal(os)
  end
end
function SSyncRoleBuffList:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.buff.BuffInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.buffList, v)
  end
end
function SSyncRoleBuffList:sizepolicy(size)
  return size <= 65535
end
return SSyncRoleBuffList
