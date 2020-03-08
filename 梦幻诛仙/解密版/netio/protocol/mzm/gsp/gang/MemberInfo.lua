local OctetsStream = require("netio.OctetsStream")
local MemberInfo = class("MemberInfo")
function MemberInfo:ctor(roleId, name, level, gender, occupationId, avatarId, avatar_frame, duty, curBangGong, historyBangGong, offlineTime, forbiddenTalk, joinTime, getLiHeTime, gongXun, weekBangGong, add_banggong_time, weekItem_banggong_count, item_banggong_time, fight_value)
  self.roleId = roleId or nil
  self.name = name or nil
  self.level = level or nil
  self.gender = gender or nil
  self.occupationId = occupationId or nil
  self.avatarId = avatarId or nil
  self.avatar_frame = avatar_frame or nil
  self.duty = duty or nil
  self.curBangGong = curBangGong or nil
  self.historyBangGong = historyBangGong or nil
  self.offlineTime = offlineTime or nil
  self.forbiddenTalk = forbiddenTalk or nil
  self.joinTime = joinTime or nil
  self.getLiHeTime = getLiHeTime or nil
  self.gongXun = gongXun or nil
  self.weekBangGong = weekBangGong or nil
  self.add_banggong_time = add_banggong_time or nil
  self.weekItem_banggong_count = weekItem_banggong_count or nil
  self.item_banggong_time = item_banggong_time or nil
  self.fight_value = fight_value or nil
end
function MemberInfo:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalString(self.name)
  os:marshalInt32(self.level)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.occupationId)
  os:marshalInt32(self.avatarId)
  os:marshalInt32(self.avatar_frame)
  os:marshalInt32(self.duty)
  os:marshalInt32(self.curBangGong)
  os:marshalInt32(self.historyBangGong)
  os:marshalInt64(self.offlineTime)
  os:marshalInt64(self.forbiddenTalk)
  os:marshalInt64(self.joinTime)
  os:marshalInt64(self.getLiHeTime)
  os:marshalInt32(self.gongXun)
  os:marshalInt32(self.weekBangGong)
  os:marshalInt64(self.add_banggong_time)
  os:marshalInt32(self.weekItem_banggong_count)
  os:marshalInt64(self.item_banggong_time)
  os:marshalInt32(self.fight_value)
end
function MemberInfo:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.name = os:unmarshalString()
  self.level = os:unmarshalInt32()
  self.gender = os:unmarshalInt32()
  self.occupationId = os:unmarshalInt32()
  self.avatarId = os:unmarshalInt32()
  self.avatar_frame = os:unmarshalInt32()
  self.duty = os:unmarshalInt32()
  self.curBangGong = os:unmarshalInt32()
  self.historyBangGong = os:unmarshalInt32()
  self.offlineTime = os:unmarshalInt64()
  self.forbiddenTalk = os:unmarshalInt64()
  self.joinTime = os:unmarshalInt64()
  self.getLiHeTime = os:unmarshalInt64()
  self.gongXun = os:unmarshalInt32()
  self.weekBangGong = os:unmarshalInt32()
  self.add_banggong_time = os:unmarshalInt64()
  self.weekItem_banggong_count = os:unmarshalInt32()
  self.item_banggong_time = os:unmarshalInt64()
  self.fight_value = os:unmarshalInt32()
end
return MemberInfo
