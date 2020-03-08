local CCombineGangApplyReq = class("CCombineGangApplyReq")
CCombineGangApplyReq.TYPEID = 12589969
function CCombineGangApplyReq:ctor(targetid)
  self.id = 12589969
  self.targetid = targetid or nil
end
function CCombineGangApplyReq:marshal(os)
  os:marshalInt64(self.targetid)
end
function CCombineGangApplyReq:unmarshal(os)
  self.targetid = os:unmarshalInt64()
end
function CCombineGangApplyReq:sizepolicy(size)
  return size <= 65535
end
return CCombineGangApplyReq
