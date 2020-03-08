local SConfirmReq = class("SConfirmReq")
SConfirmReq.TYPEID = 12617988
function SConfirmReq:ctor(confirmType, sessionid, extroInfo, acceptedMembers, endTime, defaultAgreeRoleIds)
  self.id = 12617988
  self.confirmType = confirmType or nil
  self.sessionid = sessionid or nil
  self.extroInfo = extroInfo or nil
  self.acceptedMembers = acceptedMembers or {}
  self.endTime = endTime or nil
  self.defaultAgreeRoleIds = defaultAgreeRoleIds or {}
end
function SConfirmReq:marshal(os)
  os:marshalInt32(self.confirmType)
  os:marshalInt64(self.sessionid)
  os:marshalOctets(self.extroInfo)
  os:marshalCompactUInt32(table.getn(self.acceptedMembers))
  for _, v in ipairs(self.acceptedMembers) do
    os:marshalInt64(v)
  end
  os:marshalInt32(self.endTime)
  local _size_ = 0
  for _, _ in pairs(self.defaultAgreeRoleIds) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.defaultAgreeRoleIds) do
    os:marshalInt64(k)
  end
end
function SConfirmReq:unmarshal(os)
  self.confirmType = os:unmarshalInt32()
  self.sessionid = os:unmarshalInt64()
  self.extroInfo = os:unmarshalOctets()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.acceptedMembers, v)
  end
  self.endTime = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    self.defaultAgreeRoleIds[v] = v
  end
end
function SConfirmReq:sizepolicy(size)
  return size <= 65535
end
return SConfirmReq
