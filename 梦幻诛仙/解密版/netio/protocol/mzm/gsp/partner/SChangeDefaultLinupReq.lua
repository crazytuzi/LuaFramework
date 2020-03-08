local SChangeDefaultLinupReq = class("SChangeDefaultLinupReq")
SChangeDefaultLinupReq.TYPEID = 12588036
function SChangeDefaultLinupReq:ctor(lineUpNum)
  self.id = 12588036
  self.lineUpNum = lineUpNum or nil
end
function SChangeDefaultLinupReq:marshal(os)
  os:marshalInt32(self.lineUpNum)
end
function SChangeDefaultLinupReq:unmarshal(os)
  self.lineUpNum = os:unmarshalInt32()
end
function SChangeDefaultLinupReq:sizepolicy(size)
  return size <= 65535
end
return SChangeDefaultLinupReq
