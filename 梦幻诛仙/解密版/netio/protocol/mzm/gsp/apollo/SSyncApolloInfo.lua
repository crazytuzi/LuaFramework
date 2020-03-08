local SSyncApolloInfo = class("SSyncApolloInfo")
SSyncApolloInfo.TYPEID = 12602629
function SSyncApolloInfo:ctor(business_id, global_room_speaker_info_lists)
  self.id = 12602629
  self.business_id = business_id or nil
  self.global_room_speaker_info_lists = global_room_speaker_info_lists or {}
end
function SSyncApolloInfo:marshal(os)
  os:marshalInt32(self.business_id)
  os:marshalCompactUInt32(table.getn(self.global_room_speaker_info_lists))
  for _, v in ipairs(self.global_room_speaker_info_lists) do
    v:marshal(os)
  end
end
function SSyncApolloInfo:unmarshal(os)
  self.business_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.apollo.GlobalRoomSpeakerInfoList")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.global_room_speaker_info_lists, v)
  end
end
function SSyncApolloInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncApolloInfo
