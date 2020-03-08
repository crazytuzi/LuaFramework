local OctetsStream = require("netio.OctetsStream")
local CombineGang = class("CombineGang")
function CombineGang:ctor(gangid, name, level, normal_num, normal_capacity, vitality, purpose, leader_id, leader_name, leader_level, leader_menpai, leader_gender, leader_avatarid, leader_avatar_frame, displayid)
  self.gangid = gangid or nil
  self.name = name or nil
  self.level = level or nil
  self.normal_num = normal_num or nil
  self.normal_capacity = normal_capacity or nil
  self.vitality = vitality or nil
  self.purpose = purpose or nil
  self.leader_id = leader_id or nil
  self.leader_name = leader_name or nil
  self.leader_level = leader_level or nil
  self.leader_menpai = leader_menpai or nil
  self.leader_gender = leader_gender or nil
  self.leader_avatarid = leader_avatarid or nil
  self.leader_avatar_frame = leader_avatar_frame or nil
  self.displayid = displayid or nil
end
function CombineGang:marshal(os)
  os:marshalInt64(self.gangid)
  os:marshalString(self.name)
  os:marshalInt32(self.level)
  os:marshalInt32(self.normal_num)
  os:marshalInt32(self.normal_capacity)
  os:marshalInt32(self.vitality)
  os:marshalString(self.purpose)
  os:marshalInt64(self.leader_id)
  os:marshalString(self.leader_name)
  os:marshalInt32(self.leader_level)
  os:marshalInt32(self.leader_menpai)
  os:marshalInt32(self.leader_gender)
  os:marshalInt32(self.leader_avatarid)
  os:marshalInt32(self.leader_avatar_frame)
  os:marshalInt64(self.displayid)
end
function CombineGang:unmarshal(os)
  self.gangid = os:unmarshalInt64()
  self.name = os:unmarshalString()
  self.level = os:unmarshalInt32()
  self.normal_num = os:unmarshalInt32()
  self.normal_capacity = os:unmarshalInt32()
  self.vitality = os:unmarshalInt32()
  self.purpose = os:unmarshalString()
  self.leader_id = os:unmarshalInt64()
  self.leader_name = os:unmarshalString()
  self.leader_level = os:unmarshalInt32()
  self.leader_menpai = os:unmarshalInt32()
  self.leader_gender = os:unmarshalInt32()
  self.leader_avatarid = os:unmarshalInt32()
  self.leader_avatar_frame = os:unmarshalInt32()
  self.displayid = os:unmarshalInt64()
end
return CombineGang
