local SSynVoipRoomOnlineMembers = class("SSynVoipRoomOnlineMembers")
SSynVoipRoomOnlineMembers.TYPEID = 12602641
function SSynVoipRoomOnlineMembers:ctor(voip_room_type, online_member_list)
  self.id = 12602641
  self.voip_room_type = voip_room_type or nil
  self.online_member_list = online_member_list or {}
end
function SSynVoipRoomOnlineMembers:marshal(os)
  os:marshalInt32(self.voip_room_type)
  os:marshalCompactUInt32(table.getn(self.online_member_list))
  for _, v in ipairs(self.online_member_list) do
    os:marshalInt64(v)
  end
end
function SSynVoipRoomOnlineMembers:unmarshal(os)
  self.voip_room_type = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.online_member_list, v)
  end
end
function SSynVoipRoomOnlineMembers:sizepolicy(size)
  return size <= 65535
end
return SSynVoipRoomOnlineMembers
