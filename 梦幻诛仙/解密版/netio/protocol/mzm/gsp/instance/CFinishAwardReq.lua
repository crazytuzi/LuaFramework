local CFinishAwardReq = class("CFinishAwardReq")
CFinishAwardReq.TYPEID = 12591379
function CFinishAwardReq:ctor(instanceCfgid)
  self.id = 12591379
  self.instanceCfgid = instanceCfgid or nil
end
function CFinishAwardReq:marshal(os)
  os:marshalInt32(self.instanceCfgid)
end
function CFinishAwardReq:unmarshal(os)
  self.instanceCfgid = os:unmarshalInt32()
end
function CFinishAwardReq:sizepolicy(size)
  return size <= 65535
end
return CFinishAwardReq
