local CPrisonListReq = class("CPrisonListReq")
CPrisonListReq.TYPEID = 12620039
function CPrisonListReq:ctor(pageNo)
  self.id = 12620039
  self.pageNo = pageNo or nil
end
function CPrisonListReq:marshal(os)
  os:marshalInt32(self.pageNo)
end
function CPrisonListReq:unmarshal(os)
  self.pageNo = os:unmarshalInt32()
end
function CPrisonListReq:sizepolicy(size)
  return size <= 65535
end
return CPrisonListReq
