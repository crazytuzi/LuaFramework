local OctetsStream = require("netio.OctetsStream")
local VoipRoomUserAccess = class("VoipRoomUserAccess")
function VoipRoomUserAccess:ctor(open_id, member_id, room_key, extra_data, access_ip_list)
  self.open_id = open_id or nil
  self.member_id = member_id or nil
  self.room_key = room_key or nil
  self.extra_data = extra_data or nil
  self.access_ip_list = access_ip_list or {}
end
function VoipRoomUserAccess:marshal(os)
  os:marshalOctets(self.open_id)
  os:marshalInt32(self.member_id)
  os:marshalInt64(self.room_key)
  os:marshalInt64(self.extra_data)
  os:marshalCompactUInt32(table.getn(self.access_ip_list))
  for _, v in ipairs(self.access_ip_list) do
    os:marshalOctets(v)
  end
end
function VoipRoomUserAccess:unmarshal(os)
  self.open_id = os:unmarshalOctets()
  self.member_id = os:unmarshalInt32()
  self.room_key = os:unmarshalInt64()
  self.extra_data = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalOctets()
    table.insert(self.access_ip_list, v)
  end
end
return VoipRoomUserAccess
