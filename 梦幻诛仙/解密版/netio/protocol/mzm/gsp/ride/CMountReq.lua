local CMountReq = class("CMountReq")
CMountReq.TYPEID = 797958
function CMountReq:ctor(rideCfgId)
  self.id = 797958
  self.rideCfgId = rideCfgId or nil
end
function CMountReq:marshal(os)
  os:marshalInt32(self.rideCfgId)
end
function CMountReq:unmarshal(os)
  self.rideCfgId = os:unmarshalInt32()
end
function CMountReq:sizepolicy(size)
  return size <= 65535
end
return CMountReq
