local CChallengeSingleReq = class("CChallengeSingleReq")
CChallengeSingleReq.TYPEID = 12591362
function CChallengeSingleReq:ctor(instanceCfgid, process)
  self.id = 12591362
  self.instanceCfgid = instanceCfgid or nil
  self.process = process or nil
end
function CChallengeSingleReq:marshal(os)
  os:marshalInt32(self.instanceCfgid)
  os:marshalInt32(self.process)
end
function CChallengeSingleReq:unmarshal(os)
  self.instanceCfgid = os:unmarshalInt32()
  self.process = os:unmarshalInt32()
end
function CChallengeSingleReq:sizepolicy(size)
  return size <= 65535
end
return CChallengeSingleReq
