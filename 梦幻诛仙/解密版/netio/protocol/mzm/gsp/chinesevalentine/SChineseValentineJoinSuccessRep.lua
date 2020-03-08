local SChineseValentineJoinSuccessRep = class("SChineseValentineJoinSuccessRep")
SChineseValentineJoinSuccessRep.TYPEID = 12622089
function SChineseValentineJoinSuccessRep:ctor(activityId)
  self.id = 12622089
  self.activityId = activityId or nil
end
function SChineseValentineJoinSuccessRep:marshal(os)
  os:marshalInt32(self.activityId)
end
function SChineseValentineJoinSuccessRep:unmarshal(os)
  self.activityId = os:unmarshalInt32()
end
function SChineseValentineJoinSuccessRep:sizepolicy(size)
  return size <= 65535
end
return SChineseValentineJoinSuccessRep
