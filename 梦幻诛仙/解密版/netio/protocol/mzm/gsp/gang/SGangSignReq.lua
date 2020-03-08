local SGangSignReq = class("SGangSignReq")
SGangSignReq.TYPEID = 12589935
function SGangSignReq:ctor(result)
  self.id = 12589935
  self.result = result or nil
end
function SGangSignReq:marshal(os)
  os:marshalInt32(self.result)
end
function SGangSignReq:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function SGangSignReq:sizepolicy(size)
  return size <= 65535
end
return SGangSignReq
