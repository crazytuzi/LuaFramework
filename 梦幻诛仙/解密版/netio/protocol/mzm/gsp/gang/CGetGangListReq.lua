local CGetGangListReq = class("CGetGangListReq")
CGetGangListReq.TYPEID = 12589880
function CGetGangListReq:ctor(lastId, size)
  self.id = 12589880
  self.lastId = lastId or nil
  self.size = size or nil
end
function CGetGangListReq:marshal(os)
  os:marshalInt64(self.lastId)
  os:marshalInt32(self.size)
end
function CGetGangListReq:unmarshal(os)
  self.lastId = os:unmarshalInt64()
  self.size = os:unmarshalInt32()
end
function CGetGangListReq:sizepolicy(size)
  return size <= 65535
end
return CGetGangListReq
