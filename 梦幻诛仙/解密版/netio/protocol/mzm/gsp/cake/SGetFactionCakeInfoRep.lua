local SGetFactionCakeInfoRep = class("SGetFactionCakeInfoRep")
SGetFactionCakeInfoRep.TYPEID = 12627720
function SGetFactionCakeInfoRep:ctor(activityId, factionId, factionCakeInfo)
  self.id = 12627720
  self.activityId = activityId or nil
  self.factionId = factionId or nil
  self.factionCakeInfo = factionCakeInfo or {}
end
function SGetFactionCakeInfoRep:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt64(self.factionId)
  local _size_ = 0
  for _, _ in pairs(self.factionCakeInfo) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.factionCakeInfo) do
    os:marshalInt64(k)
    v:marshal(os)
  end
end
function SGetFactionCakeInfoRep:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.factionId = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.cake.RoleCakeBaseInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.factionCakeInfo[k] = v
  end
end
function SGetFactionCakeInfoRep:sizepolicy(size)
  return size <= 65535
end
return SGetFactionCakeInfoRep
