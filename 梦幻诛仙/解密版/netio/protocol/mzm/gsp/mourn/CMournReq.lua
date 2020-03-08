local CMournReq = class("CMournReq")
CMournReq.TYPEID = 12613382
function CMournReq:ctor(mournId)
  self.id = 12613382
  self.mournId = mournId or nil
end
function CMournReq:marshal(os)
  os:marshalInt32(self.mournId)
end
function CMournReq:unmarshal(os)
  self.mournId = os:unmarshalInt32()
end
function CMournReq:sizepolicy(size)
  return size <= 65535
end
return CMournReq
