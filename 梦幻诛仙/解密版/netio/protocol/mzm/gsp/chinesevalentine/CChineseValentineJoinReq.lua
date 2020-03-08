local CChineseValentineJoinReq = class("CChineseValentineJoinReq")
CChineseValentineJoinReq.TYPEID = 12622087
function CChineseValentineJoinReq:ctor(activityId)
  self.id = 12622087
  self.activityId = activityId or nil
end
function CChineseValentineJoinReq:marshal(os)
  os:marshalInt32(self.activityId)
end
function CChineseValentineJoinReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
end
function CChineseValentineJoinReq:sizepolicy(size)
  return size <= 65535
end
return CChineseValentineJoinReq
