local OctetsStream = require("netio.OctetsStream")
local GlobalRoomSpeakerInfoList = class("GlobalRoomSpeakerInfoList")
function GlobalRoomSpeakerInfoList:ctor(room_type, speaker_infos)
  self.room_type = room_type or nil
  self.speaker_infos = speaker_infos or {}
end
function GlobalRoomSpeakerInfoList:marshal(os)
  os:marshalInt32(self.room_type)
  os:marshalCompactUInt32(table.getn(self.speaker_infos))
  for _, v in ipairs(self.speaker_infos) do
    v:marshal(os)
  end
end
function GlobalRoomSpeakerInfoList:unmarshal(os)
  self.room_type = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.apollo.GlobalSpeakerInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.speaker_infos, v)
  end
end
return GlobalRoomSpeakerInfoList
