local SCheckWingsRep = class("SCheckWingsRep")
SCheckWingsRep.TYPEID = 12596541
function SCheckWingsRep:ctor(roleId, curLv, curRank, checkWing, wings)
  self.id = 12596541
  self.roleId = roleId or nil
  self.curLv = curLv or nil
  self.curRank = curRank or nil
  self.checkWing = checkWing or nil
  self.wings = wings or {}
end
function SCheckWingsRep:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalInt32(self.curLv)
  os:marshalInt32(self.curRank)
  os:marshalInt32(self.checkWing)
  local _size_ = 0
  for _, _ in pairs(self.wings) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.wings) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SCheckWingsRep:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.curLv = os:unmarshalInt32()
  self.curRank = os:unmarshalInt32()
  self.checkWing = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.wing.WingCheckData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.wings[k] = v
  end
end
function SCheckWingsRep:sizepolicy(size)
  return size <= 65535
end
return SCheckWingsRep
