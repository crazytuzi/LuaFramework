local SSyncMatch = class("SSyncMatch")
SSyncMatch.TYPEID = 12616745
function SSyncMatch:ctor(compete_index)
  self.id = 12616745
  self.compete_index = compete_index or nil
end
function SSyncMatch:marshal(os)
  os:marshalInt32(self.compete_index)
end
function SSyncMatch:unmarshal(os)
  self.compete_index = os:unmarshalInt32()
end
function SSyncMatch:sizepolicy(size)
  return size <= 65535
end
return SSyncMatch
