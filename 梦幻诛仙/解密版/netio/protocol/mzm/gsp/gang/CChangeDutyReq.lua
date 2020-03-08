local CChangeDutyReq = class("CChangeDutyReq")
CChangeDutyReq.TYPEID = 12589897
function CChangeDutyReq:ctor(targetId, duty)
  self.id = 12589897
  self.targetId = targetId or nil
  self.duty = duty or nil
end
function CChangeDutyReq:marshal(os)
  os:marshalInt64(self.targetId)
  os:marshalInt32(self.duty)
end
function CChangeDutyReq:unmarshal(os)
  self.targetId = os:unmarshalInt64()
  self.duty = os:unmarshalInt32()
end
function CChangeDutyReq:sizepolicy(size)
  return size <= 65535
end
return CChangeDutyReq
