local SAlreadyGetRewardRes = class("SAlreadyGetRewardRes")
SAlreadyGetRewardRes.TYPEID = 12598286
function SAlreadyGetRewardRes:ctor(layer)
  self.id = 12598286
  self.layer = layer or nil
end
function SAlreadyGetRewardRes:marshal(os)
  os:marshalInt32(self.layer)
end
function SAlreadyGetRewardRes:unmarshal(os)
  self.layer = os:unmarshalInt32()
end
function SAlreadyGetRewardRes:sizepolicy(size)
  return size <= 65535
end
return SAlreadyGetRewardRes
