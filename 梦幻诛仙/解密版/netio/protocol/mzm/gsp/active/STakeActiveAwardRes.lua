local STakeActiveAwardRes = class("STakeActiveAwardRes")
STakeActiveAwardRes.TYPEID = 12599553
function STakeActiveAwardRes:ctor(index_id)
  self.id = 12599553
  self.index_id = index_id or nil
end
function STakeActiveAwardRes:marshal(os)
  os:marshalInt32(self.index_id)
end
function STakeActiveAwardRes:unmarshal(os)
  self.index_id = os:unmarshalInt32()
end
function STakeActiveAwardRes:sizepolicy(size)
  return size <= 65535
end
return STakeActiveAwardRes
