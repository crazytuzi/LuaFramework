local SRemoveBuff = class("SRemoveBuff")
SRemoveBuff.TYPEID = 12583170
function SRemoveBuff:ctor(buffId)
  self.id = 12583170
  self.buffId = buffId or nil
end
function SRemoveBuff:marshal(os)
  os:marshalInt32(self.buffId)
end
function SRemoveBuff:unmarshal(os)
  self.buffId = os:unmarshalInt32()
end
function SRemoveBuff:sizepolicy(size)
  return size <= 65535
end
return SRemoveBuff
