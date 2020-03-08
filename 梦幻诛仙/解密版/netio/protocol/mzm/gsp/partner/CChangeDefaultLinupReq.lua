local CChangeDefaultLinupReq = class("CChangeDefaultLinupReq")
CChangeDefaultLinupReq.TYPEID = 12588048
function CChangeDefaultLinupReq:ctor(lineUpNum)
  self.id = 12588048
  self.lineUpNum = lineUpNum or nil
end
function CChangeDefaultLinupReq:marshal(os)
  os:marshalInt32(self.lineUpNum)
end
function CChangeDefaultLinupReq:unmarshal(os)
  self.lineUpNum = os:unmarshalInt32()
end
function CChangeDefaultLinupReq:sizepolicy(size)
  return size <= 65535
end
return CChangeDefaultLinupReq
