local CRenameReq = class("CRenameReq")
CRenameReq.TYPEID = 12585986
CRenameReq.yuanBao = 1
CRenameReq.item = 2
function CRenameReq:ctor(newName, isUseYuanBao, rolestate)
  self.id = 12585986
  self.newName = newName or nil
  self.isUseYuanBao = isUseYuanBao or nil
  self.rolestate = rolestate or {}
end
function CRenameReq:marshal(os)
  os:marshalString(self.newName)
  os:marshalInt32(self.isUseYuanBao)
  local _size_ = 0
  for _, _ in pairs(self.rolestate) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.rolestate) do
    os:marshalInt32(k)
    os:marshalInt64(v)
  end
end
function CRenameReq:unmarshal(os)
  self.newName = os:unmarshalString()
  self.isUseYuanBao = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt64()
    self.rolestate[k] = v
  end
end
function CRenameReq:sizepolicy(size)
  return size <= 65535
end
return CRenameReq
