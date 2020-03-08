local CAddCakeReq = class("CAddCakeReq")
CAddCakeReq.TYPEID = 12627718
function CAddCakeReq:ctor(activityId, clientTurn)
  self.id = 12627718
  self.activityId = activityId or nil
  self.clientTurn = clientTurn or nil
end
function CAddCakeReq:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.clientTurn)
end
function CAddCakeReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.clientTurn = os:unmarshalInt32()
end
function CAddCakeReq:sizepolicy(size)
  return size <= 65535
end
return CAddCakeReq
