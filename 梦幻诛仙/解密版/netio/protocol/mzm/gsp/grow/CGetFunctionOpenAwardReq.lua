local CGetFunctionOpenAwardReq = class("CGetFunctionOpenAwardReq")
CGetFunctionOpenAwardReq.TYPEID = 12597000
function CGetFunctionOpenAwardReq:ctor(targetId)
  self.id = 12597000
  self.targetId = targetId or nil
end
function CGetFunctionOpenAwardReq:marshal(os)
  os:marshalInt32(self.targetId)
end
function CGetFunctionOpenAwardReq:unmarshal(os)
  self.targetId = os:unmarshalInt32()
end
function CGetFunctionOpenAwardReq:sizepolicy(size)
  return size <= 65535
end
return CGetFunctionOpenAwardReq
