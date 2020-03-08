local SMakeUpNormalInfo = class("SMakeUpNormalInfo")
SMakeUpNormalInfo.TYPEID = 12625923
SMakeUpNormalInfo.ALREADY_PICK_UP_ONE = 1
function SMakeUpNormalInfo:ctor(result, args)
  self.id = 12625923
  self.result = result or nil
  self.args = args or {}
end
function SMakeUpNormalInfo:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalOctets(v)
  end
end
function SMakeUpNormalInfo:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalOctets()
    table.insert(self.args, v)
  end
end
function SMakeUpNormalInfo:sizepolicy(size)
  return size <= 65535
end
return SMakeUpNormalInfo
