local CTaskJionCountAward = class("CTaskJionCountAward")
CTaskJionCountAward.TYPEID = 12601869
function CTaskJionCountAward:ctor(joinCount)
  self.id = 12601869
  self.joinCount = joinCount or nil
end
function CTaskJionCountAward:marshal(os)
  os:marshalInt32(self.joinCount)
end
function CTaskJionCountAward:unmarshal(os)
  self.joinCount = os:unmarshalInt32()
end
function CTaskJionCountAward:sizepolicy(size)
  return size <= 65535
end
return CTaskJionCountAward
