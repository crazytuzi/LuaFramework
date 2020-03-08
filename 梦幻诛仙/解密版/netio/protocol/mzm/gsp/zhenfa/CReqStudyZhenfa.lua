local CReqStudyZhenfa = class("CReqStudyZhenfa")
CReqStudyZhenfa.TYPEID = 12593154
function CReqStudyZhenfa:ctor(zhenfaId)
  self.id = 12593154
  self.zhenfaId = zhenfaId or nil
end
function CReqStudyZhenfa:marshal(os)
  os:marshalInt32(self.zhenfaId)
end
function CReqStudyZhenfa:unmarshal(os)
  self.zhenfaId = os:unmarshalInt32()
end
function CReqStudyZhenfa:sizepolicy(size)
  return size <= 65535
end
return CReqStudyZhenfa
