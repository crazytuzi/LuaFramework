local CRemoveBuff = class("CRemoveBuff")
CRemoveBuff.TYPEID = 12583174
function CRemoveBuff:ctor(buffId)
  self.id = 12583174
  self.buffId = buffId or nil
end
function CRemoveBuff:marshal(os)
  os:marshalInt32(self.buffId)
end
function CRemoveBuff:unmarshal(os)
  self.buffId = os:unmarshalInt32()
end
function CRemoveBuff:sizepolicy(size)
  return size <= 65535
end
return CRemoveBuff
