local CCombineGangCancelReq = class("CCombineGangCancelReq")
CCombineGangCancelReq.TYPEID = 12589973
function CCombineGangCancelReq:ctor(targetid)
  self.id = 12589973
  self.targetid = targetid or nil
end
function CCombineGangCancelReq:marshal(os)
  os:marshalInt64(self.targetid)
end
function CCombineGangCancelReq:unmarshal(os)
  self.targetid = os:unmarshalInt64()
end
function CCombineGangCancelReq:sizepolicy(size)
  return size <= 65535
end
return CCombineGangCancelReq
