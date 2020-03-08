local SChildrenChangeOccupationErrorRes = class("SChildrenChangeOccupationErrorRes")
SChildrenChangeOccupationErrorRes.TYPEID = 12609412
SChildrenChangeOccupationErrorRes.ERROR_DO_NOT_HAS_OCCUPATION = 1
SChildrenChangeOccupationErrorRes.ERROR_DO_NOT_HAS_ENOUGH_MONEY = 2
SChildrenChangeOccupationErrorRes.ERROR_DO_CHILD_IN_FIGHT_NOW = 3
function SChildrenChangeOccupationErrorRes:ctor(ret)
  self.id = 12609412
  self.ret = ret or nil
end
function SChildrenChangeOccupationErrorRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SChildrenChangeOccupationErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SChildrenChangeOccupationErrorRes:sizepolicy(size)
  return size <= 65535
end
return SChildrenChangeOccupationErrorRes
