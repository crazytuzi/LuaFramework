local CWantedListReq = class("CWantedListReq")
CWantedListReq.TYPEID = 12620293
function CWantedListReq:ctor(pageNo)
  self.id = 12620293
  self.pageNo = pageNo or nil
end
function CWantedListReq:marshal(os)
  os:marshalInt32(self.pageNo)
end
function CWantedListReq:unmarshal(os)
  self.pageNo = os:unmarshalInt32()
end
function CWantedListReq:sizepolicy(size)
  return size <= 65535
end
return CWantedListReq
