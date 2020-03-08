local SJailBreakError = class("SJailBreakError")
SJailBreakError.TYPEID = 12620040
function SJailBreakError:ctor(errorCode, params)
  self.id = 12620040
  self.errorCode = errorCode or nil
  self.params = params or {}
end
function SJailBreakError:marshal(os)
  os:marshalInt32(self.errorCode)
  os:marshalCompactUInt32(table.getn(self.params))
  for _, v in ipairs(self.params) do
    os:marshalOctets(v)
  end
end
function SJailBreakError:unmarshal(os)
  self.errorCode = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalOctets()
    table.insert(self.params, v)
  end
end
function SJailBreakError:sizepolicy(size)
  return size <= 65535
end
return SJailBreakError
