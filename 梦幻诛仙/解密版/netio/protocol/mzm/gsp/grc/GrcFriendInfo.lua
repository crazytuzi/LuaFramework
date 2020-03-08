local OctetsStream = require("netio.OctetsStream")
local GrcFriendInfo = class("GrcFriendInfo")
GrcFriendInfo.LOGIN_PRIVILEGE_NONE = 0
GrcFriendInfo.LOGIN_PRIVILEGE_QQ_GAME_CENTER = 1
GrcFriendInfo.LOGIN_PRIVILEGE_WECHAT_GAME_CENTER = 2
GrcFriendInfo.LOGIN_PRIVILEGE_YYB = 3
GrcFriendInfo.RECALL_CAN_NOT = 0
GrcFriendInfo.RECALL_CAN = 1
GrcFriendInfo.RECALL_ALEARDY = 2
function GrcFriendInfo:ctor(openid, nickname, figure_url, roleid, rolename, level, gender, occupation, avatarid, avatar_frameid, fighting_capacity, zoneid, login_privilege, qq_vip_infos, wechat_vip_infos, recall_state)
  self.openid = openid or nil
  self.nickname = nickname or nil
  self.figure_url = figure_url or nil
  self.roleid = roleid or nil
  self.rolename = rolename or nil
  self.level = level or nil
  self.gender = gender or nil
  self.occupation = occupation or nil
  self.avatarid = avatarid or nil
  self.avatar_frameid = avatar_frameid or nil
  self.fighting_capacity = fighting_capacity or nil
  self.zoneid = zoneid or nil
  self.login_privilege = login_privilege or nil
  self.qq_vip_infos = qq_vip_infos or {}
  self.wechat_vip_infos = wechat_vip_infos or nil
  self.recall_state = recall_state or nil
end
function GrcFriendInfo:marshal(os)
  os:marshalOctets(self.openid)
  os:marshalOctets(self.nickname)
  os:marshalOctets(self.figure_url)
  os:marshalInt64(self.roleid)
  os:marshalOctets(self.rolename)
  os:marshalInt32(self.level)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.occupation)
  os:marshalInt32(self.avatarid)
  os:marshalInt32(self.avatar_frameid)
  os:marshalInt64(self.fighting_capacity)
  os:marshalInt32(self.zoneid)
  os:marshalInt32(self.login_privilege)
  do
    local _size_ = 0
    for _, _ in pairs(self.qq_vip_infos) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.qq_vip_infos) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  os:marshalOctets(self.wechat_vip_infos)
  os:marshalInt32(self.recall_state)
end
function GrcFriendInfo:unmarshal(os)
  self.openid = os:unmarshalOctets()
  self.nickname = os:unmarshalOctets()
  self.figure_url = os:unmarshalOctets()
  self.roleid = os:unmarshalInt64()
  self.rolename = os:unmarshalOctets()
  self.level = os:unmarshalInt32()
  self.gender = os:unmarshalInt32()
  self.occupation = os:unmarshalInt32()
  self.avatarid = os:unmarshalInt32()
  self.avatar_frameid = os:unmarshalInt32()
  self.fighting_capacity = os:unmarshalInt64()
  self.zoneid = os:unmarshalInt32()
  self.login_privilege = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.grc.QQVipInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.qq_vip_infos[k] = v
  end
  self.wechat_vip_infos = os:unmarshalOctets()
  self.recall_state = os:unmarshalInt32()
end
return GrcFriendInfo
