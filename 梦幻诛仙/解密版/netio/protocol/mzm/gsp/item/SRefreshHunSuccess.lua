local SRefreshHunSuccess = class("SRefreshHunSuccess")
SRefreshHunSuccess.TYPEID = 12584815
function SRefreshHunSuccess:ctor(bagid, uuid, extrProps)
  self.id = 12584815
  self.bagid = bagid or nil
  self.uuid = uuid or nil
  self.extrProps = extrProps or {}
end
function SRefreshHunSuccess:marshal(os)
  os:marshalInt32(self.bagid)
  os:marshalInt64(self.uuid)
  local _size_ = 0
  for _, _ in pairs(self.extrProps) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.extrProps) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SRefreshHunSuccess:unmarshal(os)
  self.bagid = os:unmarshalInt32()
  self.uuid = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.item.TempExtraProInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.extrProps[k] = v
  end
end
function SRefreshHunSuccess:sizepolicy(size)
  return size <= 65535
end
return SRefreshHunSuccess
