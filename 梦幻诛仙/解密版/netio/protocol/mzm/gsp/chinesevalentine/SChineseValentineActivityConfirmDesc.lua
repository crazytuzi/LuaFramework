local SChineseValentineActivityConfirmDesc = class("SChineseValentineActivityConfirmDesc")
SChineseValentineActivityConfirmDesc.TYPEID = 12622085
function SChineseValentineActivityConfirmDesc:ctor(activityId)
  self.id = 12622085
  self.activityId = activityId or nil
end
function SChineseValentineActivityConfirmDesc:marshal(os)
  os:marshalInt32(self.activityId)
end
function SChineseValentineActivityConfirmDesc:unmarshal(os)
  self.activityId = os:unmarshalInt32()
end
function SChineseValentineActivityConfirmDesc:sizepolicy(size)
  return size <= 65535
end
return SChineseValentineActivityConfirmDesc
