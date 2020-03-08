local OctetsStream = require("netio.OctetsStream")
local GroupInfo = class("GroupInfo")
GroupInfo.TYPE_FRIEND = 1
GroupInfo.TYPE_JIEYI = 2
function GroupInfo:ctor(groupid, group_type, masterid, create_time, group_name, announcement, image_member_list, member_list, member_num, info_version)
  self.groupid = groupid or nil
  self.group_type = group_type or nil
  self.masterid = masterid or nil
  self.create_time = create_time or nil
  self.group_name = group_name or nil
  self.announcement = announcement or nil
  self.image_member_list = image_member_list or {}
  self.member_list = member_list or {}
  self.member_num = member_num or nil
  self.info_version = info_version or nil
end
function GroupInfo:marshal(os)
  os:marshalInt64(self.groupid)
  os:marshalUInt8(self.group_type)
  os:marshalInt64(self.masterid)
  os:marshalInt32(self.create_time)
  os:marshalOctets(self.group_name)
  os:marshalOctets(self.announcement)
  os:marshalCompactUInt32(table.getn(self.image_member_list))
  for _, v in ipairs(self.image_member_list) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.member_list))
  for _, v in ipairs(self.member_list) do
    v:marshal(os)
  end
  os:marshalInt32(self.member_num)
  os:marshalInt64(self.info_version)
end
function GroupInfo:unmarshal(os)
  self.groupid = os:unmarshalInt64()
  self.group_type = os:unmarshalUInt8()
  self.masterid = os:unmarshalInt64()
  self.create_time = os:unmarshalInt32()
  self.group_name = os:unmarshalOctets()
  self.announcement = os:unmarshalOctets()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.group.GroupMemberBasicInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.image_member_list, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.group.GroupMemberInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.member_list, v)
  end
  self.member_num = os:unmarshalInt32()
  self.info_version = os:unmarshalInt64()
end
return GroupInfo
