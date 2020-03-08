local SChildrenSelectOccupationErrorRes = class("SChildrenSelectOccupationErrorRes")
SChildrenSelectOccupationErrorRes.TYPEID = 12609372
SChildrenSelectOccupationErrorRes.ERROR_DO_NOT_HAS_OCCUPATION = 1
function SChildrenSelectOccupationErrorRes:ctor(ret)
  self.id = 12609372
  self.ret = ret or nil
end
function SChildrenSelectOccupationErrorRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SChildrenSelectOccupationErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SChildrenSelectOccupationErrorRes:sizepolicy(size)
  return size <= 65535
end
return SChildrenSelectOccupationErrorRes
