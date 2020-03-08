local CUseManekiTokenReq = class("CUseManekiTokenReq")
CUseManekiTokenReq.TYPEID = 12620568
function CUseManekiTokenReq:ctor(activityId, manekiTokenCfgId)
  self.id = 12620568
  self.activityId = activityId or nil
  self.manekiTokenCfgId = manekiTokenCfgId or nil
end
function CUseManekiTokenReq:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.manekiTokenCfgId)
end
function CUseManekiTokenReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.manekiTokenCfgId = os:unmarshalInt32()
end
function CUseManekiTokenReq:sizepolicy(size)
  return size <= 65535
end
return CUseManekiTokenReq
