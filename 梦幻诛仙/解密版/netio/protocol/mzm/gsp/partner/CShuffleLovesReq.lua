local CShuffleLovesReq = class("CShuffleLovesReq")
CShuffleLovesReq.TYPEID = 12588041
function CShuffleLovesReq:ctor(partnerId)
  self.id = 12588041
  self.partnerId = partnerId or nil
end
function CShuffleLovesReq:marshal(os)
  os:marshalInt32(self.partnerId)
end
function CShuffleLovesReq:unmarshal(os)
  self.partnerId = os:unmarshalInt32()
end
function CShuffleLovesReq:sizepolicy(size)
  return size <= 65535
end
return CShuffleLovesReq
