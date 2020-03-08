local CDesignDutyNameReq = class("CDesignDutyNameReq")
CDesignDutyNameReq.TYPEID = 12589885
function CDesignDutyNameReq:ctor(designCaseId)
  self.id = 12589885
  self.designCaseId = designCaseId or nil
end
function CDesignDutyNameReq:marshal(os)
  os:marshalInt32(self.designCaseId)
end
function CDesignDutyNameReq:unmarshal(os)
  self.designCaseId = os:unmarshalInt32()
end
function CDesignDutyNameReq:sizepolicy(size)
  return size <= 65535
end
return CDesignDutyNameReq
