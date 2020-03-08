local SAddGangHelp = class("SAddGangHelp")
SAddGangHelp.TYPEID = 12584466
function SAddGangHelp:ctor(roleId, boxIndex2Data)
  self.id = 12584466
  self.roleId = roleId or nil
  self.boxIndex2Data = boxIndex2Data or {}
end
function SAddGangHelp:marshal(os)
  os:marshalInt64(self.roleId)
  local _size_ = 0
  for _, _ in pairs(self.boxIndex2Data) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.boxIndex2Data) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SAddGangHelp:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.huanhun.BoxData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.boxIndex2Data[k] = v
  end
end
function SAddGangHelp:sizepolicy(size)
  return size <= 65535
end
return SAddGangHelp
