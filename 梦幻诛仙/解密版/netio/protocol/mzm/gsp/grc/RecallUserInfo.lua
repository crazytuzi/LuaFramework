local OctetsStream = require("netio.OctetsStream")
local RecallUserInfo = class("RecallUserInfo")
RecallUserInfo.LOGIN_PRIVILEGE_NONE = 0
RecallUserInfo.LOGIN_PRIVILEGE_QQ_GAME_CENTER = 1
RecallUserInfo.LOGIN_PRIVILEGE_WECHAT_GAME_CENTER = 2
RecallUserInfo.LOGIN_PRIVILEGE_YYB = 3
function RecallUserInfo:ctor(openid, nickname, figure_url, last_login, login_privilege, qq_vip_infos)
  self.openid = openid or nil
  self.nickname = nickname or nil
  self.figure_url = figure_url or nil
  self.last_login = last_login or nil
  self.login_privilege = login_privilege or nil
  self.qq_vip_infos = qq_vip_infos or {}
end
function RecallUserInfo:marshal(os)
  os:marshalOctets(self.openid)
  os:marshalOctets(self.nickname)
  os:marshalOctets(self.figure_url)
  os:marshalInt32(self.last_login)
  os:marshalInt32(self.login_privilege)
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
function RecallUserInfo:unmarshal(os)
  self.openid = os:unmarshalOctets()
  self.nickname = os:unmarshalOctets()
  self.figure_url = os:unmarshalOctets()
  self.last_login = os:unmarshalInt32()
  self.login_privilege = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.grc.QQVipInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.qq_vip_infos[k] = v
  end
end
return RecallUserInfo
