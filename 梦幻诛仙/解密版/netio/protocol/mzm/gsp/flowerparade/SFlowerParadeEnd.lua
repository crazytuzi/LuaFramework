local SFlowerParadeEnd = class("SFlowerParadeEnd")
SFlowerParadeEnd.TYPEID = 12625672
function SFlowerParadeEnd:ctor(activityId)
  self.id = 12625672
  self.activityId = activityId or nil
end
function SFlowerParadeEnd:marshal(os)
  os:marshalInt32(self.activityId)
end
function SFlowerParadeEnd:unmarshal(os)
  self.activityId = os:unmarshalInt32()
end
function SFlowerParadeEnd:sizepolicy(size)
  return size <= 65535
end
return SFlowerParadeEnd
