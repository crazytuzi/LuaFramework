local CSetCustomConfirmInfoReq = class("CSetCustomConfirmInfoReq")
CSetCustomConfirmInfoReq.TYPEID = 12617989
function CSetCustomConfirmInfoReq:ctor(confirmInfos)
  self.id = 12617989
  self.confirmInfos = confirmInfos or {}
end
function CSetCustomConfirmInfoReq:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.confirmInfos) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.confirmInfos) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function CSetCustomConfirmInfoReq:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.confirmInfos[k] = v
  end
end
function CSetCustomConfirmInfoReq:sizepolicy(size)
  return size <= 65535
end
return CSetCustomConfirmInfoReq
