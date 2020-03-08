local CAgreeOrRefuseMasterRecommendReq = class("CAgreeOrRefuseMasterRecommendReq")
CAgreeOrRefuseMasterRecommendReq.TYPEID = 12601662
function CAgreeOrRefuseMasterRecommendReq:ctor(operator, sessionid)
  self.id = 12601662
  self.operator = operator or nil
  self.sessionid = sessionid or nil
end
function CAgreeOrRefuseMasterRecommendReq:marshal(os)
  os:marshalInt32(self.operator)
  os:marshalInt64(self.sessionid)
end
function CAgreeOrRefuseMasterRecommendReq:unmarshal(os)
  self.operator = os:unmarshalInt32()
  self.sessionid = os:unmarshalInt64()
end
function CAgreeOrRefuseMasterRecommendReq:sizepolicy(size)
  return size <= 65535
end
return CAgreeOrRefuseMasterRecommendReq
