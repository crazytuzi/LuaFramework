local SGetCrossBattleFinalHistoryCorpsInfo = class("SGetCrossBattleFinalHistoryCorpsInfo")
SGetCrossBattleFinalHistoryCorpsInfo.TYPEID = 12617085
function SGetCrossBattleFinalHistoryCorpsInfo:ctor(session, rank, corps_id, corps_name, corps_zone_id, corps_badge_id, corps_member_set)
  self.id = 12617085
  self.session = session or nil
  self.rank = rank or nil
  self.corps_id = corps_id or nil
  self.corps_name = corps_name or nil
  self.corps_zone_id = corps_zone_id or nil
  self.corps_badge_id = corps_badge_id or nil
  self.corps_member_set = corps_member_set or {}
end
function SGetCrossBattleFinalHistoryCorpsInfo:marshal(os)
  os:marshalInt32(self.session)
  os:marshalInt32(self.rank)
  os:marshalInt64(self.corps_id)
  os:marshalOctets(self.corps_name)
  os:marshalInt32(self.corps_zone_id)
  os:marshalInt32(self.corps_badge_id)
  local _size_ = 0
  for _, _ in pairs(self.corps_member_set) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.corps_member_set) do
    k:marshal(os)
  end
end
function SGetCrossBattleFinalHistoryCorpsInfo:unmarshal(os)
  self.session = os:unmarshalInt32()
  self.rank = os:unmarshalInt32()
  self.corps_id = os:unmarshalInt64()
  self.corps_name = os:unmarshalOctets()
  self.corps_zone_id = os:unmarshalInt32()
  self.corps_badge_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.crossbattle.CorpsMemberInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.corps_member_set[v] = v
  end
end
function SGetCrossBattleFinalHistoryCorpsInfo:sizepolicy(size)
  return size <= 65535
end
return SGetCrossBattleFinalHistoryCorpsInfo
