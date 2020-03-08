local CFlushInActivityReq = class("CFlushInActivityReq")
CFlushInActivityReq.TYPEID = 12588343
CFlushInActivityReq.FIND_TEAM = 1
CFlushInActivityReq.FIND_MEMBER = 2
function CFlushInActivityReq:ctor(flushType)
  self.id = 12588343
  self.flushType = flushType or nil
end
function CFlushInActivityReq:marshal(os)
  os:marshalInt32(self.flushType)
end
function CFlushInActivityReq:unmarshal(os)
  self.flushType = os:unmarshalInt32()
end
function CFlushInActivityReq:sizepolicy(size)
  return size <= 65535
end
return CFlushInActivityReq
