local OctetsStream = require("netio.OctetsStream")
local LargeRoomEnterRspInfo = class("LargeRoomEnterRspInfo")
function LargeRoomEnterRspInfo:ctor(gid, roomid, roomkey, memberid, user_openid, user_ip, user_access, entrypt_switch, mix_voice_ability, uuid)
  self.gid = gid or nil
  self.roomid = roomid or nil
  self.roomkey = roomkey or nil
  self.memberid = memberid or nil
  self.user_openid = user_openid or nil
  self.user_ip = user_ip or nil
  self.user_access = user_access or nil
  self.entrypt_switch = entrypt_switch or nil
  self.mix_voice_ability = mix_voice_ability or nil
  self.uuid = uuid or nil
end
function LargeRoomEnterRspInfo:marshal(os)
  os:marshalInt64(self.gid)
  os:marshalInt64(self.roomid)
  os:marshalInt64(self.roomkey)
  os:marshalInt32(self.memberid)
  os:marshalInt32(self.user_openid)
  os:marshalOctets(self.user_ip)
  os:marshalOctets(self.user_access)
  os:marshalInt32(self.entrypt_switch)
  os:marshalInt32(self.mix_voice_ability)
  os:marshalOctets(self.uuid)
end
function LargeRoomEnterRspInfo:unmarshal(os)
  self.gid = os:unmarshalInt64()
  self.roomid = os:unmarshalInt64()
  self.roomkey = os:unmarshalInt64()
  self.memberid = os:unmarshalInt32()
  self.user_openid = os:unmarshalInt32()
  self.user_ip = os:unmarshalOctets()
  self.user_access = os:unmarshalOctets()
  self.entrypt_switch = os:unmarshalInt32()
  self.mix_voice_ability = os:unmarshalInt32()
  self.uuid = os:unmarshalOctets()
end
return LargeRoomEnterRspInfo
